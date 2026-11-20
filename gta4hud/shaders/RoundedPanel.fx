// Rounded rectangle panel: solid fill + optional border ring, SDF based.
float2 sSize = float2(64.0, 64.0);
float  sRadius = 10.0;
float  sFeather = 1.0;
float4 sFill = float4(0.05, 0.06, 0.07, 0.55);
float4 sBorder = float4(1.0, 1.0, 1.0, 0.15);
float  sBorderWidth = 0.0;

float4 PixelShaderFunction(float2 uv : TEXCOORD0) : COLOR0
{
	float2 p = uv * sSize;
	float2 halfSize = sSize * 0.5;
	float2 q = abs(p - halfSize) - (halfSize - sRadius);
	float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - sRadius;

	float aa = max(sFeather, 0.75);

	float fillAlpha = saturate((-dist + (aa * 0.5)) / aa) * sFill.a;
	float borderAlpha = 0.0;
	if (sBorderWidth > 0.0)
	{
		borderAlpha = saturate((sBorderWidth - abs(dist)) / aa) * sBorder.a;
	}

	float outAlpha = borderAlpha + fillAlpha * (1.0 - borderAlpha);
	float3 outColor = float3(0.0, 0.0, 0.0);
	if (outAlpha > 0.0001)
	{
		outColor = (sBorder.rgb * borderAlpha + sFill.rgb * fillAlpha * (1.0 - borderAlpha)) / outAlpha;
	}

	return float4(outColor, outAlpha);
}

technique RoundedPanel
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
