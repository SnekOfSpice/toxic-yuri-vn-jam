shader_type canvas_item;

uniform float saturation;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 tex_color = texture(SCREEN_TEXTURE, UV);

    COLOR.rgb = mix(vec3(dot(tex_color.rgb, vec3(0.299, 0.587, 0.114))), tex_color.rgb, saturation);
	COLOR.a = tex_color.a;
}