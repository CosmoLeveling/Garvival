shader_type spatial;
uniform vec3 color:source_color;
uniform float Dissolve_Height;
varying vec3 worldpos;
render_mode cull_disabled;

void vertex() {
	worldpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;;
}

void fragment() {
	ALPHA = 1.0-step(Dissolve_Height,worldpos.y);;
	ALBEDO = color;
	ALPHA_SCISSOR_THRESHOLD = 0.5;

}
