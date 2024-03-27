// Indices to `ResourceDescriptorHeap` array
#define rdh_vertex_buffer 1
#define rdh_object_buffer 2
#define rdh_frame_state_buffer 3

#define obj_flag_is_food 1
#define obj_flag_is_dead 2

#ifndef HLSL
typedef float float4x4[16];
#endif

struct Vertex {
    float x, y;
};

struct Object {
    unsigned int flags;
    unsigned int color[2];
    unsigned int mesh_index[2];
    float x, y;
    float rotation;
    float rotation_speed;
    float move_direction;
    float move_speed;
    float _padding[1];
};

struct FrameState {
    float4x4 proj;
    float _padding[112];
};
