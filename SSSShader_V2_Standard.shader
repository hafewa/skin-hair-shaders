Shader "Skin/Skin V2 Standard" {
	Properties {
		[Header(Main Textures)]
		_Color ("Color", Color) = (0.8,0.8,0.8,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTex ("Normal Map", 2D) = "bump" {}

		[Space]
		[Header(Specularity)]
		_SpecPower  ("Specular Power", Float) = 10
		_SpecularValue("Specular Value", Range(0,1)) = 1.0

		[Space]
		[Header(Subsurface Scattering)]
		[HDR] _SSSColor ("SSS Color", Color) = (1,0,0,1)
		_SSSPower ("SSS Power", Float) = 1
		_SSSAmb ("SSS Ambient", Float) = 0.25
		_SSSDist ("SSS Distortion", Float) = 0.5
		_SSSTex ("SSS Map", 2D) = "white" {}

		[Space]
		[Header(Details)]
		_DetailNormalTex ("Detail Normal Map", 2D) = "bump" {}
		_DetailNormalMapIntensity ("Detail Normal Map Intensity", Range(-10,10)) = 1
		_DetailNormalMapStrength ("Detail Normal Map Strength", Range(0,1)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf StandardSSS fullforwardshadows
		#pragma target 3.0
		#include "Translucency.cginc"
		#include "UnityPBSLighting.cginc"


		struct Input {
			float2 uv_MainTex;
			float2 uv_DetailNormalTex;
		};

		sampler2D _MainTex;
		sampler2D _NormalTex;
		sampler2D _SSSTex;
		sampler2D _DetailNormalTex;
		fixed4 _Color;
//		fixed4 _SpecularColor;
		half _SpecularValue;
		half _SpecPower;
		fixed4 _SSSColor;
		half _SSSPower;
		half _SSSAmb;
		half _SSSDist;
		half _DetailNormalMapIntensity;
		half _DetailNormalMapStrength;

		half _Attenuation;

		fixed4 LightingStandardSSS (SurfaceOutputStandard s, half3 viewDir, UnityGI gi) {

			half3 lightDir = gi.light.dir;
//			half atten = gi.light.atten;
			//half atten = lightDir;
			half atten = _Attenuation;

//			half NdotL = dot (s.Normal, lightDir);
//
//			half3 reflectionVector = normalize(2.0 * s.Normal * NdotL - lightDir);
//			half spec = pow(max(0, dot(reflectionVector, viewDir)), _SpecPower);
//			half3 finalSpec = _SpecularValue * spec;


			half translucency = Translucency(s.Normal, lightDir, viewDir, atten, _SSSPower, _SSSAmb, _SSSDist, s.Alpha);


//		 	half4 c;
//		 	c.rgb = s.Albedo * _LightColor0.rgb * (
//		 		finalSpec * atten + 
//				saturate(NdotL) * atten 
//				+ translucency * _SSSColor
//				);
//			return c;

			fixed4 pbr = LightingStandard(s, viewDir, gi);
			pbr += translucency * _SSSColor * (gi.light.color,1);
			return pbr;
		}
 
		void LightingStandardSSS_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi)
		{
			_Attenuation = data.atten;
			LightingStandard_GI(s, data, gi); 
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Hiding translucency tex in alpha
			o.Alpha = tex2D (_SSSTex, IN.uv_MainTex);


			fixed3 n = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex));
			fixed3 nD = UnpackNormal(tex2D(_DetailNormalTex, IN.uv_DetailNormalTex));
			nD.x *= _DetailNormalMapIntensity;
			nD.y *= _DetailNormalMapIntensity;
			o.Normal = normalize(lerp(n, nD, _DetailNormalMapStrength));

			o.Smoothness = _SpecularValue;
			o.Metallic = 0;

		}
		ENDCG
	}
	FallBack "Diffuse"
}