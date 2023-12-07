//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/7/12     meisq          1.0         Original
//*******************************************************************************/
`timescale 1ns/1ps
module audio_rx
(
	input                            rst,                  
	input                            clk,  
	input                            sck_bclk,     //audio bit clock
	input                            ws_lrc,       //ADC sample rate left right clock
	input                            sdata,        //ADC audio data
	output reg[31:0]                 left_data,    //left channel audio data ,ws_lrc = 1
	output reg[31:0]                 right_data,   //right channel audio data,ws_lrc = 0
	output reg                       data_valid    //audio data valid

);
reg                                  sck_bclk_d0;  //delay sck_bclk
reg                                  sck_bclk_d1;  //delay sck_bclk
reg                                  ws_lrc_d0;    //delay ws_lrc
reg                                  ws_lrc_d1;    //delay ws_lrc 
reg[31:0]                            left_data_shift; //left channel audio data shift register
reg[31:0]                            right_data_shift;//right channel audio data shift register

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		sck_bclk_d0 <= 1'b0;
		sck_bclk_d1 <= 1'b0;
		ws_lrc_d0 <= 1'b0;
		ws_lrc_d1 <= 1'b0;
	end
	else
	begin
		sck_bclk_d0 <= sck_bclk;
		sck_bclk_d1 <= sck_bclk_d0;
		ws_lrc_d0 <= ws_lrc;
		ws_lrc_d1 <= ws_lrc_d0;
	end
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		left_data_shift <= 32'd0;
	else if(ws_lrc_d1 == 1'b0 && ws_lrc_d0 == 1'b1)//ws_lrc posedge
		left_data_shift <= 32'd0;
	else if(ws_lrc_d1 == 1'b1 && sck_bclk_d1 == 1'b0 && sck_bclk_d0 == 1'b1)//ws_lrc = 1 ,sck_bclk posedge
		left_data_shift <= {left_data_shift[30:0],sdata};
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		right_data_shift <= 32'd0;
	else if(ws_lrc_d1 == 1'b0 && ws_lrc_d0 == 1'b1)//ws_lrc posedge
		right_data_shift <= 32'd0;
	else if(ws_lrc_d1 == 1'b0 && sck_bclk_d1 == 1'b0 && sck_bclk_d0 == 1'b1)//ws_lrc = 0 ,sck_bclk posedge
		right_data_shift <= {right_data_shift[30:0],sdata};
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		left_data <= 32'd0;
		right_data <= 32'd0;
	end
	else if(ws_lrc_d1 == 1'b0 && ws_lrc_d0 == 1'b1)//ws_lrc posedge
	begin
		left_data <= left_data_shift;
		right_data <= right_data_shift;
	end
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
		data_valid <= 1'b0;
	else if(ws_lrc_d1 == 1'b0 && ws_lrc_d0 == 1'b1)//ws_lrc posedge
		data_valid <= 1'b1;
	else
		data_valid <= 1'b0;
end

endmodule
