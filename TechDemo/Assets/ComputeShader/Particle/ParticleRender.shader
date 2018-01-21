// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/ParticleRender"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "White"{}
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent"  }
		blend srcAlpha oneMinusSrcAlpha
		zwrite off
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#pragma target 5.0
			#include "UnityCG.cginc"

			struct Particle {
				bool isActive;
				float3 position;
				float3 velocity;
				float4 color;
				float duration;
				float scale;
			};

			StructuredBuffer<Particle> _Particles;
			sampler2D _MainTex;

			struct v2g
			{
				float4 worldPos : SV_POSITION;
				float4 color : COLOR;
				float scale : TEXCOORD1;
			};

			struct g2f {
				float4 pos : SV_POSITION;
				float4 color: COLOR;
				float2 uv : TEXCOORD0;
			};

			v2g vert (uint id : SV_VertexID)
			{
				v2g o;
				o.worldPos = float4(_Particles[id].position, 1);
				o.color = _Particles[id].color;
				o.scale = _Particles[id].isActive ? _Particles[id].scale : 0;
				return o;
			}

			[maxvertexcount(4)]
			void geom(point v2g IN[1], inout TriangleStream<g2f> triStream) {
				float3 viewDir = normalize(_WorldSpaceCameraPos - IN[0].worldPos);
				float3 rightDir = -cross(viewDir, float3(0, 1, 0));
				float scale = 0.1;

				g2f o;

				o.pos = mul(UNITY_MATRIX_VP, IN[0].worldPos);
				o.color = IN[0].color;
				o.uv = float2(0, 0);
				triStream.Append(o);

				o.pos = mul(UNITY_MATRIX_VP, IN[0].worldPos + scale* float4(rightDir, 0));
				o.color = IN[0].color;
				o.uv = float2(1, 0);
				triStream.Append(o);

				o.pos = mul(UNITY_MATRIX_VP, IN[0].worldPos + scale * float4(0, 1, 0, 0));
				o.color = IN[0].color;
				o.uv = float2(0, 1);
				triStream.Append(o);

				o.pos = mul(UNITY_MATRIX_VP, IN[0].worldPos + scale * float4(rightDir, 0) + scale * float4(0, 1, 0, 0));
				o.color = IN[0].color;
				o.uv = float2(1, 1);
				triStream.Append(o);
			}

			fixed4 frag (g2f i) : SV_Target
			{
				fixed4 texCol = tex2D(_MainTex, i.uv);
				fixed4 col = i.color * texCol;
				return col;
			}
			ENDCG
		}
	}
}
