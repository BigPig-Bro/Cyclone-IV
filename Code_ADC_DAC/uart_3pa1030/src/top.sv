module top (
	input clk,    // Clock
	input rst_n,  // Reset, active low
	
	//3PA1030硬件接口
	input [ 9:0]			ad1030_db,
	output					ad1030_clk,
	output 					ad1030_oe_n,
	input 					ad1030_otr,

	//uart
	output 					uart_tx
);
parameter CLK_FRE 	= 50; //FPGA 输入MHz
parameter UART_RATE = 115200; //串口波特率
parameter SEND_FRE 	= 2; //串口发送频率
parameter ADC_FRE 	= 5000; //3PA1030采样频率

/********************************************************************************/
/**************************    ad1030驱动    ************************************/
/********************************************************************************/
wire [9:0] ad1030_data;
ad1030_top #(
	.CLK_FRE 	(CLK_FRE		),
	.ADC_FRE 	(ADC_FRE		)
)ad1030_top_m0(
	.clk  			(clk				),
	.rst_n 			(rst_n				),

	.ad1030_start 	(1'b1				),//一直采集
	.ad1030_data 	(ad1030_data		),

	.ad1030_db		(ad1030_db			),
	.ad1030_clk		(ad1030_clk			),
	.ad1030_oe_n 	(ad1030_oe_n 		)
);

/********************************************************************************/
/**************************    串口发送      ************************************/
/********************************************************************************/
uart_top #(
	.CLK_FRE 	(CLK_FRE		),
	.UART_RATE 	(UART_RATE		),
	.SEND_FRE 	(SEND_FRE		)
) uart_top_m0(
 	.clk			(clk			),
 	
	.ad1030_data 	(ad1030_data	),

 	.uart_tx		(uart_tx		),
	.uart_rx		(				)
	);

endmodule