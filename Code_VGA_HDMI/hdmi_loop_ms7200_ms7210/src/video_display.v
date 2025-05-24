//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           video_display
// Last modified Date:  2020/05/28 20:28:08
// Last Version:        V1.0
// Descriptions:        ��Ƶ��ʾģ�飬��ʾ����
//                      
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2020/05/28 20:28:08
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module  video_display(
    input                pixel_clk,
    input                sys_rst_n,
    
    input        [12:0]  pixel_xpos,  //���ص������
    input        [12:0]  pixel_ypos,  //���ص�������
    output  reg  [23:0]  pixel_data   //���ص�����
);

//parameter define
parameter  H_DISP = 13'd3840;                        //�ֱ��ʡ�����

localparam RGB0     = 24'h000001;
localparam RGB1     = 24'h000002;
localparam RGB2     = 24'h000004;
localparam RGB3     = 24'h000008;
localparam RGB4     = 24'h000010;
localparam RGB5     = 24'h000020;
localparam RGB6     = 24'h000040;
localparam RGB7     = 24'h000080;
localparam RGB8     = 24'h000100;
localparam RGB9     = 24'h000200;
localparam RGB10    = 24'h000400;
localparam RGB11    = 24'h000800;
localparam RGB12    = 24'h001000;
localparam RGB13    = 24'h002000;
localparam RGB14    = 24'h004000;
localparam RGB15    = 24'h008000;
localparam RGB16    = 24'h010000;
localparam RGB17    = 24'h020000;
localparam RGB18    = 24'h040000;
localparam RGB19    = 24'h080000;
localparam RGB20    = 24'h100000;
localparam RGB21    = 24'h200000;
localparam RGB22    = 24'h400000;
localparam RGB23    = 24'h800000;    
//*****************************************************
//**                    main code
//*****************************************************

//���ݵ�ǰ���ص�����ָ����ǰ���ص���ɫ���ݣ�����Ļ����ʾ����
always @(posedge pixel_clk ) begin
    if (!sys_rst_n)
        pixel_data <= 24'd0;
    else begin
             if (pixel_xpos < (H_DISP/24)*1)
            pixel_data <= RGB0;
        else if (pixel_xpos < (H_DISP/24)*2)
            pixel_data <= RGB1;  
        else if (pixel_xpos < (H_DISP/24)*3)
            pixel_data <= RGB2;  
        else if (pixel_xpos < (H_DISP/24)*4)
            pixel_data <= RGB3;
        else if (pixel_xpos < (H_DISP/24)*5)
            pixel_data <= RGB4;
        else if (pixel_xpos < (H_DISP/24)*6)
            pixel_data <= RGB5;
        else if (pixel_xpos < (H_DISP/24)*7)
            pixel_data <= RGB6;
        else if (pixel_xpos < (H_DISP/24)*8)
            pixel_data <= RGB7;
        else if (pixel_xpos < (H_DISP/24)*9)
            pixel_data <= RGB8;
        else if (pixel_xpos < (H_DISP/24)*10)
            pixel_data <= RGB9;
        else if (pixel_xpos < (H_DISP/24)*11)
            pixel_data <= RGB10;
        else if (pixel_xpos < (H_DISP/24)*12)
            pixel_data <= RGB11;
        else if (pixel_xpos < (H_DISP/24)*13)
            pixel_data <= RGB12;
        else if (pixel_xpos < (H_DISP/24)*14)
            pixel_data <= RGB13;
        else if (pixel_xpos < (H_DISP/24)*15)
            pixel_data <= RGB14;
        else if (pixel_xpos < (H_DISP/24)*16)
            pixel_data <= RGB15;
        else if (pixel_xpos < (H_DISP/24)*17)
            pixel_data <= RGB16;
        else if (pixel_xpos < (H_DISP/24)*18)
            pixel_data <= RGB17;
        else if (pixel_xpos < (H_DISP/24)*19)
            pixel_data <= RGB18;
        else if (pixel_xpos < (H_DISP/24)*20)
            pixel_data <= RGB19;
        else if (pixel_xpos < (H_DISP/24)*21)
            pixel_data <= RGB20;
        else if (pixel_xpos < (H_DISP/24)*22)
            pixel_data <= RGB21;
        else if (pixel_xpos < (H_DISP/24)*23)
            pixel_data <= RGB22;
        else 
            pixel_data <= RGB23;
    end
end

endmodule