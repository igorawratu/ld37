Shader "Text"
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

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float aspect = _width / _height;
				o.uv -= float2(0.5, 0.5);
				o.uv.x *= aspect;

				o.uv += float2(0.5, 0.5);

				return o;
			}

			float4 DrawLine(float2 p, float2 pos1, float2 pos2, float thickness) {
				float2 dir = pos1 - pos2;
				float2 newp = p - pos2;

				float scalar_proj = dot(dir, newp) / length(dir);
				float2 proj = scalar_proj * normalize(dir);

				float2 d1 = proj - dir;
				float2 d2 = proj;

				float end_dot = dot(d1, d2);

				if (end_dot > 0) {
					float dist1 = length(d1);
					float dist2 = length(d2);

					proj = dist1 > dist2 ? float2(0, 0) : pos1 - pos2;
				}

				float aspect = _width / _height;
				float2 dif = (newp - proj)/* * float2(aspect, 1.0)*/;
				float dist = length(dif);

				//return dist;

				return dist < thickness ? float4(1, 1, 1, 1) : float4(0, 0, 0, 1);
			}

			float4 Draw1(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(0.0, 0.1) * size;
				float2 p2 = pos + float2(0.0, -0.1) * size;

				return DrawLine(uv, p1, p2, thickness);
			}

			float4 Draw2(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(-0.05, 0.1) * size;
				float2 p2 = pos + float2(0.05, 0.1) * size;
				float2 p3 = pos + float2(0.05, 0.0) * size;
				float2 p4 = pos + float2(-0.05, 0.0) * size;
				float2 p5 = pos + float2(-0.05, -0.1) * size;
				float2 p6 = pos + float2(0.05, -0.1) * size;

				float4 col = DrawLine(uv, p1, p2, thickness);
				col = max(col, DrawLine(uv, p2, p3, thickness));
				col = max(col, DrawLine(uv, p3, p4, thickness));
				col = max(col, DrawLine(uv, p4, p5, thickness));
				col = max(col, DrawLine(uv, p5, p6, thickness));

				return col;
			}

			float4 Draw3(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(0.05, 0.1) * size;
				float2 p2 = pos + float2(0.05, -0.1) * size;
				float2 p3 = pos + float2(-0.05, 0.1) * size;
				float2 p4 = pos + float2(-0.05, 0.0) * size;
				float2 p5 = pos + float2(0.05, 0.0) * size;
				float2 p6 = pos + float2(-0.05, -0.1) * size;

				float4 col = DrawLine(uv, p1, p2, thickness);
				col = max(col, DrawLine(uv, p3, p1, thickness));
				col = max(col, DrawLine(uv, p4, p5, thickness));
				col = max(col, DrawLine(uv, p6, p2, thickness));

				return col;
			}

			float4 Draw4(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(-0.05, 0.1) * size;
				float2 p2 = pos + float2(-0.05, 0.0) * size;
				float2 p3 = pos + float2(0.05, 0.1) * size;
				float2 p4 = pos + float2(0.05, 0.0) * size;
				float2 p5 = pos + float2(0.05, -0.1) * size;

				float4 col = DrawLine(uv, p1, p2, thickness);
				col = max(col, DrawLine(uv, p2, p4, thickness));
				col = max(col, DrawLine(uv, p3, p5, thickness));

				return col;
			}

			float4 Draw5(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(-0.05, 0.1) * size;
				float2 p2 = pos + float2(0.05, 0.1) * size;
				float2 p3 = pos + float2(0.05, 0.0) * size;
				float2 p4 = pos + float2(-0.05, 0.0) * size;
				float2 p5 = pos + float2(-0.05, -0.1) * size;
				float2 p6 = pos + float2(0.05, -0.1) * size;

				float4 col = DrawLine(uv, p1, p2, thickness);
				col = max(col, DrawLine(uv, p1, p4, thickness));
				col = max(col, DrawLine(uv, p4, p3, thickness));
				col = max(col, DrawLine(uv, p3, p6, thickness));
				col = max(col, DrawLine(uv, p5, p6, thickness));

				return col;
			}

			float4 Draw6(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(-0.05, 0.1) * size;
				float2 p2 = pos + float2(0.05, 0.1) * size;
				float2 p3 = pos + float2(0.05, 0.0) * size;
				float2 p4 = pos + float2(-0.05, 0.0) * size;
				float2 p5 = pos + float2(-0.05, -0.1) * size;
				float2 p6 = pos + float2(0.05, -0.1) * size;

				float4 col = DrawLine(uv, p1, p2, thickness);
				col = max(col, DrawLine(uv, p1, p5, thickness));
				col = max(col, DrawLine(uv, p4, p3, thickness));
				col = max(col, DrawLine(uv, p3, p6, thickness));
				col = max(col, DrawLine(uv, p5, p6, thickness));

				return col;
			}

			float4 Draw7(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(-0.05, 0.1) * size;
				float2 p2 = pos + float2(0.05, 0.1) * size;
				float2 p3 = pos + float2(0.05, -0.1) * size;

				float4 col = DrawLine(uv, p1, p2, thickness);
				col = max(col, DrawLine(uv, p2, p3, thickness));

				return col;
			}

			float4 Draw8(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(-0.05, 0.1) * size;
				float2 p2 = pos + float2(0.05, 0.1) * size;
				float2 p3 = pos + float2(0.05, 0.0) * size;
				float2 p4 = pos + float2(-0.05, 0.0) * size;
				float2 p5 = pos + float2(-0.05, -0.1) * size;
				float2 p6 = pos + float2(0.05, -0.1) * size;

				float4 col = DrawLine(uv, p1, p2, thickness);
				col = max(col, DrawLine(uv, p1, p5, thickness));
				col = max(col, DrawLine(uv, p4, p3, thickness));
				col = max(col, DrawLine(uv, p2, p6, thickness));
				col = max(col, DrawLine(uv, p5, p6, thickness));

				return col;
			}

			float4 Draw9(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(-0.05, 0.1) * size;
				float2 p2 = pos + float2(0.05, 0.1) * size;
				float2 p3 = pos + float2(0.05, 0.0) * size;
				float2 p4 = pos + float2(-0.05, 0.0) * size;
				float2 p5 = pos + float2(-0.05, -0.1) * size;
				float2 p6 = pos + float2(0.05, -0.1) * size;

				float4 col = DrawLine(uv, p1, p2, thickness);
				col = max(col, DrawLine(uv, p1, p4, thickness));
				col = max(col, DrawLine(uv, p4, p3, thickness));
				col = max(col, DrawLine(uv, p2, p6, thickness));
				col = max(col, DrawLine(uv, p5, p6, thickness));

				return col;
			}

			float4 Draw0(float2 uv, float2 pos, float thickness, float size)
			{
				float2 p1 = pos + float2(-0.05, 0.1) * size;
				float2 p2 = pos + float2(0.05, 0.1) * size;
				float2 p3 = pos + float2(0.05, -0.1) * size;
				float2 p4 = pos + float2(-0.05, -0.1) * size;

				float4 col = DrawLine(uv, p1, p2, thickness);
				col = max(col, DrawLine(uv, p2, p3, thickness));
				col = max(col, DrawLine(uv, p3, p4, thickness));
				col = max(col, DrawLine(uv, p4, p1, thickness));

				return col;
			}

			uint NumDigits(uint i)
			{
				return i > 0 ? (uint)log10(i) + 1 : 1;
			}

			float4 DrawDigit(uint digit, float size, float2 pos, float2 uv) {
				float texelWidth = 1.0 / _width;
				float thickness = texelWidth * 10;

				switch (digit) {
					case 0:
						return Draw0(uv, pos, thickness, size);
					case 1:
						return Draw1(uv, pos, thickness, size);
					case 2:
						return Draw2(uv, pos, thickness, size);
					case 3:
						return Draw3(uv, pos, thickness, size);
					case 4:
						return Draw4(uv, pos, thickness, size);
					case 5:
						return Draw5(uv, pos, thickness, size);
					case 6:
						return Draw6(uv, pos, thickness, size);
					case 7:
						return Draw7(uv, pos, thickness, size);
					case 8:
						return Draw8(uv, pos, thickness, size);
					case 9:
						return Draw9(uv, pos, thickness, size);
					default:
						return float4(0, 0, 0, 1);
				}
			}

			float4 DrawNumber(uint number, float size, float2 uv, float2 pos) {
				uint digits = NumDigits(number);
				float4 col = float4(0, 0, 0, 0);

				for (int i = 0; i < digits; ++i) {
					uint div_by = pow(10, digits - i - 1);
					float2 currPos = float2(size * 0.15 * i + pos.x, pos.y);
					uint digit = (number / div_by) % 10;

					col = max(col, DrawDigit(digit, size, currPos, uv));
				}

				return col;
			}

			float _t;

			float4 Overwrite(float3 col, float3 newcol) {
				return length(newcol) > 0 ? float4(newcol, 1) : float4(col, 1);
			}

			float4 DrawCircle(float4 col, float2 uv, float2 pos, float size) {
				float texelWidth = 1.0 / _width;
				float pix_size = size * texelWidth;

				float dist = length(pos - uv);

				return dist < pix_size ? col : float4(0, 0, 0, 1);
			}


			float4 DrawPerson(float2 uv, float2 pos) 
			{
				float4 col = float4(0, 0, 0, 1);

				col = DrawCircle(float4(1, 1, 1, 1), uv, pos, 100);
				col = Overwrite(col.xyz, DrawCircle(float4(1, 1, 0, 1), uv, pos, 50).xyz);

				return col;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				//return DrawNumber((uint)(_t * 1000), 0.5, i.uv, float2(0.1, 0.8));
				return DrawPerson(i.uv, float2(0.5, 0.5));
			}
			ENDCG
		}
	}
}
