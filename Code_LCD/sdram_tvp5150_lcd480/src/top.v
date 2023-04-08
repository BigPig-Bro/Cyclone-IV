
module top(
	input                       clk,
	input                       rst_n,

	input						bt656_clk_27m,
	input	[ 7:0]				bt656_data,
	output						bt656_iic_scl,
	inout						bt656_iic_sda,

	output                      lcd_dclk,	
	output                      lcd_hs,            //lcd horizontal synchronization
	output                      lcd_vs,            //lcd vertical synchronization        
	output                      lcd_de,            //lcd data enable     
	output[7:0]                 lcd_r,             //lcd red
	output[7:0]                 lcd_g,             //lcd green
	output[7:0]                 lcd_b,	           //lcd blue

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
wire                            write_en;
wire[15:0]                      write_data;
wire                            write_req;
wire                            write_req_ack;
wire                            ext_mem_clk;       //external memory clock
wire                            video_clk;         //video pixel clock
wire                            hs;
wire                            vs;
wire                            de;
wire[15:0]                      vout_data;
wire[1:0]                       write_addr_index;
wire[1:0]                       read_addr_index;
wire[9:0]                       lut_index;
wire[31:0]                      lut_data;

assign lcd_hs = hs;
assign lcd_vs = vs;
assign lcd_de = de;
assign lcd_r  = {vout_data[15:11],3'd0};
assign lcd_g  = {vout_data[10:5],2'd0};
assign lcd_b  = {vout_data[4:0],3'd0};
assign lcd_dclk = ~video_clk;

assign sdram_clk = ext_mem_clk;
assign write_en = (pixel_cnt >= 7) && (pixel_cnt < 7 + 480 ); // 控制行数分辨率;
 assign write_data = {bt656_r[7:3],bt656_g[7:2],bt656_b[7:3]};
/*assign write_data = (pixel_cnt >= 7 && pixel_cnt < 7 + 480 )? 
					(pixel_cnt < 7 + 160 )? 16'b11111_000000_00000:
					(pixel_cnt < 7 + 320 )? 16'b00000_111111_00000:16'b00000_000000_11111: 16'd0; 
*/
//generate the SDRAM controller clock
sys_pll sys_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (ext_mem_clk              )
	);
//generate video pixel clock
video_pll video_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (video_clk                )
	);
//I2C master controller

//*******************************************************
//********************* 视频源初始化控制 *****************
//*******************************************************
iic_config iic_config_m0(
	.clk 		(clk 				),
	.rst_n 		(rst_n 				),

	.iic_scl 	(bt656_iic_scl 		),
	.iic_sda 	(bt656_iic_sda 		)
	);

//*******************************************************
//********************* 视频源解码 *****************
//*******************************************************
//------------------ bt656 decoder and 4:2:2 to 4:4:4 ------------------------//
//------------------ 将串行信号解码为正常的YCBCR信号    ------------------------//
wire				bt656_3;
wire				bt656_1;
wire				bt656_2;
wire				bt656_clk;
wire	[7:0]		bt656_y;
wire	[7:0]		bt656_cb;
wire	[7:0]		bt656_cr;

bt656_rx bt656_rx_m0(
	//输入图像码流
	.rst_n 		(rst_n 			) ,	// input  rst_n_sig
	.clk1 		(bt656_clk_27m 	) ,	// input  clk1_sig
	.din 		(bt656_data 	) ,	// input [7:0] din_sig

	//输出图像码流
	.lcc2 		(bt656_clk 		) ,	// output  lcc2_sig
	.de 		(bt656_1	 	) ,	// output  field_sig
	.v 			(bt656_2	 	) ,	// output  v_sig
	.h 			(bt656_3 	 	) ,	// output  h_sig

	.y 			(bt656_y  		) ,	// output [7:0] y_sig
	.cb 		(bt656_cb		) ,	// output [7:0] cb_sig
	.cr 		(bt656_cr		) 

);

//-------------------------- 将YCBCR转换成LCD能直接显示的RGB ---------------------------//
wire	[7:0]	bt656_r;
wire	[7:0]	bt656_g;
wire	[7:0]	bt656_b;

ycbcr2rgb ycbcr2rgb_m0(
	.clk 	(bt656_clk 		),
	.in_y 	(bt656_y 		),
	.in_cb	(bt656_cb		),
	.in_cr	(bt656_cr		),

	.out_r	(bt656_r		),
	.out_g	(bt656_g		),
	.out_b	(bt656_b		)
 );

//*******************************************************
//********************* 写入SDRAM *****************
//*******************************************************
reg	[10:0]	pixel_cnt;

always @ (posedge bt656_clk or negedge rst_n)
	if(~rst_n)
		pixel_cnt	<= 11'b0;
	else if(bt656_3 || bt656_2 || bt656_1)
		pixel_cnt	<= 11'b0;
	else
		pixel_cnt	<= (pixel_cnt == 720)?pixel_cnt : pixel_cnt + 1'b1;

//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen cmos_write_req_gen_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (bt656_clk                 ),
	.cmos_vsync                 (bt656_2                 ),

	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);
//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),
	.hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),
	.vout_data                  (vout_data                )
);
//video frame data read-write control
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
	.write_clk                  (bt656_clk                ),
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