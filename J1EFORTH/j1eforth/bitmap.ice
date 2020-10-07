$$if DE10NANO then
$$WIDTH = 640
$$HEIGHT = 480
$$SIZE = 307200
$$end
$$if ULX3S then
$$WIDTH = 320
$$HEIGHT = 240
$$SIZE = 76800
$$end

algorithm bitmap(
    input   uint10  pix_x,
    input   uint10  pix_y,
    input   uint1   pix_active,
    input   uint1   pix_vblank,
    output! uint$color_depth$ pix_red,
    output! uint$color_depth$ pix_green,
    output! uint$color_depth$ pix_blue,
    output! uint1   bitmap_display,
    
    // GPU to SET and GET pixels
    input int16 bitmap_x_write,
    input int16 bitmap_y_write,
    input uint10 bitmap_colour_write,
    input uint1 bitmap_write,
    input int16 bitmap_x_read,
    input int16 bitmap_y_read,
    output uint10 bitmap_colour_read
) <autorun> {
    // 640 x 480 (de10nano) or 320 x 240 (ulx3s) x 10 bit { Arrrgggbbb } colour bitmap
    dualport_bram uint1 bitmap_A[ $SIZE$ ] = uninitialized;
    dualport_bram uint3 bitmap_R[ $SIZE$ ] = uninitialized;
    dualport_bram uint3 bitmap_G[ $SIZE$ ] = uninitialized;
    dualport_bram uint3 bitmap_B[ $SIZE$ ] = uninitialized;

    // Expansion map for { rrr } to { rrrrrr }, { ggg } to { gggggg }, { bbb } to { bbbbbb }
    // or { rrr } tp { rrrrrrrr }, { ggg } to { gggggggg }, { bbb } to { bbbbbbbb }
    uint6 colourexpand3to6[8] = {  0, 9, 18, 27, 36, 45, 54, 255 };
    uint6 colourexpand3to8[8] = {  0, 36, 73, 109, 145, 182, 218, 255 };

    // Setup the address in the bitmap for the pixel being rendered
    // ULX3S half the pix_x and pix_y to double the pixels
$$if DE10NANO then
    bitmap_A.addr0 := pix_x + pix_y * $WIDTH$;
$$end
$$if ULX3S then
    bitmap_A.addr0 := (pix_x>>1) + (pix_y>>1) * $WIDTH$;
$$end
    bitmap_A.wenable0 := 0;
$$if DE10NANO then
    bitmap_R.addr0 := pix_x + pix_y * $WIDTH$;
$$end
$$if ULX3S then
    bitmap_R.addr0 := (pix_x>>1) + (pix_y>>1) * $WIDTH$;
$$end
    bitmap_R.wenable0 := 0;
$$if DE10NANO then
    bitmap_G.addr0 := pix_x + pix_y * $WIDTH$;
$$end
$$if ULX3S then
    bitmap_G.addr0 := (pix_x>>1) + (pix_y>>1) * $WIDTH$;
$$end
    bitmap_G.wenable0 := 0;
$$if DE10NANO then
    bitmap_B.addr0 := pix_x + pix_y * $WIDTH$;
$$end
$$if ULX3S then
    bitmap_B.addr0 := (pix_x>>1) + (pix_y>>1) * $WIDTH$;
$$end
    bitmap_B.wenable0 := 0;
    
    // Bitmap write access for the GPU - Only enable when x and y are in range
    bitmap_A.addr1 := bitmap_x_write + bitmap_y_write * $WIDTH$;
    bitmap_A.wdata1 := colour10(bitmap_colour_write).alpha;
    bitmap_A.wenable1 := 0;
    bitmap_R.addr1 := bitmap_x_write + bitmap_y_write * $WIDTH$;
    bitmap_R.wdata1 := colour10(bitmap_colour_write).red;
    bitmap_R.wenable1 := 0;
    bitmap_G.addr1 := bitmap_x_write + bitmap_y_write * $WIDTH$;
    bitmap_G.wdata1 := colour10(bitmap_colour_write).green;
    bitmap_G.wenable1 := 0;
    bitmap_B.addr1 := bitmap_x_write + bitmap_y_write * $WIDTH$;
    bitmap_B.wdata1 := colour10(bitmap_colour_write).blue;
    bitmap_B.wenable1 := 0;

    // Write to the bitmap
    always {
        if( bitmap_write ) {
            if( (bitmap_x_write >= 0 ) & (bitmap_x_write < $WIDTH$) & (bitmap_y_write >= 0) & (bitmap_y_write < $HEIGHT$) ) {
                bitmap_A.wenable1 = 1;
                bitmap_R.wenable1 = 1;
                bitmap_G.wenable1 = 1;
                bitmap_B.wenable1 = 1;
            }
        }
    }
    
    // Render the bitmap
    while(1) {
        if( ~bitmap_A.rdata0 ) {
            pix_red = colourexpand3to$color_depth$[ bitmap_R.rdata0 ];
            pix_green = colourexpand3to$color_depth$[ bitmap_G.rdata0 ];
            pix_blue = colourexpand3to$color_depth$[ bitmap_B.rdata0 ];
            bitmap_display = 1;
        } else {
            bitmap_display = 0;
        }
    }
}