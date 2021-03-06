﻿Shader "Hair/Hair_Blend" {
	Properties {
		[Header(Main Textures)]
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Cutoff ("Cutoff", range(0,1)) = 0.5
		// [Toggle] _Dither("Dither", Float) = 0
        
        //_GradColor ("Gradient Color", Color) = (0,0,0,1)
        //_GradAxis ("Gradient Axis X -> Y", range(0,1)) = 0
        //_GradAddMult ("Gradient Add -> Multiply", range(0,1)) = 0

		[Space]
		[Header(Specularity)]
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_Specular ("Specular Amount", Range(0,1)) = 0.5
		_SpecPower ("Specular Power", Range(0,1)) = 0.15

		[Space]
		[Header(Anisotropy)]
		_AnisoDir ("Anisotropic Direction", 2D) = ""{}

		//[Space]
		//[Header(Other Shit)]
		//[Toggle] _BaseNormals("Use Basic Normals for Diffuse", Float) = 0
		//[Toggle] _Translucency("Use Translucency", Float) = 0
		//_TransPower ("Translucency Power", Float) = 2
		//// _TransAmb ("Translucency Ambient", Float) = 0.25
		//_TransDist ("Translucency Distortion", Float) = 1.5
	}
	SubShader {
		Tags { "Queue"="AlphaTest" "RenderType"="TransparentCutout" }
		LOD 200
		Cull Off
		
		CGPROGRAM
		#pragma surface surf Anisotropic alphatest:_Cutoff addshadow fullforwardshadows
		#pragma target 3.0
		//#pragma shader_feature _BASENORMALS_ON
		//#pragma shader_feature _TRANSLUCENCY_ON


		struct Input {
			float2 uv_MainTex;
			float2 uv_AnisoDir;
			float3 worldNormal; INTERNAL_DATA
		};

		struct SurfaceAnisoOutput
		{
			fixed3 Albedo;
//			fixed3 AnisoDirection;
			fixed3 Normal;
			fixed3 NormalOrig;
			fixed3 Emission;
			fixed Alpha;
			// fixed3 Translucency;
		};

		sampler2D _MainTex;
		fixed4 _Color;
        //fixed3 _GradColor;
        //half _GradAxis;
        //half _GradAddMult;

		float4 _SpecularColor;
		float _Specular;
		float _SpecPower;
		sampler2D _AnisoDir;
		float _AnisoOffset;

		//half _TransPower;
		//// half _TransAmb;
		//half _TransDist;

        //#include "AnisoLighting.cginc"
        //#include "Translucency.cginc"

        fixed4 LightingAnisotropic(SurfaceAnisoOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
        {
            float NdotL = 1 - abs(dot(s.Normal, lightDir));
            fixed3 halfVector = normalize(normalize(lightDir) + normalize(viewDir));
            fixed spec = dot(s.Normal, halfVector);
            spec = 1 - abs(spec);
            spec = saturate(pow(spec, _SpecPower * 128) * _Specular);

            half specMult = 1;
            //#ifdef _BASENORMALS_ON
                NdotL = saturate(dot (s.NormalOrig, lightDir));
                specMult = pow(NdotL, 2);
            //#else
            //#endif

            //half translucency = 0;
            //#ifdef _TRANSLUCENCY_ON
            //  translucency = saturate(Translucency(s.NormalOrig, lightDir, viewDir, atten, _TransPower, 0, _TransDist, 1));
            //#else
            //#endif

            fixed4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * atten *
                NdotL +
                _SpecularColor.rgb * spec * atten * specMult; //+
                //translucency * _SpecularColor.rgb * atten;
            c.a = s.Alpha;

            return c;
        }
        //#include "Hair_AddGradient.cginc"
	
		void surf (Input IN, inout SurfaceAnisoOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            //o.Albedo = AddGradient(c.rgb, _GradColor, IN.uv_MainTex.xy, _GradAxis, _GradAddMult);
			o.Alpha = c.a;

			// o.NormalOrig = o.Normal;
			// o.NormalOrig = UnityObjectToWorldNormal(o.Normal);
			// o.NormalOrig = IN.worldNormal;
			o.NormalOrig = WorldNormalVector (IN, o.Normal);
			// o.Albedo = (o.NormalOrig + 1)/2;

			float3 anisoTex = tex2D(_AnisoDir, IN.uv_AnisoDir);
			o.Normal = anisoTex;
			o.Normal -= 0.5f;
			o.Normal *= 2;
//			o.Normal = anisoTex;

			// o.Translucency = fixed3(_TransPower, _TransAmb, _TransDist);
		}
		ENDCG

		CGPROGRAM
		#pragma surface surf Anisotropic alpha:blend fullforwardshadows
		#pragma target 3.0
		//#pragma shader_feature _BASENORMALS_ON
		//#pragma shader_feature _TRANSLUCENCY_ON


		struct Input {
			float2 uv_MainTex;
			float2 uv_AnisoDir;
			float3 worldNormal; INTERNAL_DATA
		};

		struct SurfaceAnisoOutput
		{
			fixed3 Albedo;
//			fixed3 AnisoDirection;
			fixed3 Normal;
			fixed3 NormalOrig;
			fixed3 Emission;
			fixed Alpha;
			// fixed3 Translucency;
		};

		sampler2D _MainTex;
		fixed4 _Color;
		fixed _Cutoff;

		float4 _SpecularColor;
		float _Specular;
		float _SpecPower;
		sampler2D _AnisoDir;
		float _AnisoOffset;

		//half _TransPower;
		//// half _TransAmb;
		//half _TransDist;

		//#include "AnisoLighting.cginc"
        //#include "Translucency.cginc"

        fixed4 LightingAnisotropic(SurfaceAnisoOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
        {
            float NdotL = 1 - abs(dot(s.Normal, lightDir));
            fixed3 halfVector = normalize(normalize(lightDir) + normalize(viewDir));
            fixed spec = dot(s.Normal, halfVector);
            spec = 1 - abs(spec);
            spec = saturate(pow(spec, _SpecPower * 128) * _Specular);

            half specMult = 1;
            //#ifdef _BASENORMALS_ON
                NdotL = saturate(dot (s.NormalOrig, lightDir));
                specMult = pow(NdotL, 2);
            //#else
            //#endif

            //half translucency = 0;
            //#ifdef _TRANSLUCENCY_ON
            //  translucency = saturate(Translucency(s.NormalOrig, lightDir, viewDir, atten, _TransPower, 0, _TransDist, 1));
            //#else
            //#endif

            fixed4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * atten *
                NdotL +
                _SpecularColor.rgb * spec * atten * specMult; //+
                //translucency * _SpecularColor.rgb * atten;
            c.a = s.Alpha;

            return c;
        }

		void surf (Input IN, inout SurfaceAnisoOutput o) {

			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;

			o.NormalOrig = WorldNormalVector (IN, o.Normal);

			float3 anisoTex = tex2D(_AnisoDir, IN.uv_AnisoDir);
			o.Normal = anisoTex;
			o.Normal -= 0.5f;
			o.Normal *= 2;
//			o.Normal = anisoTex;

			c.a = c.a / _Cutoff;
			clip(-c.a + 1);
			o.Alpha = c.a;

			// o.Translucency = fixed3(_TransPower, _TransAmb, _TransDist);
		}
		ENDCG


	}
	FallBack "Diffuse"
}