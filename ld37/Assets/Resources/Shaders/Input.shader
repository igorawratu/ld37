Shader "InputShader"
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
#include "UnityCG.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float2 _mouseMovement;
			float2 _wasdMovement;
			float4 _mouseButtons;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			bool isTexel(float2 uv, float2 pixelPos){
				float eps = 0.0001;
//#if UNITY_HALF_TEXEL_OFFSET
				if (abs(uv.x - (_MainTex_TexelSize.x * (pixelPos.x + 0.5))) < eps
					&& abs(uv.y - (_MainTex_TexelSize.y * (pixelPos.y + 0.5))) < eps){
					return true;
				}
//#else
//				if (abs(uv.x - (_MainTex_TexelSize.x * pixelPos.x)) < eps
//					&& abs(uv.y - (_MainTex_TexelSize.y * pixelPos.y)) < eps){
//					return true;
//				}
//#endif
				return false;
			}
			float2 toTexel(float2 input)
			{
				input *=0.5;
				input += 0.5;
				return input;
			}
			float2 fromTexel(float2 input)
			{
				input -= 0.5;
				input *=2.0;
				return input;
			}
			float4 UpdateInput(float2 uv) {
				if(isTexel(uv, float2(0, 0))){
					return float4(toTexel(_mouseMovement), 0, 1);
				}
				if (isTexel(uv, float2(1,0))) {
					return float4(toTexel(_wasdMovement), 0, 1);
				}
				if (isTexel(uv, float2(2,0))) {
					return _mouseButtons;
				}
				return float4(0, 0, 1, 1);
			}

			fixed4 frag (v2f i) : SV_Target
			{
//				return float4(_MainTex_TexelSize.xy, 0, 1);
//				float4 col = float4(_wasdMovement, 0, 1);
//				float4 col = float4(_mouseMovement, 0, 1);
//				return col;
				return UpdateInput(i.uv);
			}
			ENDCG
		}
	}
}
