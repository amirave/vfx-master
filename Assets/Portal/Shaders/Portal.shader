Shader "Unlit/Portal"
{
    Properties
    {
        _MainTexture ("Texture", 2D) = "white" {}
        _NoiseTexture ("Texture", 2D) = "white" {}
        [IntRange] _StencilID ("Stencil ID", Range(0, 255)) = 0
    }
    SubShader
    {
        Tags 
		{ 
			"RenderType" = "Opaque"
			"Queue" = "Geometry+1"
			"RenderPipeline" = "UniversalPipeline"
		}

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
        
        struct Attributes
        {
            // The positionOS variable contains the vertex positions in object
            // space.
            float4 positionOS   : POSITION;
        };

        struct Varyings
        {
            // The positions in this struct must have the SV_POSITION semantic.
            float4 positionHCS  : SV_POSITION;
            float3 positionWS : TEXCOORD0;
        };

        float2 Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale)
        {
            float2 delta = UV - Center;
            float radius = length(delta) * 2 * RadialScale;
            float angle = atan2(delta.x, delta.y) * 1.0/6.28 * LengthScale;
            return float2(radius, angle);
        }

        float2 unity_gradientNoise_dir(float2 p)
        {
            p = p % 289;
            float x = (34 * p.x + 1) * p.x % 289 + p.y;
            x = (34 * x + 1) * x % 289;
            x = frac(x / 41) * 2 - 1;
            return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
        }

        float unity_gradientNoise(float2 p)
        {
            float2 ip = floor(p);
            float2 fp = frac(p);
            float d00 = dot(unity_gradientNoise_dir(ip), fp);
            float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
            float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
            float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
            fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
            return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
        }

        float Unity_GradientNoise_float(float2 UV, float Scale)
        {
            return unity_gradientNoise(UV * Scale) + 0.5;
        }

        float invLerp(float a, float b, float v)
        {
            return (v - a) / (b - a);
        }

        // The vertex shader definition with properties defined in the Varyings
        // structure. The type of the vert function must match the type (struct)
        // that it returns.
        Varyings vert(Attributes IN)
        {
            // Declaring the output object (OUT) with the Varyings struct.
            Varyings OUT;
            // The TransformObjectToHClip function transforms vertex positions
            // from object space to homogenous clip space.
            OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
            OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
            // Returning the output.
            return OUT;
        }

        sampler2D _MainTexture;
        sampler2D _NoiseTexture;
        
        // The fragment shader definition.
        half4 frag(Varyings IN) : SV_Target
        {
            // Defining the color variable and returning it.
            float2 uv = IN.positionHCS / _ScaledScreenParams.xy;
            #if UNITY_REVERSED_Z
                real depth = SampleSceneDepth(uv);
            #else
                real depth = lerpUNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
            #endif

            float3 worldPos = ComputeWorldSpacePosition(uv, depth, UNITY_MATRIX_I_VP);
            float3 objectPos = TransformWorldToObject(worldPos);
            clip(0.5 - abs(objectPos));

            float2 projUv = objectPos.xz + 0.5;
            float2 polar = Unity_PolarCoordinates_float(objectPos.xz, 0, 1, 1);
            float noise = Unity_GradientNoise_float(polar + _TimeParameters.x, 20);

            float cutoff = 0.2;
            noise = invLerp(cutoff, 1, noise);
            half4 col = noise;
            col *= tex2D(_MainTexture, projUv);
            
            // clip(col.a - cutoff);
            
            #if UNITY_REVERSED_Z
                if(depth < 0.0001)
                    return half4(0,0,0,1);
            #else
                if(depth > 0.9999)
                    return half4(0,0,0,1);
            #endif
            
            return col;
        }

        half4 fragStencilMask(Varyings IN) : SV_Target
        {
            // Defining the color variable and returning it.
            float2 uv = IN.positionHCS / _ScaledScreenParams.xy;
            #if UNITY_REVERSED_Z
                real depth = SampleSceneDepth(uv);
            #else
                real depth = lerpUNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(uv));
            #endif

            float3 worldPos = ComputeWorldSpacePosition(uv, depth, UNITY_MATRIX_I_VP);
            float3 objectPos = TransformWorldToObject(worldPos);
            clip(0.5 - abs(objectPos));

            float2 projUv = objectPos.xz + 0.5;
            float2 polar = Unity_PolarCoordinates_float(objectPos.xz, 0, 1, 1);
            float noise = Unity_GradientNoise_float(polar + _TimeParameters.x, 20);

            float cutoff = 0.2;
            noise = invLerp(cutoff, 1, noise);
            half4 col = noise;
            col *= tex2D(_MainTexture, projUv);
            
            clip(col.a - cutoff);
            
            #if UNITY_REVERSED_Z
                if(depth < 0.0001)
                    return half4(0,0,0,1);
            #else
                if(depth > 0.9999)
                    return half4(0,0,0,1);
            #endif
            
            return col;
        }
        ENDHLSL
        
        Pass
        {
            Name "Decal Mask"
            Ztest Greater
            Zwrite off
            Cull Off
            Colormask 0
            Lighting Off
 
            Tags
            {
                "RenderType" = "Transparent"             
                "RenderPipeline" = "UniversalPipeline"
            }
            
            Stencil
            {
                comp Always
                ref 3
                pass replace
            }
 
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment fragStencilMask
            
        ENDHLSL
        }
  
        
        Pass
        {
            Name "Decal Effect"
            Zwrite off
            Ztest Off
            Cull Front
            Lighting Off
            Blend OneMinusDstColor One
 
            Tags
            {
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
                "RenderPipeline" = "UniversalPipeline"
                "LightMode" = "UniversalForward"
            }
           
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag  
            ENDHLSL
        }       
    }
}
