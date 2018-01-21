Shader "Custom/SurfaceScattering" {
	Properties {
		[Header(PBR)]
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		[Header(Subsurface)]
		_Distortion("Normal Distortion", range(0,1)) = 0.5
		_Power("Power", range(1,20)) = 1
		_Scale("Scale Intensity", range(0.5,3)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf StandardSubsurface fullforwardshadow
		#pragma target 3.0


		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;

		float _Distortion;
		float _Power;
		float _Scale;
		fixed4 _Color;

		#include"UnityPBSLighting.cginc"
		inline fixed4 LightingStandardSubsurface(SurfaceOutputStandard s, fixed3 viewDir, UnityGI gi ){
			fixed4 pbr = LightingStandard(s, viewDir, gi);

			// modify the new lighting down below;
			float3 N = s.Normal;                                // normal
			float3 V = viewDir;									// viewDir
			float3 L = gi.light.dir;							// lightDir

			
			// calculate the halfVector(ranging from L + H to L + 0=L
			float3 H = normalize(L + N * _Distortion);          // the distortion controls how much the H vector is biased towards the normal.
			// the intensity is the dotproduct of H and viewDir (has nothing to do with normal, because the light just goes through the material.)
			// make I attentuate faster than linearly
			float I = pow(saturate(dot(V, -H)), _Power) * _Scale;
			//-----------------------------------
			pbr.rgb = pbr.rgb + gi.light.color * I;
			return pbr;
		}

		// have to define the corresponding GI for the newly customized lighting model.
		void LightingStandardSubsurface_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi) {
			LightingStandard_GI(s, data, gi);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
