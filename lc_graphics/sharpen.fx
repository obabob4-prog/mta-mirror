// ============================================================
//  lc_graphics / sharpen.fx
//  Single-pass unsharp mask.
//
//  Why: the Liberty City conversion ships 6,516 textures, 90% of
//  them 64x64 / 128x128 and 97% with a single mip level. Bilinear
//  magnification of those textures is what reads as "blurry" up
//  close. This pass restores local contrast so facades, brick and
//  asphalt keep their edges without touching the source art.
// ============================================================

texture ScreenTexture;

sampler2D ScreenSampler = sampler_state
{
    Texture   = (ScreenTexture);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
    AddressU  = Clamp;
    AddressV  = Clamp;
};

float2 texelSize = float2(1.0 / 1920.0, 1.0 / 1080.0);
float  strength  = 0.28;

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float4 c = tex2D(ScreenSampler, uv);

    float3 blur =
          tex2D(ScreenSampler, uv + float2(texelSize.x, 0.0)).rgb
        + tex2D(ScreenSampler, uv - float2(texelSize.x, 0.0)).rgb
        + tex2D(ScreenSampler, uv + float2(0.0, texelSize.y)).rgb
        + tex2D(ScreenSampler, uv - float2(0.0, texelSize.y)).rgb;

    blur *= 0.25;

    float3 enhanced = c.rgb + (c.rgb - blur) * strength;
    return float4(saturate(enhanced), c.a);
}

technique sharpen
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
