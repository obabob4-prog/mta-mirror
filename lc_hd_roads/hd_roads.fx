// lc_hd_roads / hd_roads.fx  (2026-11-22 v4)
// REAL PBR-style albedo (Poly Haven CC0) replaces the flat original.
// For road groups, bright pixels from the original world texture are kept as
// paint. That preserves the ORIGINAL lane-marking geometry exactly while the
// asphalt underneath becomes fully detailed. For sidewalk/curb groups the
// original is ignored, because those textures are naturally bright.

texture texture0;
sampler2D baseSampler = sampler_state
{
    Texture = <texture0>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    MaxAnisotropy = 16;
    AddressU = Wrap;
    AddressV = Wrap;
};

texture hdTexture;
sampler2D hdSampler = sampler_state
{
    Texture = <hdTexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    MaxAnisotropy = 16;
    AddressU = Wrap;
    AddressV = Wrap;
};

float preserveMarkings;

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float4 surface = tex2D(hdSampler, uv);
    if (preserveMarkings < 0.5)
        return float4(surface.rgb, 1.0);

    float4 original = tex2D(baseSampler, uv);
    float lum = dot(original.rgb, float3(0.299, 0.587, 0.114));
    // Original road PNGs: asphalt 50..100, paint 180..237.
    float paintMask = smoothstep(0.42, 0.72, lum);
    float yellow = saturate((original.r - original.b) * 3.0);
    float3 paint = lerp(float3(0.94, 0.95, 0.96), float3(0.98, 0.80, 0.18), yellow);
    return float4(lerp(surface.rgb, paint, paintMask * 0.92), 1.0);
}

technique
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
