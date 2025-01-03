module video_timing_data
#(
	parameter DATA_WIDTH = 16                       // Video data one clock data width
)
(
	input                       video_clk,          // Video pixel clock

	input [15:0] 			    fifo_data_in,
	input	 			    	fifo_data_in_en,
	input	 			    	fifo_data_in_clk,
	input	 			    	fifo_data_vs,

	output reg                   hs,                 // horizontal synchronization
	output reg                   vs,                 // vertical synchronization
	output reg                   de,                 // video valid
	output[DATA_WIDTH - 1:0]    vout_data           // video data
);
wire                   video_hs;
wire                   video_vs;
wire                   video_de;


//每帧画面开始的复位，避免错误积累
reg vs_in_r;
wire vs_posedge;
wire vs_degedge;
assign vs_posedge = !vs_in_r & fifo_data_vs;
assign vs_degedge = vs_in_r & !fifo_data_vs;

always@(posedge video_clk) vs_in_r <= fifo_data_vs;

video_fifo	video_fifo_m0 (
	.aclr 		(fifo_data_vs 		),

	.data 		(fifo_data_in 		),
	.wrclk 		(fifo_data_in_clk 	),
	.wrreq 		(fifo_data_in_en 	),

	.rdclk 		(video_clk  		),
	.rdreq 		(video_de 			),
	.q 			(vout_data  		)
	);


//同步VS信号
reg 	video_rst = 0;
reg [1:0]video_state = 0;
reg [19:0] clk_delay = 0;
always@(posedge video_clk)
	case(video_state)
		2'd0:begin//等待 VS 下降沿输入
			video_rst <= 0;
			if(vs_posedge)begin video_state <= video_state + 1; clk_delay <= 0; end
		end

		// 2'd1:begin//等待缓存部分图像
		// 	if (clk_delay == 20'd550) begin 
		// 		clk_delay <= 0;
		// 		video_state <= video_state + 1;
		// 	end
		// 	else clk_delay <= clk_delay + 1;
		// end

		// 2'd2:begin//等待 HS 上升沿输入
		// 	if(fifo_data_in_en)begin video_state <= video_state + 1; end
		// end

		2'd1:begin
			video_rst <= 1;
			video_state <= 0;
		end
	endcase

always@(posedge video_clk)begin
	hs <= video_hs;
	vs <= video_vs;
	de <= video_de;
end

rgb_timing rgb_timing_m0(
	.rgb_clk	(video_clk		),	
	.rgb_rst_n	(!video_rst		),	
	.rgb_hs		(video_hs		),
	.rgb_vs		(video_vs		),
	.rgb_de		(video_de		),
	.rgb_x		(				),
	.rgb_y		(				)
	);
endmodule 