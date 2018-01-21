Shader "Miscellaneous/OutLine_Shde" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_OutlineColor("Outline Color", Color) = (0,0,0,0)
		_Outline ("Outline Thickness", range(0, 0.1)) = 0
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		// this pass for the outline
		pass{
			Tags { "RenderType"="Opaque" }
			cull front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _OutlineColor;
			float _Outline;

			struct v2f{
				float4 pos : POSITION;
			};

			v2f vert (appdata_base v){
				v2f o;
				//o.pos = UnityObjectToClipPos(v.vertex + v.normal * _Outline);
				o.pos = UnityObjectToClipPos(v.vertex); 
				float3 N = mul((float3x3) UNITY_MATRIX_MV, v.normal);
				N.x *= UNITY_MATRIX_P[0][0];
				N.y *= UNITY_MATRIX_P[1][1];
				o.pos.xy += N.xy * _Outline;
				return o;
			}

			fixed4 frag(v2f v) : COLOR{
				return _OutlineColor;
			}
			ENDCG
		}


		CGPROGRAM

		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
