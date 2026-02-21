shader_type canvas_item;

uniform float MOVE_SPEED = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float time = TIME;
	time = floor(TIME * 3.0) / 3.0;
	COLOR = texture(TEXTURE, UV + vec2(0,
		(time * -0.5 * MOVE_SPEED) +
		(TIME * 0.03 * MOVE_SPEED)
	));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
