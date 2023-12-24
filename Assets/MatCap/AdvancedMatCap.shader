Shader "Unlit/AdvancedMatCap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.cap);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
