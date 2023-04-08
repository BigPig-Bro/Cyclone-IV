/*============================================================================
*
*  LOGIC CORE:          显示设备驱动硬件配置头文件
*  MODULE NAME:         camera_init()
*  COMPANY:             武汉芯路恒科技有限公司
*                       http://xiaomeige.taobao.com
*  author:					小梅哥
*  Website:					www.corecourse.cn
*  REVISION HISTORY:  
*
*  Revision: 				1.0  04/10/2019     
*  Description: 			Initial Release.
*
*  FUNCTIONAL DESCRIPTION:
===========================================================================*/

module camera_init(
	Clk,
	Rst_n,
	
	Init_Done,
	camera_rst_n,
	camera_pwdn,
	
	i2c_sclk,
	i2c_sdat
);
	parameter IMAGE_FLIP   = 1'b1;
	parameter IMAGE_MIRROR = 1'b1;
	
	input Clk;
	input Rst_n;
	
	output reg Init_Done;
	output camera_rst_n;
	output camera_pwdn;

	output i2c_sclk;
	inout i2c_sdat;
	
	assign camera_pwdn = 0;
	
	wire [15:0]addr;
	reg wrreg_req;
	reg rdreg_req;
	wire [7:0] wrdata;
	
	wire [7:0]rddata;
	wire RW_Done;
	wire ack;
   
   reg [7:0]cnt;
	wire [15:0]lut;
	
	localparam device_id = 8'h42;
	localparam addr_mode = 1'b0;
	
	localparam lut_size = 115;

	ov7670_init_table_rgb
	#(
		.IMAGE_FLIP(IMAGE_FLIP),
		.IMAGE_MIRROR(IMAGE_MIRROR)
	)
	camera_init_table(
		.addr(cnt),
		.clk(Clk),
		.q(lut)
	);
	assign addr = lut[15:8];
	assign wrdata = lut[7:0];
	
	i2c_control i2c_control(
		.Clk(Clk),
		.Rst_n(Rst_n),
		.wrreg_req(wrreg_req),
		.rdreg_req(0),
		.addr(addr),
		.addr_mode(addr_mode),
		.wrdata(wrdata),
		.rddata(rddata),
		.device_id(device_id),
		.RW_Done(RW_Done),
		.ack(ack),		
		.i2c_sclk(i2c_sclk),
		.i2c_sdat(i2c_sdat)
	);
	
	wire Go; //initial enable
	reg [15:0] delay_cnt;

	always @ (posedge Clk or negedge Rst_n)
	if (!Rst_n)
		delay_cnt <= 16'd0;
	else if (delay_cnt == 16'hffff)
		delay_cnt <= delay_cnt;
	else
		delay_cnt <= delay_cnt + 1'd1;
	
	assign Go = (delay_cnt == 16'hfffe) ? 1'b1 : 1'b0;

	assign camera_rst_n = Rst_n;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		cnt <= 0;
	else if(Go) 
		cnt <= 0;
	else if(cnt < lut_size)begin
		if(RW_Done && (!ack))
			cnt <= cnt + 1'b1;
		else
			cnt <= cnt;
	end
	else
		cnt <= 0;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)
		Init_Done <= 0;
	else if(Go) 
		Init_Done <= 0;
	else if(cnt == lut_size)
		Init_Done <= 1;

	reg [1:0]state;
	
	always@(posedge Clk or negedge Rst_n)
	if(!Rst_n)begin
		state <= 0;
		wrreg_req <= 1'b0;
	end
	else if(cnt < lut_size)begin
		case(state)
			0:
				if(Go)
					state <= 1;
				else
					state <= 0;
			1:
				begin
					wrreg_req <= 1'b1;
					state <= 2;
				end
			2:
				begin
					wrreg_req <= 1'b0;
					if(RW_Done)
						state <= 1;
					else
						state <= 2;
				end
			default:state <= 0;
		endcase
	end
	else
		state <= 0;

endmodule
