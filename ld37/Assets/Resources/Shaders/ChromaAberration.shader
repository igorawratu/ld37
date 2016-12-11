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
				return 1;
				float aspect = _width / _height;

				int v1 = co.x * _width;
				int v2 = co.y * _height;

				return (v1 + v2) % 2 == 0? 1 : -1;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//o.uv += float2(_t * 0.01, 0);

				float aspect = _width / _height;

				return o;
			}

			float2 Warp(float2 uv) {
				float2 shifted = uv - float2(0.5, 0.5);
				float2 offset = abs(float2(shifted.y, shifted.x)) / float2(3.0, 2.0);
				shifted = shifted + shifted * offset * offset;
				uv = shifted + float2(0.5, 0.5);

				return uv;
			}

			float4 Vignette(float2 uv) {
				float3 white = float3(1, 1, 1);

				float2 shifted = (uv - float2(0.5, 0.5)) * 2;
				float3 power = saturate(white * (1 - (length(shifted) * length(shifted)) / 1.9) );

				return float4(power, 1);
			}

			float4 ClampedSample(float2 uv) {
				if (uv.x > 1 || uv.x < 0 || uv.y > 1 || uv.y < 0) {
					return float4(0, 0, 0, 1);
				}

				return tex2D(_MainTex, uv);
			}

			float4 DrawScanline(float2 uv, float size, float gap, float offset) {
				float texel_height = 1.0 / _height;
				float texel_width = 1.0 / _width;

				float pixel_size_y = texel_height * size;
				float pixel_gap_y = texel_height * gap;

				float pixel_size_x = texel_width * size;
				float pixel_gap_x = texel_width * gap;

				float modded_v = abs(uv.y) % pixel_gap_y;
				float modded_u = abs(uv.x) % pixel_gap_x;
				
				return modded_v < pixel_size_y || modded_u < pixel_size_x  ? float4(0.5, 0.5, 0.5, 1) : float4(1, 1, 1, 1);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float ca_strength = 2.5;

				float2 dims = float2(_width, _height);

				float randval = rand(i.uv);

				float2 warped_uv = Warp(i.uv);

				float2 r_uv = warped_uv + (1 / dims) * ca_strength;
				float2 g_uv = warped_uv + (1 / dims) * ca_strength * 1.5;
				float2 b_uv = warped_uv + (1 / dims) * -ca_strength * 1.5;

				float col_r = ClampedSample(r_uv).r;
				float col_g = ClampedSample(g_uv).g;
				float col_b = ClampedSample(b_uv).b;

				fixed4 col = fixed4(col_r, col_g, col_b, 1) * Vignette(i.uv);

				//return DrawScanline(i.uv, 5, sin(_t));

				col *= DrawScanline(i.uv, 2, 5, sin(_t));
				return col;
			}
			ENDCG
		}
	}
}
