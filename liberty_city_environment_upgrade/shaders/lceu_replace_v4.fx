// liberty_city_environment_upgrade / lceu_replace_v4.fx
// ps_2_0-safe version: decorrelated world-space UV, no rotation trigonometry.
// Original average brightness is preserved so lighting stays natural.

float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 gWorld              : WORLD;

texture gTexture0 < string textureState = "0,Texture"; >;
sampler2D baseSampler = sampler_state
{
    Texture = (gTexture0);
    MinFilter = Linear; MagFilter = Linear; MipFilter = Linear;
    MaxAnisotropy = 16; AddressU = Wrap; AddressV = Wrap;
};

texture hdTexture;
sampler2D hdSampler = sampler_state
{
    Texture = <hdTexture>;
    MinFilter = Linear; MagFilter = Linear; MipFilter = Linear;
    MaxAnisotropy = 16; AddressU = Wrap; AddressV = Wrap;
};

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

float hash12(float2 p)
{
    return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
}

float4 ps(VSOutput i) : COLOR0
{
    float3 original = tex2D(baseSampler, i.TexCoord).rgb;
    float2 wp = i.WorldPos.xz;

    float2 cell = floor(wp * 0.3333);
    float2 off = float2(hash12(cell), hash12(cell + float2(23.7, 9.1))) * 0.37;
    float2 uv = frac(wp * worldScale) + off;

    float3 hi = tex2D(hdSampler, uv).rgb;
    float3 grit = tex2D(hdSampler, uv * 2.13 + off).rgb - 0.5;
    hi += grit * 0.055;

    float lum = dot(original, float3(0.299, 0.587, 0.114));
    return float4(saturate(hi * (0.62 + lum * 0.75)), 1.0);
}

technique
{
    pass P0
    {
        VertexShader = compile vs_2_0 vs();
        PixelShader  = compile ps_2_0 ps();
    }
}
