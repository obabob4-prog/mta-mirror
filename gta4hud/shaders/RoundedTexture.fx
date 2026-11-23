// Rounded rectangle alpha mask for a texture (used by the minimap).
texture sTexture;
float2 sTextureSize = float2(1.0, 1.0);
float  sRadius = 20.0;
float  sFeather = 1.0;

sampler TextureSampler = sampler_state
{
	Texture = (sTexture);
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = Linear;
	AddressU = Clamp;
	AddressV = Clamp;
};

float4 PixelShaderFunction(float2 uv : TEXCOORD0) : COLOR0
{
	float4 color = tex2D(TextureSampler, uv);
	float2 p = uv * sTextureSize;
	float2 halfSize = sTextureSize * 0.5;
	float2 q = abs(p - halfSize) - (halfSize - sRadius);
	float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - sRadius;
	float maskAlpha = saturate(-dist / max(sFeather, 0.001));

	color.a *= maskAlpha;
	return color;
}

technique RoundedTexture
{
	pass P0
	{
		PixelShader = compile ps_2_0 PixelShaderFunction();
	}
}

technique fallback
{
	pass P0
	{
	}
}
