// Copyright (C) 2020  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and any partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details, at
// https://fpgasoftware.intel.com/eula.

// *****************************************************************************
// This file contains a Verilog test bench template that is freely editable to  
// suit user's needs .Comments are provided in each section to help the user    
// fill out necessary details.                                                  
// *****************************************************************************
// Generated on "04/26/2023 22:30:10"
                                                                                
// Verilog Test Bench template for design : top
// 
// Simulation tool : ModelSim-Altera (Verilog)
// 

`timescale 1 ns/ 1 ns
module top_tb();

// test vector input registers
reg clk;
reg rst_n;	
// wires                                               
wire lcd_clk;
wire lcd_de;
wire lcd_hs;
wire [23:0]  lcd_rgb;
wire lcd_vs;
wire uart_tx;

// assign statements (if any)                          
top i1 (
// port map - connection between master ports and signals/registers   
	.clk(clk),
	.rst_n(rst_n),	
	.lcd_clk(lcd_clk),
	.lcd_de(lcd_de),
	.lcd_hs(lcd_hs),
	.lcd_rgb(lcd_rgb),
	.lcd_vs(lcd_vs),
	.uart_tx(uart_tx)
);
initial                                                
begin                                                  
#0 clk = 0;rst_n = 0;

#1000 rst_n = 1;

#1_000_000 $stop;
end                                                    
always  #10 clk = ~clk;                                                   
endmodule

