// GM:FM (b0.2.7) — smooths the packed 8-bit SSAO depth of Linux / macOS (no float targets there)
// into 16 bits. The fog passes give the depth in steps (2 units at 300 units away): a flat wall
// came out as a staircase of plateaus ~12 pixels tall, and the occlusion read every step as a
// ledge — horizontal stripes. Each pass averages 15 pixels along one axis, only those within three
// steps of the middle one (a silhouette stays sharp), so the stairs become the ramp they stand for.
// SPLIT_IN: the input is this shader's own output (R = high byte, G = low byte of depth / far);
// otherwise the packed bands (R = 4 d / far, G = 16 d / far, B = 64 d / far, each stopping at 1).
// Output: R = high byte, G = low byte of depth / far (1 = sky / past the last band).
// c0: xy = the step to the next pixel along the axis, z = far (units)
sampler DepthSampler : register(s0);
const float4 g_Params : register(c0);

float depthOf(float2 uv)
{
	float3 t = tex2D(DepthSampler, uv).rgb;
#ifdef SPLIT_IN
	return t.r + t.g / 255.0;
#else
	return (t.b < 0.996) ? t.b / 64.0 : ((t.g < 0.996) ? t.g / 16.0 : ((t.r < 0.996) ? t.r / 4.0 : 1.0));
#endif
}

float stepOf(float d)    // one step of the packed depth at d (a part of far)
{
	return (d < 1.0 / 64.0) ? 1.0 / (64.0 * 255.0) : ((d < 1.0 / 16.0) ? 1.0 / (16.0 * 255.0) : 1.0 / (4.0 * 255.0));
}

float4 main(float2 uv : TEXCOORD0) : COLOR
{
	float d0 = depthOf(uv);
	float tol = 3.0 * stepOf(d0);
	float sum = d0, wsum = 1.0;
	[unroll] for (int i = 1; i <= 7; i++)
	{
		float a = depthOf(uv + g_Params.xy * i);
		float b = depthOf(uv - g_Params.xy * i);
		float wa = (abs(a - d0) <= tol) ? 1.0 : 0.0;
		float wb = (abs(b - d0) <= tol) ? 1.0 : 0.0;
		sum += a * wa + b * wb;
		wsum += wa + wb;
	}
	float d = sum / wsum;
	d = (d0 >= 0.999) ? 1.0 : d;     // the sky stays the sky
	float hi = floor(d * 255.0) / 255.0;
	float lo = frac(d * 255.0);
	return float4(hi, lo, 0, 1);
}
