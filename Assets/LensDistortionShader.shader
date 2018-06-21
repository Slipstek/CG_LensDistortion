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

            // FRAGMENT SHADER
            half4 frag (v2f i) : SV_Target
            {
				// Distance to texture center (total width and length of texture is 1)
				float distance_x = 0.5;
				float distance_y = 0.5;
				// Get pixel x position and subtract half of texture size to center it in x scale
				float uu = i.grabPosUV.x - distance_x;
				// Swap pixel side in y direction as distortion algorithms y axis directs in opposite direction of unitys y axis
				float vu = 1 - i.grabPosUV.y;
				// Get pixel y position and subtract half of texture size to center it in y scale
				vu = vu - distance_y;

				// Calculate pixel distance from texture center
				float r = sqrt(uu * uu + vu * vu);
				// Precalculate power of 2 and 4 of pixel distance to texture center
				float r2 = pow(r, 2);
				float r4 = pow(r, 4);
				// Brown-Conrady distortion algorithm
				// Calculate radial distortion
				float ud = uu + uu * (_Factor_K1 * r2 + _Factor_K2 * r4) + 2 * _Factor_P1 * uu * vu + _Factor_P2 * (r2 + 2 * pow(uu,2));
				// Calculate tangential distortion
				float vd = vu + vu * (_Factor_K1 * r2 + _Factor_K2 * r4) + _Factor_P1 * (r2 + 2 * r2) + 2 * _Factor_P2 * uu * vu;
                // Move pixel back to actual position
				ud = ud + distance_x;
				vd = vd + distance_y;
				// Swap y axis again
				vd = 1 - vd;
			    // Return manipulated pixel
			    return tex2D(_GrabTexture, float2(ud, vd));
            }
            ENDCG
        }
	}
}
