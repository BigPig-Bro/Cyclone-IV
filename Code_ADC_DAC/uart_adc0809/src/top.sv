module top (
	input clk,    // Clock
	input rst_n,  // Reset, active low
	
	//ADC0809硬件接口
	output [ 2:0]			adc0809_addr,
	input [ 7:0]			adc0809_db,
	output 					adc0809_oe,
	output					adc0809_clk,
	output 					adc0809_st,
	input 					adc0809_eoc,
	output 					adc0809_ale,
	
	output reg [3:0] test,
	
	//uart
	output 					uart_tx
);
parameter CLK_FRE 	= 50; //FPGA 输入MHz
parameter UART_RATE = 115200; //串口波特率
parameter SEND_FRE 	= 2; //串口发送频率
parameter ADC_FRE 	= 50000; //ADC0809采样频率

always@(posedge clk) test++;

/********************************************************************************/
/**************************    ADC0809驱动    ************************************/
/********************************************************************************/
wire [7:0][7:0] adc0809_data;
adc0809_top #(
	.CLK_FRE 	(CLK_FRE		),
	.ADC_FRE 	(ADC_FRE		)
)adc0809_top_m0(
	.clk  			(clk				),
	.rst_n 			(rst_n				),

	.adc0809_start 	(1'b1				),//一直采集
	.adc0809_done 	(					),
	.adc0809_data 	(adc0809_data		),

	.adc0809_addr	(adc0809_addr		),
	.adc0809_db		(adc0809_db			),
	.adc0809_oe		(adc0809_oe			),
	.adc0809_clk	(adc0809_clk		),
	.adc0809_st		(adc0809_st			),
	.adc0809_eoc	(adc0809_eoc		),
	.adc0809_ale	(adc0809_ale		)
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
 	
	.adc0809_data 	(adc0809_data	),

 	.uart_tx		(uart_tx		)
	);

endmodule