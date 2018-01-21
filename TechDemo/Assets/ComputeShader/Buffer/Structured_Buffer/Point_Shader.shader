Shader "Unlit/Point_Shader"
{
	SubShader
	{
		Pass
		{
			zwrite off cull off ztest always

			// enable target 5.0, which contains DirectCompute
			CGPROGRAM
			#pragma target 5.0
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform StructuredBuffer<float3> buffer;

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};
			
			v2f vert (uint id : SV_VertexID)
			{
				float4 p = float4(buffer[id], 1);
				v2f o;
				o.vertex = p;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return fixed4(1,0,0,1);
			}
			ENDCG
		}
	}
}
