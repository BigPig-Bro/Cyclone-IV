//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ��?ZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���?
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           video_driver
// Last modified Date:  2020/05/28 20:28:08
// Last Version:        V1.0
// Descriptions:        ��Ƶ��ʾ����ģ��
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/05/28 20:28:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module video_driver(
    input           	pixel_clk	,
    input           	sys_rst_n	,
		
    //RGB�ӿ�	
    output          	video_hs	,     //��ͬ���ź�
    output          	video_vs	,     //��ͬ���ź�
    output          	video_de	,     //����ʹ��
    output  	[23:0]  video_rgb	,     //RGB888��ɫ����
    output	reg			data_req 	,
	
    input   	[23:0]  pixel_data	,     //���ص�����
    output  reg	[12:0]  pixel_xpos	,     //���ص������?
    output  reg	[12:0]  pixel_ypos        //���ص�������
);

//parameter define
//1280*720 �ֱ���ʱ�����?  75m
//parameter  H_SYNC   =  11'd40;   //��ͬ��
//parameter  H_BACK   =  11'd220;  //����ʾ����
//parameter  H_DISP   =  11'd1280; //����Ч����
//parameter  H_FRONT  =  11'd110;  //����ʾǰ��
//parameter  H_TOTAL  =  11'd1650; //��ɨ������

//parameter  V_SYNC   =  11'd5;    //��ͬ��
//parameter  V_BACK   =  11'd20;   //����ʾ����
//parameter  V_DISP   =  11'd720;  //����Ч����
//parameter  V_FRONT  =  11'd5;    //����ʾǰ��
//parameter  V_TOTAL  =  11'd750;  //��ɨ������

//1920*1080�ֱ���ʱ�����? 150m
// parameter  H_SYNC   =  12'd44;   //��ͬ��
// parameter  H_BACK   =  12'd148;  //����ʾ����
// parameter  H_DISP   =  12'd1920; //����Ч����
// parameter  H_FRONT  =  12'd88;  //����ʾǰ��
// parameter  H_TOTAL  =  12'd2200; //��ɨ������

// parameter  V_SYNC   =  12'd5;    //��ͬ��
// parameter  V_BACK   =  12'd36;   //����ʾ����
// parameter  V_DISP   =  12'd1080;  //����Ч����
// parameter  V_FRONT  =  12'd4;    //����ʾǰ��
// parameter  V_TOTAL  =  12'd1125;  //��ɨ������

//3840*2160�ֱ���ʱ�����?  300m
parameter  H_SYNC   =  13'd88;   //��ͬ��
parameter  H_BACK   =  13'd296;  //����ʾ����
parameter  H_DISP   =  13'd3840; //����Ч����
parameter  H_FRONT  =  13'd176;  //����ʾǰ��
parameter  H_TOTAL  =  13'd4400; //��ɨ������

parameter  V_SYNC   =  12'd10;    //��ͬ��
parameter  V_BACK   =  12'd72;   //����ʾ����
parameter  V_DISP   =  12'd2160;  //����Ч����
parameter  V_FRONT  =  12'd8;    //����ʾǰ��
parameter  V_TOTAL  =  12'd2250;  //��ɨ������

//2560*1600�ֱ���ʱ�����? 270m
//parameter  H_SYNC   =  13'd32;   //��ͬ��
//parameter  H_BACK   =  13'd80;  //����ʾ����
//parameter  H_DISP   =  13'd2560; //����Ч����
//parameter  H_FRONT  =  13'd48;  //����ʾǰ��
//parameter  H_TOTAL  =  13'd2720; //��ɨ������

//parameter  V_SYNC   =  12'd6;    //��ͬ��
//parameter  V_BACK   =  12'd37;   //����ʾ����
//parameter  V_DISP   =  12'd1600;  //����Ч����
//parameter  V_FRONT  =  12'd3;    //����ʾǰ��
//parameter  V_TOTAL  =  12'd1646;  //��ɨ������

//reg define
reg  [12:0] cnt_h;
reg  [12:0] cnt_v;
reg         video_en;

//*****************************************************
//**                    main code
//*****************************************************

assign video_de  = video_en;
assign video_hs  = ( cnt_h < H_SYNC ) ? 1'b0 : 1'b1;  //��ͬ���źŸ�ֵ
assign video_vs  = ( cnt_v < V_SYNC ) ? 1'b0 : 1'b1;  //��ͬ���źŸ�ֵ
//RGB888�������?
assign video_rgb = video_de ? pixel_data : 24'd0; 

//ʹ��RGB�������?
always @(posedge pixel_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)
		video_en <= 1'b0;
	else
		video_en <= data_req;
end

//�������ص���ɫ��������
always @(posedge pixel_clk or negedge sys_rst_n) begin
	if(!sys_rst_n)
		data_req <= 1'b0;
	else if(((cnt_h >= H_SYNC + H_BACK - 2'd2) && (cnt_h < H_SYNC + H_BACK + H_DISP - 2'd2))
                  && ((cnt_v >= V_SYNC + V_BACK) && (cnt_v < V_SYNC + V_BACK+V_DISP)))
		data_req <= 1'b1;
	else
		data_req <= 1'b0;
end

//���ص�x����
always@ (posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pixel_xpos <= 13'd0;
    else if(data_req)
        pixel_xpos <= cnt_h + 2'd2 - H_SYNC - H_BACK ;
    else 
        pixel_xpos <= 13'd0;
end
    
//���ص�y����	
always@ (posedge pixel_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        pixel_ypos <= 13'd0;
    else if((cnt_v >= (V_SYNC + V_BACK)) && (cnt_v < (V_SYNC + V_BACK + V_DISP)))
        pixel_ypos <= cnt_v + 1'b1 - (V_SYNC + V_BACK) ;
    else 
        pixel_ypos <= 13'd0;
end

//�м�����������ʱ�Ӽ���
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

//�����������м���
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