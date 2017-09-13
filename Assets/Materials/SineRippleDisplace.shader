Shader "Custom/SineRippleDisplace" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		
		_A ("Amplitude", Float) = 0.5 //amplitude
		_L ("Wavelength", Float) = 1 //wavelength
		_S ("Speed", Float) = 0.1 //speed
		_Q ("Steepness", Range(0,1)) = 0.5 //steepness
		_i ("Number of Waves",Range(1,10)) = 1 //number of waves
		_O ("Ripple Source", Vector) = (0.5,0.0,0.5,0.0) //wave direction
		
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float _A; //amplitude
		float _L; //wavelength
		float _S; //speed
		float _Q; //steepness	
		float3 _O; //wave source

		//w = 2/L
		float freq(float wavelength){
			return 2/wavelength;
		}

		float gInner(float3 pos,float2 D, float w, float phaseConstant){
		
			return dot(D,pos.xz) * w + phaseConstant;
		}

		void vert(inout appdata_full v){
			float3 vert = mul(unity_ObjectToWorld, v.vertex).xyz;//v.vertex.xyz*_SeaScale;//
			float3 norm = v.normal.xyz;

			float3 D = _O;//vert - _O;
			float w = freq(_L);
			float phaseConst = _S * w * _Time.y;

			float3 wavePos = 0;
			wavePos.x = _A * sin(gInner(vert,D,w,phaseConst));
			wavePos.z = _A * sin(gInner(vert,D,w,phaseConst));

			v.vertex.xyz += wavePos;

		}

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

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
