Shader "GameRenderer"
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
			float _width;
			float _height;
			sampler2D _logicTex;
			float4 _logicTex_TexelSize;
			float4 _logicTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			float4 DrawPlayer(float2 uv) {
				float player_size = 0.01;
				float2 player_pos = tex2D(_logicTex, float2(0, 0)).xy;
				float aspect = _width / _height;

				float dist = length(player_pos - uv);
				if (dist < player_size) {
					return float4(1, 0, 0, 1);
				}

				for(int i = 0; i < 10; i++){
					float2 boid_pos = tex2D(_logicTex, _logicTex_TexelSize.xy * float2(i, 0)).xy;

					float distBoid = length(boid_pos - uv);
					if(distBoid < player_size){
						return float4(1, 1, 0, 1);
					}
				}
				return float4(0.5, 0, 0, 1);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return DrawPlayer(i.uv);
			}
			ENDCG
		}
	}
}
