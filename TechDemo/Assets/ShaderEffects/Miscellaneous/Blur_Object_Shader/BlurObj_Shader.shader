Shader "Miscellaneous/BlurObj_Shader"
{
	Properties
	{
		_BlurFactor("Blue Factor", range(0,15)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "IgnoreProjector"="True"}

		GrabPass{}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ABR_precision_hint_fastest

			#include "UnityCG.cginc"

			float _BlurFactor;
			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 screenuv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				// remember when using grabscreenpos, it has to be of world-space coord, and it returns a float4
				o.screenuv = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(0,0,0,0);

				// the way to decode grabtexture is to use the following
				#define addOffset(weight, offsetX) tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(fixed4(i.screenuv.x + offsetX * _BlurFactor * _GrabTexture_TexelSize.x, i.screenuv.y, i.screenuv.z, i.screenuv.w)))*weight

				// could vary depending on needs
				col += addOffset(0.05, 4.0);
                col += addOffset(0.09, 3.0);
                col += addOffset(0.12, 2.0);
                col += addOffset(0.15, 1.0);
                col += addOffset(0.18, 0.0);
                col += addOffset(0.15, -1.0);
                col += addOffset(0.12, -2.0);
                col += addOffset(0.09, -3.0);
                col += addOffset(0.05, -4.0);

				return col;
			}
			ENDCG
		}

		GrabPass{}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ABR_precision_hint_fastest

			#include "UnityCG.cginc"

			float _BlurFactor;
			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 screenuv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenuv = ComputeGrabScreenPos(o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(0,0,0,0);

				#define addOffset(weight, offsetY) tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(fixed4(i.screenuv.x, i.screenuv.y + offsetY * _BlurFactor * _GrabTexture_TexelSize.y, i.screenuv.z, i.screenuv.w)))*weight

				// could vary depending on needs
				col += addOffset(0.05, 4.0);
                col += addOffset(0.09, 3.0);
                col += addOffset(0.12, 2.0);
                col += addOffset(0.15, 1.0);
                col += addOffset(0.18, 0.0);
                col += addOffset(0.15, -1.0);
                col += addOffset(0.12, -2.0);
                col += addOffset(0.09, -3.0);
                col += addOffset(0.05, -4.0);

				return col;
			}
			ENDCG
		}
	}
}
