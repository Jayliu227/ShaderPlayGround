Shader "VRRM/VRRM_DistanceAided"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[Header(RaymarchHit Variables)]
		_Radius("Radius of the sphere", range(0, 1)) = 0.5
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
						return i / (float)STEPS;

					pos += STEP_SIZE * dir;
				}
				return fixed4(0, 0, 0, 0);
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
