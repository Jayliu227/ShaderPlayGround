Shader "Miscellaneous/CircularHealthBar_Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color1 ("Color 1", COLOR) = (1,0,0,1)
		_Color2 ("Color 2", COLOR) = (0,1,0,0)
		_Health ("Health", range(0,1)) = 0
		_Thickness ("Thickness of the ring", range(0.1, 0.3)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _Color1;
			fixed4 _Color2;
			float _Health;
			float _Thickness;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float pi = 3.14159265358979323846264338327;
				// map uv from 0,1 to -1,1
				float2 uv = i.uv * 2 - 1;
				// the length between the uv coord and the center
				float _Length = distance(uv, float2(0, 0));
				// inside and outside mask, invert the outside so they can overlap
				float _InMask = floor(_Thickness + _Length);
				float _OutMask = 1 - floor(_Length);
				// angular gradient
				float AG = 1 - atan2(uv.r, uv.g);
				// map it to 0,1 (return value -pi, pi)
				AG = (AG + pi) / (2 * pi);
				// use _Health field to control
				AG -= _Health * 1.16;
				// ceil it so that there is only 0 and 1 value
				AG = 1 - ceil(AG);
				// the bar color is in relation to the current health
				fixed4 col = lerp(_Color1, _Color2, _Health);
				// the final color has been affected by various elements
				col *= _OutMask * _InMask * AG * tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
