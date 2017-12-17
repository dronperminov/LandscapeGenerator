#version 330 core
in vec3 vFragPosition;
in vec2 vTexCoords;
in vec3 vNormal;

uniform int normal_mode;
uniform sampler2D groundTexture;
uniform sampler2D waterTexture;

const float sandStart = 0.5f;
const float groundStart = 1.0f;
const float grassStart= 8.0f;
const float mountainsStart= 14.0f;
const float snowStart= 18.0f;

const vec3 waterMinColor = vec3(0.0f, 0.0f, 0.6f);
const vec3 waterMaxColor = vec3(0.0f, 1.0f, 1.0f);

const vec3 sandColor = vec3(0.92f, 0.98f, 0.25f);
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

void main() {
	vec3 lightDir = vec3(0.0f, 1.0f, 0.0f);
	float kd = max(dot(vNormal, lightDir), 0.0);

	if (normal_mode == 1) {
		color = vec4(vNormal, 1.0f);
	} else {
		float height = vFragPosition.y;

		if (height < sandStart) {
			vec3 col = vec3(height / 5.0f, height / 5.0f, height / 2 + rand(vec2(-0.05f, 0.05f))); // water
			color = mix(texture(waterTexture, vTexCoords), vec4(kd * col, 1.0f), height / 1.5);
		}
		else {
			vec3 col;

			if (height >= snowStart + 2) {
				//col = map(height, snowStart, 25, snowColor, snowColor);
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
			} else {
				col = map(height, sandStart, groundStart, sandColor, groundColor);
			}

			color = mix(texture(groundTexture, vTexCoords), vec4(kd * col, 1.0), 0.4);		
		}
	}
}