module top (
	input clk,    // Clock
	input rst_n,  // Reset, active low
	
	//AD7606硬件接口
	output 					ad7606_convstA,	ad7606_convstB,
	output    				ad7606_range,
	input 		[15:0]		ad7606_db,		
	output 					ad7606_cs_n,	
	output 					ad7606_rd_n,	
	input 					ad7606_busy,	
	output 		[2:0]		ad7606_os,		
	output 					ad7606_rst,

	//uart
	output 					uart_tx
);
parameter CLK_FRE 	= 50; //FPGA 输入MHz
parameter UART_RATE = 115200; //串口波特率
parameter SEND_FRE 	= 2; //串口发送频率
parameter ADC_FRE 	= 1000; //AD7606采样频率

/********************************************************************************/
/**************************    AD7606驱动    ************************************/
/********************************************************************************/
wire [7:0][15:0] ad7606_data;
ad7606_top #(
	.CLK_FRE 	(CLK_FRE		),
	.ADC_FRE 	(ADC_FRE		)
)ad7606_top_m0(
	.clk  			(clk			),
	.rst_n 			(rst_n			),

	.ad7606_start 	(1'b1			),//一直采集
	.ad7606_done 	(				),
	.ad7606_data 	(ad7606_data	),

	.ad7606_convstA (ad7606_convstA	),
	.ad7606_convstB (ad7606_convstB	),
	.ad7606_range   (ad7606_range 	),
	.ad7606_db 		(ad7606_db		),
	.ad7606_cs_n 	(ad7606_cs_n	),
	.ad7606_rd_n 	(ad7606_rd_n	),
	.ad7606_busy 	(ad7606_busy	),
	.ad7606_os 		(ad7606_os		),
	.ad7606_rst 	(ad7606_rst		)
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
 	
	.ad7606_data 	(ad7606_data	),

 	.uart_tx		(uart_tx		)
	);

endmodule