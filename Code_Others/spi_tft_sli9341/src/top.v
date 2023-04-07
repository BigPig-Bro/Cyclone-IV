module top (
	input  clk,    // Clock
	input  rst_n,
	output tft_cs,
	output tft_sck,
	output tft_rst,
	output tft_dc,
	// input  tft_miso, //tft 无返回值
	output tft_mosi
);
parameter 	CLK_FRE = 50; //输入的时钟频率 Mhz
parameter 	SPI_FRE = 200; //SPI SCK工作时钟频率 步进x10Khz

//tft控制机
wire send_busy,send_en,send_dc;
wire [7:0] send_data,recv_data;
tft_ctrl#(
	.CLK_FRE (CLK_FRE	 )
	) tft_ctrl_m0(
	.clk 	  		(clk 		),
	.rst_n 			(rst_n 		),
	.state_rst		(tft_rst 	),

	.send_busy	  	(send_busy 	),
	.send_en   		(send_en 	),
	.send_dc   		(send_dc 	),
	.send_data 		(send_data 	)
	);


//SPI 底层驱动
//1、默认工作在 MODE 0
//2、tft 无返回值
spi_master#(
	.CLK_FRE (CLK_FRE	 ),
	.SPI_FRE (SPI_FRE 	 )
	) spi_master_m0(
	.clk 	  (clk 			),
	.send_busy(send_busy 	),

	.send_en  (send_en 		),
	.send_dc  (send_dc 	 	),
	.send_data(send_data 	),
	.recv_data(  	 	 	),

	.spi_cs   (tft_cs 	 	),
	.spi_dc   (tft_dc  		),
	.spi_sck  (tft_sck 		),
	.spi_miso (  	 		),
	.spi_mosi (tft_mosi 	)
	);

endmodule