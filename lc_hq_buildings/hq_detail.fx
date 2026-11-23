// lc_hq_buildings / hq_detail.fx
// Preserves the original LC building texture and adds light micro-detail.
// gTexture0 is MTA's automatically-bound world texture (texture0 was NOT bound
// and could sample as black). A fallback technique restores stock rendering.

texture gTexture0 < string textureState="0,Texture"; >;
sampler2D baseSampler = sampler_state
{
    Texture = (gTexture0);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    MaxAnisotropy = 8;
    AddressU = Wrap;
    AddressV = Wrap;
};

float2 texel;
float sharpen;

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float4 c  = tex2D(baseSampler, uv);
    float4 b1 = tex2D(baseSampler, uv + float2(texel.x, 0.0));
    float4 b2 = tex2D(baseSampler, uv - float2(texel.x, 0.0));
    float4 b3 = tex2D(baseSampler, uv + float2(0.0, texel.y));
    float4 b4 = tex2D(baseSampler, uv - float2(0.0, texel.y));
    float4 blur = (b1 + b2 + b3 + b4) * 0.25;

    float4 sharp = c + (c - blur) * sharpen;
    float lum = dot(sharp.rgb, float3(0.299, 0.587, 0.114));
    float n = frac(sin(dot(floor(uv * 1024.0), float2(12.9898, 78.233))) * 43758.5453) - 0.5;
    sharp.rgb = saturate(sharp.rgb + n * 0.022 * (0.35 + 0.65 * lum));
    return float4(sharp.rgb, c.a);
}

technique detail
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}

// If the pixel shader is unsupported, keep the original texture exactly.
technique fallback
{
    pass P0
    {
        Texture[0] = gTexture0;
    }
}
