Shader "Unlit/TeslaDischargeFragment"
{
    Properties
    {
        _CoreColor ("Core Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _GlowColor ("Glow Color", Color) = (0.3, 0.6, 1.0,  1.0)
        _NoiseScale ("Noise Scale", Range(2, 20))  = 8.0
        _WarpStrength ("Warp Strength", Range(0, 1)) = 0.4
        _Speed ("Speed", Range(0, 10)) = 5.0
        _FlickerRate ("Flicker Rate", Range(1, 30)) = 12.0
        _Threshold ("Threshold", Range(0, 1)) = 0.62
        _GlowWidth ("Glow Width", Range(0, 0.4)) = 0.2
        _Intensity ("Intensity", Range(1, 5)) = 2.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "RenderPipeline" = "HDRenderPipeline"
            "Queue"  = "Transparent"
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
            float4 _GlowColor;
            float  _NoiseScale;
            float  _WarpStrength;
            float  _Speed;
            float  _FlickerRate;
            float  _Threshold;
            float  _GlowWidth;
            float  _Intensity;
            
            // Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            // Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            // Takes a float2 position and returns a pseudo-random float [0,1]
            // The magic numbers are just primes that scramble the input well
            float Hash(float2 p)
            {
                p = frac(p * float2(234.34, 435.345));
                p += dot(p, p + 34.23);
                return frac(p.x * p.y);
            }
            
            // Value noise
            float Noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                // Smoothstep removes linear interpolation artifacts
                f = f * f * (3.0 - 2.0 * f);

                float a = Hash(i);
                float b = Hash(i + float2(1, 0));
                float c = Hash(i + float2(0, 1));
                float d = Hash(i + float2(1, 1));

                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }
            
            // Fractional Brownian Motion
            float FBM(float2 p)
            {
                float value = 0.0;
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
                return OUT;
            }
            
            // Fragment Shader
            float4 Frag(Varyings IN) : SV_Target
            {
                float2 uv = IN.uv - 0.5;

                // Flickering
                float flicker = floor(_Time.y * _FlickerRate) / _FlickerRate;
                float t = flicker * _Speed;

                // Domain warping
                float2 warpOffset = float2(FBM(uv * _NoiseScale + float2(t, 0.0)), FBM(uv * _NoiseScale + float2(0.0, t + 1.7)));
                float2 warpedUV = uv + warpOffset * _WarpStrength;

                // Sample noise on warped coordinates
                float electric = FBM(warpedUV * _NoiseScale + t);

                // Bright core
                float core = smoothstep(_Threshold, _Threshold + 0.03, electric);

                // Soft glow
                float glow = smoothstep(_Threshold - _GlowWidth, _Threshold, electric) * 0.6;

                // Compose color
                float3 color = lerp(float3(0, 0, 0), _GlowColor.rgb, glow);
                color = lerp(color, _CoreColor.rgb, core);
                color *= _Intensity;

                // Alpha
                float alpha = saturate(glow + core);

                return float4(color, alpha);
            }

            ENDHLSL
        }
    }
}
