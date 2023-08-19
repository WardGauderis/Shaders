#define MAX_STEPS 1000
#define MAX_DIST 100.0
#define SURF_DIST 0.001

mat2 rot(float a){
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

float smin(float a, float b, float k){
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float sdCylinder(vec3 p, vec3 a, vec3 b, float r){
      vec3 ab = b-a;
    vec3 ap = p-a;
    
    float t = dot(ab, ap) / dot(ab, ab);
    //t = clamp(t, 0.0, 1.0);
    
    vec3 c = a + t * ab;
    
    float x = length(p - c) - r;
	float y = (abs(t - 0.5) - 0.5) * length(ab);
    float e = length(max(vec2(x, y), 0.0));
    float i = min(max(x,y), 0.0);
    
    return e+i;
}

float sdBox(vec3 p, vec3 s){
    return length(max(abs(p) - s, 0.0));
}

float sdTorus(vec3 p, vec2 r){
    float x = length(p.xz) - r.x;
    return length(vec2(x, p.y)) - r.y;
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
    vec3 ab = b-a;
    vec3 ap = p-a;
    
    float t = dot(ab, ap) / dot(ab, ab);
    t = clamp(t, 0.0, 1.0);
    
    vec3 c = a + t * ab;
    
    return length(p - c) - r;
}

float getDist(vec3 p){
    float pd = p.y;
    
    vec3 bp = p - vec3(0.0, 0.5, 6.0);
    bp.xz *= rot(-iTime);
    float bd = sdBox(bp, vec3(0.5));
    
    float sda = length(p - vec3(-2.0, 1.0, 6.0)) - 1.0;
    float sdb = length(p - vec3(-1.0, 1.0, 5.6)) - 0.5;
    float sd = smin(sda, sdb, sin(iTime)*0.5+0.5);
    
    float sdc = length(p - vec3(0.0, 0.5, 6.0)) - 0.7;
    
    float mix = mix(sdc, bd, sin(iTime)*0.5+0.5);

    
    float d = min(min(pd, mix), sd);
    return d;
}

float rayMarch(vec3 ro, vec3 rd) {
	float d0 = 0.0;
    for(int i = 0; i < MAX_STEPS; i++){
    	 vec3 p = ro + rd * d0;
        float ds = getDist(p);
        d0 += ds;
        if (d0 > MAX_DIST || ds < SURF_DIST) break;
    }
    return d0;
}

vec3 getNormal(vec3 p){
    float d = getDist(p);
    vec2 e = vec2(0.01, 0.0);
    
    vec3 n = d - vec3(
        getDist(p-e.xyy), 
        getDist(p-e.yxy),
    	getDist(p-e.yyx));
    
    return normalize(n);
}

float getLight(vec3 p){
    vec3 lightPos = vec3(0.0, 5.0, 2.0);
    //lightPos.xz += vec2(sin(iTime) * 2.0, cos(iTime) * 2.0) * 2.0;
    vec3 l = normalize(lightPos-p);
    vec3 n =getNormal(p);
    
    float dif = clamp(dot(n, l), 0.0, 1.0); 
    
    float d = rayMarch(p + n * SURF_DIST * 2.0, l);
    if (d < length(lightPos - p)) dif *= 0.1;
    
    return dif;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
    vec3 col = vec3(0.0);
    
    vec3 ro = vec3(0.0, 2.0, 2.0);
    vec3 rd = normalize(vec3(uv.x, uv.y - 0.2, 1.0));
	
    float d = rayMarch(ro, rd);
    
    vec3 p = ro + rd * d;
    
    float dif = getLight(p);
    col = vec3(dif);
    fragColor = vec4(col,1.0);
}
