Shader "VRRM/VRRM_ConstantStep"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[Header(RaymarchHit Variables)]
		//_Center("Center of the sphere", float3) = (0,0,0)
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
			
			bool sphereHit(float3 pos) {
				if (distance(pos, _Center) < _Radius)
					return true;
				return false;
			}

			#define STEPS 64
			#define STEP_SIZE 0.01
			bool raymarchHit(float3 pos, float3 dir) {
				for (int i = 0; i < STEPS; i++) {
					if (sphereHit(pos))
						return true;

					pos += STEP_SIZE * dir;
				}
				return false;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 viewDir = normalize(i.wPos - _WorldSpaceCameraPos);
				float3 worldPos = i.wPos;

				if (raymarchHit(worldPos, viewDir))
					return fixed4(1, 0, 0, 1);
				else
					return fixed4(1, 1, 1, 1);
			}
			ENDCG
		}
	}
}
