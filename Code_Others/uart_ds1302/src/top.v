module top (
	input clk,    // Clock
	input rst_n,
	output reg [15:0] cnt,
	output ds1302_sck,
	inout  ds1302_dat,
	output ds1302_rst, // CE

	// input uart_rx, 例程不需要接收
	output uart_tx
);
always@(posedge clk) cnt <= cnt + 1;
parameter CLK_FRE = 50;

wire [7:0] sec;
ds1302_top#(
	.CLK_FRE 	(CLK_FRE 	),
	.DS1302_FRE (100000		),

	//复位时间
	.START_SEC 	(8'H01 		),// 秒 
	.START_MIN 	(8'H01 		),// 分
	.START_HOU 	(8'H12 		),// 时
	.START_DAY 	(8'H01 		),// 日
	.START_MON 	(8'H01 		),// 月
	.START_WEK 	(8'H01 		),// 周
	.START_YEA 	(8'H22 		) // 年
	) m1(
	.clk 		(clk 		),
	.rst_n		(rst_n 		),

	.sec_data 	(sec 		),
	.min_data 	(			),
	.hou_data 	(			),
	.day_data 	(			),
	.mon_data 	(			),
	.wek_data 	(			),
	.yea_data 	(			),

	.ds1302_sck (ds1302_sck ),
	.ds1302_dat (ds1302_dat ),
	.ds1302_rst (ds1302_rst )
	);

uart_top #(
	.CLK_FRE   (CLK_FRE	),
	.BAUD_RATE (115200	)
	)m2(
	.clk		(clk 	 ),
	.rst_n		(rst_n 	 ),

	.sec_data 	(sec 	 ),

	.uart_rx	(	 	 ),	
	.uart_tx	(uart_tx )	
	);


endmodule