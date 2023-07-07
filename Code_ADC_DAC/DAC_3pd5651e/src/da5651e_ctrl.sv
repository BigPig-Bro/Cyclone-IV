module da5651e_ctl(
    input              clk,

    output reg [9:0]   da5651e_data
);

//生成一个锯齿波
always@(posedge clk) da5651e_data <= da5651e_data + 1;

endmodule