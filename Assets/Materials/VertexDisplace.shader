Shader "Custom/Vertex Distortion"
{
	Properties
	{
		_Color("", Color) = (1,1,1,1)
		_MainTex("Color", 2D) = "white" {}
		_OffsetScale("Offset Scale",Range(0,10)) = 1
		_Smoothing("Smoothing",Range(0,1)) = 0.5 //in case we want to recalc. normals
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
		float dummy; 
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;

	sampler2D _MainTex;

	float _OffsetScale = 1;
	float _Smoothing; //in case we want to calculate normals and smooth them

	float3 _DisplaceTarget;


	void vert(inout appdata_full v)
	{	
		float3 wsVertex = v.vertex.xyz;//mul(unity_ObjectToWorld, v.vertex);

		//get a vector to the target, and the magnitude
		float3 vecToTarget = _DisplaceTarget - wsVertex;
		float lenToTarget = length(vecToTarget);
		
		//move each vertex along vector toward target, 
		//scaled by the distance of this vertex from the target
		//and the Offset scale (parameter set in material inspector)
		wsVertex += normalize(vecToTarget) / lenToTarget *_OffsetScale;

		v.vertex.xyz = wsVertex;

	}

	void surf(Input IN, inout SurfaceOutputStandard o)
	{
		o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;//_Color.rgb;
		o.Metallic = 0;// _Metallic;
		o.Smoothness = 0;// _Glossiness;
		float colVal = saturate((1 - tex2D(_MainTex, IN.uv_MainTex).b) * 10); //make blue alpha .. but wrong blue for now
		o.Alpha = 1;
	}

	ENDCG
	}
		FallBack "Diffuse"
}