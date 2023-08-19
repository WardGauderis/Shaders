vec3 palette(float t) {
  vec3 a = vec3(0.5, 0.5, 0.5);
  vec3 b = vec3(0.5, 0.5, 0.5);
  vec3 c = vec3(1, 1, 1);
  vec3 d = vec3(0.263, 0.416, 0.557);

  return a + b * cos(6.28318 * (c * t + d));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
  vec2 uv0 = uv;
  vec3 finalcolor = vec3(0);

  for (float i = 0.; i < 4.; i++) {
    uv = fract(uv * 1.5) - 0.5;

    float d = length(uv) * exp(-length(uv0));

    vec3 col = palette(length(uv0) + i * 0.4 + iTime * 0.4);

    d = sin(d * 8. + iTime) / 8.;
    d = abs(d);


    d = pow(0.01 / d, 1.5);

    finalcolor += col * d;
  }

  fragColor = vec4(finalcolor, 1);
}