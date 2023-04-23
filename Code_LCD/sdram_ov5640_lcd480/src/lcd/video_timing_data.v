module video_timing_data
#(
	parameter DATA_WIDTH = 16                       // Video data one clock data width
)(
	input                       video_clk,          // Video pixel clock
	input                       rst_n,
	output reg                  read_req,           // Start reading a frame of data     
	input                       read_req_ack,       // Read request response
	output                      read_en,            // Read data enable
	input[DATA_WIDTH - 1:0]     read_data,          // Read data

	output reg [ 9:0] 			 video_x,video_y,	// Video x position
	output reg                   video_hs,                 // horizontal synchronization
	output reg                   video_vs,                 // vertical synchronization
	output reg                   video_de,                 // video valid
	output [DATA_WIDTH - 1:0]    video_data           // video data
);

reg[DATA_WIDTH - 1:0]  vout_data_r;
assign read_en = video_de;
always@(posedge video_clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		video_hs <= 1'b0;
		video_vs <= 1'b0;
		video_de <= 1'b0;
	end
	else
	begin
		//delay video_hs video_vs  video_de 1 clock cycles
		video_hs <= rgb_hs;
		video_vs <= rgb_vs;
		video_de <= rgb_de;	

		video_x <= rgb_x;
		video_y <= rgb_y; 
	end
end

assign video_data = video_de ? read_data : {DATA_WIDTH{1'b0}};

always@(posedge video_clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		read_req <= 1'b0;
	else if(rgb_vs & ~video_vs) //vertical synchronization edge (the rising or falling edges are OK)
		read_req <= 1'b1;
	else if(read_req_ack)
		read_req <= 1'b0;
end

//产生标准空白RGB视频流
wire 		rgb_clk;
wire 		rgb_vs,rgb_hs,rgb_de;
wire [ 9:0] rgb_x,rgb_y;
rgb_timing rgb_timing_m0(
	.rgb_clk	(video_clk	),	
	.rst_n		(rst_n		),	
	.rgb_hs		(rgb_hs		),
	.rgb_vs		(rgb_vs		),
	.rgb_de		(rgb_de		),
	.rgb_x		(rgb_x		),
	.rgb_y		(rgb_y		)
	);

endmodule 