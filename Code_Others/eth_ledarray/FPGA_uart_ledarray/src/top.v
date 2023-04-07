module top (
	input clk_50M,    // Clock
	
	input uart_rx,output reg [7:0] cnt,

	output led_A,led_B,led_C,led_D,led_G,led_DI,led_CLK,led_LAT	
);
wire [55:0] rx_data;
wire light;

always@(posedge clk_50M)
	cnt <= cnt + 1;

uart_rx#
(
	.CLK_FRE(50),
	.BAUD_RATE(115200)
) uart_rx_inst
(
	.clk                        (clk_50M                  ),
	.rst_n                      (1'b1                     ),
	.rx_data                    (rx_data               	  ),
	.light 						(light_in 				  ),
	.rx_data_ready              (1'b1		              ),
	.rx_pin                     (uart_rx                  )
);

led_ctrl led_ctrl_m0(
	.clk 						(clk_50M 				),

	.data_in 					(rx_data 				),
	.light_ctrl 				(light_in 				),

	.led_A 						(led_A 				 	),
	.led_B 						(led_B 				 	),
	.led_C 						(led_C 				 	),
	.led_D 						(led_D 				 	),
	.led_G 						(led_G 				 	),
	.led_DI 					(led_DI 				),
	.led_CLK 					(led_CLK 				),
	.led_LAT 					(led_LAT 				)
	);

endmodule
