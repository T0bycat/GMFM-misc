// GM:FM (b0.2.7) — packs the fog passes of the SSAO depth into one 8-bit RGBA texture (Linux /
// macOS, where no float target can be drawn into), two textures at a time: a third sampler
// ($texture2) drew nothing in some sessions there, so the packing is two steps.
//   gmfm_depthpack  — s0, s1 = the passes ending at far / 4 and far / 16 -> R, G
//   gmfm_depthpack2 — s0 = that, s1 = the pass ending at far / 64 -> R, G kept, B
// Each pass holds depth / its end, 1 at or past it. Read raw (no linear read), written raw.
sampler First  : register(s0);
sampler Second : register(s1);

float4 main(float2 uv : TEXCOORD0) : COLOR
{
#ifdef SECOND_STEP
	return float4(tex2D(First, uv).rg, tex2D(Second, uv).r, 1);
#else
	return float4(tex2D(First, uv).r, tex2D(Second, uv).r, 0, 1);
#endif
}
