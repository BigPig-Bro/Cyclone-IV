module fft_top #(
    parameter DATA_WIDTH        = 16 //输入数据位宽 0~32，位宽不够时补符号位
)(
    input           rst_n,

    input [15:0]    data_in,
    input           data_in_clk,

    output [7:0][7:0] res_data
);
/******************************************************************/
/*******************  FFT核       *********************************/
/******************************************************************/ 
wire [63:0] fft_data_amp; 
wire [10:0] fft_data_cnt;
fft1024_top #(
	.DATA_WIDTH 		(16 			)
)fft1024_top_m0(
	.rst_n 				(rst_n 			),

	.data_in 			(data_in 		),
	.data_in_clk 		(data_in_clk	),

	.fft_data_cnt 		(fft_data_cnt	),
	.fft_data_amp 		(fft_data_amp	)	
);

/******************************************************************/
/*******************  统计为八个数据  ******************************/
/******************************************************************/  
wire 			source_valid ,source_sop   ,source_eop   ;
wire [15:0] 	source_real  ,source_imag  ;
fft_cnt fft_cnt_m0(
    .fft_clk 	    	(data_in_clk    ),

	.fft_data_cnt 		(fft_data_cnt	),
	.fft_data_amp 		(fft_data_amp	),

    .res_data     		(res_data 		)
);

endmodule