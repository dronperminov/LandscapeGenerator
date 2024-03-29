#version 330 core
layout(triangles) in;
layout(line_strip, max_vertices=2) out;

uniform mat4 view;
uniform mat4 projection;
uniform mat4 model;

void main() {
	vec3 V0 = gl_in[0].gl_Position.xyz - gl_in[1].gl_Position.xyz;
	vec3 V1 = gl_in[2].gl_Position.xyz - gl_in[1].gl_Position.xyz;
	
	vec3 P = (gl_in[0].gl_Position.xyz + gl_in[1].gl_Position.xyz + gl_in[2].gl_Position.xyz) / 3.0;

	gl_Position = projection * view * model * vec4(P, 1.0);
	EmitVertex();

	gl_Position = projection * view * model * vec4(P + normalize(cross(V1, V0)),1.0f);
	EmitVertex();

	EndPrimitive();
}
