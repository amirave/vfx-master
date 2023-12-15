Shader "Unlit/FakeWindow"
{
    Properties
    {
        _MainTex ("Texture", Cube) = "" {}
        _Size ("Size", Float) = 1
        _Offset ("Offset", Vector) = (0, 0, 0)
        _Rotation ("Rotation", Vector) = (0, 0, 0)
        [Toggle(_USEOBJECTSPACE)] _UseObjectSpace ("Use Object Space", Float) = 0.0
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
            // make fog work
            #pragma multi_compile_fog

            #pragma shader_feature _USEOBJECTSPACE

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
                float4 worldPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            samplerCUBE _MainTex;
            float4 _MainTex_ST;
            float _Size;
            float4 _Offset;
            float4 _Rotation;
            static const float Epsilon = 0.001;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 objPos = mul(unity_WorldToObject, i.worldPos).xyz;

                float3 planes[6] = {float3(-1,0,0), float3(1,0,0), float3(0,-1,0), float3(0,1,0), float3(0,0,-1), float3(0,0,1)};
                float3 planeNormals[6] = {float3(1,0,0), float3(-1,0,0), float3(0,1,0), float3(0,-1,0), float3(0,0,1), float3(0,0,-1)};
                
                float3 camPos = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)).xyz;
                float3 camDir = normalize(objPos - camPos).xyz;
                
                fixed4 col = fixed4(0,0,0,1);
                
                for (int i = 0; i < 6; i++)
                {
                    int mask = 1;
                    
                    float denominator = dot(planeNormals[i], camDir);
                    mask -= denominator < 0;
                    
                    float3 diff = (planes[i] * _Size) + _Offset - camPos;
                    float t = dot(diff, planeNormals[i]) / denominator;
                    mask -= t < 0;
                    
                    float3 p = camPos + t * camDir - _Offset.xyz;
                    float3 cutoff = _Size + Epsilon;
                    mask -= abs(p.x) > cutoff.x || abs(p.y) > cutoff.y || abs(p.z) > cutoff.z;
                    
                    // UNITY_APPLY_FOG(i.fogCoord, col);
                    p = mul(rotate(radians(_Rotation.xyz)), p);
                    col = texCUBE(_MainTex, p);
                }
                
                return col;
                // return half4((distance(p, camDir)/100).xxx, 1);
            }
            ENDCG
        }
    }
}
