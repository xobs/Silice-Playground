algorithm background(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,

    input uint6 backgroundcolour,
    input uint6 backgroundcolour_alt,
    input uint3 backgroundcolour_mode,
    input uint3 backgroundcolour_fade,
    input uint3 backgroundcolour_write
) <autorun> {
    // Expansion map for { rr } to { rrrrrr }, { gg } to { gggggg }, { bb } to { bbbbbb }
    // or { rr } tp { rrrrrrrr }, { gg } to { gggggggg }, { bb } to { bbbbbbbb }
    uint6 colourexpand2to6[4] = {  0, 21, 42, 63 };
    uint8 colourexpand2to8[4] = {  0, 85, 170, 255 };

    uint6 background = 0;
    uint6 background_alt = 0;
    uint3 background_mode = 0;
    uint3 background_fade = 0;
    
    always {
        switch( backgroundcolour_write ) {
            case 1: {
                background = backgroundcolour;
            }
            case 2: {
                background_alt = backgroundcolour_alt;
            }
            case 3: {
                background_mode = backgroundcolour_mode;
            }
            case 4: {
                background_fade = backgroundcolour_fade;
            }
            default: {}
        }
    }
    
    while(1) {
        switch( backgroundcolour_mode ) {
            case 0: {
                // SOLID
                pix_red = colourexpand2to$color_depth$[ colour6(background).red ] >> background_fade;
                pix_green = colourexpand2to$color_depth$[ colour6(background).green ] >> background_fade;
                pix_blue = colourexpand2to$color_depth$[ colour6(background).blue ] >> background_fade;
            }
            default: {
                pix_red = 0;
                pix_green = 0;
                pix_blue = 0;
            }
        }
    }
}
