Shader "Unlit/FakeWindow"
{
    Properties
    {
        _MainTex ("Texture", Cube) = "" {}
        _Size ("Size", Float) = 1
        _Offset ("Offset", Vector) = (0, 0, 0)
        _Rotation ("Rotation", Vector) = (0, 0, 0)
        [Toggle(_USEAO)] _UseAO ("Use Ambient Occlusion", Float) = 0.0
        _AOStrength ("AO Strength", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Background" "Queue"="Geometry+500" }
        ZWrite Off
        ZTest Always
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #pragma shader_feature _USEAO

            #include "UnityCG.cginc"
            #include "Rotation.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(1)
                float4 pos : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float3 camPos : TEXCOORD2;
            };

            float4 blendOverlay(float4 base, float4 blend, float opacity)
            {
                float4 result1 = 1.0 - 2.0 * (1.0 - base) * (1.0 - blend);
                float4 result2 = 2.0 * base * blend;
                float4 zeroOrOne = step(base, 0.5);
                float4 o = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                return lerp(base, o, opacity);
            }

            float4 blendSoftLight(float4 base, float4 blend, float opacity)
            {
                float4 result1 = 2.0 * base * blend + base * base * (1.0 - 2.0 * blend);
                float4 result2 = sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend);
                float4 zeroOrOne = step(0.5, blend);
                float4 o = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                return lerp(base, o, opacity);
            }
            
            samplerCUBE _MainTex;
            float4 _MainTex_ST;
            float _Size;
            float4 _Offset;
            float4 _Rotation;
            float _AOStrength;
            
            static const float Epsilon = 0.00001;
            static const float3 Planes[6] = {float3(-1,0,0), float3(1,0,0), float3(0,-1,0), float3(0,1,0), float3(0,0,-1), float3(0,0,1)};
            static const float3 PlaneNormals[6] = {float3(1,0,0), float3(-1,0,0), float3(0,1,0), float3(0,-1,0), float3(0,0,1), float3(0,0,-1)};

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = v.vertex;
                
                o.camPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)).xyz;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 fract = frac((i.pos.xz+0.5) * _MainTex_ST.xy + _MainTex_ST.zw).xxy;//frac(i.pos.xyz * 0.999 * _MainTex_ST.xyy + _MainTex_ST.zww);
                // return fixed4((fract.xz -0.5), 0, 1);
                // float h = frac(i.pos.y * _MainTex_ST.y + _MainTex_ST.w);
                
                // float3 test = float3(fract.x - 0.5, 0, fract.z - 0.5);
                float3 dir = normalize(i.pos.xyz - i.camPos);
                // return fixed4(test, 1);
                float3 bmin = _Size * ((0,0,0) - 0.5) + _Offset;
                float3 bmax = _Size * ((1,1,1) - 0.5) + _Offset;

                float3 tmins = (bmin - i.camPos) / dir;
                float3 tmaxs = (bmax - i.camPos) / dir;
                
                float tmax = min(min(max(tmins.x, tmaxs.x), max(tmins.y, tmaxs.y)), max(tmins.z, tmaxs.z)); 
             
                float3 p = i.camPos + dir * tmax;
                float3 rotP = mul(rotate(radians(_Rotation.xyz)), p - _Offset);
                fixed4 col = texCUBE(_MainTex, rotP);

                #if _USEAO
                float3 aoFactor = 1 - distance(float3(0,0,0), p - _Offset);
                col = blendSoftLight(col, fixed4(aoFactor, 1), _AOStrength);
                #endif
                
                return col;
            }
            ENDCG
        }
    }
}
