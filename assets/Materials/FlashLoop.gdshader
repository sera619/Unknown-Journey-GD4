//Shader BY LURGX second shader */
//

shader_type canvas_item;
uniform bool shine = true;
uniform bool move = true;
uniform float side = 0.9;
uniform float up = 0.1;
uniform vec4 color: source_color;
uniform float u_time: hint_range (0.,10.);


void vertex() {//Movement 
if (move == true){
	VERTEX += vec2(cos(TIME*u_time)*side,cos(TIME*u_time)*up);
}
}

void fragment() { //COLOR SHINE
if (shine == true){
	COLOR = texture(TEXTURE, UV);
	COLOR.rgb += vec3(color.r,color.g,color.b)*(abs(cos(TIME*u_time)));
}
}