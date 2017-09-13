Shader "Custom/Waves 2"
{
	Properties
	{
		_Color("", Color) = (1,1,1,1)
		_MainTex("Color", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_OffsetScale("RippleFade",Range(0,10)) = 1
		_Smoothing("Smoothing",Range(0,1)) = 0.5 //in case we want to recalc. normals
	
		A ("Amplitude", Float) = 0.5 //amplitude
		L ("Wavelength", Float) = 1 //wavelength
		S ("Speed", Float) = 0.1 //speed
		Q ("Steepness", Range(0,1)) = 0.5 //steepness
		i ("Number of Waves",Range(1,10)) = 1 //number of waves
		D ("Wave Direction", Vector) = (0.5,0.0,0.5,0.0) //wave direction

	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		//Cull Off

		CGPROGRAM

//#pragma surface surf Standard vertex:vert nolightmap  addshadow alpha:fade 
// Physically based Standard lighting model, and enable shadows on all light types
	#pragma surface surf Standard vertex:vert fullforwardshadows
	#pragma target 3.0

//#include "Common.cginc"

	struct Input { 
		float2 uv_MainTex : TEXCOORD0;
		float3 worldPos;
		float3 worldRefl;
		//float dummy; 
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;

	sampler2D _MainTex;

	float _OffsetScale = 1;
	float _Smoothing; //in case we want to calculate normals and smooth them

	float3 _DisplaceTarget;

	float A = 0.5; //amplitude
	float L = 1; //wavelength
	float S = 0.1; //speed
	float Q = 0.5; //steepness
	float i = 1; //number of waves
	float2 D = float2(0.5,0.5); //wave direction
	float w;

	//w = 2/L
	float freq(float wavelength){
		return 2/L;
	}

	float QA(float w){
		i = ceil(i);
		//return A;
		return A*Q/(w*A*i);
	}

	float phaseConstant(float speed){
		return speed * w * _Time.y;
	}

	float gInner(float3 pos){
		return dot(D,pos.xz) * w + phaseConstant(S);
		
		//return sin(posXY.x)*A;
	}

	float3 gerstnerWave(float3 pos){
		w = freq(L);
		//D = normalize(D);
		float ampCalc = QA(w);
		float waveCalc = gInner(pos);
		pos.x += ampCalc * D.x * cos(waveCalc);
		pos.z += ampCalc * D.y * cos(waveCalc);
		pos.y += A * sin(waveCalc);

		return pos;
	}

	float sinNormal(float3 P){
		return sin(dot(D,P)* w * phaseConstant(S));
	}

	float3 waveNormal(float3 wavePos){
		float normalCalc = gInner(wavePos);
		float x = -1 * D.x * w * A * cos(normalCalc);
		float z = -1 * D.y * w * A * cos(normalCalc);
		float y = 1-(Q * w * A * sin(normalCalc));

		return float3(x,y,z);
	}

	void vert(inout appdata_full v)
	{	
		float3 wsVertex = mul(unity_ObjectToWorld, v.vertex).xyz;
		
		//for ripples from point:
		D = D - wsVertex.xz;// - D;
		//ripple fade out
		A *= saturate(1*_OffsetScale-length(D))+0.00001;

		//Swap in this for waves
		//D = normalize(D);

		wsVertex = gerstnerWave(wsVertex);

		//get a vector to the target, and the magnitude
		//float3 vecToTarget = _DisplaceTarget - wsVertex;
		//float lenToTarget = length(vecToTarget);
		
		//move each vertex along vector toward target, 
		//scaled by the distance of this vertex from the target
		//and the Offset scale (parameter set in material inspector)
		//wsVertex += normalize(vecToTarget) / lenToTarget *_OffsetScale;

		v.vertex.xyz = wsVertex;
		//v.vertex = mul(unity_ObjectToWorld, v.vertex);
		v.normal.xyz += waveNormal(wsVertex);
	}

	void surf(Input IN, inout SurfaceOutputStandard o)
	{
		o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Color.rgb;
		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness;
		o.Emission = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, WorldReflectionVector (IN, o.Normal));

		float colVal = saturate((1 - tex2D(_MainTex, IN.uv_MainTex).b) * 10); //make blue alpha .. but wrong blue for now
		o.Alpha = 1;
	}

	ENDCG
	}
		FallBack "Diffuse"
}