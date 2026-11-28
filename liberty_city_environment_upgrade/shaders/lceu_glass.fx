// liberty_city_environment_upgrade / lceu_glass.fx
// Conservative glass treatment. MTA:SA world shaders cannot do real cube
// reflections, so this adds a very faint vertical sky gradient + micro
// grime while keeping the original window colour and darkness intact.

float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
float4x4 gWorld              : WORLD;

texture gTexture0 < string textureState = "0,Texture"; >;
sampler2D baseSampler = sampler_state
{
    Texture = (gTexture0);
    MinFilter = Linear; MagFilter = Linear; MipFilter = Linear;
    MaxAnisotropy = 8; AddressU = Wrap; AddressV = Wrap;
};

texture detailTexture;
sampler2D detailSampler = sampler_state
{
    Texture = <detailTexture>;
    MinFilter = Linear; MagFilter = Linear; MipFilter = Linear;
    MaxAnisotropy = 8; AddressU = Wrap; AddressV = Wrap;
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

float4 ps(VSOutput i) : COLOR0
{
    float3 base = tex2D(baseSampler, i.TexCoord).rgb;

    float3 d = (tex2D(detailSampler, i.WorldPos.zy * worldScale).rgb
              + tex2D(detailSampler, i.WorldPos.xz * worldScale).rgb
              + tex2D(detailSampler, i.WorldPos.xy * worldScale).rgb) / 3.0;

    float band = frac(i.WorldPos.y * 0.085 + i.WorldPos.x * 0.021);
    float sky = smoothstep(0.62, 0.98, band) * 0.07;

    float3 col = base * (0.96 + (d - 0.5) * 0.14);
    col += float3(0.55, 0.68, 0.85) * sky;

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
