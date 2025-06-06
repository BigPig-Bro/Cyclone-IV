module top(
	//时钟和复位信号
	input                       clk,
	input                       rst_n,
	input 						key_sel,

	//CMOS传感器接口
	inout                       cmos_scl,          //cmos i2c clock
	inout                       cmos_sda,          //cmos i2c data
	input                       cmos_vsync,        //cmos vsync
	input                       cmos_href,         //cmos hsync refrence,data valid
	input                       cmos_pclk,         //cmos pxiel clock
	input   [7:0]               cmos_db,           //cmos data
	output                      cmos_pwdn,         //cmos power down
	// output                      cmos_rst_n,        //cmos reset 使用到版本接口不兼容301
	// output                      cmos_xclk,         //cmos externl clock 使用到版本外置时钟

	//LCD接口
	output                      lcd_clk,	
	output                      lcd_hs,            //lcd horizontal synchronization
	output                      lcd_vs,            //lcd vertical synchronization        
	output                      lcd_de,            //lcd data enable     
	output[23:0]                lcd_data,          //lcd data

	//SDRAM接口
	output                      sdram_clk,         //sdram clock
	output                      sdram_cke,         //sdram clock enable
	output                      sdram_cs_n,        //sdram chip select
	output                      sdram_we_n,        //sdram write enable
	output                      sdram_cas_n,       //sdram column address strobe
	output                      sdram_ras_n,       //sdram row address strobe
	output[1:0]                 sdram_dqm,         //sdram data enable
	output[1:0]                 sdram_ba,          //sdram bank address
	output[12:0]                sdram_addr,        //sdram address
	inout[15:0]                 sdram_dq           //sdram data
);

/********************************************************************************/
/**************************    系统时钟       ************************************/
/********************************************************************************/
//generate the CMOS sensor clock and the SDRAM controller clock
sys_pll sys_pll_m0(
	.inclk0                     (clk                      ), // 50M
	.c0                         (ext_mem_clk              ) // 100M
	);
//generate video pixel clock
video_pll video_pll_m0(
	.inclk0                     (clk                      ), // 50M
	.c0                         (video_clk                ) // 9M
	);

/********************************************************************************/
/********************    OV5640初始化及其数据读取       **************************/
/********************************************************************************/
assign cmos_pwdn = 1'b0;

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

wire [15:0] cmos_16bit_data;
wire 		 write_en = cmos_16bit_wr;
wire [15:0] write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};

//CMOS sensor 8bit data is converted to 16bit data
cmos_8_16bit cmos_8_16bit_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.pdata_i                    (cmos_db                  ),
	.de_i                       (cmos_href                ),
	.pdata_o                    (cmos_16bit_data          ),
	.hblank                     (                         ),
	.de_o                       (cmos_16bit_wr            )
);
//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen cmos_write_req_gen_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.cmos_vsync                 (cmos_vsync               ),
	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);


/********************************************************************************/
/********************     图像读取SDRAM并处理输出       **************************/
/********************************************************************************/
wire                            video_hs;
wire                            video_vs;
wire                            video_de;
wire[15:0]                      video_data;

assign lcd_clk = ~video_clk;

video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                 ),
	.rst_n                      (rst_n                     ),
	.read_req                   (read_req                  ),
	.read_req_ack               (read_req_ack              ),
	.read_en                    (read_en                   ),
	.read_data                  (read_data                 ),
	
	.video_x 					(video_x 				   ),
	.video_y 					(video_y 				   ),
	.video_hs                   (video_hs                  ),
	.video_vs                   (video_vs                  ),
	.video_de                   (video_de                  ),
	.video_data                 (video_data                )
);

//对RGB 高斯滤波 减少杂点
wire                            gauss_hs;
wire                            gauss_vs;
wire                            gauss_de;
wire[15:0]                      gauss_data;
rgb_gauss #(
	.H_ACTIVE		(480			),
	.RGB_WIDTH 		(16 			)
) rgb_gauss_m0(
	.clk 			(lcd_clk 		),

	.in_hs 			(video_hs    	),
	.in_vs 			(video_vs    	),
	.in_de 			(video_de    	),
	.in_data 		(video_data  	),
		
	.out_hs 		(gauss_hs		),
	.out_vs 		(gauss_vs		),
	.out_de			(gauss_de 		),
	.out_data 		(gauss_data		)
	);

 //在标准RGB视频流中显示
 display display_m0(
	.key_sel		(key_sel		),

 	.in1_hs 		(video_hs		),
 	.in1_vs 		(video_vs		),
 	.in1_de 		(video_de		),
 	.in1_data 		(video_data 	),

 	.in2_hs 		(gauss_hs		),
 	.in2_vs 		(gauss_vs		),
 	.in2_de 		(gauss_de		),
 	.in2_data 		(gauss_data 	),
		
 	.out_hs 		(lcd_hs			),
 	.out_vs 		(lcd_vs			),
 	.out_de			(lcd_de 		),
 	.out_data 		(lcd_data		)
 	);

/********************************************************************************/
/********************        SDRAM仲裁和控制核          **************************/
/********************************************************************************/
parameter MEM_DATA_BITS          = 16;             //external memory user interface data width
parameter ADDR_BITS              = 24;             //external memory user interface address width
parameter BUSRT_BITS             = 10;             //external memory user interface burst width
wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;
wire                            read_req;
wire                            read_req_ack;
wire                            read_en;
wire[15:0]                      read_data;
wire                            write_req;
wire                            write_req_ack;
wire                            ext_mem_clk;       //external memory clock
wire                            video_clk;         //video pixel clock

wire[1:0]                       write_addr_index;
wire[1:0]                       read_addr_index;

assign sdram_clk = ext_mem_clk;

frame_read_write frame_read_write_m0
(
	.rst                        (~rst_n                   ),
	.mem_clk                    (ext_mem_clk              ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.read_clk                   (video_clk                ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (                         ),
	.read_addr_0                (24'd0                    ), //The first frame address is 0
	.read_addr_1                (24'd2073600              ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (24'd4147200              ),
	.read_addr_3                (24'd6220800              ),
	.read_addr_index            (read_addr_index          ),
	.read_len                   (24'd130560               ), //frame size 480x272
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),

	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.write_clk                  (cmos_pclk                ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (                         ),
	.write_addr_0               (24'd0                    ),
	.write_addr_1               (24'd2073600              ),
	.write_addr_2               (24'd4147200              ),
	.write_addr_3               (24'd6220800              ),
	.write_addr_index           (write_addr_index         ),
	.write_len                  (24'd130560               ), //frame size
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )
);
//sdram controller
sdram_core sdram_core_m0
(
	.rst                        (~rst_n                   ),
	.clk                        (ext_mem_clk              ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.sdram_cke                  (sdram_cke                ),
	.sdram_cs_n                 (sdram_cs_n               ),
	.sdram_ras_n                (sdram_ras_n              ),
	.sdram_cas_n                (sdram_cas_n              ),
	.sdram_we_n                 (sdram_we_n               ),
	.sdram_dqm                  (sdram_dqm                ),
	.sdram_ba                   (sdram_ba                 ),
	.sdram_addr                 (sdram_addr               ),
	.sdram_dq                   (sdram_dq                 )
);
endmodule