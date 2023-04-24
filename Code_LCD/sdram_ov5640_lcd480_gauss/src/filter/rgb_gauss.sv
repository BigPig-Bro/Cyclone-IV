module rgb_gauss#(
	parameter H_ACTIVE = 480,
	parameter RGB_WIDTH = 16s
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
linebuffer_Wapper#//缓存三行的模块
(
	.no_of_lines 	 	(3 			),
	.samples_per_line 	(H_ACTIVE 	),
	.data_width 		(RGB_WIDTH 	)
)
 linebuffer_Wapper_test(
	.ce         (1'b1    		),
	.wr_clk     (clk    		),
	.wr_en      (in_de    		),
	.wr_rst     (1'b1    		),
	.data_in    (in_data  		),
	
	.rd_en      (in_de   		),
	.rd_clk     (clk    		),
	.rd_rst     (1'b1    		),
	.data_out   ({w3,w2,w1} 	)
   );

reg [2:0] [15:0] p1,p2,p3;
always@(posedge clk)
begin//形成3*3算子
	p1 <= {p1[1:0],w1};
	p2 <= {p2[1:0],w2};
	p3 <= {p3[1:0],w3};
end	

wire [2:0] [11:0] data_tem;
assign data_tem[0] = p1[0][15:11] + p1[1][15:11] * 2 + p1[2][15:11] + p2[0][15:11] * 2 + p2[1][15:11] * 4 
					+ p2[2][15:11] * 2 + p3[0][15:11] + p3[1][15:11] * 2 + p3[2][15:11]; 
assign data_tem[1] = p1[0][10:5] + p1[1][10:5] * 2 + p1[2][10:5] + p2[0][10:5] * 2 + p2[1][10:5] * 4 
					+ p2[2][10:5] * 2 + p3[0][10:5] + p3[1][10:5] * 2 + p3[2][10:5]; 
assign data_tem[2] = p1[0][ 4: 0] + p1[1][ 4: 0] * 2 + p1[2][ 4: 0] + p2[0][ 4: 0] * 2 + p2[1][ 4: 0] * 4 
					+ p2[2][ 4: 0] * 2 + p3[0][ 4: 0] + p3[1][ 4: 0] * 2 + p3[2][ 4: 0]; 

/*****************************************************************/
/********************     数据输出       **************************/
/***************************************************************/
assign out_data[15:11] = data_tem[0][11:4];
assign out_data[10: 5] = data_tem[1][11:4];
assign out_data[ 4: 0] = data_tem[2][11:4];

assign out_de = de_r[4];//DE输出
assign out_vs = vs_r[4];//VS输出
assign out_hs = hs_r[4];//HS输出

reg[4:0] vs_r,hs_r,de_r;
always@(posedge clk )//根据数据处理延迟4个时钟
begin
	vs_r        <= {vs_r[3:0],in_vs};
	hs_r		<= {hs_r[3:0],in_hs};
	de_r		<= {de_r[3:0],in_de};
end
endmodule 

