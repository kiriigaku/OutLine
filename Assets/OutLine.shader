Shader "ToonShading/OutLine"
{

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

	CGINCLUDE		
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float4 _MainTex_ST;
	float4 _EdgeColor;
	sampler2D _CameraDepthTexture;	  // Depth texture
	sampler2D _CameraGBufferTexture0; // Diffuse color (RGB), unused (A)
	sampler2D _CameraGBufferTexture1; // Specular color (RGB), roughness (A)
	sampler2D _CameraGBufferTexture2; // World space normal (RGB), unused (A) textureなので0~1
	sampler2D _CameraGBufferTexture3; // AGRBHalf (HDR) format: Emission + lighting + lightmaps + reflection probes buffer	


	//http://ramemiso.hateblo.jp/entry/2013/10/20/001909
	float Sobel(float2 uv, sampler2D tex, float weight){
		float2 _uv = float2(1/_ScreenParams.x, 1/_ScreenParams.y);

		//水平方向
		float4 h0 = tex2D(tex, uv+float2(-1*_uv.x, _uv.y)) * -1.0;
    	float4 h1 = tex2D(tex, uv+float2(-1*_uv.x, 0)) * -2.0;
    	float4 h2 = tex2D(tex, uv+float2(-1*_uv.x, -1*_uv.y)) * -1.0;
    	float4 h3 = tex2D(tex, uv+float2(_uv.x, _uv.y)) * 1.0;
    	float4 h4 = tex2D(tex, uv+float2(_uv.x, 0)) * 2.0;
    	float4 h5 = tex2D(tex, uv+float2(_uv.x, -1*_uv.y)) * 1.0;
    	float4 h = h0 + h1 + h2 + h3 + h4 + h5;
    
    	// 垂直方向
   		float4 v0 = tex2D(tex, uv+float2(-1*_uv.x, _uv.y)) * -1.0;
    	float4 v1 = tex2D(tex, uv+float2(0, _uv.y)) * -2.0;
   		float4 v2 = tex2D(tex, uv+float2(_uv.x, _uv.y)) * -1.0;
    	float4 v3 = tex2D(tex, uv+float2(-1*_uv.x, -1*_uv.y)) * 1.0;
    	float4 v4 = tex2D(tex, uv+float2(0, -1*_uv.y)) * 2.0;
    	float4 v5 = tex2D(tex, uv+float2(_uv.x, -1*_uv.y)) * 1.0;
    	float4 v = v0 + v1 + v2 + v3 + v4 + v5;
    
    	float edge = sqrt(dot(h,h) + dot(v,v));
    	edge = step(edge, weight);

    	return edge;
	}
			
	float4 frag (v2f_img i) : SV_Target
	{
		// sample the texture
		float4 _normal = tex2D(_CameraGBufferTexture2, i.uv);
		float4 col = tex2D(_MainTex, i.uv);

		float normal_edge = Sobel(i.uv, _CameraGBufferTexture2, 0.9);
		float depth_edge = Sobel(i.uv, _CameraDepthTexture, 0.9);

		if(normal_edge == 0 || depth_edge == 0){
			return _EdgeColor;
		}
		return col;
	}
	ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Geometry"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			ENDCG
		}
	}
}
