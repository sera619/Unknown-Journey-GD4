shader_type canvas_item;

uniform float time : hint_range(0.0, 10.0) = 0.0;
uniform vec2 intensity = vec2(0.1, 0.2);
uniform vec2 speed  = vec2(1.0, 2.0);
uniform vec2 resolution = vec2(800.0, 600.0);

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 p = -1.0 + 2.0 * uv;
    vec2 offset = vec2(
        sin(time * speed.x) * intensity.x * (resolution.x / 1000.0),
        cos(time * speed.y) * intensity.y * (resolution.y / 1000.0)
    );
    vec4 color = texture(TEXTURE, uv + offset);
    COLOR = color;
}
