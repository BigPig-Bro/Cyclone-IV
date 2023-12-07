module top (
	input clk,    // Clock
	
	output              lcd_clk,	
	output              lcd_hs,    //lcd horizontal synchronization
	output              lcd_vs,    //lcd vertical synchronization        
	output              lcd_de,    //lcd data enable     
	output 	  [23:0]    lcd_rgb
);

parameter PIXEL_NUM = 800 ;

wire [9:0] lcd_x,lcd_y;

assign lcd_rgb = lcd_de? 
(lcd_x < PIXEL_NUM *  1 / 24	)? 24'H800000: (lcd_x < PIXEL_NUM *  2 / 24 )? 24'H400000: 
(lcd_x < PIXEL_NUM *  3 / 24	)? 24'H200000: (lcd_x < PIXEL_NUM *  4 / 24 )? 24'H100000:
(lcd_x < PIXEL_NUM *  5 / 24	)? 24'H080000: (lcd_x < PIXEL_NUM *  6 / 24 )? 24'H040000:
(lcd_x < PIXEL_NUM *  7 / 24	)? 24'H020000: (lcd_x < PIXEL_NUM *  8 / 24 )? 24'H010000:
(lcd_x < PIXEL_NUM *  9 / 24	)? 24'H008000: (lcd_x < PIXEL_NUM * 10 / 24 )? 24'H004000:
(lcd_x < PIXEL_NUM * 11 / 24	)? 24'H002000: (lcd_x < PIXEL_NUM * 12 / 24 )? 24'H001000:
(lcd_x < PIXEL_NUM * 13 / 24	)? 24'H000800: (lcd_x < PIXEL_NUM * 14 / 24 )? 24'H000400:
(lcd_x < PIXEL_NUM * 15 / 24	)? 24'H000200: (lcd_x < PIXEL_NUM * 16 / 24 )? 24'H000100:
(lcd_x < PIXEL_NUM * 17 / 24	)? 24'H000080: (lcd_x < PIXEL_NUM * 18 / 24 )? 24'H000040:
(lcd_x < PIXEL_NUM * 19 / 24	)? 24'H000020: (lcd_x < PIXEL_NUM * 20 / 24 )? 24'H000010:
(lcd_x < PIXEL_NUM * 21 / 24	)? 24'H000008: (lcd_x < PIXEL_NUM * 22 / 24 )? 24'H000004:
(lcd_x < PIXEL_NUM * 23 / 24	)? 24'H000002: 24'H000001 : 24'H000000;

wire rgb_clk;
video_pll video_pll_m0(
	.inclk0  	(clk 		),
	.c0 		(rgb_clk 	)
	);

assign lcd_clk = ~rgb_clk;
rgb_timing rgb_timing_m0(
	.rgb_clk	(rgb_clk	),	
	.rgb_rst_n	(1'b1		),	
	.rgb_hs		(lcd_hs		),
	.rgb_vs		(lcd_vs		),
	.rgb_de		(lcd_de		),
	.rgb_x		(lcd_x		),
	.rgb_y		(lcd_y		)
	);
endmodule