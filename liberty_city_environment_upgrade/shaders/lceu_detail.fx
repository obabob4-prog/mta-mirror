// liberty_city_environment_upgrade / lceu_detail.fx
// Material-preserving facade enhancement: unsharp mask for clear edges,
// plus a three-plane world-space detail field so walls of every orientation
// gain grain / wear without stretching. Original artwork and colours stay.

float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 gWorld              : WORLD;

texture gTexture0 < string textureState = "0,Texture"; >;
sampler2D baseSampler = sampler_state
{
    Texture = (gTexture0);
    MinFilter = Linear; MagFilter = Linear; MipFilter = Linear;
    MaxAnisotropy = 16; AddressU = Wrap; AddressV = Wrap;
};

texture detailTexture;
sampler2D detailSampler = sampler_state
{
    Texture = <detailTexture>;
    MinFilter = Linear; MagFilter = Linear; MipFilter = Linear;
    MaxAnisotropy = 8; AddressU = Wrap; AddressV = Wrap;
};

float2 texel;
float sharpen;
float detailStrength;
float worldScale;

struct VSInput { float3 Position : POSITION; float2 TexCoord : TEXCOORD0; };
struct VSOutput
{
    float4 Position : POSITION;
    float2 TexCoord : TEXCOORD0;
    float3 WorldPos : TEXCOORD1;
};

VSOutput vs(VSInput i)
{
    VSOutput o;
    o.Position = mul(float4(i.Position, 1.0), gWorldViewProjection);
    o.TexCoord = i.TexCoord;
    o.WorldPos = mul(float4(i.Position, 1.0), gWorld).xyz;
    return o;
}

float4 ps(VSOutput i) : COLOR0
{
    float2 uv = i.TexCoord;
    float3 base = tex2D(baseSampler, uv).rgb;

    // clarify facade edges, window frames and doors
    float3 blur = (tex2D(baseSampler, uv + float2(texel.x, 0.0))
                 + tex2D(baseSampler, uv - float2(texel.x, 0.0))
                 + tex2D(baseSampler, uv + float2(0.0, texel.y))
                 + tex2D(baseSampler, uv - float2(0.0, texel.y))) * 0.25;
    float3 col = base + (base - blur) * sharpen;

    // 3-plane sampling: no orientation ever gets a stretched detail map
    float2 ux = i.WorldPos.zy * worldScale;
    float2 uy = i.WorldPos.xz * worldScale;
    float2 uz = i.WorldPos.xy * worldScale;
    float3 d = (tex2D(detailSampler, ux).rgb
              + tex2D(detailSampler, uy).rgb
              + tex2D(detailSampler, uz).rgb) / 3.0;

    float lum = dot(col, float3(0.299, 0.587, 0.114));
    col += (d - 0.5) * detailStrength * (0.35 + lum * 0.9);

    return float4(saturate(col), 1.0);
}

technique
{
    pass P0
    {
        VertexShader = compile vs_2_0 vs();
        PixelShader  = compile ps_2_0 ps();
    }
}
