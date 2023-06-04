module top (
	input 			clk,    // Clock
	input 			rst_n,

	input  			uart_rx,
	
	output 			vga_hs,
	output 			vga_vs,
	output [15:0] 	vga_data
);
parameter CLK_FRE 	= 50;
parameter UART_RATE = 9600;

video_pll video_pll_m0(
	.inclk0 		(clk 			),
	.c0 			(rgb_clk 		),	
);

//RGB视频流生成时序 (无数据)
wire 		rgb_clk;
wire 		rgb_vs,rgb_hs,rgb_de;
wire [11:0] rgb_x,rgb_y;

rgb_timing m1(
	.rgb_clk	(rgb_clk			),	
	.rgb_rst_n	(rst_n				),	
	.rgb_hs		(rgb_hs				),
	.rgb_vs		(rgb_vs				),
	.rgb_de		(rgb_de				),
	.rgb_x		(rgb_x				),
	.rgb_y		(rgb_y				)
	);

//RGB视频数据显示
wire [23:0] 	vga_data_r;
assign vga_data [15:11] = vga_data_r [23:19];
assign vga_data [10: 5] = vga_data_r [15:10];
assign vga_data [ 4: 0] = vga_data_r [ 7: 3];

display m2(
	.clk 		(rgb_clk 			),
	
	.hs_in 		(rgb_hs				),
	.vs_in 		(rgb_vs				),
	.de_in 		(rgb_de				),
	.x_in 		(rgb_x				),
	.y_in 		(rgb_y				),
	
	.game_state (game_state 	  	),
	.mole_score (mole_score 		),
	.mole_find 	(mole_find 		  	),
	.left_time	(left_time		  	),
		
	.hs_out 	(vga_hs				),
	.vs_out 	(vga_vs				),
	.de_out 	(					),
	.data_out 	(vga_data_r			)
	);

//串口指令解码
//字符 ABCD EFGH IJKL MNOP
wire [7:0] 	rx_data;
wire 		rx_data_en;
uart_rx#(
	.CLK_FRE(CLK_FRE),
	.UART_RATE(UART_RATE)
) uart_rx_inst(
	.clk            (clk          	  ),
	.recv_data      (rx_data          ),
	.recv_en 		(rx_data_en    	  ),
	.rx_pin         (uart_rx          )
);

//游戏状态控制
wire [11:0] left_time;
wire [ 3:0] mole_find;
wire [ 7:0] mole_score;
wire [ 1:0] game_state;
game_ctrl #(
	.CLK_FRE 		(CLK_FRE 			)
)m4(
	.clk            (rgb_clk 	        ),
	.vs_in 			(rgb_vs			  	),
	.rst_n          (rst_n            	),
	
	.rx_data        (rx_data          	),
	.rx_data_en  	(rx_data_en    	),

	.state 			(game_state 	 	),
	.mole_find 		(mole_find 		 	),
	.mole_score 	(mole_score 		),
	.left_time		(left_time		 	)
	);


endmodule