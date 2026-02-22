shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float a = 1.0;
uniform float b = 1.0;
uniform float c = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 cur = texture(screen_texture, SCREEN_UV);
	vec4 below =
		textureLod(screen_texture, SCREEN_UV, 3) * 1.2 +
		textureLod(screen_texture, SCREEN_UV, 1) * 0.8;
	below -= b;
	below.a = 1.0;
	cur += max(vec4(0.0), below) * c;
	//cur = mix(cur, cur / (cur + 1.0), 0.3);
	COLOR = cur;
	//COLOR = COLOR / (COLOR + 1.0);
	COLOR.a = 1.0;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
