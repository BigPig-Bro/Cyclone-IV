module top (
	input  clk,    // Clock
	input  rst_n,
	

	output iic_scl,
	inout  iic_sda
);
parameter 	CLK_FRE = 50; //输入的时钟频率 Mhz
parameter 	IIC_FRE = 400; //IIC SCK工作时钟频率 步进xKhz

parameter   IIC_OLED_SLAVE_ADDR_EX 	= 0;
parameter   IIC_OLED_SLAVE_ADDR 	= 16'h78;

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
wire 		send_busy,send_en;
wire [ 7:0] send_data,send_addr;
wire 		brust_ready,brust_vaild;
oled_ctrl#(
	.CLK_FRE (CLK_FRE	 )
	) oled_ctrl_m0(
	.clk 	  		(clk 			),
	.rst_n 			(rst_n 			),

	.read_addr 		(read_addr		),
	.read_data 		(read_data		),

	.brust_ready	(brust_ready	),		
	.brust_vaild	(brust_vaild	),

	.send_busy	  	(send_busy 		),
	.send_en   		(send_en 		),
	.send_addr   	(send_addr 		),
	.send_data 		(send_data 		)
	);

//IIC 底层驱动
iic_master#(
	.CLK_FRE (CLK_FRE	 ),
	.IIC_FRE (IIC_FRE 	 )
	) iic_master_m0(
	.clk			(clk					),

	.slave_addr_ex	(IIC_OLED_SLAVE_ADDR_EX	),		
	.slave_addr		(IIC_OLED_SLAVE_ADDR	),	
	.send_rw		(1'b0 					),//OLED 只有写没有读	
	.reg_addr		(send_addr				),	
	.send_en		(send_en				),	
	.brust_ready	(brust_ready			),		
	.brust_vaild	(brust_vaild			),		
	.send_data		(send_data				),	
	.recv_data		(						),//OLED 只有写没有读	
	.send_busy		(send_busy				),
		
	.iic_scl		(iic_scl				),	
	.iic_sda		(iic_sda				)	
	);

endmodule