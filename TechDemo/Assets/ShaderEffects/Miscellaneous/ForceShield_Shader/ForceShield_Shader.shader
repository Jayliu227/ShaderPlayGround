Shader "Miscellaneous/ForceShield_Shader"
{
	Properties
	{
		_Color("Main Color", COLOR) = (0,0,0,1)
	}
	SubShader
	{
		Tags { "Queue"="Transparent" }

		blend srcAlpha oneMinusSrcAlpha
		zwrite off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 screenuv : TEXCOORD0;
				float depth : DEPTH;
			};

			fixed4 _Color;
			sampler2D _CameraDepthNormalsTexture;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.screenuv = ((o.vertex.xy / o.vertex.w) + 1) / 2;
				o.screenuv.y = 1 - o.screenuv.y;
				o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float screenDepth = DecodeFloatRG(tex2D(_CameraDepthNormalsTexture, i.screenuv).zw);
				float diff = screenDepth - i.depth;
				float intersect = 0;

				if(diff > 0)
					intersect = 1 - smoothstep(0, _ProjectionParams.w * 0.5, diff);

				float niceColor = fixed4(lerp(_Color.rgb, fixed3(1,1,1), pow(intersect, 4)), 1);
				fixed4 col = _Color * _Color.a + niceColor * intersect;
				return col;
			}
			ENDCG
		}
	}
}
