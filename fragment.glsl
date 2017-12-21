#version 330 core
in vec3 vFragPosition;
in vec2 vTexCoords;
in vec3 vNormal;

uniform int normal_mode;
uniform int shadow_mode;
uniform sampler2D groundTexture;
//uniform sampler2D grassTexture;
uniform sampler2D waterTexture;
uniform float fog_density;
uniform float light;
uniform bool g_fog;

const float groundStart = 1.0f;
const float grassStart= 11.0f;
const float mountainsStart= 14.0f;
const float snowStart= 18.0f;

const float day_len = 4;

const vec3 waterMinColor = vec3(0.0f, 0.0f, 0.6f);
const vec3 waterMaxColor = vec3(0.0f, 1.0f, 1.0f);

const vec3 groundColor = vec3(0.43f, 0.26f, 0.13f);
const vec3 grassColor = vec3(0.0f, 0.4f, 0.0f);
const vec3 mountainsColor = vec3(0.7f, 0.7f, 0.7f);
const vec3 snowColor = vec3(1.0f, 1.0f, 1.0f);

out vec4 color;

float rand(vec2 n) {
    return 0.5f + 0.5f * fract(sin(dot(n.xy, vec2(12.9898f, 78.233f))) * 43758.5453f);
}

vec3 map(float value, float minValue, float maxValue, vec3 from, vec3 to) {
	return (value - minValue) / (maxValue - minValue) * (to - from) + from;
}

float ToLinear(float depth) {
	float zFar = 200;
	float zNear = 0.2;

	return (2.0 * zNear * zFar) / (zFar + zNear - (2.0 * gl_FragCoord.z - 1.0) * (zFar - zNear)) / zFar;
}

void main() {
	float dirl = sin(light / day_len);
	float foggy = exp(-pow((fog_density / ((gl_FragCoord.z / gl_FragCoord.w))), 2.0));

	vec3 lightDir = vec3(dirl, 1.0f, 0.0f);
	float kd = max(dot(vNormal, lightDir), 0.3);

	if (normal_mode == 1) {
		color = vec4(0.5f * vNormal + vec3(0.5f, 0.5f, 0.5f), 1.0f);
	} else if (shadow_mode == 1) {
		color = vec4(vec3(ToLinear(gl_FragCoord.z)), 1.0);
	} else {
		float height = vFragPosition.y;

		if (height < groundStart) {
			vec4 col = vec4(0.0f, 0.0f, 1.0f, height / groundStart); // water
			color = vec4(kd * mix(texture(waterTexture, vTexCoords), col, 0.95f));
			color = color * 0.95;
		}
		else {
			vec3 col;

			if (height >= snowStart + 2) {
				col = vec3(height / 30.0f + rand(vec2(-0.25f, 0.25f)), height / 30.0f + rand(vec2(-0.25f, 0.25f)), height / 30.0f + rand(vec2(-0.25f, 0.25f)));
			}
			else if (height >= snowStart) {
				vec3 rnd = vec3(height / 30.0f + rand(vec2(-0.25f, 0.25f)), height / 30.0f + rand(vec2(-0.25f, 0.25f)), height / 30.0f + rand(vec2(-0.25f, 0.25f)));
				col = map(height, snowStart, snowStart + 2, snowColor, rnd);
			}
			else if (height >= mountainsStart) {
				col = map(height, mountainsStart, snowStart, mountainsColor, snowColor); // mountains
			}
			else if (height >= grassStart) {
				col = map(height, grassStart, mountainsStart, grassColor, mountainsColor); // grass
			}
			else if (height >= groundStart) {
				col = map(height, groundStart, grassStart, groundColor, grassColor); // ground
			}

			color = vec4(kd * mix(texture(groundTexture, vTexCoords), vec4(col, 1.0f), 0.3));	
		}
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
	color.w = 1.0;
}