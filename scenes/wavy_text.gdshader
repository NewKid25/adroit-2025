shader_type canvas_item;

uniform vec4 text_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void vertex() {
	VERTEX.y += sin(TIME * 2.0 + VERTEX.x * 0.03) * 2.0;
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
