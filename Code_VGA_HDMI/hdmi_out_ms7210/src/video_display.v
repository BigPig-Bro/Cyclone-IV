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
parameter  H_DISP = 13'd1920;                        //�ֱ��ʡ�����
parameter  V_DISP = 13'd1080;                        //�ֱ��ʡ�����

localparam WHITE  = 24'b11111111_11111111_11111111;  //RGB888 ��ɫ
localparam BLACK  = 24'b00000000_00000000_00000000;  //RGB888 ��ɫ
localparam RED    = 24'b11111111_00001100_00000000;  //RGB888 ��ɫ
localparam GREEN  = 24'b00000000_11111111_00000000;  //RGB888 ��ɫ
localparam BLUE   = 24'b00000000_00000000_11111111;  //RGB888 ��ɫ
    
//*****************************************************
//**                    main code
//*****************************************************

//���ݵ�ǰ���ص�����ָ����ǰ���ص���ɫ���ݣ�����Ļ����ʾ����
always @(posedge pixel_clk ) begin
    if (!sys_rst_n)
        pixel_data <= 24'd0;
    else begin
        if((pixel_xpos >= 0) && (pixel_xpos < (H_DISP/5)*1))
            pixel_data <= WHITE;
        else if((pixel_xpos >= (H_DISP/5)*1) && (pixel_xpos < (H_DISP/5)*2))
            pixel_data <= BLACK;  
        else if((pixel_xpos >= (H_DISP/5)*2) && (pixel_xpos < (H_DISP/5)*3))
            pixel_data <= RED;  
        else if((pixel_xpos >= (H_DISP/5)*3) && (pixel_xpos < (H_DISP/5)*4))
            pixel_data <= GREEN;
        else 
            pixel_data <= BLUE;
    end
end

endmodule