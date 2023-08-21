Shader "VFX/UV_Flow" {
	Properties{
		_MainTex("RGB:Color A:Alpha" , 2D) = "white"{}
		_Opacity("Opacity" , range(0.0 , 1.0)) = 1.0
		_NoiseMap("R:Noise" , 2D) = "gray"{}      
		_NoiseInt("Noise Intensity" , range(0.0 , 5.0)) = 1.0           
		_FlowSpeed("Flow Speed", range(-10.0 , 10.0)) = 5.0     
		_FlowDir("Flow Direction",vector)=(0,0,0,0)
	}
		SubShader{
			Tags {"Queue" = "Transparent" "IgnoreProjector" = "True""RenderType" = "Transparent" "PreviewType" = "Plane"}
			Pass {
				Name "FORWARD"
				Tags {
					"LightMode" = "ForwardBase"
				}
				ZWrite Off
				Blend SrcAlpha One


				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_particles
				#include "UnityCG.cginc"

				uniform sampler2D _MainTex;
				uniform half _Opacity;
				uniform sampler2D _NoiseMap; 
				uniform float4 _NoiseMap_ST;
				uniform half _NoiseInt;
				uniform half _FlowSpeed;
				uniform float4 _FlowDir;

				struct VertexInput {
					float4 vertex : POSITION;
					float2 uv0    : TEXCOORD0;
					float4 color  :  COlOR;
				};
				struct VertexOutput {
					float4 pos : SV_POSITION;
					float4 uv0 : TEXCOORD0;         
					float4 color :TEXCOORD1;
				};
				VertexOutput vert(VertexInput v) {
					VertexOutput o = (VertexOutput)0;
						o.pos = UnityObjectToClipPos(v.vertex);
						o.uv0.xy = v.uv0;                                        //uv0.xy采样MainTex
						o.uv0.zw = v.uv0 * _NoiseMap_ST.xy + _NoiseMap_ST.zw;    //uv0.zw采样NoiseMap
						o.uv0.zw += _FlowDir.xy * frac(_Time.x * _FlowSpeed);                   //uv0.w会随着时间变化(上下uv流动)
						o.color = v.color;
					return o;
				}

				half4 frag(VertexOutput i) : SV_TARGET {

					half4 var_MainTex = tex2D(_MainTex , i.uv0.xy)* i.color;
					half  var_NoiseMap = tex2D(_NoiseMap , i.uv0.zw).r;	      
					half  noise = lerp(1.0 , var_NoiseMap * 2 , _NoiseInt);	   
						  noise = max(0.0 , noise);                             
					half  opacity = var_MainTex.a * _Opacity * noise;
					return half4(var_MainTex.rgb * opacity , opacity);
				}
					ENDCG
			}
		}
			FallBack "Diffuse"
}