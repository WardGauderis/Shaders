#iUniform float scale = 0.5 in{0.0, 1.0 }

vec3 palette(float t) {
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1, 1, 1);
  vec3 d = vec3(0.263, 0.416, 0.557);

  return a + b * cos(6.28318 * (c * t + d));
}

float sdCircle(in vec2 p, in float r) { return length(p) - r; }

float sdStar5(in vec2 p, in float r, in float rf) {
  const vec2 k1 = vec2(0.809016994375, -0.587785252292);
  const vec2 k2 = vec2(-k1.x, k1.y);
  p.x = abs(p.x);
  p -= 2.0 * max(dot(k1, p), 0.0) * k1;
  p -= 2.0 * max(dot(k2, p), 0.0) * k2;
  p.x = abs(p.x);
  p.y -= r;
  vec2 ba = rf * vec2(-k1.y, k1.x) - vec2(0, 1);
  float h = clamp(dot(p, ba) / dot(ba, ba), 0.0, r);
  return length(p - ba * h) * sign(p.y * ba.x - p.x * ba.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
  vec3 finalcolor = vec3(0.);

  uv = fract(uv) - 0.5;
  uv *= 2.;

  float time = cos(iTime * 1.5) * 0.5 + 0.5;

  float d = sdCircle(uv, time);
  float d1 = sdStar5(uv, time, 0.4);

  d = mix(d, d1, pow(time, 10.0));

  vec3 col = d < 0. ? vec3(0.9, 0.6, 0.3) : vec3(0.65, 0.85, 1.0);

  col *= sin(50. * d);

  fragColor = vec4(col, 1);
}