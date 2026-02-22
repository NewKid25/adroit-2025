shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform bool invert = false;

uniform float a = 1.0;
uniform float b = 1.0;
uniform float c = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 cur = texture(screen_texture, SCREEN_UV);
	//vec4 below =
		//textureLod(screen_texture, SCREEN_UV, 3) * 1.2 +
		//textureLod(screen_texture, SCREEN_UV, 1) * 0.8;
	vec4 below =
		textureLod(screen_texture, SCREEN_UV, 8) +
		textureLod(screen_texture, SCREEN_UV, 4);
	if (invert) {
		below = 2.0 - below;
		cur = 1.0 - cur;
	}
	below -= b;
	below.a = 1.0;
	cur += vec4(max(vec3(0.0), below.rgb) * c, 0.0);
	//cur = mix(cur, cur / (cur + 1.0), 0.3);
	if (invert) {
		cur = 1.0 - cur;
	}
	COLOR = cur;
	//COLOR = COLOR / (COLOR + 1.0);
	COLOR.a = 1.0;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
