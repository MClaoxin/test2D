shader_type canvas_item;

uniform bool enable_tint = false;
uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // 红色

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (enable_tint) {
        tex_color *= tint_color;
    }
    COLOR = tex_color;
}
