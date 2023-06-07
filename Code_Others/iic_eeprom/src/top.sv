module top(
    input           clk,
    input           rst_n,

    output          data_beat,

    inout           iic_sda,
    output          iic_scl
);
parameter CLK_FRE 				= 50; //FPGA输入时钟 50Mhz
parameter IIC_FRE 				= 400;//IIC CLK时钟频率 100Khz
parameter IIC_SLAVE_ADDR_EX 	= 0;//0 7位地址模式 1 10位地址模式
parameter IIC_SLAVE_ADDR 		= 8'b10100000;//IIC 从机地址
parameter IIC_SLAVE_REG_EX 		= 1;//0 8位寄存器地址 1 16位寄存器地址

parameter TEST_FRE              = 2; //测试读写频率 1Hz
/********************************************************************************/
/**************************      控制逻辑   ************************************/
/********************************************************************************/
wire                                    iic_start,iic_busy;
wire                                    reg_rw;
wire [7 + IIC_SLAVE_REG_EX  * 8 :0]     reg_addr;
wire [7:0]                              send_data,recv_data;
eeprom_test eeprom_test_m0(
    .clk            (clk                ),
    .rst_n          (rst_n              ),

    .iic_start      (iic_start          ),
    .iic_busy       (iic_busy           ),
    .reg_rw         (reg_rw             ),
    .reg_addr       (reg_addr           ),
    .send_data      (send_data          ),
    .recv_data      (recv_data          ),

    .data_beat      (data_beat          )
);


/********************************************************************************/
/**************************      IIC驱动   ************************************/
/********************************************************************************/
// 注 ： 由于各个器件的读取时序并不相同，以下例化仅适用于EEPROM的读取和写入
iic_master#(
	.CLK_FRE 				(CLK_FRE	 			),
	.IIC_FRE 				(IIC_FRE 	 			),
	.IIC_SLAVE_ADDR_EX 		(IIC_SLAVE_ADDR_EX      ),
	.IIC_SLAVE_REG_EX 		(IIC_SLAVE_REG_EX 	    )
	) iic_master_m0(
	.clk			(clk					),

	.iic_busy		(iic_busy				),
	.iic_start		(iic_start				),	
	.slave_addr		(IIC_SLAVE_ADDR	        ),	
	.send_rw		(reg_rw 				),	
	.reg_addr		(reg_addr				),		
	.send_data		(send_data				),	
	.recv_data		(recv_data				),

    .brust_ready	(						),	//此例程未涉及连续读写	
	.brust_vaild	(1'b0					),		
		
	.iic_scl		(iic_scl				),	
	.iic_sda		(iic_sda				)	
	);
endmodule 