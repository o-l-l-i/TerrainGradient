Shader "Custom/TerrainGradientShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Top ("Top height", float) = 1.0
        _Bottom ("Bottom height", float) = -1.0
        _GradientTex ("Height gradient texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types.
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting.
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _GradientTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Top;
        float _Bottom;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)
        
        float normalizeToRange(float m, float rMin, float rMax, float tMin, float tMax)
        {
            // Normalize input value to 0-1 range.  Need to provide correct min and max measurements.
            float normalized = (m - rMin) / (rMax - rMin);
            // Map the value to the desired range.
            float scaled = normalized * (tMax - tMin) + tMin;
            return scaled;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color.
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            // Normalize world position between the two values.
            float posNormalized = normalizeToRange(IN.worldPos.y, _Bottom, _Top, 0, 1);
            // Sample gradient texture
            fixed4 gradient = tex2D (_GradientTex, float2(posNormalized, 0.5));
            // Mix colors
            c.rgb *= gradient;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables.
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
