Shader "Custom/SineRippleBasic" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_WaveLength ("WaveLength", Range(0.0001,1)) = 0.02
		_WaveHeight ("Wave Height", Range(0,1)) = 0.02
		_FadeDistance ("Fade Distance", Range(0,10)) = 5
		_Speed("Ripple Speed", Range(0,10)) = 2
		_Steepness("Ripple Steepness", Range(0,10)) = 2
		_NoiseSize ("Noise Size", Range(0,5)) = 0.7
		_NoiseStrength ("Noise Strength", Range(0,0.1)) = 0.02
		_NormalSmoothing("Normal Smoothing",Float) = 0.005
		_Center("Ripple Center",Vector) = (0,0,0,0)

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		#include "noise.cginc"

		sampler2D _MainTex;
		sampler2D _BumpMap;
		samplerCUBE _Cube;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 worldPos;
			float3 worldRefl;
			INTERNAL_DATA
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		half _WaveLength;
		half _WaveHeight;
		half _FadeDistance;
		half _Speed;
		half _Steepness;
		half _NoiseSize;
		half _NoiseStrength;
		float _NormalSmoothing;

		float3 _Center;


		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		float getFreq(float w){
			return 1/w;
		}

		float getRippleHeight(float3 vert, float3 center){
			float dist = length(vert.xz-center.xz);
			//float noiseSize = 0.7;
			//float noiseStrength = 0.04;
			dist += saturate(snoise(vert.xz*_NoiseSize+float2(_Time.x,_Time.y))*_NoiseStrength);
			float falloff = clamp((_FadeDistance - dist),0,_FadeDistance);
			falloff*=falloff;

			float wave = (sin(pow(dist,2)*getFreq(_WaveLength)-_Time.y*_Speed)+1)/2;

			int invert = -1;
			return falloff * _WaveHeight * pow(wave,_Steepness)*invert;
		}

		float3 addRipple(float3 vert){
			vert.y += getRippleHeight(vert,_Center);
			return vert;
		}


		void vert(inout appdata_full v){
			float3 vert = mul(unity_ObjectToWorld, v.vertex).xyz;
			_Center = mul(unity_ObjectToWorld, _Center).xyz;
			float3 uv0 = addRipple(vert);
			//float3 vert = v.vertex.xyz;
			//vert.y += getRippleHeight(vert,center);
			//vert = mul(unity_ObjectToWorld, vert);


			float3 normalOffset = float3(_NormalSmoothing,0,0);

			float3 uv1 = vert+normalOffset;
			uv1 = addRipple(uv1);
			float3 uv2 = vert+normalOffset.zyx;
			uv2 = addRipple(uv2);

			float3 normal = normalize(cross(uv2-uv0,uv1-uv0));

			//v.vertex.xyz = uv0;
			v.vertex.xyz = vert;
			v.normal.xyz = normal;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			//o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));

			//c = sin(length(IN.uv_MainTex-_Center.xz)*getFreq(_WaveLength)-_Time.y*_Speed);
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Emission = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, WorldReflectionVector (IN, o.Normal)).rgb*0.1;

			o.Alpha = 1;//c.a;
			
		}
		ENDCG
	}
	FallBack "Diffuse"
}
