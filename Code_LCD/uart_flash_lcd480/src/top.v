module top(
	input                       clk,

	input 						uart_rx,

	output          			ncs,
	output          			dclk,
	output          			mosi,
	input           			miso,

	input                       rst_n,
	output                      lcd_dclk,   
	output reg                       lcd_hs,      //lcd horizontal synchronization
	output reg                       lcd_vs,      //lcd vertical synchronization  
	output reg                       lcd_de,      //lcd data valid
	output  [7:0]                 lcd_r,       //lcd red
	output  [7:0]                 lcd_g,       //lcd green
	output  [7:0]                 lcd_b        //lcd blue
);

wire     video_clk;

wire pic_data;
wire[11:0] y_cnt;
wire[11:0] x_cnt;


wire pre_de;
wire pre_hs;
wire pre_vs;

wire [7:0] rx_data;
wire rx_data_valid;

//*****ram相关*****
wire [13:0] flash_data_addr;
wire [13:0] ram_r_addr;
wire [ 7:0] flash_data;
wire [ 7:0] ram_data;

//视频输出
// assign lcd_hs = pre_hs;
// assign lcd_vs = pre_vs;
// assign lcd_de = pre_de;
assign lcd_r  = (pre_de && x_cnt < 256 && y_cnt < 256)?{ram_data[ 7: 5],5'd0}:pre_de?8'h0F:8'd0;//{ram_data[15:11],3'd0}
assign lcd_g  = (pre_de && x_cnt < 256 && y_cnt < 256)?{ram_data[ 4: 2],5'd0}:pre_de?8'h0F:8'd0;//{ram_data[10: 5],2'd0}
assign lcd_b  = (pre_de && x_cnt < 256 && y_cnt < 256)?{ram_data[ 1: 0],6'd0}:pre_de?8'h0F:8'd0;//{ram_data[ 4: 0],3'd0}
assign lcd_dclk = ~video_clk;              //to meet the timing requirements, the clock is inverting

//generate video pixel clock
video_pll video_pll_m0(
	.inclk0   (clk       ),
	
	.c0       (video_clk )
);

uart_rx#
(
	.CLK_FRE(50),
	.BAUD_RATE(9600)
) uart_rx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_data                  ),
	.rx_data_valid              (rx_data_valid            ),
	.rx_data_ready              (1'b1		              ),
	.rx_pin                     (uart_rx                  )
);

flash_ctrl flash_ctrl_m0(
	.clk 			(clk 		),
	.rst_n 			(rst_n 		),

	.data_in 		(rx_data 	),
	.data_in_en 	(rx_data_valid),

	.data_out 		(flash_data ),
	.data_out_en 	(flash_data_en),
	.data_out_addr  (flash_data_addr),

	.ncs  (ncs ),
	.miso (miso),
	.mosi (mosi),
	.dclk (dclk) 		
	);

vga_timing vga_timing_m0(
	.clk      (video_clk ),
	
	.rst      (~rst_n    ),
	.hs       (pre_hs    ),
	.vs       (pre_vs    ),
	.de       (pre_de    ),
	.active_x (x_cnt      ),
	.active_y (y_cnt      )
);

assign ram_r_addr = x_cnt[11:1] + y_cnt[11:1] * 128;

vga_ram	vga_ram_m0 (
	.wrclock 		( clk 			),
	.data 			( flash_data 	),
	.wraddress 		( flash_data_addr),
	.wren 			( flash_data_en ),

	.rdclock 		( video_clk 	),
	.rdaddress 		( ram_r_addr    ),
	.q 				( ram_data 		)
	);

always@(posedge video_clk)
begin
	lcd_hs <= pre_hs;
	lcd_vs <= pre_vs;
	lcd_de <= pre_de;
end

endmodule