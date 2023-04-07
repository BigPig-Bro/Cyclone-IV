`timescale 1ns/1ns
module top_tb;

reg clk,rst_n;

LCD1602_top top_m0(
	.clk(clk),	
	.rst_n(rst_n),
	.LCD1602_RS(),
	.LCD1602_E(),
	.LCD1602_RW(),
	.LCD1602_DAT()
	);

initial clk = 'd0;
initial rst_n = 'b1;
initial #100_000_000 $stop;

always #5 clk = ~clk;

endmodule