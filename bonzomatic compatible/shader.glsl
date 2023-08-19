#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D werner;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


vec3 palette(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1, 1, 1);
    vec3 d = vec3(0.263, 0.416, 0.557);
    
    
    return a + b * cos(6.28318 * (c * t + d));
}

void main(void)
{
    vec2 uv = (gl_FragCoord.xy * 2 - v2Resolution) / v2Resolution.y;
    vec2 uv0 = uv;
    vec3 finalcolor = vec3(0);
    
    for (int i = 0; i < 4; i++) {
        uv = fract(uv * 1.5) - 0.5;
        
        float d = length(uv) * exp(-length(uv0));
        
        vec3 col = palette(length(uv0) + i * 0.4 + fGlobalTime * 0.4);
        
        d = sin(d * 8 + fGlobalTime)/8;
        d = abs(d);
        
        d = pow(0.01 / d, 1.5);
            
        finalcolor += col * d;
    }    
    
    
    out_color = vec4(finalcolor, 1);
}