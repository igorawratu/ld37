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
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
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
				float2 dif = (newp - proj) * float2(1.0, aspect);
				float dist = length(dif);

				//return dist;

				return dist < thickness ? float4(1, 1, 1, 1) : float4(0, 0, 0, 1);
			}

			float4 Draw1(float2 uv, float2 pos, float thickness) 
			{
				float2 p1 = pos + float2(0.0, 0.1);
				float2 p2 = pos + float2(0.0, -0.1);

				return DrawLine(uv, p1, p2, thickness);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				return Draw1(i.uv, float2(0.5, 0.5), _MainTex_TexelSize.x);
			}
			ENDCG
		}
	}
}
