Shader "Hidden/Datamosh"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline"}
        LOD 100
        ZWrite Off Cull Off

        Pass
        {
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            // TEXTURE2D_X(_CameraOpaqueTexture);
            // SAMPLER(sampler_CameraOpaqueTexture);
            sampler2D _CameraOpaqueTexture;
            sampler2D _CameraDepthTexture;
            sampler2D _MotionVectorTexture;
            sampler2D _Prev2;

            half4 frag (Varyings i) : SV_Target
            {
                // float4 col = SAMPLE_TEXTURE2D_X(_CameraOpaqueTexture, sampler_CameraOpaqueTexture, i.texcoord);
                float4 depth = tex2D(_CameraDepthTexture, i.texcoord);
                float4 mot = tex2D(_MotionVectorTexture, i.texcoord + 0*float2(-1, 1));

                mot *= 1;
                float2 mvuv = float2(i.texcoord.x - mot.r, i.texcoord.y - mot.g);
                // float4 col = lerp(tex2D(_CameraOpaqueTexture, mvuv), tex2D(_Prev, mvuv), 0.5*sin(_Time.y)+0.5);
                float4 col = tex2D(_Prev2, i.texcoord);
                // float4 col = float4(_Test.xxx, 1);
                // col = mot * 10;
                // col *= 10*distance(mot, float3(0,0,0));
                // mvuv = UnityStereoTransformScreenSpaceTex(mvuv, 0);
                // float4 col = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_PointClamp, mvuv);
                // col += mot * 10;
                // just invert the colors
                return col;
            }
            ENDHLSL
        }
    }
}
