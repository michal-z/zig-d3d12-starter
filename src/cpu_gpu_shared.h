// Indices to `ResourceDescriptorHeap` array
#define rdh_vertex_buffer 1
#define rdh_object_buffer 2
#define rdh_frame_state_buffer 3

#ifndef HLSL
typedef float float4x4[16];
#endif

struct Vertex {
    float x, y;
};

struct Object {
    unsigned int color;
    unsigned int mesh_index;
    float x, y;
    float rotation;
    float _padding[3];
};

struct FrameState {
    float4x4 proj;
    float _padding[112];
};
