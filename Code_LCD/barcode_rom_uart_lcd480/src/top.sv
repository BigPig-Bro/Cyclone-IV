 module top (
	input 			clk,    // Clock
	input 			rst_n,  // Reset, active low
	
	output 			uart_tx, // 串口发送

	output 			lcd_clk,	
	output 			lcd_hs,	
	output 			lcd_vs,	
	output 			lcd_de,	
	output [23:0] 	lcd_rgb
);

/************************************************/
/**************   模拟摄像头画面  ****************/
/************************************************/
sys_pll sys_pll_m0(
	.inclk0		(clk 		),
	.c0			(lcd_clk 	)
	);

//产生标准空白RGB视频流
wire 		rgb_vs,rgb_hs,rgb_de;
wire [ 9:0] rgb_x,rgb_y;
rgb_timing rgb_timing_m0(
	.rgb_clk	(lcd_clk	),	
	.rgb_rst_n	(rst_n		),	
	.rgb_hs		(rgb_hs		),
	.rgb_vs		(rgb_vs		),
	.rgb_de		(rgb_de		),
	.rgb_x		(rgb_x		),
	.rgb_y		(rgb_y		)
	);

//PIC ROM
wire 		pic_data;
pic pic_m0(
	.clock 	 (lcd_clk			),
	.address (rgb_x + rgb_y * 480 ),
	.q 		 (pic_data 			)
	);

/************************************************/
/**************   图像滤波部分  ******************/
/************************************************/
//对RGB 中值滤波 减少杂点

//在RGB范围内 进行二值化处理（如有必要，建议加YCBCR的色域转换）

//二值后的画面进行形态学处理（先腐蚀后膨胀）算子大小 和 迭代次数由实际决定

//对形态学后画面进行边沿处理，得到完整的边沿数据

/************************************************/
/**************   图像识别部分  ******************/
/************************************************/
//条形码筛选部分 条码为1，背景为0
wire [12:0] [3:0] scan_data;
wire [ 9:0] bar_left,bar_right;
wire scan_en;
thres_scan thres_scan_m0(
	.clk 		(lcd_clk 		),

	.loc_x		(rgb_x			),
	.loc_y		(rgb_y			),
	.thres_de 	(rgb_de 		),
	.thres_data (pic_data 		),

	.scan_en 	(scan_en 		),
	.scan_data	(scan_data 		)
	);

//在标准RGB视频流中显示
display display_m0(
	.x_in 			(rgb_x 			),
	.y_in 			(rgb_y 			),
	.scan_en 		(scan_en 		),

	.in_hs 			(rgb_hs			),
	.in_vs 			(rgb_vs			),
	.in_de 			(rgb_de			),
	.in_data 		(pic_data 		),
		
	.out_hs 		(lcd_hs			),
	.out_vs 		(lcd_vs			),
	.out_de			(lcd_de 		),
	.out_data 		(lcd_rgb		)
	);
/************************************************/
/**************   串口发送部分  ******************/
/************************************************/
uart_top #(
	.CLK_FRE 	(50				),
	.UART_RATE 	(115200			)
	) uart_top_m0(
 	.clk			(clk			),
	
	.scan_data		(scan_data		),

 	.uart_tx		(uart_tx		)
	);
endmodule