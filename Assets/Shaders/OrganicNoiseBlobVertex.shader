Shader "Unlit/OrganicNoiseBlobVertex"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 0.4, 0.1, 1)
        _Amplitude ("Amplitude", Range(0, 0.5)) = 0.15
        _Frequency ("Frequency", Range(1, 15)) = 4.0
        _Speed ("Speed", Range(0, 5)) = 1.0
        _RimStrength ("Rim Strength", Range(0, 3)) = 1.5
        _RimColor ("Rim Color", Color) = (1, 0.6, 0.2, 1)
    } 

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "HDRenderPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "ForwardOnly"
            Tags { "LightMode" = "ForwardOnly" }

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            
            // Properties
            float4 _BaseColor;
            float  _Amplitude;
            float  _Frequency;
            float  _Speed;
            float  _RimStrength;
            float4 _RimColor;
            
            // Attributes
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            // Varyings
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 viewDirWS : TEXCOORD1;
            };
            
            // We sum three sine waves with sligthly modified frequency multipliers
            // This creates some kind of randomness
            float ComputeDisplacement(float3 posOS, float time)
            {
                float wave =
                    sin(posOS.x * _Frequency + time) +
                        sin(posOS.y * _Frequency  * 1.3 + time * 0.7) +
                            sin(posOS.z * _Frequency  * 0.9 + time * 1.1);

                // Each sine is in [-1, 1], so summed they're in [-3, 3]
                // We divide by 3 to normalize back to [-1, 1]
                // then scale by amplitude to get the final offset
                return (wave / 3.0) * _Amplitude;
            }
            
            // Vertex Shader
            Varyings Vert(Attributes IN)
            {
                Varyings OUT;
                
                float time = _Time.y * _Speed;
                
                // We move the vertex along its own normal by the displacement amount.
                float  displacement = ComputeDisplacement(IN.positionOS, time);
                float3 displacedOS  = IN.positionOS + IN.normalOS * displacement;
                
                // The GPU needs clip space to know where on screen to draw.
                OUT.positionCS = TransformObjectToHClip(displacedOS);
                
                OUT.normalWS = TransformObjectToWorldNormal(IN.normalOS);
                
                float3 positionWS = TransformObjectToWorld(displacedOS);
                OUT.viewDirWS = normalize(_WorldSpaceCameraPos.xyz - positionWS);

                return OUT;
            }
            
            float4 Frag(Varyings IN) : SV_Target
            {
                float3 normal  = normalize(IN.normalWS);
                float3 viewDir = normalize(IN.viewDirWS);

                // Fresnel
                float NdotV = saturate(dot(normal, viewDir));
                float rim = pow(1.0 - NdotV, 3.0) * _RimStrength;

                // Blend base color with rim color
                float3 color = lerp(_BaseColor.rgb, _RimColor.rgb, rim);

                return float4(color, 1.0);
            }

            ENDHLSL
        }
    }
}
