Shader "TextureBake/FractalNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Layer1("Layer1", 2D) = "white" {}
        _Mask("Mask", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha 

        LOD 100

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
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex,_Layer1,_Mask;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
              half3 albedo= tex2D(_MainTex,i.uv).rgb;
              half3 layer1= tex2D(_Layer1,i.uv).rgb;
              half mask= tex2D(_Mask,i.uv).r;
              half3 finalAlbedo= lerp(albedo,layer1,mask);

              fixed4 color = half4(finalAlbedo,1);
              return color;
            }
            ENDCG
        }
    }
}