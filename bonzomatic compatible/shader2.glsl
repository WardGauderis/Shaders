#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D werner;

layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

#define MAX_STEPS 100
#define MAX_DIST 100
#define SURF_DIST 0.01

///////////////////////////////////////////////////////////////

float sphere(in vec3 p, in float r){
    return length(p)-r;
}

float box(in vec3 p, in vec3 b){
    vec3 q = abs(p) - b;
    return length(max(q, 0)) + min(max(q.x, max(q.y, q.z)), 0);
}

float horizontalPlain(in vec3 p){
    return p.y;
}

///////////////////////////////////////////////////////////////

float getDist(in vec3 p){
    float d = box(p - vec3(0, 0.5, 0), vec3(0.5));
    d = min(d, horizontalPlain(p + 0.5));
    return d;
}

float rayMarch(in vec3 ro, in vec3 rd){
    float d0 = 0;
    uint i = 0;
    for(; i < MAX_STEPS; ++i){
        vec3 p = ro + rd * d0;
        float ds = getDist(p);
        d0 += ds;
        if (d0 > MAX_DIST || ds < SURF_DIST) break;
    }
    return d0;
}

vec3 getNormal(in vec3 p){
    float d = getDist(p);
    vec2 e = vec2(0.01, 0);
    
    vec3 n = d - vec3(
        getDist(p-e.xyy),
        getDist(p-e.yxy),
        getDist(p-e.yyx));
    
    return normalize(n);
}

float getLight(in vec3 p){
    vec3 lightPos = vec3(3, 3, 1);
     
    vec3 delta = lightPos - p;
    
    vec3 l = normalize(delta);
    vec3 n = getNormal(p);
    
    float diff = clamp(dot(n, l), 0, 1);
    
    float d =  rayMarch(p+n * SURF_DIST * 2, l);
    if (d < length(delta)) diff *= 0.1;
    
    return diff;
}

vec3 getRayDir(in vec2 uv, in vec3 ro, in vec3 p, in float z){
    vec3 f = normalize(p-ro);
    vec3 r = normalize(cross(vec3(0,1,0), f));
    vec3 u = cross(f, r);
    vec3 c = f*z;
    return normalize(c+uv.x*r+uv.y*u);
}

///////////////////////////////////////////////////////////////

void main(void)
{
    vec2 uv = (gl_FragCoord.xy - v2Resolution*0.5) / v2Resolution.y;
    vec3 col = vec3(0);
    
    vec3 ro = vec3(0, 0, 5);
    
    mat2 rotate;
    rotate[0] = vec2(cos(1.5), sin(1.5));
    rotate[1] = vec2(-sin(1.5), cos(1.5));
    //ro.xz *= rotate;
    
    vec3 rd = getRayDir(uv, ro, vec3(0, .5, 0), 1);
        
    float d = rayMarch(ro, rd);
        
    vec3 p = ro + rd * d;
    
    float diff = getLight(p);
   
    col = vec3(diff);

    out_color = vec4(col, 1);
}