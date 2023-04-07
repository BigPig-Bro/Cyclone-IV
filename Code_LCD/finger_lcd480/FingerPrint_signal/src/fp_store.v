module fp_store (	
	input 				video_out_clk,
	input [ 7:0]		video_out_add,
	output  [511:0]		video_out_data,

	input 				search_out_clk,
	input [7:0] 		search_out_add,search_out_add_test,
	output[511:0]		search_out_data,

	input 				ram_in_clk,
	input  				ram_in_sel, // 0 匹配模板 1 待测指纹
	input [ 7:0]		ram_in_add,
	input [255:0]		ram_in_data
);

//输入时钟 延迟
reg ram_in_clk_r;
always@(posedge video_out_clk) ram_in_clk_r <= ram_in_clk;

//用于显示测试的俩模板
//录入的 指纹模板 1 
fp_ram_single	fp_ram_inst1 (
	.address	(ram_in_clk?ram_in_add:video_out_add),
	.clock 		(ram_in_clk?ram_in_clk_r:video_out_clk ),
	.data	 	(ram_in_data   		),
	.wren	 	(!ram_in_sel? ram_in_clk	: 1'b0),
	.q		 	(video_out_data[255:0] 		)
	);
fp_ram_single	fp_ram_inst2 (
	.address	(ram_in_clk?ram_in_add:video_out_add),
	.clock 		(ram_in_clk?ram_in_clk_r:video_out_clk ),
	.data	 	(ram_in_data   		),
	.wren	 	( ram_in_sel? ram_in_clk	: 1'b0),
	.q		 	(video_out_data [511:256]  		)
	);

//用于快速搜索的俩模板
//录入的 待测指纹
fp_ram_single	fp_ram_inst3 (
	.address	(ram_in_clk?ram_in_add:search_out_add_test),
	.clock 	 	(search_out_clk    		),
	.data	 	(ram_in_data   		),
	.wren	 	(!ram_in_sel? ram_in_clk_r	: 1'b0),
	.q		 	(search_out_data[255:0]  		)
	);
fp_ram_single	fp_ram_inst4 (
	.address	(ram_in_clk?ram_in_add:search_out_add),
	.clock 	 	(search_out_clk    		),
	.data	 	(ram_in_data   		),
	.wren	 	(ram_in_sel? ram_in_clk_r	: 1'b0),
	.q		 	(search_out_data[511:256]  		)
	);
endmodule