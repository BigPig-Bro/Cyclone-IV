module ad9280_top#(
    parameter CLK_FRE = 50,
    parameter ADC_FRE = 5000
)(
    input           clk,
    input           rst_n, 

    input           ad9280_start, 	
    output [7:0]    ad9280_data ,

    input  [7:0]    ad9280_db,		
    output reg      ad9280_clk
);

//数据输出
assign ad9280_data = rst_n & ad9280_start?ad9280_db : 'd0;

//时钟输出
reg [23:0] clk_cnt = 'd0;
always @(posedge clk or negedge rst_n)
    if(!rst_n)
        clk_cnt <= 'd0;
    else if(clk_cnt == CLK_FRE * 500_000 /ADC_FRE - 1)begin
        ad9280_clk <= ~ad9280_clk;
        clk_cnt <= 'd0;
    end
    else
        clk_cnt <= (ad9280_start)? clk_cnt: clk_cnt + 'd1;
endmodule