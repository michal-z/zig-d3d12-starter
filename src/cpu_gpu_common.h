// Indices to `ResourceDescriptorHeap` array
#define rdh_vertex_buffer 1
#define rdh_object_buffer 2

struct Vertex {
    float x, y;
};

struct Object {
    unsigned int color;
    unsigned int mesh_index;
    float _padding[2];
};
