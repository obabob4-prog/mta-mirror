// lc_hd_roads / hd_roads_world.fx (v5 - ps_2_0 safe)
// The previous v4.2 shader compiled to 91 arithmetic instruction slots and
// failed on this machine (X5608, ps_2_0 limit is 64), so NO road shader was
// ever applied. This is a minimal equivalent: HD asphalt + light macro detail
// + clean white/silver markings from the original texture.

float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;

texture gTexture0 < string textureState = "0,Texture"; >;
sampler2D baseSampler = sampler_state
{
    Texture = (gTexture0);
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
float detailStrength;
float tileScale;

struct VSInput
{
    float3 Position : POSITION;
    float2 TexCoord : TEXCOORD0;
};

struct VSOutput
{
    float4 Position : POSITION;
    float2 TexCoord : TEXCOORD0;
};

VSOutput vs(VSInput input)
{
    VSOutput o;
    o.Position = mul(float4(input.Position, 1.0), gWorldViewProjection);
    o.TexCoord = input.TexCoord;
    return o;
}

float4 ps(VSOutput input) : COLOR0
{
    float2 uv = input.TexCoord;

    // 3 texture reads only; no sin/hash/pow, so it fits ps_2_0 comfortably.
    float4 original = tex2D(baseSampler, uv);
    float4 surface = tex2D(hdSampler, uv);
    float3 macro = tex2D(macroSampler, uv * 0.5 + float2(0.25, 0.25)).rgb;

    surface.rgb = lerp(surface.rgb, macro, saturate(detailStrength) * 0.35);

    float lum = dot(original.rgb, float3(0.299, 0.587, 0.114));
    float mask = smoothstep(0.66, 0.82, lum) * saturate(preserveMarkings);
    float3 paint = float3(0.92, 0.94, 0.97);

    return float4(lerp(surface.rgb, paint, mask), 1.0);
}

technique
{
    pass P0
    {
        VertexShader = compile vs_2_0 vs();
        PixelShader  = compile ps_2_0 ps();
    }
}
