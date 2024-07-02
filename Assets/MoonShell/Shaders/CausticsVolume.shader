Shader "Unlit/CausticsVolume"
{
    Properties
    {
        _CausticsTexture ("Caustics Texture", 2D) = "white" {}
        _TintColor ("Tint Color", Color) = (1,1,1,1)
        _CausticsSpeed ("Caustics Speed", Float) = 1
        _CausticsScale ("Caustics Scale", Float) = 1
        _CausticsStrength ("Caustics Strength", Float) = 1
        _CausticsPower ("Caustics Power", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Front
        ZTest Always   

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            half2 Panner(half2 uv, half speed, half tiling)
            {
                return (half2(1, 0) * _Time.y * speed) + (uv * tiling);
            }

            // TEXTURE2D_X_FLOAT(_CameraNormalTexture);
            // SAMPLER(sampler_CameraNormalTexture);
            //
            // float3 SampleSceneNormal(float2 uv)
            // {
            //     return SAMPLE_TEXTURE2D_X(_CameraNormalTexture, sampler_CameraNormalTexture, UnityStereoTransformScreenSpaceTex(uv));
            // }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            TEXTURE2D(_CausticsTexture);
            SAMPLER(sampler_CausticsTexture);
            half4 _TintColor;
            half _CausticsSpeed;
            half _CausticsScale;
            half _CausticsStrength;
            half _CausticsPower;
            
            half4x4 _MainLightMatrix = half4x4(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1);
            half4 _MainLightDirection = half4(0,0,0,0);

            half4 frag(Varyings IN) : SV_Target
            {
                // calculate position in screen-space coordinates
                float2 positionNDC = IN.positionCS.xy / _ScaledScreenParams.xy;

                // sample scene depth using screen-space coordinates
                #if UNITY_REVERSED_Z
                    float depth = SampleSceneDepth(positionNDC);
                #else
                    float depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
                #endif

                // calculate position in world-space coordinates
                float3 positionWS = ComputeWorldSpacePosition(positionNDC, depth, UNITY_MATRIX_I_VP);
                
                                
                float3 positionOS = TransformWorldToObject(positionWS);

                // create bounding box mask
                float boundingBoxMask = all(step(positionOS, 0.5) * (1 - step(positionOS, -0.5)));
                
                half2 uv = mul(positionWS, _MainLightMatrix).xy;

                half2 uv1 = Panner(uv, 0.75 * _CausticsSpeed, 1 / _CausticsScale);
                half2 uv2 = Panner(uv, 1 * _CausticsSpeed, -1 / _CausticsScale);

                half4 tex1 = SAMPLE_TEXTURE2D(_CausticsTexture, sampler_CausticsTexture, uv1);
                half4 tex2 = SAMPLE_TEXTURE2D(_CausticsTexture, sampler_CausticsTexture, uv2);

                half4 caustics = min(tex1, tex2);
                caustics = pow(caustics, _CausticsPower) * _TintColor * _CausticsStrength;

                return half4(caustics.xyz, caustics.w * boundingBoxMask);
            }
            ENDHLSL
        }
    }
}
