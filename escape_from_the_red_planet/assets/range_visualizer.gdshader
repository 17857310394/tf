shader_type spatial;
render_mode unshaded, depth_draw_always, cull_disabled, blend_add;

uniform float glow_strength : hint_range(0.0, 2.0) = 2.0;
uniform float alpha : hint_range(0.0, 1.0) = 0.02;

void vertex() {
    // Called for every vertex the material is visible on.
}

void fragment() {
    // 创建半透明效果
    ALBEDO = vec3(0.0, 0.5, 1.0);
    ALPHA = alpha;
    
    // 添加发光效果
    vec3 view_dir = normalize(CAMERA_POSITION_WORLD - NODE_POSITION_WORLD);
    float fresnel = 1.0 - dot(normalize(NORMAL), view_dir);
    ALBEDO += vec3(0.2, 0.4, 1.0) * fresnel * glow_strength;
}

//void light() {
//    // Called for every pixel for every light affecting the material.
//    // Uncomment to replace the default light processing function with this one.
//}