Shader "VRRM/VRRM_Gradient"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[Header(RaymarchHit Variables)]
		_Albedo("Albedo", Color) = (0,1,1,1)
		_Radius("Radius of the sphere", range(0, 1)) = 0.5
		_SpecularPow("Power of Specular", range(1, 10)) = 1
		_SpecularScale("Scaler for specular lighting", range(0, 3)) = 1
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
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 wPos: TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float3 _Center = float3(0,0,0);
			float _Radius;
			fixed4 _Albedo;
			float _SpecularPow;
			float _SpecularScale;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			// signed distance function:
			/*
				1. when it returns positive value, the pos is outside the sphere.
				2. when it returns zero, the point is on it;
				3. when it returns negative value, the point is inside the sphere.
			*/
			float sphereDistance(float3 pos) {
				return (distance(pos, _Center) - _Radius);
			}

			float3 estimateNormal(float3 n) {
				float delta = 0.01;
				float3 result = normalize(float3(
					sphereDistance(n + float3(delta, 0, 0)) - sphereDistance(n - float3(delta, 0, 0)),
					sphereDistance(n + float3(delta, 0, 0)) - sphereDistance(n - float3(0, delta, 0)),
					sphereDistance(n + float3(0, 0, delta)) - sphereDistance(n - float3(0, 0, delta))
					));
				return -result;
			}

			fixed4 lambert(float3 normal, float3 dir) {
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 lightColor = _LightColor0.rgb;
				fixed3 viewDir = dir;

				float NdotL = max(0, dot(normalize(normal), lightDir));
				
				float3 halfVector = (lightDir + viewDir) / 2;
				float specularFactor = pow(dot(halfVector, normal), _SpecularPow) * _SpecularScale;
				
				fixed4 color;
				color.rgb = _Albedo.rgb * lightColor * NdotL + specularFactor;
				color.a = 1;
				return color;
			}

			fixed4 render(float3 p, float3 dir) {
				float3 normal = estimateNormal(p);
				return lambert(normal, dir);
			}

			#define STEPS 64
			#define STEP_SIZE 0.01
			#define MIN_DISTANCE 0.001
			// color the cube based on the distance between the ray and the sphere center
			/*
				if the ray is close enough to the sphere, then this pixel is colored
				how close it is to the center is determined by MIN_DISTANCE (like a skin)
				if the distance is negative then return value is always negative (clamped to zero)
				otherwise, it would be colored based on how many steps it takes to reach to the point close enough to the sphere
			*/
			fixed4 raymarch(float3 pos, float3 dir) {	
				for (int i = 0; i < STEPS; i++) {
					float distance = sphereDistance(pos);
					if (distance < MIN_DISTANCE)
						return render(pos, dir);

					pos += STEP_SIZE * dir;
				}
				return fixed4(1, 1, 1, 1);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 viewDir = normalize(i.wPos - _WorldSpaceCameraPos);
				float3 worldPos = i.wPos;
				return raymarch(worldPos, viewDir);
			}
			ENDCG
		}
	}
}
