shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform vec2 scroll = vec2(0.05, 0.05);
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

void fragment(){
	vec4 noise_col = texture(noise, UV + scroll * TIME);
	vec4 screen_col = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = screen_col;
}