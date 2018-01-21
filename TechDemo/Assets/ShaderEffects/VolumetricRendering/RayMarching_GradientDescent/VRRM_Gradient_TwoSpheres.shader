Shader "VRRM/VRRM_Gradient_TwoSpheres"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[Header(RaymarchHit Variables)]
		_Albedo("Albedo", Color) = (0,1,1,1)
		_SpecularPow("Power of Specular", range(1, 10)) = 1
		_SpecularScale("Scaler for specular lighting", range(0, 3)) = 1
		_Radius("Radius of the sphere", range(0, 1)) = 0.5
		_Spacing("Space between two spheres", range(0, 2)) = 1
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
			float _Spacing;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.wPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			float sdf_blend(float v1, float v2, float t) {
				return (v1 * t) + (v2 * (1 - t));
			}

			float sdf_sphere(float3 pos, float3 center, float radius) {
				return (distance(pos, center) - radius);
			}

			float sdf_box(float3 p, float3 c, float3 s)
			{
				// p.x - c.x is the distance between point.x to center.x
				/*
					it's value, if bigger than half of the dimension in x axis, indicates it is outside the
					cube.
					float x = abs(p.x - c.x) - float3(s.x / 2, 0, 0);
				*/
				
				float x = max
				(p.x - c.x - float3(s.x / 2., 0, 0),
					c.x - p.x - float3(s.x / 2., 0, 0)
				);

				float y = max
				(p.y - c.y - float3(s.y / 2., 0, 0),
					c.y - p.y - float3(s.y / 2., 0, 0)
				);

				float z = max
				(p.z - c.z - float3(s.z / 2., 0, 0),
					c.z - p.z - float3(s.z / 2., 0, 0)
				);

				// pick the biggest value among x, y, z
				float d = x;
				d = max(d, y);
				d = max(d, z);
				return d;
			}

			/*
				since there are more than one objects we need to determine which face to render
				if we use the min, we will get the union because as soon as the ray hits something
				it returns. But if we use max, it would find the face that is hit the last, resulting
				in the shape that is the intersection of all the objects.

				this is like a wrapper funtion that integrates the effects of all the sphereDistance
				functions for each sphere.

				min - union
				max - intersection
			*/
			float raymarchDistance(float3 pos) {
				/*
				return max(
					sdf_sphere(pos, _Center - float3(_Spacing,0,0), _Radius),
					sdf_sphere(pos, _Center + float3(_Spacing,0,0), _Radius)
				);
				return sdf_box(pos, float3(0, 0, 0), float3(1, 1, 1));
				*/
				return sdf_blend(
					sdf_box(pos, float3(0, 0, 0), float3(1, 1, 1)),
					sdf_sphere(pos, float3(0, 0, 0), 1),
					(_SinTime[3] + 1) / 2);
			}

			float3 estimateNormal(float3 n) {
				float delta = 0.01;
				float3 result = normalize(float3(
					raymarchDistance(n + float3(delta, 0, 0)) - raymarchDistance(n - float3(delta, 0, 0)),
					raymarchDistance(n + float3(delta, 0, 0)) - raymarchDistance(n - float3(0, delta, 0)),
					raymarchDistance(n + float3(0, 0, delta)) - raymarchDistance(n - float3(0, 0, delta))
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

			#define STEPS 256
			#define STEP_SIZE 0.01
			#define MIN_DISTANCE 0.001
			fixed4 raymarch(float3 pos, float3 dir) {	
				for (int i = 0; i < STEPS; i++) {
					float distance = raymarchDistance(pos);
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
