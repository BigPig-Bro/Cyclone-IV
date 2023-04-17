module top(
	input                       clk,
	input                       rst_n,

	//cmos ov5640
	output                      cmos_scl,          //cmos i2c clock
	inout                       cmos_sda,          //cmos i2c data
	input                       cmos_vsync,        //cmos vsync
	input                       cmos_href,         //cmos hsync refrence,data valid
	input                       cmos_pclk,         //cmos pxiel clock
	output                      cmos_xclk,         //cmos externl clock
	input   [7:0]               cmos_db,           //cmos data
	output                      cmos_rst_n,        //cmos reset
	output                      cmos_pwdn,         //cmos power down

	//lcd 480x272
	output                      lcd_dclk,	
	output                      lcd_hs,            //lcd horizontal synchronization
	output                      lcd_vs,            //lcd vertical synchronization        
	output                      lcd_de,            //lcd data enable     
	output[7:0]                 lcd_r,             //lcd red
	output[7:0]                 lcd_g,             //lcd green
	output[7:0]                 lcd_b,	           //lcd blue

	//sdram
	output                      sdram_clk,         //sdram clock
	output                      sdram_cke,         //sdram clock enable
	output                      sdram_cs_n,        //sdram chip select
	output                      sdram_we_n,        //sdram write enable
	output                      sdram_cas_n,       //sdram column address strobe
	output                      sdram_ras_n,       //sdram row address strobe
	output[1:0]                 sdram_dqm,         //sdram data enable
	output[1:0]                 sdram_ba,          //sdram bank address
	output[12:0]                sdram_addr,        //sdram address
	inout[15:0]                 sdram_dq,           //sdram data
	
	//key 
	input 	win_in,
	input 	col_in
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
wire                            cmos_hs;
wire                            cmos_vs;
wire                            cmos_de;
wire[15:0]                      cmos_data;
wire[15:0]                      cmos_16bit_data;
wire                            cmos_16bit_wr;
wire[1:0]                       write_addr_index;
wire[1:0]                       read_addr_index;

assign lcd_dclk = ~video_clk;
assign sdram_clk = ext_mem_clk;
assign write_en = cmos_16bit_wr;
assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};

wire [11:0]	cmos_x,cmos_y;
wire [7:0]	ycbcr_cb,ycbcr_cr,ycbcr_y;

reg [11:0] x[9:0];
reg [11:0] y[9:0];
integer i;
always @(posedge video_clk) begin
	x[0] <= cmos_x;
	y[0] <= cmos_y;
	for (i=1; i<10; i = i + 1) begin
		x[i]  <= x[i-1];
		y[i]  <= y[i-1];
	end
end

/*************************************************************/
/*************************************************************/
/*****************    图像处理部分   **************************/
/*************************************************************/
/*************************************************************/
// keyfilter Outputs
wire  windows;
keyfilter u_keyfilter (
    .clk                     ( video_clk      ),
    .rst_n                   ( rst_n     	  ),
    .keyin                   ( win_in    	  ),

    .keyout                  ( windows        )
);

wire  color;
keyfilter u_keyfilter2 (
    .clk                     ( video_clk      ),
    .rst_n                   ( rst_n    ),
    .keyin                   ( col_in    ),

    .keyout                  ( color   )
);

//RGB二值化
wire thr_hs,thr_vs,thr_de,thr_data;
cam_thrould cam_thrould_m0(
	.clk 		(video_clk 	),

	.in_hs 		(cmos_hs		),
	.in_vs 		(cmos_vs		),
	.in_de 		(cmos_de		),
	.in_data 	(cmos_data	    ),

	.thr_hs 	(thr_hs			),
	.thr_vs 	(thr_vs			),
	.thr_de 	(thr_de			),
	.thr_data 	(thr_data		)
	);

//腐蚀滤波
wire  erode_vs;
wire  erode_hs;
wire  erode_de;
wire  erode_data;
erode  u_erode (
    .clk                     ( video_clk     ),

    .thr_hs              	 ( thr_hs    	 ),
    .thr_vs              	 ( thr_vs    	 ),
    .thr_de              	 ( thr_de    	 ),
    .thr_out             	 ( thr_data  	 ),

    .erode_vs                ( erode_vs      ),
    .erode_hs                ( erode_hs      ),
    .erode_de                ( erode_de      ),
    .erode_data              ( erode_data    )
);

//计算连通域
wire con_clk;
wire [9:0]	con_data;
wire fst_de;
wire fst_hs;
wire fst_vs;
wire [47:0] con_loc1,con_loc2,con_loc3;
mark_fifo mark_m0(				
	.video_clk  (video_clk	),		//输入 视频像素时钟
	.con_clk	(con_clk	),		//输入 连通域处理时钟
	
	.data_in    (erode_data	),		//输入 处理视频 像素
	.hs_in      (erode_hs		),		//输入 处理视频 hs
	.vs_in      (erode_vs		),		//输入 处理视频 vs
	.de_in      (erode_de		),		//输入 处理视频 de
	.x_in	    (x[9]		 ),		//输入 处理视频 x坐标
	.y_in	    (y[9]		 ),		//输入 处理视频 y坐标
	
	.data_out   (con_data 	),		//输出 标记后像素
	.hs_out     (fst_hs		), 		//输出 后 hs
	.vs_out     (fst_vs		), 		//输出 后 vs
	.de_out     (fst_de		), 		//输出 后 de
	.loc_out1   (con_loc1	), 		//输出 被选择的连通域区域边界
	.loc_out2   (con_loc2	), 		//输出 被选择的连通域区域边界
	.loc_out3   (con_loc3	) 		//输出 被选择的连通域区域边界
); 

//输出结果
wire  [15:0]  data_out;
video_out  u_video_out (
    .video_clk               ( video_clk     ),
    .rst_n                   ( rst_n         ),
	.active_x				 (x[9] 			 ),
	.active_y				 (y[9] 			 ),
    .cmos_data               ( cmos_data     ),
    .windows                 ( windows       ),
	.color                   ( color         ),
    .erode_data              ( erode_data    ),
	.loc_out1				 (con_loc1		 ),
	.loc_out2				 (con_loc2		 ),
	.loc_out3				 (con_loc3		 ),
	.con_data				 (con_data		 ),
    .data_out                ( data_out      )
);


assign lcd_hs = fst_hs;
assign lcd_vs = fst_vs;
assign lcd_de = fst_de;
assign lcd_r  = {data_out[15:11],3'b0};
assign lcd_g  = {data_out[10:5],2'b0};
assign lcd_b  = {data_out[4:0],3'b0};


/*************************************************************/
/*************************************************************/
/*****************    底层驱动部分   **************************/
/*************************************************************/
/*************************************************************/
//generate the CMOS sensor clock and the SDRAM controller clock
sys_pll sys_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (cmos_xclk                ),
	.c1                         (ext_mem_clk              )
	);

//generate video pixel clock
video_pll video_pll_m0(
	.inclk0                     (clk                      ),
	.c0                         (video_clk                ),
	.c1							(con_clk 				  )
	);

//cmos register intial
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
//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),
	.hs                         (cmos_hs                  ),
	.vs                         (cmos_vs                  ),
	.de                         (cmos_de                  ),
	.vout_data                  (cmos_data                ),
	.active_x	 				(cmos_x 				  ),
	.active_y	 				(cmos_y 				  )
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