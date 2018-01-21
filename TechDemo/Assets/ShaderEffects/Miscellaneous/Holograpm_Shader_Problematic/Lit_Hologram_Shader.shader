Shader "Unlit/Lit_Hologram_Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LightColor("Light color", COLOR) = (1,1,1,1)
		_LightAlpha("Alpha for the light part", range(0,1)) = 0.7
		_LightSecondAlpha("Second alpha for the light part", range(0,1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			#include "UnityCG.cginc"

			fixed4 _LightColor;
			fixed _LightAlpha;
			fixed _LightSecondAlpha;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float4 vert: TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.vert = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed gray = dot(col.rgb, fixed3(0.299, 0.587, 0.114));
				col = fixed4(gray, gray, gray, 1);
				col = col * 0.8 + _LightColor * 0.2;
				col.a = _LightAlpha;

				if (((i.vert.y + 1) * 100 % 100) > 0.5)
				{
					col.a = _LightSecondAlpha;
				}

				gray = cos(i.vert.y * 10 + _Time * 100);
				if (gray > 0.99)
				{
					fixed delta = (gray - 0.99) / 0.0075;
					col.a = _LightSecondAlpha + delta;
				}
				else
				{
					gray = sin(i.vert.y * 7 + _Time * 130);
					if (gray > 0.99)
					{
						fixed delta = (gray - 0.99) / 0.0075;
						col.a = _LightSecondAlpha + delta;
					}
				}
				return col;
			}
			ENDCG
		}
	}
}
