// luxury_graphics / cinematic.fx
// Single-pass cinematic grade: saturation, contrast, tint, vignette,
// grain, unsharp mask and a cheap threshold bloom.

texture ScreenTexture;

sampler2D ScreenSampler = sampler_state
{
    Texture = <ScreenTexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Clamp;
    AddressV = Clamp;
};

float texelW;
float texelH;
float time;
float saturation;
float contrast;
float brightness;
float tintR;
float tintG;
float tintB;
float vignette;
float grain;
float sharpen;
float bloom;

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float2 tx = float2(texelW, texelH);

    float4 base = tex2D(ScreenSampler, uv);

    // 4-tap unsharp mask
    float3 neighbors =
        tex2D(ScreenSampler, uv + float2(tx.x, 0.0)).rgb +
        tex2D(ScreenSampler, uv - float2(tx.x, 0.0)).rgb +
        tex2D(ScreenSampler, uv + float2(0.0, tx.y)).rgb +
        tex2D(ScreenSampler, uv - float2(0.0, tx.y)).rgb;
    neighbors *= 0.25;

    float3 color = lerp(base.rgb, base.rgb + (base.rgb - neighbors), saturate(sharpen));

    // wide 4-tap bloom, thresholded so only bright areas glow
    float3 glow =
        tex2D(ScreenSampler, uv + float2(tx.x * 6.0, 0.0)).rgb +
        tex2D(ScreenSampler, uv - float2(tx.x * 6.0, 0.0)).rgb +
        tex2D(ScreenSampler, uv + float2(0.0, tx.y * 6.0)).rgb +
        tex2D(ScreenSampler, uv - float2(0.0, tx.y * 6.0)).rgb;
    glow *= 0.25;
    color += saturate(glow - 0.62) * bloom;

    // grade
    color *= brightness;
    color = (color - 0.5) * contrast + 0.5;

    float luma = dot(color, float3(0.299, 0.587, 0.114));
    color = lerp(float3(luma, luma, luma), color, saturation);
    color *= float3(tintR, tintG, tintB);

    // vignette
    float2 d = uv - 0.5;
    float shade = 1.0 - dot(d, d) * 1.6 * saturate(vignette);
    color *= saturate(shade);

    // film grain
    float noise = frac(sin(dot(uv, float2(12.9898, 78.233)) + time) * 43758.5453);
    color += (noise - 0.5) * grain;

    return float4(saturate(color), 1.0);
}

technique
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
