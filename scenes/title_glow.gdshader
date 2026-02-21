shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

float sfunmod(float x) {
	float targ = mod(TIME * 0.1, 0.5);
	float dist = x - targ + 1.0;
	dist = 1.0 - dist;
	dist /= 0.3;
	dist = 1.0 - dist;
	if (x > targ) dist = pow(2.0 - dist, 10.0);
	return clamp(dist, 0.0, 1.0);
}

float funmod(float x) {
	if (x > 0.5) x = 1.0 - x;
	return sfunmod(x) + sfunmod(x - 0.5) + sfunmod(x + 0.5);
}

void fragment() {
	float fun = funmod(UV.x);
	COLOR *= 1.0 + fun * 0.06;
	COLOR += fun * 0.04;
	//COLOR = vec4(vec3(fun), 1);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
