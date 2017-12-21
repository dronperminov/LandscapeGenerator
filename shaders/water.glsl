#version 330 core
in vec3 vFragPosition;
in vec2 vTexCoords;
in vec3 vNormal;

uniform sampler2D waterTexture;
uniform int normal_mode;
uniform int shadow_mode;
uniform float fog_density;
uniform float light;
uniform bool g_fog;

out vec4 color;

float ToLinear(float depth) {
	float zFar = 200;
	float zNear = 0.2;

	return (2.0 * zNear * zFar) / (zFar + zNear - (gl_FragCoord.z * 2.0 - 1.0) * (zFar - zNear)) / zFar;
}

void main() {
	float day_len = 4;
	float dirl = sin(light / day_len);

	vec3 lightDir = vec3(0.0f, 1.0f, 0.0f);
	float kd = max(dot(vNormal, lightDir), 0.0);
	
	vec4 col;

	float foggy = exp(-pow((fog_density / ((gl_FragCoord.z / gl_FragCoord.w))), 2.0));

	if (normal_mode == 1) {
		color = vec4(vNormal * 0.5 + vec3(0.5, 0.5, 0.5), 1.0);
	} else if (shadow_mode == 1) {
		color = vec4(vec3(ToLinear(gl_FragCoord.z)), 1.0);
	} else {
		col = vec4(0.0f, 0.0f, 1.0f, 0.5);
		color = vec4(kd * mix(texture(waterTexture, vTexCoords), col, 0.35));
	}

	if (g_fog)
		color = mix(color, vec4(1.0, 1.0, 1.0, 1.0), foggy);

	float real_time = 0.0;

	if (sin(light / day_len) > 0.3)
		real_time = 1.0;
	else if (sin(light / day_len) < -0.7)
		real_time = 0.0;
	else
		real_time = (sin(light / day_len) + 0.7); 

	color = color * real_time;
	color.w = 0.7;
}