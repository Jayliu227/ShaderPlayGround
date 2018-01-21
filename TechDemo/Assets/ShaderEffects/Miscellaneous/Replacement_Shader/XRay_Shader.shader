Shader "Miscellaneous/XRay_Shader"
{
	Properties
	{

	}
	SubShader
	{
		Tags { "Queue"="Transparent" }

		Zwrite off
		ZTest always
		blend one one

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			half4 _OverAllColor;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float depth : DEPTH;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return _OverAllColor;
			}
			ENDCG
		}
	}
}
