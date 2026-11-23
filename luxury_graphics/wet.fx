// luxury_graphics / wet.fx
// Applied to road world textures. Darkens the surface as rain builds up and
// adds a cool sheen so asphalt reads as wet without a mirror render target.

sampler2D texture0;

float wetness;

float4 main(float2 uv : TEXCOORD0) : COLOR0
{
    float4 src = tex2D(texture0, uv);
    float w = saturate(wetness);

    // wet asphalt is darker and slightly cooler
    float3 color = src.rgb * lerp(1.0, 0.76, w);
    color += float3(0.030, 0.042, 0.060) * w;

    // a touch of contrast keeps the texture from going flat
    color = (color - 0.5) * lerp(1.0, 1.07, w) + 0.5;

    return float4(saturate(color), src.a);
}

technique
{
    pass P0
    {
        PixelShader = compile ps_2_0 main();
    }
}
