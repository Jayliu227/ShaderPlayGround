Shader "Miscellaneous/Dissolve_Problem_Shader"
{
	Properties
	{
		_Ramp ("Ramp Tex", 2D) = "white" {}
		_Noise ("Noise Tex", 2D) = "white"{}
		_Value ("Dissolve Value", range(0, 1)) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			cull off
			//blend srcalpha oneminussrcalpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		
			#include "UnityCG.cginc"

			sampler2D _Ramp;
			sampler2D _Noise;
			float _Value;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv: texcoord0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : texcoord0;
			};
		
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// final output color
				fixed4 col;
				// get the noiseValue (information) from noise texture, already clamped01
				float noiseValue = tex2D(_Noise, i.uv).r; 
				// invert the _Value so that 0 means non-dissolved
				_Value = 1 - _Value;
				// map _Value to something that makes the discardValue workable
				_Value = _Value * 0.5 - 0.68;
				// value for each pixel to determine visibility
				float discardValue = noiseValue + _Value;
				if( discardValue <= 0) discard;


				// why the hell would this generate grey color when it breaks out of the boundary?
				noiseValue = 1 - saturate(noiseValue);
				col = tex2D(_Ramp, float2(noiseValue, 0));
				//col = lerp(fixed4(1,0,0,1), fixed4(0,0,1,1), noiseValue);
				return col;
			}
			ENDCG
		}
	}
}
