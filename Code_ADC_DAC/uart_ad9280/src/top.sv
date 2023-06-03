module top (
	input clk,    // Clock
	input rst_n,  // Reset, active low
	
	//AD9280硬件接口
	input [ 7:0]			ad9280_db,
	output					ad9280_clk,

	//uart
	output 					uart_tx
);
parameter CLK_FRE 	= 50; //FPGA 输入MHz
parameter UART_RATE = 115200; //串口波特率
parameter SEND_FRE 	= 2; //串口发送频率
parameter ADC_FRE 	= 500; //AD9280采样频率

/********************************************************************************/
/**************************    ad9280驱动    ************************************/
/********************************************************************************/
wire [7:0] ad9280_data;
ad9280_top #(
	.CLK_FRE 	(CLK_FRE		),
	.ADC_FRE 	(ADC_FRE		)
)ad9280_top_m0(
	.clk  			(clk				),
	.rst_n 			(rst_n				),

	.ad9280_start 	(1'b1				),//一直采集
	.ad9280_data 	(ad9280_data		),

	.ad9280_db		(ad9280_db			),
	.ad9280_clk		(ad9280_clk			)
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
 	
	.ad9280_data 	(ad9280_data	),

 	.uart_tx		(uart_tx		),
	.uart_rx		(				)
	);

endmodule