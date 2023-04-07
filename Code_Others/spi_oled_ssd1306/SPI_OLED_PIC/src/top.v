module top (
	input  clk,    // Clock
	input  rst_n,
	
	output oled_cs,
	output oled_sck,
	output oled_rst,
	output oled_dc,
	// input  oled_miso, //oled 无返回值
	output oled_mosi
);
parameter 	CLK_FRE = 50; //输入的时钟频率 Mhz
parameter 	SPI_FRE = 100; //SPI SCK工作时钟频率 步进x10Khz

//OLED 显存
wire [9:0] read_addr;
wire [7:0] read_data;
oled_ram oled_ram_m0(
	.clk 	 	(clk			),

	.write_addr (				),
	.write_data (				),

	.read_addr 	(read_addr		),
	.read_data 	(read_data		)
	);

//OLED控制机
wire send_busy,send_en,send_dc;
wire [7:0] send_data,recv_data;
oled_ctrl#(
	.CLK_FRE (CLK_FRE	 )
	) oled_ctrl_m0(
	.clk 	  		(clk 		),
	.rst_n 			(rst_n 		),
	.state_rst		(oled_rst 	),

	.read_addr 		(read_addr	),
	.read_data 		(read_data	),

	.send_busy	  	(send_busy 	),
	.send_en   		(send_en 	),
	.send_dc   		(send_dc 	),
	.send_data 		(send_data 	)
	);


//SPI 底层驱动
//1、默认工作在 MODE 0
//2、oled 无返回值
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

	.spi_cs   (oled_cs 	 	),
	.spi_dc   (oled_dc  	),
	.spi_sck  (oled_sck 	),
	.spi_miso (  	 		),
	.spi_mosi (oled_mosi 	)
	);

endmodule