Shader "Miscellaneous/Masker_Shader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Transparent" }
		LOD 200

		Stencil{
			ref 1
			comp always
			pass replace

		}

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		 #pragma surface surf Lambert alpha
 
        struct Input {
            fixed3 Albedo;
        };
 
        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = fixed3(1, 1, 1);
            o.Alpha = 0;
        }
		ENDCG
	}
	FallBack "Diffuse"
}
