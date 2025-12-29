shader_type canvas_item;

uniform float strength = 1.0;

void fragment() {
    vec2 px = TEXTURE_PIXEL_SIZE * strength;

    float a = 0.0;
    a += texture(TEXTURE, UV + vec2(-px.x, -px.y)).a;
    a += texture(TEXTURE, UV + vec2( 0.0, -px.y)).a;
    a += texture(TEXTURE, UV + vec2( px.x, -px.y)).a;
    a += texture(TEXTURE, UV + vec2(-px.x,  0.0)).a;
    a += texture(TEXTURE, UV).a;
    a += texture(TEXTURE, UV + vec2( px.x,  0.0)).a;
    a += texture(TEXTURE, UV + vec2(-px.x,  px.y)).a;
    a += texture(TEXTURE, UV + vec2( 0.0,  px.y)).a;
    a += texture(TEXTURE, UV + vec2( px.x,  px.y)).a;

    a /= 9.0;
	a = min(a,0.75);
    COLOR = vec4(0.0, 0.0, 0.0, a);
}
