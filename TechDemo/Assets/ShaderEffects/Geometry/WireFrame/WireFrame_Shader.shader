Shader "Unlit/WireFrame_Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		[PowerSlider(3)]
		_Threshold ("Threshold", range(0, 0.5)) = 0.05
		[Header(Color)]
		_FrontColor("Front Color", COLOR) = (0,0,1,1)
		_BackColor("Back Color", COLOR)= (1,1,0,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull back
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2g{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 bary : TEXCOORD1;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _Threshold;
			float4 _FrontColor;
			float4 _BackColor;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream){
				g2f o;

				o.pos = input[0].pos;
				o.uv = input[0].uv;
				o.bary = float3(1,0,0);
				tristream.Append(o);

				o.pos = input[1].pos;
				o.uv = input[1].uv;
				o.bary = float3(0,1,0);
				tristream.Append(o);

				o.pos = input[2].pos;
				o.uv = input[2].uv;
				o.bary = float3(0,0,1);
				tristream.Append(o);

				tristream.RestartStrip();
			}

			fixed4 frag (g2f i) : SV_Target
			{
				if(!any(bool3(i.bary.x < _Threshold, i.bary.y < _Threshold, i.bary.z < _Threshold))){
					discard;
				}
				fixed4 col = tex2D(_MainTex, i.uv) * _FrontColor;
				return col;
			}
			ENDCG
		}

		Pass
		{
			Cull front
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2g{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 bary : TEXCOORD1;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _Threshold;
			float4 _FrontColor;
			float4 _BackColor;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream){
				g2f o;

				o.pos = input[0].pos;
				o.uv = input[0].uv;
				o.bary = float3(1,0,0);
				tristream.Append(o);

				o.pos = input[1].pos;
				o.uv = input[1].uv;
				o.bary = float3(0,1,0);
				tristream.Append(o);

				o.pos = input[2].pos;
				o.uv = input[2].uv;
				o.bary = float3(0,0,1);
				tristream.Append(o);

				tristream.RestartStrip();
			}

			fixed4 frag (g2f i) : SV_Target
			{
				if(!any(bool3(i.bary.x < _Threshold, i.bary.y < _Threshold, i.bary.z < _Threshold))){
					discard;
				}
				fixed4 col = tex2D(_MainTex, i.uv) * _BackColor;
				return col;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
