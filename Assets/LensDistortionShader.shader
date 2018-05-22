// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/LensDistortionShader"
{
	Properties
	{
		// Declare Property to adjust smoothing factor
		_Factor ("Factor", Range(0, 5)) = 1.0
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
                float4 vertex : SV_POSITION;
                float4 grabPosUV : TEXCOORD0;
            };
			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;
            // VERTEX SHADER
            v2f vert (appdata v)
            {
                v2f o;
                // use UnityObjectToClipPos from UnityCG.cginc to calculate 
                // the clip-space of the vertex
                //o.pos = UnityObjectToClipPos(v.vertex);

                // use ComputeGrabScreenPos function from UnityCG.cginc
                // to get the correct texture coordinate
                //o.grabPosUV = ComputeGrabScreenPos(o.pos);

				o.vertex = UnityObjectToClipPos(v.vertex);
				float3x3 intrinsicCameraMatrix_inverse= {1, 0, -_GrabTexture_TexelSize.z/2, 0, 1, -_GrabTexture_TexelSize.w/2, 0, 0, 1};
				float3x3 intrinsicCameraMatrix= {1, 0, _GrabTexture_TexelSize.z/2, 0, 1, _GrabTexture_TexelSize.w/2, 0, 0, 1};
				o.vertex = mul(v.vertex, intrinsicCameraMatrix_inverse);

				int k1 = 1;
				int k2 = 1;
				int p1 = 1;
				int p2 = 1;
				float distance_x = abs(_GrabTexture_TexelSize.z - uv.x);
				float distance_y = abs(_GrabTexture_TexelSize.w - uv.y);
				float r = sqrt(distance_x * distance_x + distance_y * distance_y);
				float x = uv.x + uv.x * (k1 * pow(r,2) + k2 *pow(r,4)) + 2 * p1 * uv.x * uv.y + p2 * (pow(r,2)+2*pow(uv.x,2));
				float y = uv.y + uv.y * (k1 * pow(r,2) + k2 *pow(r,4)) + p1 * (pow(r,2) + 2 * pow(r,2)) + 2 * p2 * uv.x * uv.y;

				o.vertex = mul(intrinsicCameraMatrix, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);
				o.grabPosUV = ComputeGrabScreenPos(o.pos);
                return o;
            }

            // define effect variables to use in Fragement Shader
            sampler2D _GrabTexture;

            // Size information needed to access the pixels of the texture 
            // https://docs.unity3d.com/Manual/SL-PropertiesInPrograms.html
            float4 _GrabTexture_TexelSize;

            float _Factor;

            // FRAGMENT SHADER
            half4 frag (v2f i) : SV_Target
            {
 				//half4 pixelCol = half4(0, 0, 0, 0);

 				// Method to accumulate pixels in x direction
 				// x-Texture-Coord + Texel-Size * Kernel-Offset * Factor
 				//#define ADDPIXEL(k1, k2, p1, p2, radius) tex2D(_GrabTexture, float2(i.grabPosUV.x + _GrabTexture_TexelSize.x * kernelX * _Factor, \
                //											 						  i.grabPosUV.y + _GrabTexture_TexelSize.y * kernelY * _Factor)) * weight 

				// int k1 = 1;
				// int k2 = 1;
				// int p1 = 1;
				// int p2 = 1;
				// float distance_x = abs(_GrabTexture_TexelSize.z - i.grabPosUV.x);
				// float distance_y = abs(_GrabTexture_TexelSize.w - i.grabPosUV.y);
				// float r = sqrt(distance_x * distance_x + distance_y * distance_y);
				// float x = i.grabPosUV.x + i.grabPosUV.x * (k1 * pow(r,2) + k2 *pow(r,4)) + 2 * p1 * i.grabPosUV.x * i.grabPosUV.y + p2 * (pow(r,2)+2*pow(i.grabPosUV.x,2));
				// float y = i.grabPosUV.y + i.grabPosUV.y * (k1 * pow(r,2) + k2 *pow(r,4)) + p1 * (pow(r,2) + 2 * pow(r,2)) + 2 * p2 * i.grabPosUV.x * i.grabPosUV.y;
				// pixelCol = tex2D(_GrabTexture, float2(x, y));
														
				// //pixelCol 
                // return pixelCol;

				fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
	}
}
