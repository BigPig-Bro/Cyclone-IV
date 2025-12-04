module top (
	input 				i_clk,    // Clock

	input [2:0]         i_key_A, i_key_B, // Keys [1:0] A B [2] Enter
	
	output              o_lcd_clk,	
	output              o_lcd_hs,    //lcd horizontal synchronization
	output              o_lcd_vs,    //lcd vertical synchronization        
	output              o_lcd_de,    //lcd data enable     
	output 	  [23:0]    o_lcd_rgb
);
/********************************************************************************/
/**************************      KEY           **********************************/
/********************************************************************************/
wire     		[7:0]   reg_A, reg_B;
Encoder_top #(
	.CLK_FRE        (50_000_000     ) //50MHz
)Encoder_top_m0(
	.i_clk          (i_clk          ),
	.i_key_A        (i_key_A        ),
	.i_key_B        (i_key_B        ),
	.o_reg_A        (reg_A          ),
	.o_reg_B        (reg_B          )
);

/********************************************************************************/
/**************************     RGB_Display    **********************************/
/********************************************************************************/
wire rgb_clk;
video_pll video_pll_m0(
	.inclk0  	(i_clk 		),
	.c0 		(rgb_clk 	)
	);
	
rgb_top rgb_top_m0(
	.i_rgb_clk		(rgb_clk	),

	.i_reg_A		(reg_A		),
	.i_reg_B		(reg_B		),

	.o_lcd_clk		(o_lcd_clk	),
	.o_lcd_hs		(o_lcd_hs	),
	.o_lcd_vs		(o_lcd_vs	),
	.o_lcd_de		(o_lcd_de	),
	.o_lcd_rgb		(o_lcd_rgb	)
);


endmodule