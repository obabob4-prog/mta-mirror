// luxury_graphics / wet.fx  -- ULTRA wet roads (MTA 1.6 / ps_2_0)
// Integrated technique lineage: ccw "shader_wet_roads" -> Ren712 reflective
// bump/roadshine -> Sam@ke "Wet Roads Reloaded" (staged wet/dry + puddles).
// No render targets, no screen-space/ray-traced reflections are claimed here.
// wetness  = server-synchronised, eased road wetness (0=dry, 1=soaked)
// puddles  = quality-gated puddle mask strength (0 disables puddle response)
// night    = 0..1, strengthens cool specular sheen after dark
// timeSec  = animation clock for very subtle puddle ripple

sampler2D texture0;

float wetness;
float puddles;
float night;
float timeSec;

float hash21(float2 p)
{
    return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
}

float valueNoise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));
    return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
}

float fbm(float2 p)
{
    float v = 0.0;
    v += 0.56 * valueNoise(p);
    v += 0.28 * valueNoise(p * 2.03 + 17.1);
    v += 0.16 * valueNoise(p * 4.11 + 43.7);
    return v;
}

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float4 src = tex2D(texture0, uv);
    float w = saturate(wetness);

    // Large-scale surface variation: different stretches wet at different rates.
    float macro = fbm(uv * 5.7);
    float micro = fbm(uv * 46.0);
    float wetMask = saturate(w * (0.58 + 0.78 * macro + 0.22 * micro));

    // Lane paint / bright markings must stay readable, not turn into a mirror.
    float lum = dot(src.rgb, float3(0.299, 0.587, 0.114));
    float marking = smoothstep(0.55, 0.84, lum);
    float darken = lerp(0.70, 0.91, marking);

    float3 color = src.rgb * lerp(1.0, darken, wetMask);
    color += float3(0.010, 0.016, 0.026) * wetMask;
    color = (color - 0.5) * lerp(1.0, 1.055, wetMask) + 0.5;

    // Puddles collect in the low parts of the macro noise, never everywhere.
    float basin = smoothstep(0.54, 0.79, macro + 0.12 * micro);
    float puddle = saturate((puddles * w - 0.22) * 2.6) * basin;
    puddle *= 1.0 - marking * 0.75;

    // Bump-like normal from the micro height field: subtle anisotropic sheen.
    float hx = valueNoise(uv * 92.0 + float2(0.17, 0.0))
             - valueNoise(uv * 92.0 - float2(0.17, 0.0));
    float hy = valueNoise(uv * 92.0 + float2(0.0, 0.23))
             - valueNoise(uv * 92.0 - float2(0.0, 0.23));
    float3 n = normalize(float3(hx * 0.85, hy * 0.85, 1.0));
    float3 l = normalize(float3(0.34, -0.42, 0.84));
    float spec = pow(saturate(dot(n, l)), 16.0);
    float sheen = spec * (0.055 + 0.17 * saturate(night)) * (wetMask + 1.35 * puddle);
    color += float3(0.52, 0.63, 0.80) * sheen;

    // Puddle body: dark, cool, with a very faint animated ripple.
    float ripple = sin((uv.x * 37.0 + uv.y * 53.0) + timeSec * 2.3) * 0.010;
    color = lerp(color, color * 0.60 + float3(0.018, 0.028, 0.044) * night + ripple, puddle * 0.62);

    return float4(saturate(color), src.a);
}

technique wet_roads
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
