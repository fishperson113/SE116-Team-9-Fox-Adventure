shader_type canvas_item;

uniform vec4 light_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec2 direction = vec2(1.0, 1.0);
uniform vec2 offset = vec2(0.0, 0.0);
uniform float thickness = 0.1;
uniform float softness = 1;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec2 uv = UV;

	vec2 dir = normalize(direction);
	vec2 p = uv - offset;
	vec2 normal = vec2(-dir.y, dir.x);
	float dist = abs(dot(p, normal));
	vec3 color = tex.rgb;
	if(dist < thickness){
		float streak = smoothstep(thickness, 0.0, dist);
		streak = pow(streak, softness);
		color += streak * light_color.rgb;
	}
	
	COLOR = vec4(color, tex.a);
}