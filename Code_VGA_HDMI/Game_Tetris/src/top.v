module top(
	input 					clk,
	input					rst_n,

	input 					key_sw_pre,
	input 					key_l_pre,
	input 					key_r_pre,

	output					lcd_rst_n,
	output [7:0] 			lcd_r,
	output [7:0]			lcd_g,
	output [7:0]			lcd_b,
	output 					lcd_dclk,
	output 					lcd_hs,
	output 					lcd_vs,
	output					lcd_pwm,
	output 					lcd_de
);

wire			key_sw;
wire 			key_l;
wire 			key_r;

wire 			fst_hs;
wire			fst_vs;
wire 			fst_de;
wire [9:0]		fst_x;
wire [9:0]		fst_y;

assign lcd_rst_n = rst_n;

//按键消抖
key key_m0(
	.clk 		(clk 		),
	.key 		(key_sw_pre ),
	.key_out 	(key_sw 	)
	);

key key_m1(
	.clk 		(clk 		),
	.key 		(key_l_pre ),
	.key_out 	(key_l 		)
	);

key key_m2(
	.clk 		(clk 		),
	.key 		(key_r_pre ),
	.key_out 	(key_r 		)
	);

//生成一个标准空白画面时序
video_pll video_pll_m0(
	.inclk0  	(clk 		),
	
	.c0			(lcd_dclk 	)
	);

vga_timing vga_timing_m0(
	.clk 		(lcd_dclk 	),
	.rst 		(~rst_n		),

	.hs 		(fst_hs 	),
	.vs 		(fst_vs 	),
	.de 		(fst_de 	),
	.active_x  	(fst_x 		),
	.active_y	(fst_y	 	)
	);

//填充具体的画面像素
lcd_display lcd_display_m0(
	.clk 		(lcd_dclk 	),
	.rst_n 		(rst_n		),
	.key_sw 	(key_sw 	),
	.key_l		(key_l		),
	.key_r		(key_r		),

	.hs_in		(fst_hs 	),
	.de_in		(fst_de 	),
	.vs_in		(fst_vs 	),
	.x_in		({6'd0,fst_x}),
	.y_in		({6'd0,fst_y}),

	.hs_out		(lcd_hs 	),
	.de_out		(lcd_de 	),
	.vs_out		(lcd_vs 	),	
	.rgb_out	({lcd_r,lcd_g,lcd_b}),
	.pwm_out 	(lcd_pwm 	)	
	);
endmodule 