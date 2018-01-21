Shader "Unlit/Extrude_Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Factor ("Extrude Factor", range(0., 2.)) = 0.2
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Cull off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#include "UnityCG.cginc"

			struct appdata{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2g{
				float4 objPos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct g2f{
				float4 worldPos : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 col : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Factor;
			
			v2g vert (appdata v)
			{
				v2g o;
				o.objPos = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				return o;
			}

			// two triangle for each vertical face and one for the top and bottom face
			[maxvertexcount(24)]
			void geom (triangle v2g input[3], inout TriangleStream<g2f> tristream){
				g2f o;

				// calculate face normal in obj space
				float3 edgeOne = (input[1].objPos - input[0].objPos).xyz;
				float3 edgeTwo = (input[2].objPos - input[0].objPos).xyz;
				float3 faceNormal = normalize(cross(edgeOne, edgeTwo));

				// construct lateral faces
				for(int i = 0; i < 3; i++){

					// save the original first vertex to the stream
					o.worldPos = UnityObjectToClipPos(input[i].objPos);
					o.uv = input[i].uv;
					o.col = fixed4(0,0,0,1);
					tristream.Append(o);

					o.worldPos = UnityObjectToClipPos(input[i].objPos + float4(faceNormal,0) * _Factor);
					o.uv = input[i].uv;
					o.col = fixed4(1,1,1,1);
					tristream.Append(o);

					int nextVertexIndex = (i + 1) %3;
					o.worldPos = UnityObjectToClipPos(input[nextVertexIndex].objPos);
					o.uv = input[i].uv;
					o.col = fixed4(0,0,0,1);
					tristream.Append(o);

					// after three vertices were added in, make it restart a new triangle strip
					tristream.RestartStrip();

					// since Unity uses left handed coordinate system, we need to add in vertices clockwisely if
					// we face towards the normal
					o.worldPos = UnityObjectToClipPos(input[nextVertexIndex].objPos + float4(faceNormal,0) * _Factor);
					o.uv = input[i].uv;
					o.col = fixed4(1,1,1,1);
					tristream.Append(o);

					o.worldPos = UnityObjectToClipPos(input[nextVertexIndex].objPos);
					o.uv = input[i].uv;
					o.col = fixed4(0,0,0,1);
					tristream.Append(o);

					o.worldPos = UnityObjectToClipPos(input[i].objPos + float4(faceNormal,0) * _Factor);
					o.uv = input[i].uv;
					o.col = fixed4(1,1,1,1);
					tristream.Append(o);

					tristream.RestartStrip();
				}

				// construct top face
				for(int i = 0; i < 3; i++){
					o.worldPos = UnityObjectToClipPos(input[i].objPos + float4(faceNormal,0) * _Factor);
					o.uv = input[i].uv;
					o.col = fixed4(0,0,0,1);
					tristream.Append(o);
				}

				tristream.RestartStrip();

				// construct bottom face
				for(int i = 0; i < 3; i++){
					o.worldPos = UnityObjectToClipPos(input[i].objPos + float4(faceNormal,0) * _Factor);
					o.uv = input[i].uv;
					o.col = fixed4(1,1,1,1);
					tristream.Append(o);
				}

				tristream.RestartStrip();
			}


			fixed4 frag (g2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * i.col;
				return col;
			}
			ENDCG
		}
	}
}
