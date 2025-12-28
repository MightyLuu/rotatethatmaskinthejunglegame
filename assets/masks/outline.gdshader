shader_type canvas_item;

// Farbe der Outline
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);

// Dicke der Outline in Pixeln
uniform float thickness : hint_range(0.1, 4.0) = 1.0;
uniform float inner_alpha : hint_range(0.0, 1) = 0.5;
uniform float outa_alpha : hint_range(0.0, 1) = 0.5;

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    // Nur ursprüngliche Sprite-Pixel betrachten
    if (base.a < 0.01) {
        discard;
    }

    vec2 px = TEXTURE_PIXEL_SIZE * thickness;

    // direkte Nachbarn
    float a_left  = texture(TEXTURE, UV + vec2(-px.x, 0)).a;
    float a_right = texture(TEXTURE, UV + vec2( px.x, 0)).a;
    float a_up    = texture(TEXTURE, UV + vec2(0, -px.y)).a;
    float a_down  = texture(TEXTURE, UV + vec2(0,  px.y)).a;

    // diagonale Nachbarn
    float a_tl = texture(TEXTURE, UV + vec2(-px.x, -px.y)).a;
    float a_tr = texture(TEXTURE, UV + vec2( px.x, -px.y)).a;
    float a_bl = texture(TEXTURE, UV + vec2(-px.x,  px.y)).a;
    float a_br = texture(TEXTURE, UV + vec2( px.x,  px.y)).a;

    bool neighbor_edge = (a_left < 0.01 || a_right < 0.01 || a_up < 0.01 || a_down < 0.01 ||
                 a_tl < 0.01 || a_tr < 0.01 || a_bl < 0.01 || a_br < 0.01);


// Edge durch Sprite-Rand
vec2 uv_thickness = px; // entspricht 1 Pixel in UV
bool at_border = (UV.x < uv_thickness.x || UV.x > 1.0 - uv_thickness.x ||
                  UV.y < uv_thickness.y || UV.y > 1.0 - uv_thickness.y);

// Gesamtkante
bool edge = neighbor_edge || at_border;
	
	
    // Nur Kanten zeichnen
    if (edge) {
        COLOR = outline_color;
    } else {
        COLOR.a = inner_alpha; // Innen komplett transparent
    }

}
