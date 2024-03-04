#include "cpu_gpu_common.h"

#ifdef _S00

#define root_signature "RootFlags(CBV_SRV_UAV_HEAP_DIRECTLY_INDEXED), " \
    "RootConstants(b0, num32BitConstants = 2)"

struct RootConst {
    uint first_vertex;
    uint object_id;
};
ConstantBuffer<RootConst> root_const : register(b0);

[RootSignature(root_signature)]
void s00_vertex(
    uint vertex_id : SV_VertexID,
    out float4 out_position : SV_Position,
    out float3 out_color : _Color
) {
    StructuredBuffer<Vertex> vertex_buffer = ResourceDescriptorHeap[sheap_static_vertex_buffer];

    const uint first_vertex = root_const.first_vertex;
    const uint object_id = root_const.object_id;

    const float3 colors[] = { float3(1.0, 0.0, 0.0), float3(0.0, 1.0, 0.0), float3(0.0, 0.0, 1.0) };
    out_position = float4(vertex_buffer[vertex_id + first_vertex], 0.0, 1.0);
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
