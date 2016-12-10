Shader "ChromaAberration"
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
			float4 _MainTex_ST;

			float _width;
			float _height;
			float _t;

			float rand(float2 co)
			{
				int val = co.x + co.y + _t * 5;

				return val % 2 == 0 ? 1 : -1;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			

			fixed4 frag (v2f i) : SV_Target
			{
				float ca_strength = 5;

				float2 dims = float2(_width, _height);

				float randval = rand(i.uv);

				float2 r_uv = i.uv + (randval / dims) * ca_strength;
				float2 g_uv = i.uv + (randval / dims) * ca_strength;
				float2 b_uv = i.uv + (randval / dims) * -ca_strength;

				float col_r = tex2D(_MainTex, r_uv).r;
				float col_g = tex2D(_MainTex, g_uv).g;
				float col_b = tex2D(_MainTex, b_uv).b;

				//return float4(r_uv - i.uv, 0, 1);
				fixed4 col = fixed4(col_r, col_g, col_b, 1);
				return col;
			}
			ENDCG
		}
	}
}
