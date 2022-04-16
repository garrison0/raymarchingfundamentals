#version 300 es

out vec2 vUv;
in vec2 texcoord;
in vec2 position;

precision highp float;

void main() {
    vUv = texcoord;

    gl_Position = vec4(position, 1.0, 1.0);
}