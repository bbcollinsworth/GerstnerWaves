Shader "Custom/Waves" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		/*
		A ("Amplitude", Float) = 0.5 //amplitude
		L ("Wavelength", Float) = 1 //wavelength
		S ("Speed", Float) = 0.1 //speed
		Q ("Steepness", Range(0,1)) = 0.5 //steepness
		i ("Number of Waves",Range(1,10)) = 1 //number of waves
		D ("Wave Direction", Vector) = (0.5,0.0,0.5,0.0) //wave direction
		*/
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		//Cull Off
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert nolightmap  addshadow alpha:fade

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input { 
			float2 uv_MainTex : TEXCOORD0;
			float dummy; 
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END


	float _OffsetScale = 1;
	float _Smoothing; //in case we want to calculate normals and smooth them

	float3 _DisplaceTarget;

	/*
	float A = 0.5; //amplitude
	float L = 1; //wavelength
	float S = 0.1; //speed
	float Q = 0.5; //steepness
	float i = 1; //number of waves
	float2 D = float2(0.5,0.5); //wave direction


	//w = 2/L
	float freq(float wavelength){
		return 2*UNITY_PI/wavelength;
	}

	float QA(float w){
		i = ceil(i);
		return A;
		//return Q/(w*A*2*UNITY_PI*i);
	}

	float phaseConstant(float speed, float w){
		return speed * w;
	}

	float gerstnerDistort(float2 posXY, float dComponent){
		float w = freq(L);
		//return QA(w) * dComponent * sin(dot(D,posXY) * w + _Time.y * phaseConstant(S,w));
		return sin(posXY.x)*A;
	}

	float3 gerstnerWave(float3 pos){
		
		D = normalize(D);
		//pos.x += gerstnerDistort(pos.xz,D.x);
		//pos.z += gerstnerDistort(pos.xz,D.y);
		pos.z += gerstnerDistort(pos.xz,D.x);

		return pos;
	}
	*/

	void vert(inout appdata_full v)
	{	
		float3 wsVertex = v.vertex.xyz;//mul(unity_ObjectToWorld, v.vertex);
		//wsVertex = gerstnerWave(wsVertex);

		//get a vector to the target, and the magnitude
		float3 vecToTarget = _DisplaceTarget - wsVertex;
		float lenToTarget = length(vecToTarget);
		
		//move each vertex along vector toward target, 
		//scaled by the distance of this vertex from the target
		//and the Offset scale (parameter set in material inspector)
		wsVertex += normalize(vecToTarget) / lenToTarget *_OffsetScale;

		v.vertex.xyz = wsVertex;

	}

	void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
	}
	ENDCG
	}
	FallBack "Diffuse"
}
