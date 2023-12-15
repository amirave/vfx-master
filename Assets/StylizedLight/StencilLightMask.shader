Shader "Unlit/StencilLight Mask"
{
    Properties
    {
        [IntRange] _StencilID ("Stencil ID", Range(0, 255)) = 0
        _NoiseTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }
        
        CGINCLUDE
        #include "UnityCG.cginc"
        #include "VertexScaleAndRotate.cginc"
        #include "Assets/ShaderHelpers.cginc"
        ENDCG
        
        LOD 100
        
        Pass
        {
            Ztest Greater
            Zwrite off
            Cull Front
            Colormask 0
            
            Stencil
            {
                Comp Always
                Ref [_StencilID]
                Pass Replace
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                
                float2 uv = TRANSFORM_TEX(float2(0.5, _Time.y/5), _NoiseTex);
                float noise = tex2Dlod(_NoiseTex, float4(uv.xy, 0, 0)).r;
                noise = remap(0, 1, 0.92, 1, noise);
                float4 vert = TransformVertex(v.vertex, RandomRotation(_Time.y), noise.xxx);
                o.vertex = UnityObjectToClipPos(vert);
                
                o.uv = TRANSFORM_TEX(v.uv, _NoiseTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(1,1,1,1);
            }
            ENDCG
        }
    }
}
