// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/LensDistortionShader"
{
	Properties
	{
		// Declare Property to adjust smoothing factor
		_Factor_K1 ("K1", Range(-5, 5)) = 0.0
        _Factor_K2 ("K2", Range(-5, 5)) = 0.0
		_Factor_P1 ("P1", Range(-5, 5)) = 0.0
        _Factor_P2 ("P2", Range(-5, 5)) = 0.0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		// "Queue"="Transparent": Draw ourselves after all opaque geometry
		// "IgnoreProjector"="True": Don't be affected by any Projectors
		// "RenderType"="Transparent": Declare RenderType as transparent
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
       
        // Grab the screen behind the object into Default _GrabTexture
        // https://docs.unity3d.com/Manual/SL-GrabPass.html
        GrabPass
        {
            "_GrabTexture"
        }
       
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
                float4 pos : SV_POSITION;
                float4 grabPosUV : TEXCOORD0;
            };

            // VERTEX SHADER
            v2f vert (appdata v)
            {
                v2f o;
                // use UnityObjectToClipPos from UnityCG.cginc to calculate 
                // the clip-space of the vertex
                o.pos = UnityObjectToClipPos(v.vertex);

                // use ComputeGrabScreenPos function from UnityCG.cginc
                // to get the correct texture coordinate
                o.grabPosUV = ComputeGrabScreenPos(o.pos);
                return o;
            }

            // define effect variables to use in Fragement Shader

            // Size information needed to access the pixels of the texture 
            // https://docs.unity3d.com/Manual/SL-PropertiesInPrograms.html

            float _Factor_K1;
            float _Factor_K2;
			float _Factor_P1;
			float _Factor_P2;

			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;

            // FRAGMENT SHADER
            half4 frag (v2f i) : SV_Target
            {
 				half4 pixelCol = (0, 0, 0, 0);

				float k1 = _Factor_K1;
				float k2 = _Factor_K2;
				float p1 = _Factor_P1;
				float p2 = _Factor_P2;
				float distance_x = 0.5;
				float distance_y = 0.5;
				float r = sqrt(distance_x * distance_x + distance_y * distance_y);
				float uu = i.grabPosUV.x - distance_x;
				float vu = -i.grabPosUV.y + distance_y;
				float ud = uu + uu * (k1 * pow(r,2) + k2 * pow(r,4)) + 2 * p1 * uu * vu + p2 * (pow(r,2) + 2 * pow(uu,2));
				float vd = vu + vu * (k1 * pow(r,2) + k2 * pow(r,4)) + p1 * (pow(r,2) + 2 * pow(r,2)) + 2 * p2 * uu * vu;
                pixelCol = tex2D(_GrabTexture, float2(ud, -vd));
				//pixelCol = tex2D(_GrabTexture, float2(i.grabPosUV.x, i.grabPosUV.y));										
				//pixelCol 
                return pixelCol;

				//fixed4 col = tex2Dproj(_GrabTexture, i.grabPosUV);
                //return col;
            }
            ENDCG
        }
	}
}
