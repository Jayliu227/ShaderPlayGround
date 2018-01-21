Shader "Miscellaneous/Sketch_Shader"
{
	Properties
	{
			_MainTex ("Texture", 2D) = "white" {}
			_BrightTAM  ("Hatch 0", 2D) = "white" {}
			_DarkTAM  ("Hatch 1", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
			float3 n : NORMAL;
			};

			struct v2f
			{
			float2 uv : TEXCOORD0;
			float3 worldPos : TEXCOORD1;
			float4 vertex : SV_POSITION;
			float3 normal :NORMAL;
			};

			sampler2D _MainTex;
			sampler2D _BrightTAM;
			sampler2D _DarkTAM;
			float4 _MainTex_ST;
			float4 _LightColor0;
			

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(UNITY_MATRIX_MV, v.vertex);
				o.normal = mul(float4(v.n, 0.0), unity_WorldToObject).xyz;
				return o;
			}

			fixed3 Hatching(float2 _uv, half _intensity)
			{
				// r g b - brightest to medium
				half3 hatch0 = tex2D(_BrightTAM, _uv).rgb;
				// r g b - medium to darkest
				half3 hatch1 = tex2D(_DarkTAM, _uv).rgb;

				// in case the intensity is bigger than 1, we need to add the whiteness to it
				half3 overbright = max(0, _intensity - 1.0);
				/*
					intensity is between 1 and 0, 1 being brightest, 0 being darkest
					so weightA r g b weightB r g b would be dark to bright
				*/
				half3 weightsD = saturate((_intensity * 6.0) + half3(-0, -1, -2));
				half3 weightsB = saturate((_intensity * 6.0) + half3(-3, -4, -5));

				weightsD.xy -= weightsD.yz;
				weightsD.z -= weightsB.x;
				weightsB.xy -= weightsB.yz;
				/*
					from bright to dark
					tex:          hatch0.r  hatch0.g  hatch0.b  hatch1.r  hatch1.g  hatch1.b
					weight:		  weightB.z weightB.y weightB.x weightD.z weightD.y weightD.x
					the key is to remember that intensity is valued unintuitively:
						intensity of 1 means it is brightest, whereas if we use the formula above
						we would treat it as the other way around
				*/
				half3 hatching = overbright 
					+ hatch0.r * weightsB.z
					+ hatch0.g * weightsB.y
					+ hatch0.b * weightsB.x
					+ hatch1.r * weightsD.z
					+ hatch1.g * weightsD.y
					+ hatch1.b * weightsD.x;
				return hatching;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				// since this is directional light, can use dot light pos and normal
				// if this is directional light, then this variable is the light dir
				fixed3 diffuse = color.rgb * _LightColor0.rgb * dot(-_WorldSpaceLightPos0, normalize(i.normal));

				// calulate how bright a fragment is (a dot product against a vector constant - Luminosity Function)
				/*  TRICK:
				the value selection has something related to human eye sensitivity with different color.
				most subjective. This describes the average sensitivity of human visual perception of brightness.
				*/
				fixed3 _LuminosityVector = fixed3(0.2326, 0.7152, 0.0722);
				/*
					intensity now is a float between 0 and 1. 1 means brightest, 0 means darkest.
				*/
				fixed intensity = dot(diffuse, _LuminosityVector);
				color.rgb = Hatching(i.uv * 8, intensity);
				return color;
			}
			ENDCG
		}
	}
}
