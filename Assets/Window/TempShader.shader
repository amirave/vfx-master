Shader "Unlit/TempShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
        _LightPos("Light Position", Vector) = (0,0,0,0)
        [HDR] _LightColor("Light Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float3 viewNormal : TEXCOORD1;
                float4 pos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _BaseColor;

            float4 _LightPos;
            float4 _LightColor;

            float4 blendSoftLight(float4 base, float4 blend, float opacity)
            {
                float4 result1 = 2.0 * base * blend + base * base * (1.0 - 2.0 * blend);
                float4 result2 = sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend);
                float4 zeroOrOne = step(0.5, blend);
                float4 o = result2 * zeroOrOne + (1 - zeroOrOne) * result1;
                return lerp(base, o, opacity);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.viewNormal = v.normal;
                o.pos = v.vertex;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= _BaseColor;
                clip(col.a - 0.1);

                float val = dot(normalize(i.viewNormal), normalize(_LightPos - i.pos));

                col = blendSoftLight(col, _LightColor, val * _LightColor);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
