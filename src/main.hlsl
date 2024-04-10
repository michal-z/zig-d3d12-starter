#include "cpu_gpu_shared.h"

#ifdef _S00

#define root_signature "RootFlags(CBV_SRV_UAV_HEAP_DIRECTLY_INDEXED), " \
    "RootConstants(b0, num32BitConstants = 3)"

struct RootConst {
    uint first_vertex;
    uint object_id;
    uint submesh_index;
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
    const Object parent = object_buffer[object.parent];

    const float o_sin_r = sin(object.rotation);
    const float o_cos_r = cos(object.rotation);

    const float p_sin_r = sin(parent.rotation);
    const float p_cos_r = cos(parent.rotation);

#ifdef SHADOW
    const float vx = vertex.x + 10.0;
    const float vy = vertex.y + 10.0;
#else
    const float vx = vertex.x;
    const float vy = vertex.y;
#endif

    const float2 p =
        float2(vx * o_cos_r - vy * o_sin_r + object.x,
               vx * o_sin_r + vy * o_cos_r + object.y);

    out_position = mul(
        float4(p.x * p_cos_r - p.y * p_sin_r + parent.x,
               p.x * p_sin_r + p.y * p_cos_r + parent.y,
               0.0, 1.0),
        frame_state.proj);
    out_color = unpack_color(object.colors[root_const.submesh_index]);
}

[RootSignature(root_signature)]
void s00_pixel(
    float4 position : SV_Position,
    float3 color : _Color,
    out float4 out_color : SV_Target0
) {
#ifdef SHADOW
    out_color = float4(0, 0, 0, 0.65);
#else
    out_color = float4(color, 1.0);
#endif
}

#elif _S01



#endif
