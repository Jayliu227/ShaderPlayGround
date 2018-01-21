Shader "Miscellaneous/3DPrint_Shader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		[Header(Print Variable)]
		_ConstructColor("Construct Color", Color) = (1,1,1,1)
		_ConstructY("Threshold Y", range(-1,1)) = 0
		_ConstructEdgeLength("Thickness of the edge", range(0, 1)) = 0.1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		cull off
		
		CGPROGRAM
		#pragma surface surf Custom fullforwardshadows

		#pragma target 3.0
		#include "UnityPBSLighting.cginc"
		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 viewDir;
			float2 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _ConstructColor;
		float3 viewDir;
		float _ConstructY;
		float _ConstructEdgeLength;
		int part;

		UNITY_INSTANCING_CBUFFER_START(Props)
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			float wobbly1 = sin((IN.worldPos.x * IN.worldPos.y) * 70 + _Time[2] + o.Normal) / 50;
			float wobbly2 = cos((IN.worldPos.x * IN.worldPos.y) * 50 + _Time[3]) / 60;

			if (IN.worldPos.y > _ConstructY + wobbly1 + _ConstructEdgeLength)
				discard;

			if (IN.worldPos.y < _ConstructY + wobbly2) {
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Alpha = c.a;
				part = 0;
			}
			else {
				o.Albedo = _ConstructColor.rgb;
				o.Alpha = _ConstructColor.a;
				part = 1;
			}

			viewDir = IN.viewDir;
			// these two are PBR variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}

		// Customized Lighting Function
		inline void LightingCustom_GI(SurfaceOutputStandard s, UnityGIInput input, inout UnityGI gi) {
			LightingStandard_GI(s, input, gi);
		}

		inline half4 LightingCustom(SurfaceOutputStandard s, half lightDir, UnityGI gi) {
			if (part)
				return _ConstructColor;
			if (dot(viewDir, s.Normal) < 0)
				return _ConstructColor;

			return LightingStandard(s, lightDir, gi);
		}

		ENDCG
	}
	FallBack "Diffuse"
}
