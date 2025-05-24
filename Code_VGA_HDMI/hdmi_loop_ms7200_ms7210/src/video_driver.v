//****************************************Copyright (c)***********************************//
//??????www.yuanzige.com
//??www.openedv.com
//??http://openedv.taobao.com
//????????"?"??ZYNQ & FPGA & STM32 & LINUX?
//????
//Copyright(C) ? 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           video_driver
// Last modified Date:  2020/05/28 20:28:08
// Last Version:        V1.0
// Descriptions:        ???
//                      
//----------------------------------------------------------------------------------------
// Created by:          ?
// Created date:        2020/05/28 20:28:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module video_driver(
    input           	pixel_clk	,
    input           	sys_rst_n	,
		
    //RGB?	
    output          	video_hs	,     //??
    output          	video_vs	,     //??
    output          	video_de	,     //?
    output  	[23:0]  video_rgb	,     //RGB888?
    output	reg			data_req 	,
	
    input   	[23:0]  pixel_data	,     //?
    output  reg	[12:0]  pixel_xpos	,     //??
    output  reg	[12:0]  pixel_ypos        //?
);

//parameter define
//1280*720 ???  75m
// parameter  H_SYNC   =  11'd40;   //?
// parameter  H_BACK   =  11'd220;  //?
// parameter  H_DISP   =  11'd1280; //?
// parameter  H_FRONT  =  11'd110;  //??
// parameter  H_TOTAL  =  11'd1650; //?

// parameter  V_SYNC   =  11'd5;    //?
// parameter  V_BACK   =  11'd20;   //?
// parameter  V_DISP   =  11'd720;  //?
// parameter  V_FRONT  =  11'd5;    //??
// parameter  V_TOTAL  =  11'd750;  //?

//1920*1080??? 148.5m
// parameter  H_SYNC   =  12'd44;   //?
// parameter  H_BACK   =  12'd148;  //?
// parameter  H_DISP   =  12'd1920; //?
// parameter  H_FRONT  =  12'd88;  //??
// parameter  H_TOTAL  =  12'd2200; //?

// parameter  V_SYNC   =  12'd5;    //?
// parameter  V_BACK   =  12'd36;   //?
// parameter  V_DISP   =  12'd1080;  //?
// parameter  V_FRONT  =  12'd4;    //??
// parameter  V_TOTAL  =  12'd1125;  //?

//2560*1440??? 241.5m
// parameter  H_SYNC   =  12'd32;   //?
// parameter  H_BACK   =  12'd80;  //?
// parameter  H_DISP   =  12'd2560; //?
// parameter  H_FRONT  =  12'd48;  //??
// parameter  H_TOTAL  =  12'd2720; //?

// parameter  V_SYNC   =  12'd5;    //?
// parameter  V_BACK   =  12'd33;   //?
// parameter  V_DISP   =  12'd1440;  //?
// parameter  V_FRONT  =  12'd3;    //??
// parameter  V_TOTAL  =  12'd1481;  //?

//3840*2160???  300m
parameter  H_SYNC   =  13'd88;   //?
parameter  H_BACK   =  13'd296;  //?
parameter  H_DISP   =  13'd3840; //?
parameter  H_FRONT  =  13'd176;  //??
parameter  H_TOTAL  =  13'd4400; //?

parameter  V_SYNC   =  12'd10;    //?
parameter  V_BACK   =  12'd72;   //?
parameter  V_DISP   =  12'd2160;  //?
parameter  V_FRONT  =  12'd8;    //??
parameter  V_TOTAL  =  12'd2250;  //?

//2560*1600??? 270m
//parameter  H_SYNC   =  13'd32;   //?
//parameter  H_BACK   =  13'd80;  //?
//parameter  H_DISP   =  13'd2560; //?
//parameter  H_FRONT  =  13'd48;  //??
//parameter  H_TOTAL  =  13'd2720; //?

//parameter  V_SYNC   =  12'd6;    //?
//parameter  V_BACK   =  12'd37;   //?
//parameter  V_DISP   =  12'd1600;  //?
//parameter  V_FRONT  =  12'd3;    //??
//parameter  V_TOTAL  =  12'd1646;  //?

//reg define
reg  [12:0] cnt_h;
reg  [12:0] cnt_v;
reg         video_en;

//*****************************************************
//**                    main code
//*****************************************************

assign video_de  = video_en;
assign video_hs  = ( cnt_h < H_SYNC ) ? 1'b0 : 1'b1;  //??Ÿ?
assign video_vs  = ( cnt_v < V_SYNC ) ? 1'b0 : 1'b1;  //??Ÿ?
//RGB888?
assign video_rgb = video_de ? pixel_data : 24'd0; 

//?RGB?
always @(posedge pixel_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)
		video_en <= 1'b0;
	else
		video_en <= data_req;
end

//??
always @(posedge pixel_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)
		data_req <= 1'b0;
	else if(((cnt_h >= H_SYNC + H_BACK - 2'd2) && (cnt_h < H_SYNC + H_BACK + H_DISP - 2'd2))
                  && ((cnt_v >= V_SYNC + V_BACK) && (cnt_v < V_SYNC + V_BACK+V_DISP)))
		data_req <= 1'b1;
	else
		data_req <= 1'b0;
end

//?x
always@ (posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pixel_xpos <= 13'd0;
    else if(data_req)
        pixel_xpos <= cnt_h + 2'd2 - H_SYNC - H_BACK ;
    else 
        pixel_xpos <= 13'd0;
end
    
//?y	
always@ (posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pixel_ypos <= 13'd0;
    else if((cnt_v >= (V_SYNC + V_BACK)) && (cnt_v < (V_SYNC + V_BACK + V_DISP)))
        pixel_ypos <= cnt_v + 1'b1 - (V_SYNC + V_BACK) ;
    else 
        pixel_ypos <= 13'd0;
end

//???
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_h <= 13'd0;
    else begin
        if(cnt_h < H_TOTAL - 1'b1)
            cnt_h <= cnt_h + 1'b1;
        else 
            cnt_h <= 13'd0;
    end
end

//?
always @(posedge pixel_clk or negedge sys_rst_n) begin
    if (!sys_rst_n)
        cnt_v <= 13'd0;
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)
            cnt_v <= cnt_v + 1'b1;
        else 
            cnt_v <= 13'd0;
    end
end

endmodule