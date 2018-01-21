Shader "Triplanar_Mapping_Shader/Triplanar_Mapping" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		[Header(Triplanar)]
		_TextureScaler("Texture scaling", float) = 1
		_TriplanarBlendSharpness("Sharpness", float) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			//float2 uv_MainTex;
			float3 worldPos;
			float3 worldNormal;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float _TextureScaler;
		float _TriplanarBlendSharpness;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		/*
			The idea is to sample the color three times:
			projected from x, y and z axis.

			Then we calculate a weight based off of the normal of a vertex, say (0.5, 0.1, -0.7)
			Take the absolute value of it -> (0.5, 0.1, 0.7) so it is really heavy along z axis so
				the color got from the sampling via z axis should influence more on the final color
			We can even attenuate them by doing a power. -> (0.4, 0.15, 0.64)
			We need to make sure that the weightx, y, z are added up to 1 (ready for interpolation)
			(0.5, 0.1, 0.7) / (0.5 + 0.1 + 0.7) -> final float3 where each component indicates the weight
				along that specific axis.
			We then do a linear interpolation between three sample color -> final color
				c = diffuseX * blendWeights.x + diffuseY * blendWeights.y + diffuseZ * blendWeights.z;
		*/
		void surf (Input IN, inout SurfaceOutputStandard o) {
			half4 c = half4(0,0,0,0);

			half2 uvX = IN.worldPos.yz / _TextureScaler;
			half2 uvY = IN.worldPos.xz / _TextureScaler;
			half2 uvZ = IN.worldPos.xy / _TextureScaler;

			half4 diffuseX = tex2D(_MainTex, uvX);
			half4 diffuseY = tex2D(_MainTex, uvY);
			half4 diffuseZ = tex2D(_MainTex, uvZ);

			float3 blendWeights = pow( abs(IN.worldNormal), _TriplanarBlendSharpness);
			blendWeights /= (blendWeights.x + blendWeights.y + blendWeights.z);

			c = diffuseX * blendWeights.x + diffuseY * blendWeights.y + diffuseZ * blendWeights.z;

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
