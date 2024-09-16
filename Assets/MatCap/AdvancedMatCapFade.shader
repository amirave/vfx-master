Shader "Unlit/AdvancedMatCapFade"
{
    Properties
    {
        _MainTex ("Texture 1", 2D) = "white" {}
        _Tex2 ("Texture 2", 2D) = "white" {}
        
        _Fade ("Fade", Range(0,1)) = 0.5
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

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 cap : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Tex2;
            float4 _Tex2_ST;
            float _Fade;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

				float4 p = float4( v.vertex );

				float3 e = normalize( mul( UNITY_MATRIX_MV , p) );
				float3 n = normalize( mul( UNITY_MATRIX_MV, v.normal));

				float3 r = reflect( e, n );
                float m = 2. * sqrt( 
					pow( r.x, 2. ) + 
					pow( r.y, 2. ) + 
					pow( r.z + 1., 2. ) 
				);
				half2 capCoord;
				capCoord = r.xy / m + 0.5;
				o.cap = capCoord;
                    
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            vector<float, 4> sampleTex(v2f i)
            {
                float val1 = smoothstep(0.0, i.cap.y, _Fade);
                float val2 = smoothstep(0.0, saturate(distance(float2(0.5,0.5), i.cap.xy)), _Fade);
                float val3 = smoothstep(0.0, 1 - saturate(distance(float2(0.5,0.5), i.cap.xy)), _Fade);
                // return lerp(tex2D(_MainTex, i.cap), tex2D(_Tex2, i.cap), _Fade);
                return lerp(tex2D(_MainTex, i.cap), tex2D(_Tex2, i.cap), val2);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = sampleTex(i);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
