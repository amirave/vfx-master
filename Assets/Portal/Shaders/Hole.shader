Shader "Unlit/Hole"
{
    Properties
    {
        [HDR]_ColorTop("Color",Color) = (1,1,1,1)    
        [HDR]_ColorMiddle("Color",Color) = (0.5,0.5,0.5,1)    
        [HDR]_ColorBottom("Color",Color) = (0,0,0,1)    
        _Exponent("Exponent", Range(0, 2)) = 0.5
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
      Tags { "RenderType" = "Opaque" "Queue" = "Geometry+2"}
        ColorMask RGB
        
            ZTest off
            ZWrite On
            Cull Front
            Lighting Off
          
            
            Stencil
            {
                Ref 3
                Comp equal
                Pass keep
                fail keep
                zfail keep
            }
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
 
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
 
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
                float4 pos : TEXCOORD1;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float4 _ColorTop;
            float4 _ColorMiddle;
            float4 _ColorBottom;
            float _Exponent;
 
            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = v.vertex;
                o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }
 
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed t = i.pos.y + 0.5;
                fixed4 colBottom = lerp(_ColorBottom, _ColorMiddle, pow(saturate(t*2), _Exponent));
                fixed4 colTop = lerp(_ColorMiddle, _ColorTop, pow(saturate(t*2-1), _Exponent));

                fixed4 finalCol = lerp(colBottom, colTop, step(0.5,t));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return finalCol;
            }
            ENDCG
        }
    }
}