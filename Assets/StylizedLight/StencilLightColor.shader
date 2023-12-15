Shader "Unlit/StencilLight Color"
{
    Properties
    {
        [IntRange] _StencilID ("Stencil ID", Range(0, 255)) = 0
        _NoiseTex ("Texture", 2D) = "white" {}
        [HDR] _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        CGINCLUDE
        #include "UnityCG.cginc"
        #include "VertexScaleAndRotate.cginc"
        #include "Assets/ShaderHelpers.cginc"

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
        fixed4 _Color;

        v2f vert (appdata v)
        {
            v2f o;
            
            float2 uv = TRANSFORM_TEX(float2(0.5, _Time.y/5), _NoiseTex);
            float noise = tex2Dlod(_NoiseTex, float4(uv.xy, 0, 0)).r;
            noise = remap(0, 1, 0.92, 1, noise);
            float4 vert = TransformVertex(v.vertex, RandomRotation(_Time.y), noise.xxx);
            o.vertex = UnityObjectToClipPos(vert);
            
            o.vertex = UnityObjectToClipPos(vert);
            // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            UNITY_TRANSFER_FOG(o,o.vertex);
            return o;
        }

        fixed4 frag (v2f i) : SV_Target
        {
            fixed4 col = _Color;
            UNITY_APPLY_FOG(i.fogCoord, col);
            return col;
        }
        ENDCG
        
        LOD 100
        
        Pass
        {
            Tags
            {
                "RenderType" = "Transparent"          
                "RenderPipeline" = "UniversalPipeline"            
            }       
            
            Zwrite off
            Ztest Lequal
            Cull Back
            Blend SrcAlpha One
            
            Stencil {
                Ref [_StencilID]
                Comp Equal
                Pass Zero
                fail Zero
                zfail Zero
            }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
        
        Pass
        {
            Tags
            {
                "RenderPipeline" = "UniversalPipeline"
                "LightMode" = "UniversalForward"
            }
            
            Ztest Always
            Zwrite off
            Cull Front
            Blend SrcAlpha One
            
            Stencil
            {
                Comp LEqual
                Ref [_StencilID]
                Pass zero
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
