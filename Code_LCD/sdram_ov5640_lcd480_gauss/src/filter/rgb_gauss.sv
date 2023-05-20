module rgb_gauss#(
	parameter H_ACTIVE = 480,
	parameter RGB_WIDTH = 16
)(
	input			clk ,			

	input			in_hs, 			
	input			in_vs, 			
	input			in_de, 			
	input	[15:0]	in_data, 		
		
	output 			out_hs, 		
	output 			out_vs, 		
	output 			out_de,			
	output [15:0]	out_data 		
);
/*****************************************************************/
/********************     图像处理       **************************/
/***************************************************************/
wire [15:0] w1,w2,w3;

linebuffer #(
	.DATA_LINES 	(3 			),
	.DATA_WIDTH 	(RGB_WIDTH 	),
	.DATA_NUM		(H_ACTIVE 	)
)linebuffer_m0(
	.rst_n 		(1'b1 			),

	.in_clk 	(clk 			),
	.in_data 	(in_data 		),
	.in_de 		(in_de 			),

	.out_clk 	(clk 			),
	.out_de 	(out_de 		),
	.out_data 	({w3,w2,w1} 	)
);

reg [2:0] [15:0] p1,p2,p3;
always@(posedge clk)
begin//形成3*3算子
	p1 <= {p1[1:0],w1};
	p2 <= {p2[1:0],w2};
	p3 <= {p3[1:0],w3};
end	

wire [2:0] [11:0] data_tem;
assign data_tem[0] = p1[0][15:11] + p1[1][15:11] * 2 + p1[2][15:11] + p2[0][15:11] * 2 + p2[1][15:11] * 4 + p2[2][15:11] * 2 + p3[0][15:11] + p3[1][15:11] * 2 + p3[2][15:11]; 
assign data_tem[1] = p1[0][10: 5] + p1[1][10: 5] * 2 + p1[2][10: 5] + p2[0][10: 5] * 2 + p2[1][10: 5] * 4 + p2[2][10: 5] * 2 + p3[0][10: 5] + p3[1][10: 5] * 2 + p3[2][10: 5]; 
assign data_tem[2] = p1[0][ 4: 0] + p1[1][ 4: 0] * 2 + p1[2][ 4: 0] + p2[0][ 4: 0] * 2 + p2[1][ 4: 0] * 4 + p2[2][ 4: 0] * 2 + p3[0][ 4: 0] + p3[1][ 4: 0] * 2 + p3[2][ 4: 0]; 


reg[1:0] vs_r,hs_r,de_r;
always@(posedge clk )//根据数据处理延迟2个时钟
begin
	vs_r        <= {vs_r[0],in_vs};
	hs_r		<= {hs_r[0],in_hs};
	de_r		<= {de_r[0],in_de};
end

/*****************************************************************/
/********************     数据输出       **************************/
/***************************************************************/
assign out_data[15:11] = out_de?data_tem[0][11:4]:'d0;
assign out_data[10: 5] = out_de?data_tem[1][11:4]:'d0;
assign out_data[ 4: 0] = out_de?data_tem[2][11:4]:'d0;

assign out_de = de_r[1];//DE输出
assign out_vs = vs_r[1];//VS输出
assign out_hs = hs_r[1];//HS输出

endmodule 

