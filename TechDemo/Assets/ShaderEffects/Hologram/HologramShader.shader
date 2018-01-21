// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/HologramShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("MainColor", color) = (0,1,1,1)
		_ChangeSpeed ("Speed", range(0,2)) = 1
		_Frequency ("Frequency", range(1, 100)) = 40
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha One
		    ZWrite off
			Cull off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 worldPos : texcoord1;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _ChangeSpeed;
			float _Frequency;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.normal = mul(v.normal,unity_WorldToObject);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col *= max(0, _Color * cos(i.worldPos.y * _Frequency + _ChangeSpeed * 100 * _Time.x));
				col *= max(0, _Color * cos(i.worldPos.x * _Frequency + _ChangeSpeed * 100 * _Time.x));
				col *= max(0, _Color * cos(i.worldPos.z * _Frequency + _ChangeSpeed * 100 * _Time.x));

				float3 V = normalize(WorldSpaceViewDir(i.worldPos));
				float NdotV = 1 - dot(normalize(i.normal), V);

				float rimWidth = 0.7;
				col.rgb *= abs(NdotV);
				return col;
			}
			ENDCG
		}
	}
}
