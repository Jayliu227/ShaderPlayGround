// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/LowPoly_Shader"
{
	Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}
    }
   
    SubShader
    {
 
        Tags{ "Queue"="Geometry" "RenderType"= "Opaque" "LightMode" = "ForwardBase" }
 
        Pass
        {
            CGPROGRAM
 
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
 
            float4 _Color;
            sampler2D _MainTex;
 
            struct v2g
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 vertex : TEXCOORD1;
            };
 
            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float light : TEXCOORD1;
            };
 
            v2g vert(appdata_full v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            /*
            Geometry shaders have a limited register space for output. With this function decorator, 
            you tell the shader compiler to allocate a certain amount of memory from the available output space. 
            This is necessary specifically in geometry shader because the actual quantity of the resulting geometry 
            is not necessarily known before the shader invocation.

            when the triangleStream reaches the maxvertexcount and continues to append new data, it would automatically
            call XXStream.RestartStrip();

            in this case, we want our output to be of triangles, so the maxcertexcount should be at least three.
            */

            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                g2f o;
 
                // Compute the normal which would be shared by all points within this strip
                float3 vecA = input[1].vertex - input[0].vertex;
                float3 vecB = input[2].vertex - input[0].vertex;
                float3 normal = cross(vecA, vecB);
                normal = normalize(mul(normal, (float3x3) unity_WorldToObject));
 
                // Compute diffuse light
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                o.light = max(0., dot(normal, lightDir));
 
                // Compute barycentric uv
                o.uv = (input[0].uv + input[1].uv + input[2].uv) / 3;
 
                for(int i = 0; i < 3; i++)
                {
                    o.pos = input[i].pos;
                    triStream.Append(o);
                }
            }
 
            half4 frag(g2f i) : COLOR
            {
                float4 col = tex2D(_MainTex, i.uv);
                col.rgb *= i.light * _Color;
                return col;
            }
 
            ENDCG
        }
    }
    Fallback "Diffuse"
}
