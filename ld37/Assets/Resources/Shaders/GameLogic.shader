Shader "GameLogic"
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
			float4 _MainTex_TexelSize;
			float4 _MainTex_ST;

			sampler2D _inputTex;
			float4 _inputTex_TexelSize;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			bool isTexel(float2 uv, float2 pixelPos){
				float eps = 0.001;
				if (abs(uv.x - (_MainTex_TexelSize.x * pixelPos.x)) < eps 
					&& abs(uv.y - (_MainTex_TexelSize.y * pixelPos.y)) < eps)
				{
					return true;
				}
				return false;
			}

			float4 UpdatePlayerPos(float2 uv) {
				float eps = 0.00001;
				//player position
				if(isTexel(uv, float2(0,0))){
					float2 previous_player_pos = tex2D(_MainTex, float2(0, 0)).xy;
					float2 player_velocity = tex2D(_MainTex, _MainTex_TexelSize.xy * float2(2, 0)).xy;

					return saturate(float4(previous_player_pos + player_velocity * 0.02, 0, 1));
				}
				//player velocity
				else if (isTexel(uv, float2(2, 0))) {
					float2 player_velocity = tex2D(_MainTex, _MainTex_TexelSize.xy * float2(2, 0)).xy * 0.02;
					float2 mouse_movement = tex2D(_inputTex, float2(0, 0)).xy;
					float2 wasd_movement = tex2D(_inputTex, _inputTex_TexelSize.xy * float2(2, 0)).xy;
					return float4(player_velocity + wasd_movement, 0, 1);
				}
//				else if (isTexel(uv, float2(2, 0))){
//					float boidPos = tex2D(_MainTex, float2(2, 0)).xy;
//					float2 wasd_movement = tex2D(_inputTex, float2(1, 0)).xy;
//					return saturate(float4(boidPos + wasd_movement * 0.0002, 0, 1));
//				}
				else {
					return float4(0, 0, 0, 1);
				}
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return UpdatePlayerPos(i.uv);
			}
			ENDCG
		}
	}
}
