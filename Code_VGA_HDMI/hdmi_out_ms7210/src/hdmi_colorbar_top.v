//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com 
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ��?ZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���?
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           hdmi_colorbar_top
// Last modified Date:  2023/9/21 9:30:00
// Last Version:        V1.1
// Descriptions:        HDMI������ʾʵ�鶥��ģ��
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2023/9/21 9:30:00
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module  hdmi_colorbar_top(
    input         		sys_clk,     // input system clock 100MHz
    input         		sys_rst_n,     
    
    output              led,

    output            	rstn_out,     //оƬ��λ�źţ�����Ч
    output            	iic_scl,      //I2C�Ĵ���ʱ���ź�
    inout             	iic_sda,      //I2C�Ĵ��������ź�
   
    output              video_clk,    //���ʱ��?                        
    output            	video_vs,     //��ͬ���ź�
    output            	video_hs,     //��ͬ���ź�
    output            	video_de,     //����ʹ��
    output     [23:0]   video_rgb     //RGB888��ɫ����
);

//wire define
wire          locked;
wire          rst_n;
wire  [12:0]  pixel_xpos_w;
wire  [12:0]  pixel_ypos_w;
wire  [23:0]  pixel_data_w;

//*****************************************************
//**                    main code
//*****************************************************
assign rst_n =  sys_rst_n & locked;

sys_pll sys_pll_m0(
    .inclk0 (sys_clk        ),
    .locked (locked         ),
    .c0    (video_clk        )
);

//������ƵоƬ����ģ��
wire init_over;
ms72xx_ctl ms72xx_ctl(
    .clk            (sys_clk), 
    .rst_n          (rst_n),  

    .rstn_out       (rstn_out),         //����ȫ����ɱ��?                     
    .init_over      (init_over),        //оƬ��λ�źţ�����Ч  
    .iic_scl        (iic_scl), 
    .iic_sda        (iic_sda)  
);

reg [25:0] clk_cnt;
always@(posedge sys_clk) clk_cnt <= clk_cnt + 1;
assign  led = init_over? clk_cnt[25] : 1'b0;

//������Ƶ��ʾ����ģ��
video_driver  u_video_driver(
    .pixel_clk      ( video_clk ),
    .sys_rst_n      ( rst_n ),

    .video_hs       ( video_hs ),
    .video_vs       ( video_vs ),
    .video_de       ( video_de ),
    .video_rgb      ( video_rgb ),
	.data_req		(),

    .pixel_xpos     ( pixel_xpos_w ),
    .pixel_ypos     ( pixel_ypos_w ),
	.pixel_data     ( pixel_data_w )
);

//������Ƶ��ʾģ��
video_display  u_video_display(
    .pixel_clk      (video_clk),
    .sys_rst_n      (rst_n),

    .pixel_xpos     (pixel_xpos_w),
    .pixel_ypos     (pixel_ypos_w),
    .pixel_data     (pixel_data_w)
    );

endmodule 

/* SM 406M
set_location_assignment PIN_T15 -to video_rgb[23]
set_location_assignment PIN_N16 -to video_rgb[22]
set_location_assignment PIN_R14 -to video_rgb[21]
set_location_assignment PIN_P16 -to video_rgb[20]
set_location_assignment PIN_T14 -to video_rgb[19]
set_location_assignment PIN_R16 -to video_rgb[18]
set_location_assignment PIN_R13 -to video_rgb[17]
set_location_assignment PIN_P15 -to video_rgb[16]
set_location_assignment PIN_T13 -to video_rgb[15]
set_location_assignment PIN_N15 -to video_rgb[14]
set_location_assignment PIN_R12 -to video_rgb[13]
set_location_assignment PIN_P14 -to video_rgb[12]
set_location_assignment PIN_T12 -to video_rgb[11]
set_location_assignment PIN_N14 -to video_rgb[10]
set_location_assignment PIN_R11 -to video_rgb[9]
set_location_assignment PIN_N13 -to video_clk
set_location_assignment PIN_T11 -to video_rgb[8]
set_location_assignment PIN_P11 -to video_rgb[7]
set_location_assignment PIN_R9 -to video_rgb[6]
set_location_assignment PIN_T10 -to video_rgb[5]
set_location_assignment PIN_T9 -to video_rgb[4]
set_location_assignment PIN_R10 -to video_rgb[3]
set_location_assignment PIN_R8 -to video_rgb[2]
set_location_assignment PIN_P9 -to video_rgb[1]
set_location_assignment PIN_T8 -to video_rgb[0]
set_location_assignment PIN_P8 -to video_de
set_location_assignment PIN_T7 -to video_hs
set_location_assignment PIN_R7 -to video_vs

set_location_assignment PIN_R6 -to rstn_out
set_location_assignment PIN_R4 -to iic_scl
set_location_assignment PIN_T5 -to iic_sda

*/