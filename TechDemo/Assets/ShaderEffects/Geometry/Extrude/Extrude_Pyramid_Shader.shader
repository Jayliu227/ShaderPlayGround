Shader "Unlit/Extrude_Pyramid_Shader"
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

			[maxvertexcount(12)]
			void geom (triangle v2g input[3], inout TriangleStream<g2f> tristream){
				g2f o;

				float3 faceNormal = normalize(cross(input[1].objPos - input[0].objPos, input[2].objPos - input[0].objPos));

				// determine which lateral side is the longest
				float edge0 = distance(input[1].objPos, input[2].objPos);
				float edge1 = distance(input[2].objPos, input[0].objPos);
				float edge2 = distance(input[1].objPos, input[0].objPos);

				float4 CentralPos = (input[1].objPos + input[2].objPos)/2;
				float2 CentralTex = (input[1].uv + input[2].uv)/2;

				// step(a,x) if x > a return 1 otherwise 0
				// so if the multiplication is equal to 1, both steps return 1
				// which means that x is longer than either of them
				if(step(edge1, edge2) * step(edge0, edge2) == 1){
					CentralPos = (input[1].objPos + input[0].objPos)/2;
					CentralTex = (input[1].uv + input[0].uv)/2;
				}else if(step(edge0, edge1) * step(edge2, edge1) == 1){
					CentralPos = (input[2].objPos + input[0].objPos)/2;
					CentralTex = (input[2].uv + input[0].uv)/2;
				}

				CentralPos += float4(faceNormal,0) * _Factor;

				for(int i = 0; i < 3; i++){
					o.worldPos = UnityObjectToClipPos(input[i].objPos);
					o.uv = input[i].uv;
					o.col = fixed4(0,0,0,1);
					tristream.Append(o);

					o.worldPos = UnityObjectToClipPos(CentralPos);
					o.uv = CentralTex;
					o.col = fixed4(1,1,1,1);
					tristream.Append(o);

					int nexti = (i+1)%3;
					o.worldPos = UnityObjectToClipPos(input[nexti].objPos);
					o.uv = input[nexti].uv;
					o.col = fixed4(0,0,0,1);
					tristream.Append(o);

					tristream.RestartStrip();
				}

				o.worldPos = UnityObjectToClipPos(input[2].objPos);
				o.uv = input[2].uv;
				o.col = fixed4(0,0,0,1);
				tristream.Append(o);

				o.worldPos = UnityObjectToClipPos(input[1].objPos);
				o.uv = input[1].uv;
				o.col = fixed4(0,0,0,1);
				tristream.Append(o);

				o.worldPos = UnityObjectToClipPos(input[0].objPos);
				o.uv = input[0].uv;
				o.col = fixed4(0,0,0,1);
				tristream.Append(o);

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
