shader_type canvas_item;

// helpful to visually debug the noise scrolling texture.
uniform bool render_noise = false;
// Change if you want to move the bottom vertex of each tile.
uniform bool move_top = true;
// how strong is the vertex going to be pulled.
uniform vec2 distortion_force = vec2(10.0, 0.0);
// how fast is the noise texture is going to scroll.
uniform float time_scale :hint_range(0.0, 1.0, 0.01) = 0.1;
// the distortion texture, can be hand made or generated with the Godot builtin
// noise texture.
uniform sampler2D noise_texture: hint_default_white;
// the scale of the texture
uniform float noise_scale :hint_range(0.0, 2.0, 0.0001)= 0.002;

// you need to pass the world position from a script as seen
// https://docs.godotengine.org/en/3.5/tutorials/shaders/shader_reference/canvas_item_shader.html#vertex-built-ins
uniform mat4 global_transform;
varying vec2 world_position;

// the size of the tilemap tiles.
const float tile_size = 8.0;

vec2 get_uv(vec2 uv, float scale, float time) {
	vec2 new_uv = uv;
	new_uv *= scale;
	new_uv += time;
	return new_uv;
}

void vertex(){
    world_position = (global_transform * vec4(VERTEX, 0.0, 1.0)).xy;
	vec2 world_uv = get_uv(world_position, noise_scale, TIME * time_scale); 
	vec2 noise = texture(noise_texture, world_uv).rg;
	noise *= 2.0;
	noise -= 1.0;
	noise *= distortion_force;
	
	float a = fract(VERTEX.y / tile_size);
	
	if (a == 0.0 && move_top) {
		VERTEX.x += noise.x;
		VERTEX.y += noise.y;
	}
	if (a > 0.0 && !move_top) {
		VERTEX.x += noise.x;
		VERTEX.y += noise.y;
	}
}

void fragment() {
	vec4 sample = texture(TEXTURE, UV);
	COLOR = sample;
	
	if (render_noise) {
		vec3 color = sample.rgb;
		vec2 world_uv = get_uv(world_position, noise_scale, TIME * time_scale); 
		color = texture(noise_texture, world_uv).rgb;
		COLOR = vec4(color, 1.0);
	}
}