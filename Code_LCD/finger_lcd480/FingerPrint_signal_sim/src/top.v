module top (
	input 			clk_50M,    // Clock
	input 			rst_n,

	input			key_update,
	input  			key_check,

	output [3:0] 	state_led,

	output			lcd_dclk,lcd_hs,lcd_vs,lcd_de,
	output [7:0] 	lcd_r,lcd_b,lcd_g,

	output [5:0] 	seg_sel,
	output [7:0] 	seg_dig,

	input 			uart_test_rx,
	output 			uart_test_tx,
	input			uart_rx,
	output			uart_tx	
);

wire 		 write_sel;
wire [255:0] write_data;
wire [  7:0] write_add;
wire 	   	 write_clk;
wire [  7:0] video_add;
wire [511:0] video_data;
wire [7:0] search_add,search_add_test;
wire [511:0] search_data;


wire test_clk;
wire video_clk,video_hs,video_vs,video_de;
wire [9:0] video_x;
wire [9:0] video_y;
wire 		check_done;
wire 		update_led;

assign state_led[0] = ~update_led;
assign state_led[1] = ~check_done;
assign state_led[2] =  r > 50 & f < 80;
assign uart_test_tx = uart_rx;
//assign uart_tx = uart_test_rx;

//按键触发 更新指纹 查询指纹
wire update,check;
key key_m0(
	.clk 		(video_clk 		),
	.key_in 	({key_update,key_check}),
	.key_out	({update,check})
	);

//与AS608进行包通信
// uart_top uart_top_m0(
// 	.clk 		(video_clk 		),
// 	.rst_n 		(1'b1 			),

// 	.key_check  (check 			),
// 	.key_update (update 		),

// 	.check_done (check_done 	),
// 	.update_led (update_led	  	),

// 	.ram_sel 	(write_sel 		),
// 	.ram_clk 	(write_clk 		),
// 	.ram_add 	(write_add 		),
// 	.ram_data 	(write_data 	),

// 	.uart_rx 	(uart_rx  		),
// 	.uart_tx 	(uart_tx  		)
// 	);

// //主状态控制 与 结果反馈
// main_state main_state_m0(
// 	.clk 	(video_clk 		),

// 	.update_in  (update 	),
// 	.check_in 	(check 		),

// 	.write_sel (write_sel 	)

// 	);

//指纹的存储与比对
fp_store fp_store(
	.video_out_clk (video_clk		),
	.video_out_add (video_add 		),
	.video_out_data(video_data 		),

	.search_out_clk (test_clk		),
	.search_out_add (search_add 		),
	.search_out_add_test (search_add_test 		),
	.search_out_data(search_data 		)

	);

//测试显示 与 匹配比对
video_pll video_pll_m0(
	.inclk0(clk_50M),
	.c1 (test_clk ),//测试时钟
	.c0(video_clk)
	);

vga_timing vga_timing_m0(
	.clk(video_clk),           //pixel clock
	.rst(1'b0),           //reset signal high active
	.hs(video_hs),            //horizontal synchronization
	.vs(video_vs),            //vertical synchronization
	.de(video_de),            //video valid

	.active_x(video_x),              //video x position 
	.active_y(video_y)             //video y position 
	);

wire [7:0] video_l;

assign lcd_r = video_de?video_l:8'd0;
assign lcd_g = video_de?video_l:8'd0;
assign lcd_b = video_de?video_l:8'd0;
assign lcd_dclk = video_clk;
assign lcd_de = video_de;
assign lcd_hs = video_hs;
assign lcd_vs = video_vs;

wire [7:0] r,f;
display display_m0(
	.video_clk 	(video_clk 	),
	.search_clk (test_clk 	),
	.rst_n 	(rst_n 		),

	.x_in 	(video_x 	),
	.y_in 	(video_y 	),


	.test_done (check),

	.video_ram_add(video_add 	),
	.video_ram_data1(video_data[511:256] ),
	.video_ram_test(video_data[255:0] ),

	.search_ram_add  		(search_add 	 	),
	.search_ram_data1		(search_data[511:256] 		),

	.search_ram_test_add  	(search_add_test 	 	),
	.search_ram_test_data 	(search_data[255:  0] 		),

	.max_right(r),
	.max_false(f),

	.rgb_out(video_l 	)
	);

tra tra_m9(
	.clk (video_hs 	),

	.data_in1(12),
	.data_in2(f),

	.sel(seg_sel),
	.dig(seg_dig)
	);

endmodule