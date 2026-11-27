// lc_hd_roads / hd_roads.fx  (v4.2)
// Strong, baked photoreal asphalt + white/silver lane paint ONLY.
// No yellow lines: original paint geometry is kept but recoloured clean white.
// Detail: lower-frequency grit sample survives mipmapping, stronger local contrast.

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

texture macroTexture;
sampler2D macroSampler = sampler_state
{
    Texture = <macroTexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    MaxAnisotropy = 8;
    AddressU = Wrap;
    AddressV = Wrap;
};

float preserveMarkings;
float tileScale;   // unused in fallback shader
float detailStrength;

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float4 surface = tex2D(hdSampler, uv);

    // visible gravel + micro-cracks, tuned so it survives downsampling
    float3 fine = tex2D(hdSampler, uv * 1.85 + float2(0.11, 0.43)).rgb - 0.5;
    float3 col = pow(max(surface.rgb, 0.002), 0.90);
    col = (col - 0.5) * 1.18 + 0.5;
    col += fine * 0.12;

    // larger cracks / patches at half frequency survive mipmapping.
    // applied AFTER contrast so bright patches cannot blow out to white.
    float3 macro = tex2D(macroSampler, uv * 0.42 + float2(0.31, 0.67)).rgb;
    float mLum = dot(macro, float3(0.299, 0.587, 0.114));
    float sLum = dot(col, float3(0.299, 0.587, 0.114));
    col = lerp(col, macro * (sLum / max(mLum, 0.02)), detailStrength);
    surface.rgb = saturate(col);

    if (preserveMarkings < 0.5)
        return float4(surface.rgb, 1.0);

    // only genuine paint (>168/255) from the untouched original texture
    float4 original = tex2D(baseSampler, uv);
    float lum = dot(original.rgb, float3(0.299, 0.587, 0.114));
    float paintMask = smoothstep(0.66, 0.82, lum);
    // clean white / very slight cool silver - NO YELLOW
    float3 paint = float3(0.92, 0.94, 0.97);
    return float4(lerp(surface.rgb, paint, paintMask * 0.95), 1.0);
}

technique
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
