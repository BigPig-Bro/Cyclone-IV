module top (
	//时钟复位接口
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	//超声波接口
	input echo,
	output trig,

	//串口接口
	output uart_tx
);

parameter  CLK_FRE = 50; 		//时钟 Mhz
parameter  UART_RATE = 115200;  //串口波特率 

//HC SR04驱动
wire [15:0] data;
hc_sr04_ctr #(
	.CLK_FRE 	(CLK_FRE	)
	)hc_sr04_ctr_m0(
 	.clk			(clk			),

 	.echo			(echo			),
 	.trig			(trig			),

 	.data			(data			)
	);

//串口收发
uart_top #(
	.CLK_FRE 	(CLK_FRE	),
	.UART_RATE 	(UART_RATE	)
	) uart_top_m0(
 	.clk			(clk			),
 	
 	.data			(data			),

 	.uart_tx		(uart_tx		)
	);
endmodule
