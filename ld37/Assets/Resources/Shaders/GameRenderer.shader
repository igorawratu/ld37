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

			float4 DrawNumber(uint number, float size, float2 uv, float2 pos, float4 text_col, bool center) {
				uint digits = NumDigits(number);
				float4 col = float4(0, 0, 0, 0);

				float center_offset = center ? (float)digits / 2.0 : 0;

				for (int i = 0; i < digits; ++i) {
					uint div_by = pow(10, digits - i - 1);
					float2 currPos = float2(size * 0.15 * ((float)i - center_offset) + pos.x, pos.y);
					uint digit = (number / div_by) % 10;

					col = max(col, DrawDigit(digit, size, currPos, uv));
				}

				return col * text_col;
			}

			float _t;

			float2 Rotate(float2 p, float rotation) {
				float2 rotated;
				rotated.x = p.x * cos(rotation) - p.y * sin(rotation);
				rotated.y = p.y * cos(rotation) + p.x * sin(rotation);

				return rotated;
			}

			float AngleBetween(float2 p1, float2 p2) {
				return atan2(p2.x, p2.y) - atan2(p1.x, p1.y);
			}

			float4 Overwrite(float3 col, float3 newcol) {
				return length(newcol) > 0 ? float4(newcol, 1) : float4(col, 1);
			}

			float4 DrawCircle(float4 col, float2 uv, float2 pos, float size) {
				float texelWidth = 1.0 / _width;
				float pix_size = size * texelWidth;

				float dist = length(pos - uv);

				return dist < pix_size ? col : float4(0, 0, 0, 1);
			}

			float4 DrawEllipse(float4 col, float2 uv, float2 pos, float2 size, float rotation, float2 cor) {
				float texelWidth = 1.0 / _width;
				float2 pix_size = size * texelWidth;

				float2 fixed_uv = uv - cor;
				float2 rotated_uv = Rotate(fixed_uv, rotation) - cor + pos;

				float d = (rotated_uv.x * rotated_uv.x) / (pix_size.x * pix_size.x) + (rotated_uv.y * rotated_uv.y) / (pix_size.y * pix_size.y);

				return d <= 1 ? col : float4(0, 0, 0, 1);
			}


			float4 DrawPerson(float2 uv, float2 pos, float2 orientation, float4 hair_col, float4 shirt_col, float4 shoes_col, float size)
			{
				float texelWidth = 1.0 / _width;

				float PI = 3.14159265359;

				float4 col = float4(0, 0, 0, 1);

				float2 orig_orientation = float2(0, -1);
				float angle = AngleBetween(orig_orientation, normalize(orientation));

				//shoes
				col = DrawEllipse(shoes_col, uv, pos + size * float2(60 * texelWidth, 50 * texelWidth), size * float2(50, 100), angle, pos);
				col = Overwrite(col, DrawEllipse(shoes_col, uv, pos + size * float2(-60 * texelWidth, 50 * texelWidth), size * float2(50, 100), angle, pos));

				//body
				col = Overwrite(col, DrawEllipse(shirt_col, uv, pos, size * float2(200, 100), angle, pos));

				//head
				col = Overwrite(col, DrawCircle(hair_col, uv, pos, size * 100));

				return col;
			}

			float4 DrawRectangle(float4 col, float2 uv, float2 pos, float2 halfdims, float rotation, float2 cor) {
				float2 fixed_uv = uv - cor;
				float2 rotated_uv = Rotate(fixed_uv, rotation) - cor + pos;

				return abs(rotated_uv.x) <= halfdims.x && abs(rotated_uv.y) <= halfdims.y ? col : float4(0, 0, 0, 1);
			}

			float4 DrawPlant(float2 uv, float2 pos, float size) {
				float texelWidth = (1.0 / _width) * size;

				float4 col = float4(0, 0, 0, 1);

				col = Overwrite(col, DrawCircle(float4(0.7, 0.2, 0.2, 1), uv, pos, size));
				col = Overwrite(col, DrawCircle(float4(0.2, 0.75, 0.2, 1), uv, pos, size * 0.5));

				return col;
			}

			//room will always be 400x300 multiplied by size
			float4 DrawRoom(float2 uv, float2 pos, float size) {
				float4 col = float4(0, 0, 0, 1);
				float texelWidth = (1.0 / _width) * size;

				//floor
				col = Overwrite(col, DrawRectangle(float4(0.8, 0.8, 0.8, 1), uv, pos, float2(texelWidth * 200, texelWidth * 150), 0, pos));

				//walls
				float wall_thickness = 10 * texelWidth;

				float2 wall_x_offset = float2(texelWidth * 200 - wall_thickness / 2, 0);
				float2 wall_y_offset = float2(0, texelWidth * 150 - wall_thickness / 2);

				col = Overwrite(col, DrawRectangle(float4(0.3, 0.3, 0.3, 1), uv, pos + wall_x_offset, float2(wall_thickness, texelWidth * 150), 0, pos));
				col = Overwrite(col, DrawRectangle(float4(0.3, 0.3, 0.3, 1), uv, pos - wall_x_offset, float2(wall_thickness, texelWidth * 150), 0, pos));
				col = Overwrite(col, DrawRectangle(float4(0.3, 0.3, 0.3, 1), uv, pos + wall_y_offset, float2(texelWidth * 200, wall_thickness), 0, pos));
				col = Overwrite(col, DrawRectangle(float4(0.3, 0.3, 0.3, 1), uv, pos - wall_y_offset, float2(texelWidth * 200, wall_thickness), 0, pos));

				//benches
				col = Overwrite(col, DrawRectangle(float4(0.5, 0.3, 0.3, 1), uv, pos - (wall_y_offset * 0.75), float2(texelWidth * 150, 20 * texelWidth), 0, pos));
				col = Overwrite(col, DrawRectangle(float4(0.5, 0.3, 0.3, 1), uv, pos + (wall_y_offset * 0.75), float2(texelWidth * 150, 20 * texelWidth), 0, pos));

				//plants
				col = Overwrite(col, DrawPlant(uv, pos - (wall_x_offset * 0.85) - (wall_y_offset * 0.75), 20 * size));
				col = Overwrite(col, DrawPlant(uv, pos + (wall_x_offset * 0.85) + (wall_y_offset * 0.75), 20 * size));

				//table
				col = Overwrite(col, DrawRectangle(float4(0.1, 0.8, 0.8, 1), uv, pos, float2(texelWidth * 80, texelWidth * 60), 0, pos));

				return col;
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

			float4 DrawEndGame(float2 uv, float time) {
				return DrawNumber(time, 1, uv, float2(0.5, 0.5), float4(0.8, 0.2, 0.2, 1), true);
			}

			float4 DrawTimeScore(float2 uv, float score, float score_upper, float score_lower, float time_lower, float time_upper) {
				float aspect = _width / _height;
				float4 col = float4(0, 0, 0, 1);

				float4 time_col = float4(0.2, 0.8, 0.2, 1);
				float4 score_col = float4(0.8, 0.2, 0.2, 1);

				if (score < score_upper && score > score_lower) {
					score_col = float4(0.8, 0.8, 0.2, 1);
				}
				else if (score < score_lower) {
					score_col = float4(0.8, 0.2, 0.2, 1);
				}

				if (_t < time_upper && _t > time_lower) {
					score_col = float4(0.8, 0.8, 0.2, 1);
				}
				else if (_t < time_lower) {
					score_col = float4(0.2, 0.8, 0.2, 1);
				}

				col = Overwrite(col, DrawNumber(_t, 0.5, uv, float2(0.2 - (0.5 * (aspect / 2)), 0.9), time_col, false));
				col = Overwrite(col, DrawNumber(score, 0.5, uv, float2(0.5 - (0.5 * (aspect / 2)), 0.9), score_col, false));

				return col;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float4 col = float4(0.3, 0.3, 0.3, 1);
				//return DrawPlayer(i.uv);

				col = Overwrite(col, DrawEndGame(i.uv, 34049));
				col = Overwrite(col, DrawTimeScore(i.uv, _t, 25, 10, 5, 15));

				return col;
			}
			ENDCG
		}
	}
}
