#include "cpu_gpu_common.h"

#ifdef _S00

#define root_signature "RootFlags(CBV_SRV_UAV_HEAP_DIRECTLY_INDEXED), " \
    "RootConstants(b0, num32BitConstants = 2)"

struct RootConst {
    uint first_vertex;
    uint object_id;
};
ConstantBuffer<RootConst> root_const : register(b0);

float3 unpack_color(uint color) {
    return float3(
        ((color & 0xff0000) >> 16) / 255.0,
        ((color & 0xff00) >> 8) / 255.0,
        (color & 0xff) / 255.0
    );
}

[RootSignature(root_signature)]
void s00_vertex(
    uint vertex_id : SV_VertexID,
    out float4 out_position : SV_Position,
    out float3 out_color : _Color
) {
    StructuredBuffer<Vertex> vertex_buffer = ResourceDescriptorHeap[rdh_vertex_buffer];
    StructuredBuffer<Object> object_buffer = ResourceDescriptorHeap[rdh_object_buffer];

    ConstantBuffer<FrameState> frame_state = ResourceDescriptorHeap[rdh_frame_state_buffer];

    const uint first_vertex = root_const.first_vertex;
    const uint object_id = root_const.object_id;

    const Vertex vertex = vertex_buffer[vertex_id + first_vertex];
    const Object object = object_buffer[object_id];

    out_position = mul(float4(vertex.x + object.x, vertex.y + object.y, 0.0, 1.0), frame_state.proj);
    out_color = unpack_color(object.color);
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
