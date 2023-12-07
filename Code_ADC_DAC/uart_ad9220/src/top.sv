module top (
	input clk,    // Clock
	input rst_n,  // Reset, active low
	
	//AD9220硬件接口
	input [11:0]			ad9220_db,
	output					ad9220_clk,

	//uart
	output 					uart_tx
);
parameter CLK_FRE 	= 50; //FPGA 输入MHz
parameter UART_RATE = 115200; //串口波特率
parameter SEND_FRE 	= 2; //串口发送频率
parameter ADC_FRE 	= 1000000; //AD9220采样频率 频率过高（MAX: 10M），由PLL给出，不使用分频

/********************************************************************************/
/**************************    ad9220驱动    ************************************/
/********************************************************************************/
wire [11:0] ad9220_data;
ad9220_top #(
	.CLK_FRE 	(CLK_FRE		),
	.ADC_FRE 	(ADC_FRE		)
)ad9220_top_m0(
	.clk  			(clk				),
	.rst_n 			(rst_n				),

	.ad9220_start 	(1'b1				),//一直采集
	.ad9220_data 	(ad9220_data		),

	.ad9220_db		(ad9220_db			),
	.ad9220_clk		(ad9220_clk			)
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
 	
	.ad9220_data 	(ad9220_data	),

 	.uart_tx		(uart_tx		),
	.uart_rx		(				)
	);

endmodule