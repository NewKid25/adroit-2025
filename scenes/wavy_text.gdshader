shader_type canvas_item;

uniform float scale = 1.0;

void vertex() {
	VERTEX.y += sin(TIME * 2.0 + VERTEX.x * 0.03) * scale;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
