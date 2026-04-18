Shader "Unlit/PlasmaBallFragment"
{
    Properties
    {
        _CoreColor ("Core Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _TendrilColor ("Tendril Color", Color) = (0.4, 0.8, 1.0, 1.0)
        _RimColor ("Rim Color", Color) = (0.2, 0.4, 1.0,  1.0)
        _CenterColor ("Center Glow Color", Color) = (0.8, 0.9, 1.0, 1.0)
        _NoiseScale ("Noise Scale", Range(2, 20)) = 6.0
        _WarpStrength ("Warp Strength", Range(0, 2)) = 0.8
        _Speed ("Speed", Range(0, 5)) = 1.2
        _Threshold ("Threshold", Range(0, 1)) = 0.58
        _GlowWidth ("Glow Width", Range(0, 0.5)) = 0.25
        _RimPower ("Rim Power", Range(1, 8)) = 3.0
        _RimStrength ("Rim Strength", Range(0, 3)) = 1.5
        _CenterRadius ("Center Glow Radius",Range(0, 0.8)) = 0.3
        _Intensity ("Intensity", Range(1, 6)) = 2.5
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "RenderPipeline" = "HDRenderPipeline"
            "Queue" = "Transparent"
        }

        Pass
        {
            Name "ForwardOnly"
            Tags { "LightMode" = "ForwardOnly" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            
            // Properties
            float4 _CoreColor;
            float4 _TendrilColor;
            float4 _RimColor;
            float4 _CenterColor;
            float  _NoiseScale;
            float  _WarpStrength;
            float  _Speed;
            float  _Threshold;
            float  _GlowWidth;
            float  _RimPower;
            float  _RimStrength;
            float  _CenterRadius;
            float  _Intensity;
            
            // Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            // Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 viewDirWS  : TEXCOORD2;
            };
            
            // Hash
            float Hash(float2 p)
            {
                p = frac(p * float2(234.34, 435.345));
                p += dot(p, p + 34.23);
                return frac(p.x * p.y);
            }

            float Noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);
                float a = Hash(i);
                float b = Hash(i + float2(1, 0));
                float c = Hash(i + float2(0, 1));
                float d = Hash(i + float2(1, 1));
                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }

            float FBM(float2 p)
            {
                float value     = 0.0;
                float amplitude = 0.5;
                for (int i = 0; i < 4; i++)
                {
                    value += amplitude * Noise(p);
                    p *= 2.0;
                    amplitude *= 0.5;
                }
                return value;
            }
            
            // Vertex Shader
            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.uv = IN.uv;
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);

                float3 positionWS = TransformObjectToWorld(IN.positionOS);
                OUT.viewDirWS = normalize(_WorldSpaceCameraPos.xyz - positionWS);

                return OUT;
            }
            
            // Fragment Shader
            float4 Frag(Varyings IN) : SV_Target
            {
                // Center UVs so (0,0) is the middle of the sphere face
                float2 uv = IN.uv - 0.5;

                // Polar coordinates
                float radius = length(uv);
                float angle  = atan2(uv.y, uv.x);

                float t = _Time.y * _Speed;

                // Angular domain warping
                float2 polarUV = float2(angle / (2.0 * 3.14159), radius);

                float2 warpOffset = float2(
                    FBM(polarUV * _NoiseScale + float2(t,       0.3)),
                    FBM(polarUV * _NoiseScale + float2(t * 0.7, 1.9))
                );
                
                float2 warpedPolar = polarUV + float2(
                    warpOffset.x * _WarpStrength,
                    warpOffset.y * _WarpStrength * 0.2
                );

                // Sample final noise on warped polar coords
                float plasma = FBM(warpedPolar * _NoiseScale + t * 0.5);

                // Radial fade
                float radialFade = pow(saturate(1.0 - radius * 1.8), 0.4);
                plasma *= radialFade;

                // Core tendrils
                float core = smoothstep(_Threshold, _Threshold + 0.03, plasma);

                // Soft glow around tendrils
                float glow = smoothstep(_Threshold - _GlowWidth, _Threshold, plasma) * 0.7;

                // Center glow
                float centerGlow = smoothstep(_CenterRadius, 0.0, radius);

                // Fresnel rim
                float3 normal  = normalize(IN.normalWS);
                float3 viewDir = normalize(IN.viewDirWS);
                float NdotV = saturate(dot(normal, viewDir));
                float rim = pow(1.0 - NdotV, _RimPower) * _RimStrength;

                // Compose final color
                float3 color = float3(0, 0, 0);
                color = lerp(color, _TendrilColor.rgb, glow);
                color = lerp(color, _CoreColor.rgb,    core);
                color += _CenterColor.rgb * centerGlow * 0.6;
                color += _RimColor.rgb * rim;
                color *= _Intensity;

                // Alpha
                float alpha = saturate(glow + core + centerGlow * 0.8 + rim * 0.5);

                return float4(color, alpha);
            }

            ENDHLSL
        }
    }
}
