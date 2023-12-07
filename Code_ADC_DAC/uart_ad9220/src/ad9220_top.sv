module ad9220_top#(
    parameter CLK_FRE = 50,
    parameter ADC_FRE = 5000
)(
    input           clk,
    input           rst_n, 

    input           ad9220_start, 	
    output [11:0]    ad9220_data ,

    input  [11:0]    ad9220_db,		
    output reg      ad9220_clk
);

//数据输出
assign ad9220_data = rst_n & ad9220_start?ad9220_db : 'd0;

//时钟输出
// reg [23:0] clk_cnt = 'd0;
// always @(posedge clk or negedge rst_n)
//     if(!rst_n)
//         clk_cnt <= 'd0;
//     else if(clk_cnt == CLK_FRE * 500_000 /ADC_FRE - 1)begin
//         ad9220_clk <= ~ad9220_clk;
//         clk_cnt <= 'd0;
//     end
//     else
//         clk_cnt <= (ad9220_start)? clk_cnt: clk_cnt + 'd1;

ad_pll ad_pll_m0(
    .inclk0         (clk         ),
    .c0             (ad9220_clk  )
    );

endmodule