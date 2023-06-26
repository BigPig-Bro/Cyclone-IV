module dac904e_ctl(
    input              clk,

    output reg [13:0]   dac904e_data
);

//生成一个锯齿波
always@(posedge clk) dac904e_data <= dac904e_data + 1;

endmodule