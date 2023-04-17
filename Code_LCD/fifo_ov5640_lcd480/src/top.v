module top(
	input                       clk,
	input                       rst_n,
	output                       cmos_scl,          //cmos i2c clock
	inout                       cmos_sda,          //cmos i2c data
	input                       cmos_vsync,        //cmos vsync
	input                       cmos_href,         //cmos hsync refrence,data valid
	input                       cmos_pclk,         //cmos pxiel clock
//  output                      cmos_xclk,         //cmos externl clock 新款内置晶振
	input   [7:0]               cmos_db,           //cmos data
//	output                      cmos_rst_n,        //cmos reset 新款不支持
	output                      cmos_pwdn,         //cmos power down
	output                      lcd_dclk,	
	output                      lcd_hs,            //lcd horizontal synchronization
	output                      lcd_vs,            //lcd vertical synchronization        
	output                      lcd_de,            //lcd data enable     
	output[7:0]                 lcd_r,             //lcd red
	output[7:0]                 lcd_g,             //lcd green
	output[7:0]                 lcd_b	           //lcd blue
);

wire                            video_clk;         //video pixel clock
wire                            hs;
wire                            vs;
wire                            de;
wire[15:0]                      vout_data;
wire[15:0]                      cmos_16bit_data;
wire[15:0] 						write_data;

assign lcd_hs = hs;
assign lcd_vs = vs;
assign lcd_de = de;
assign lcd_r  = {vout_data[15:11],3'd0};
assign lcd_g  = {vout_data[10:5],2'd0};
assign lcd_b  = {vout_data[4:0],3'd0};
assign lcd_dclk = ~video_clk;

assign cmos_pwdn = 1'b0;
assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};
//generate the CMOS sensor clock and the SDRAM controller clock
sys_pll sys_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (video_clk 	              )
	);

//I2C master controller
iic_ctrl#(
 .CLK_FRE                	(50     					),
 .IIC_FRE                	(100    					),
 .IIC_SLAVE_REG_EX       	(1      					),
 .IIC_SLAVE_ADDR_EX      	(0      					),
 .IIC_SLAVE_ADDR         	(16'h78 					),
 .INIT_CMD_NUM           	(256    					)
 ) iic_ctrl_m0(	
 .clk                        (clk                      ),
 .rst_n                      (rst_n                    ),
 .iic_scl                    (cmos_scl                 ),
 .iic_sda                    (cmos_sda                 )
 );

//CMOS sensor 8bit data is converted to 16bit data
cmos_8_16bit cmos_8_16bit_m0(
	.rst_n                      (rst_n                    ),
	.pclk                       (cmos_pclk                ),
	.pdata_i                    (cmos_db                  ),
	.de_i                       (cmos_href                ),
	.pdata_o                    (cmos_16bit_data          ),
	.hblank                     (                         ),
	.de_o                       (cmos_16bit_wr            )
);

//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                ),

	.fifo_data_in   			(write_data 		  	  ),
	.fifo_data_in_en			(cmos_16bit_wr 			  ),
	.fifo_data_in_clk			(cmos_pclk 			  	  ),
	.fifo_data_vs  				(cmos_vsync 			  ),

	.hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),
	.vout_data                  (vout_data                )
);

endmodule