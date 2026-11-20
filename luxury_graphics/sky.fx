// luxury_graphics / sky.fx
// Equirectangular sky dome with a two-texture cross-fade.
// Textures are sky-only maps: v=0 zenith, v=1 horizon.

texture texATexture;
texture texBTexture;

sampler2D texASampler = sampler_state
{
    Texture = <texATexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Clamp;
};

sampler2D texBSampler = sampler_state
{
    Texture = <texBTexture>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    AddressU = Wrap;
    AddressV = Clamp;
};

float blend;
float tintR;
float tintG;
float tintB;
float haze;
float hazeR;
float hazeG;
float hazeB;
float uOffset;

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float2 coord = float2(frac(uv.x + uOffset), saturate(uv.y));

    float3 a = tex2D(texASampler, coord).rgb;
    float3 b = tex2D(texBSampler, coord).rgb;
    float3 c = lerp(a, b, saturate(blend));

    c *= float3(tintR, tintG, tintB);

    // horizon haze: strongest at v=1, fading towards the zenith
    float horizon = pow(saturate(uv.y), 3.0);
    c = lerp(c, float3(hazeR, hazeG, hazeB), saturate(haze) * horizon);

    // gentle filmic contrast so the dome matches the graded world
    c = (c - 0.5) * 1.04 + 0.5;

    return float4(saturate(c), 1.0);
}

technique
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
