shader_type spatial;
render_mode specular_toon;

const float mesh_size = 512.0; // The size of the plane mesh being shaded

uniform sampler2D noise;
uniform float height_scale = 0.5;

uniform sampler2D normalmap;

varying vec2 vertex_position;

//float wave(vec2 position){
//	position += texture(noise, position/(0.005*mesh_size)).x * 2.0 - 1.0;
//	vec2 wv = 1.0 - abs(sin(position));
//	return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0) * height_scale;
//}

float height(vec2 position, float time) {
	vec2 offset = 0.04 * (position + time);
	return texture(noise, position - offset ).x * height_scale;
}

void vertex() {
	vec2 pos = VERTEX.xz / mesh_size;
	vertex_position = pos;
	float k = height(pos, TIME);
	VERTEX.y = k;
	//NORMAL = normalize(vec3(k - height(pos + vec2(0.1, 0.0), TIME), 0.1, k - height(pos + vec2(0.0, 0.1), TIME)));
	//vertex_position = VERTEX.xz / mesh_size;
}

void fragment() {
	float fresnel = sqrt(1.0 - dot(NORMAL, VIEW));
	RIM = 0.2;
	METALLIC = 0.0;
	ROUGHNESS = 0.01 * (1.0 - fresnel);
	ALBEDO = vec3(0.01, 0.03, 0.05) + (0.1 * fresnel);
	NORMAL_MAP = texture(normalmap, vertex_position).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
