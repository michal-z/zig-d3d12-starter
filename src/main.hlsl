#ifdef _S00

#define root_signature "RootFlags(0)"

[RootSignature(root_signature)]
void s00_vertex(
    uint vertex_id : SV_VertexID,
    out float4 out_position : SV_Position,
    out float3 out_color : _Color
) {
    const float2 verts[] = { float2(-0.9, -0.9), float2(0.0, 0.9), float2(0.9, -0.9) };
    const float3 colors[] = { float3(1.0, 0.0, 0.0), float3(0.0, 1.0, 0.0), float3(0.0, 0.0, 1.0) };
    out_position = float4(verts[vertex_id], 0.0, 1.0);
    out_color = colors[vertex_id];
}

[RootSignature(root_signature)]
void s00_pixel(
    float4 position : SV_Position,
    float3 color : _Color,
    out float4 out_color : SV_Target0
) {
    out_color = float4(color, 1.0);
}

#elif _S01



#endif
