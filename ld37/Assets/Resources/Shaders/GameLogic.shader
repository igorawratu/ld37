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
				float eps = 0.0000001;
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

			float rand(float co){
			    return frac(sin(dot(float2(co, _Time),float2(12.9898,78.233))) * 43758.5453);
			}

			float4 UpdatePlayerPos(float2 uv) {
				float2 mouse_movement = tex2D(_inputTex, _inputTex_TexelSize.xy * float2(0, 0)).xy;
				float2 wasd_movement = tex2D(_inputTex, _inputTex_TexelSize.xy * float2(1, 0)).yx;
//				return float4(rand(uv.x),rand(uv.y), 0, 1);

				for(int i = 0; i < 32; i++){
					//boid position
					if(isTexel(uv, float2(i, 0))){
						float2 boid_pos = tex2D(_MainTex, _MainTex_TexelSize.xy * float2(i, 0)).xy;
						float2 boid_velocity = tex2D(_MainTex, _MainTex_TexelSize.xy * float2(i, 1)).xy;
						float boid_active = tex2D(_MainTex, _MainTex_TexelSize.xy * float2(i, 2)).x;
						if(boid_active < 1)
							return float4(rand(uv.x), rand(rand(uv.x)), 0, 1);

						return saturate(float4(boid_pos + boid_velocity * 0.02, 0, 1));
					}
					//boid velocity
					if (isTexel(uv, float2(i, 1))) {
						float2 boid_velocity = tex2D(_MainTex, _MainTex_TexelSize.xy * float2(i, 1)).xy * 0.02;
						return float4(boid_velocity + wasd_movement + mouse_movement, 0, 1);
					}
					//boid active
					if (isTexel(uv, float2(i, 2))) {
						float boid_active = tex2D(_MainTex, _MainTex_TexelSize.xy * float2(i, 2)).x;
						if(boid_active < 1.0)
							return float4(1,0, 0, 1);
						return float4(boid_active, 0, 0, 1);
					}
				}
				return float4(0,0, 0, 1);
			}

			bool InRoom(float2 person_pos, float2 room_pos, float room_size) {
				float texelWidth = 1.0 / _width * room_size;

				halfdims = float2(texelWidth * 200, texelWidth * 150);
				float2 fixed_uv - person_pos - room_pos;

				return abs(fixed_uv.x) <= halfdims.x && abs(fixed_uv.y) <= halfdims.y;
			}

			bool HitBorder(float2 pos, float size) {
				float pix_size = 1.0 / _width * 100 * size;

				return pos.x < pix_size || pos.y < pix_size;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return UpdatePlayerPos(i.uv);
			}
			ENDCG
		}
	}
}
