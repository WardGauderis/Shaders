#define s(a, b, t) smoothstep(a, b, t)

float distLine(vec2 p, vec2 a, vec2 b){
	vec2 pa = p - a;
	vec2 ba = b - a;
	float t = clamp(dot(pa, ba)/dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * t);
}

float N21(vec2 p){
	p = fract(p * vec2(233.34, 851.73));
	p += dot(p, p + 23.45);
	return fract(p.x * p.y);
}

vec2 N22(vec2 p){
	float n = N21(p);
	return vec2(n, N21(p+n));
}

vec2 getPos(vec2 id, vec2 offs){
	vec2 n = N22(id + offs) * iTime;
	return offs + sin(n) * 0.4;
}

float line(vec2 p, vec2 a, vec2 b){
	float d = distLine(p, a, b);
	float m = s(0.03, 0.01, d);
	float d2 = length(a - b);
	m *= s(1.2, 0.8, d2) * 0.5 + s(0.05, 0.03, abs(d2 - 0.75));
	return m;
}

float layer(vec2 uv){
	float m = 0.0;

	vec2 gv = fract(uv) - 0.5;
	vec2 id = floor(uv);

	vec2 p[9];

	int i = 0;
	for (float y = -1.0; y <= 1.0; ++y){
		for (float x = -1.0; x <= 1.0; ++x){
			p[i++] = getPos(id, vec2(x, y));
		}
	}

	float t = iTime * 10.0;
	for (int i = 0; i < 9; ++i){
		m += line(gv, p[4], p[i]);

		vec2 j = (p[i] - gv) * 20.0;
		float sparkle = 1.0 / dot(j, j);

		m += sparkle * (sin(t + fract(p[i].x) * 10.0) * 0.5 + 0.5);
	}
	m += line(gv, p[1], p[3]);
	m += line(gv, p[1], p[5]);
	m += line(gv, p[7], p[3]);
	m += line(gv, p[7], p[5]);
	return m;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord - 0.5 *iResolution.xy)/iResolution.y;
	vec2 mouse = (iMouse.xy/iResolution.xy) - 0.5;

	float m = 0.0;

	float t = iTime * 0.1;
	float s = sin(t);
	float c = cos(t);
	mat2 rot = mat2(c, -s, s, c);
	
	s = sin(-t*5.0);
	c = cos(-t*5.0);
	mat2 rot2 = mat2(c, -s, s, c);

	float gradient = (uv * rot2).y + 0.5;
	uv *= rot;
	mouse *= rot;

	for (float i = 0.0; i < 1.0; i += 1.0 / 4.0){
		float z = fract(i + t);
		float size = mix(10.0, 0.5, z);
		float fade = s(0.0, 0.5, z) * s(1.0, 0.8, z);
		m += layer(uv * size + i * 20.0 - mouse) * fade;
	}

	vec3 base = sin(5.0 * t * vec3(0.345, 0.456, 0.657)) * 0.4 + 0.6;

	vec3 col = m * base;
	float fft = texelFetch(iChannel0, ivec2(0.7, 0.0), 0).x;
	gradient -= fft;
	col -= gradient * base;
	/* if (gv.x > 0.48 || gv.y > 0.48) col = vec3(1.0, 0.0, 0.0); */
	fragColor = vec4(col,1.0);
}

