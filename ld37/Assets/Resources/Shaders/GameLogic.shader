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
			float _t;

			float _width;
			float _height;

			float _dt;

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

			float2 rand2(float2 co){
			    return float2(frac(sin(dot(co * _t, float2(12.9898, 78.233))) * 43758.5453), frac(sin(dot(co * _t, float2(12.9898, 78.233))) * 43758.5453));
			}

			float rand1(float co) {
				return frac(sin(dot(float2(co, _t), float2(12.9898, 78.233))) * 43758.5453);
			}

			bool InRoom(float2 person_pos, float2 room_pos, float room_size) {
				float texelWidth = 1.0 / 1920 * room_size;

				float2 halfdims = float2(texelWidth * 200, texelWidth * 150);
				float2 fixed_uv = person_pos - room_pos;

				return abs(fixed_uv.x) < halfdims.x && abs(fixed_uv.y) < halfdims.y;
			}

			bool HitBorder(float2 pos, float size) {
				float texel_width = (1.0 / 1920) * 100 * size;
				float texel_height = (1.0 / 1080) * 100 * size;

				return pos.x < texel_width || pos.y < texel_height || 1 - pos.x < texel_width || 1 - pos.y < texel_height;
			}

			float4 UpdatePlayerPos(float2 uv) {
				
				float max_score = 10000;
				float2 mouse_movement = tex2D(_inputTex, _inputTex_TexelSize.xy * float2(0, 0)).xy;
				float2 wasd_movement = tex2D(_inputTex, _inputTex_TexelSize.xy * float2(1, 0)).yx;
				float4 prev_score = tex2D(_MainTex, float2(0.5 * _MainTex_TexelSize.x, _MainTex_TexelSize.y * 2.5));

				if (prev_score.y > 0.5) {
					return prev_score;
				}

				//return float4(rand2(uv), 0, 1);
//				return float4(rand(uv.x),rand(uv.y), 0, 1);

				if (isTexel(uv, float2((uv.x - 0.5 * _MainTex_TexelSize.x) / _MainTex_TexelSize.x, 0))) {
					if (_t < 0.5) {
						return float4(0, 0, 0, 0);
					}

					float4 boid_pos = tex2D(_MainTex, float2(uv.x, 0));

					if (boid_pos.z > 0.5) {
						if (boid_pos.w > 0.5) {
							return float4(0, 0, 0, 0);
						}

						float2 boid_velocity = tex2D(_MainTex, _MainTex_TexelSize.xy * float2(uv.x, 1.5)).xy;
						//float2 repulsive_force = float2(0.0,0.0);
						//float player_pos = tex2D(_MainTex, _MainTex_TexelSize.xy * float2(0, 0)).xy ;
						//repulsive_force = length(player_pos-boid_pos);
						 

						float2 newpos = saturate(boid_pos.xy + boid_velocity * 0.02);

						float destroying = HitBorder(boid_pos.xy, 0.25) ? 1 : 0;

						return float4(newpos, boid_pos.z, destroying);
					}
					//spawn logic here
					else {
						float timer = _t % 1.0;

						if (abs(timer) > 0.1) {
							return boid_pos;
						}

						float spawn_prob = min(_t / 60, 1);
						spawn_prob *= _dt;

						float chance = abs(rand1(uv.x));
						chance = chance < 0 ? -chance : chance;
						boid_pos.w = 0;
						if (spawn_prob >= chance) {
							boid_pos.z = 1;
							boid_pos.xy = (rand2(uv) + float2(1, 1)) / 2;
							
						}
						else{
							boid_pos.z = 0;
						}

						return boid_pos;
					}
				}
				else if (isTexel(uv, float2((uv.x - 0.5 * _MainTex_TexelSize.x) / _MainTex_TexelSize.x, 1))) {
					float2 boid_velocity = tex2D(_MainTex, float2(uv.x, _MainTex_TexelSize.y * 1.5)).xy;
					float2 new_vel = boid_velocity + wasd_movement * 0.02 + mouse_movement * 0.02;

					float2 old_vel = length(new_vel) == 0 ? boid_velocity : new_vel;
					return float4(new_vel, old_vel);
				}
				else if (isTexel(uv, float2(0, 2))) {
					if (_t < 0.5) {
						return float4(500 / max_score, 0, 0, 1);
					}

					float scoreForRound = 0.0;

					for (int j = 0; j < 32; j++) {
						float4 boid_pos = tex2D(_MainTex, _MainTex_TexelSize.xy * float2((float)j + 0.5, 0.5));

						if (boid_pos.z > 0.5) {
							scoreForRound += InRoom(boid_pos.xy, float2(0.5, 0.5), 3) ? _dt : 0;

							if (boid_pos.w > 0.5) {
								scoreForRound -= 50;
							}
						}
					} 

					prev_score.x = (prev_score.x * max_score + scoreForRound) / max_score;

					if (prev_score.x * max_score < 1) {
						prev_score.z = _t / max_score;
						prev_score.y = 1;
					}

					return prev_score;
				}
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
