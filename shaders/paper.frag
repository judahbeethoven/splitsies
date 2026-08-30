#include <flutter/runtime_effect.glsl>

uniform vec3 bg;

out vec4 fragColor;

const float grid = 14.0;
const float r = 0.07;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec3 color = bg;

    vec2 cell = fract(fragCoord / grid) - 0.5;
    float spot = 1.0 - smoothstep(r - 0.03, r + 0.03, length(cell));
    color = mix(color,  bg * 0.80, spot * 0.5);

    fragColor = vec4(color, 1.0);
}