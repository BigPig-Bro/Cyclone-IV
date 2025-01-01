`timescale 1ns / 1ps
//****************************************Copyright (c)***********************************//
//??????????????www.yuanzige.com
//????????www.openedv.com
//????????http://openedv.taobao.com 
//????????????????"???????"???????ZYNQ & FPGA & STM32 & LINUX?????
//??????§µ?????????
//Copyright(C) ??????? 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ms72xx_ctl
// Last modified Date:  2023/9/21 9:30:00
// Last Version:        V1.1
// Descriptions:        ???§à????????
//----------------------------------------------------------------------------------------
// Created by:          ???????
// Created date:        2023/9/21 9:30:00
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ms72xx_ctl(
    input       clk,
    input       rst_n,
    
    output      rstn_out,    //§à???¦Ë????????§¹
    output      init_over,   //????????????
    output      iic_scl ,   
    inout       iic_sda 
);


//parameter define
parameter SLAVE_ADDR = 7'h2b          ; //???????
parameter BIT_CTRL   = 1'b1           ; //??????16¦Ë  0:8¦Ë 1:16¦Ë
parameter CLK_FREQ   = 27'd50_000_000 ; //i2c_dri?????????????? 
parameter I2C_FREQ   = 18'd250_000    ; //I2C??SCL??????,??????400KHz

//reg define


//wire define
wire        i2c_exec       ;  //I2C??????????
wire [23:0] i2c_data       ;  //I2C??????????????(??16¦Ë???,??8¦Ë????)          
wire        i2c_done       ;  //I2C???????????????
wire        i2c_dri_clk    ;  //I2C???????
wire [ 7:0] i2c_data_r     ;  //I2C??????????
wire        i2c_rh_wl      ;  //I2C??§Õ???????

//*****************************************************
//**                    main code
//*****************************************************


//I2C???????
i2c_ms7210_cfg u_i2c_ms7210_cfg(
    .clk                (i2c_dri_clk),
    .rst_n              (rst_n),
            
    .i2c_exec           (i2c_exec),
    .i2c_data           (i2c_data),
    .i2c_rh_wl          (i2c_rh_wl),        //I2C??§Õ???????
    .i2c_done           (i2c_done), 
    .i2c_data_r         (i2c_data_r),   
    .rstn_out           (rstn_out),       
    .init_done          (init_over)         //????????????
    );    

//I2C???????
i2c_dri #(
    .SLAVE_ADDR         (SLAVE_ADDR),       //????????
    .CLK_FREQ           (CLK_FREQ  ),              
    .I2C_FREQ           (I2C_FREQ  ) 
    )
u_i2c_dri(
    .clk                (clk),
    .rst_n              (rst_n     ),

    .i2c_exec           (i2c_exec  ),   
    .bit_ctrl           (BIT_CTRL ),   
    .i2c_rh_wl          (i2c_rh_wl),        //????0????????IIC??????§Õ????   
    .i2c_addr           ({i2c_data[15:8],i2c_data[23:16]}),   
    .i2c_data_w         (i2c_data[7:0]),   
    .i2c_data_r         (i2c_data_r),   
    .i2c_done           (i2c_done  ),
    
    .scl                (iic_scl   ),   
    .sda                (iic_sda   ),   

    .dri_clk            (i2c_dri_clk)       //I2C???????
    );	

    
endmodule
