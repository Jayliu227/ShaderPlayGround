Shader "Miscellaneous/ShowDepth_Shader"
{
	Properties
	{
		
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
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				// this is a new semantic!!
				float depth : DEPTH;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				/*
					v.vertex, after transformed to view direction, its z component would represent the depth
					ranged from 0, nearest to the near clipping plane, to some value smaller (negative) , nearest to the far clipping plane.
					we than invert this value so that the bigger the value is, the further it is to the near plane.
					in order to uniform this value, we multiply this value ranged (0, farplane) by _ProjectionParams.w (1/farplane),
					and this gives us the depth value ranged from 0 to 1 !! 
					(no matter what we set the farplane to, the final value would end up being in this range.)
				*/
				o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;

				return o;
			}

			/*
				IMPORTANT: all the properties in shaders replaced by this one would still maintain and be available to use here!
			*/
			half4 _Color;

			fixed4 frag (v2f i) : SV_Target
			{
				// invert it so that the closer, the value is bigger, whiter
				float invert = 1 - i.depth;
				return fixed4(invert, invert, invert, 1) * _Color;
			}
			ENDCG
		}
	}

	// for Transparent Objects
	SubShader
	{
		Tags { "RenderType"="Transparent" }

		zwrite off
		blend srcalpha oneminussrcalpha

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
				// this is a new semantic!!
				float depth : DEPTH;
			};
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.depth = -mul(UNITY_MATRIX_MV, v.vertex).z * _ProjectionParams.w;

				return o;
			}

			/*
				IMPORTANT: all the properties in shaders replaced by this one would still maintain and be available to use here!
			*/
			half4 _Color;

			fixed4 frag (v2f i) : SV_Target
			{
				float invert = 1 - i.depth;
				return _Color;
			}
			ENDCG
		}
	}
}
