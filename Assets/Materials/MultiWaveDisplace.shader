Shader "Custom/MultiWaves"
{
	Properties
	{
		_Color("", Color) = (1,1,1,1)
		_MainTex("Color", 2D) = "white" {}
		_UVTex("UV Map", 2D) = "white" {}
		_Cube ("Reflection Cubemap", CUBE) = "" {}
		_ScrollSpeed("Scroll Speed",Range(-1,1)) = 0.1
		_SeaScale("Sea Scale",Range(0,10)) = 1
		_HeightRange("Height Range",Range(0.1,10)) = 1
		_Smoothing("Smoothing",Range(0,4)) = 0.5 //in case we want to recalc. normals
		_Glossiness("Glossiness",Range(0,1)) = 0.5
		_Metallic("Metallic",Range(0,1)) = 0.5
		/*
		A ("Amplitude", Float) = 0.5 //amplitude
		L ("Wavelength", Float) = 1 //wavelength
		S ("Speed", Float) = 0.1 //speed
		Q ("Steepness", Range(0,1)) = 0.5 //steepness
		i ("Number of Waves",Range(1,10)) = 1 //number of waves
		D ("Wave Direction", Vector) = (0.5,0.0,0.5,0.0) //wave direction
		*/
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		Cull Off

		CGPROGRAM

#pragma surface surf Standard vertex:vert nolightmap  addshadow alpha:fade 
#pragma target 3.0

//#include "Common.cginc"

	struct Input { 
		float2 uv_MainTex : TEXCOORD0;
		float2 uv_UVTex;
		float3 worldPos;
		float3 worldRefl;
        INTERNAL_DATA
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;

	sampler2D _MainTex;
	sampler2D _UVTex;
	samplerCUBE _Cube;

	float _OffsetScale = 1;
	float _ScrollSpeed;
	float _Smoothing; //in case we want to calculate normals and smooth them

	float3 _DisplaceTarget;
	float _SeaScale;
	float _HeightRange;

	float _A[10]; //amplitude
	float _L[10]; //wavelength
	float _S[10]; //speed
	float _Q[10]; //steepness	
	float2 _D[10]; //wave direction
	//float w[10];

	int _i; //number of waves

	//w = 2/L
	float freq(float wavelength){
		return 2/wavelength;
	}

	float QA(float w, float Q, float A){
		//i = ceil(i);
		//return A;
		return A*Q/(w*A*_i);
	}

	//float phaseConstant(float speed){
	//	return speed * w * _Time.y;
	//}

	float gInner(float3 pos,float2 D, float w, float phaseConstant){
		
		return dot(D,pos.xz) * w + phaseConstant;
	}
	

	void vert(inout appdata_full v)
	{	
		float3 vert = mul(unity_ObjectToWorld, v.vertex).xyz;//v.vertex.xyz*_SeaScale;//
		float3 norm = v.normal.xyz;//mul(unity_ObjectToWorld, v.normal).xyz;

		for (int j = 0; j < _i; j++){

			float A = _A[j];
			float L = _L[j];
			float S = _S[j];
			float Q = _Q[j];
			float2 D = normalize(_D[j]);

			float w = freq(L);
			float phaseConst = S * w * _Time.y;
			
			float ampCalc = QA(w,Q,A);
			float waveCalc = gInner(vert,D,w,phaseConst);

			float3 wavePos = 0;
			wavePos.x = ampCalc * D.x * cos(waveCalc);
			wavePos.z = ampCalc * D.y * cos(waveCalc);
			wavePos.y = A * sin(waveCalc);

			vert += wavePos;

			float normalCalc = gInner(vert,D,w,phaseConst);

			norm.x += -1 * D.x * w * A * cos(normalCalc);
			norm.z += -1 * D.y * w * A * cos(normalCalc);
			norm.y += 1 - (Q * w * A * sin(normalCalc));
		}

		
		//norm.x*=-1;
		//norm.z*=-1;
		//norm.y = 1-norm.y;
		
		v.vertex.xyz = vert;
		v.normal.xyz = norm;
	}

	void surf(Input IN, inout SurfaceOutputStandard o)
	{
		float2 scroll = float2(_Time.y,_Time.y)*_ScrollSpeed;
		float2 uv = IN.uv_MainTex + scroll;
		float3 tex = tex2D(_MainTex, uv).r;
		
		float heightAdj = lerp(0.2,1,saturate(IN.worldPos.y+_HeightRange)/pow(_HeightRange,_Smoothing));
		tex *= heightAdj;
		o.Albedo = tex +_Color.rgb;
		o.Normal = saturate(UnpackNormal (tex2D (_UVTex, IN.uv_UVTex+scroll))*0.5 + (1.2-heightAdj)*float3(0,0,1.5)); 
		o.Metallic = _Metallic*tex;
		o.Smoothness = _Glossiness*tex;
		o.Emission = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, WorldReflectionVector (IN, o.Normal)).rgb*0.1;
		//float colVal = saturate((1 - tex2D(_MainTex, IN.uv_MainTex).b) * 10); //make blue alpha .. but wrong blue for now
		o.Alpha = 1;
	}

	ENDCG
	}
		FallBack "Diffuse"
}