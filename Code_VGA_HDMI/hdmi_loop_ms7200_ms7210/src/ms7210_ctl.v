`timescale 1ns / 1ps
//****************************************Copyright (c)***********************************//
//??????????????www.yuanzige.com
//????????www.openedv.com
//????????http://openedv.taobao.com 
//????????????????"???????"???????ZYNQ & FPGA & STM32 & LINUX?????
//??????��?????????
//Copyright(C) ??????? 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ms72xx_ctl
// Last modified Date:  2023/9/21 9:30:00
// Last Version:        V1.1
// Descriptions:        ???��????????
//----------------------------------------------------------------------------------------
// Created by:          ???????
// Created date:        2023/9/21 9:30:00
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ms7210_ctl(
    input       clk,
    input       rst_n,
    
    output      rstn_out,    //��???��????????��
    output      init_over,   //????????????
    output      iic_scl ,   
    inout       iic_sda 
);


//parameter define
parameter SLAVE_ADDR = 7'h2b          ; //器件地址
parameter BIT_CTRL   = 1'b1           ; //字节地址为16位  0:8位 1:16位
parameter CLK_FREQ   = 27'd50_000_000 ; //i2c_dri模块的驱动时钟频率 
parameter I2C_FREQ   = 18'd250_000    ; //I2C的SCL时钟频率,不超过400KHz

//reg define


//wire define
wire        i2c_exec       ;  //I2C触发执行信号
wire [23:0] i2c_data       ;  //I2C要配置的地址与数据(高16位地址,低8位数据) 
wire        i2c_done       ;  //I2C寄存器配置完成信号
wire        i2c_dri_clk    ;  //I2C操作时钟
wire [ 7:0] i2c_data_r     ;  //I2C读出的数据
wire        i2c_rh_wl      ;  //I2C读写控制信号

//*****************************************************
//**                    main code
//*****************************************************


//I2C配置模块
i2c_ms7210_cfg u_i2c_ms7210_cfg(
    .clk                (i2c_dri_clk),
    .rst_n              (rst_n),
            
    .i2c_exec           (i2c_exec),
    .i2c_data           (i2c_data),
    .i2c_rh_wl          (i2c_rh_wl),        //I2C??��???????
    .i2c_done           (i2c_done), 
    .i2c_data_r         (i2c_data_r),   
    .rstn_out           (rstn_out),       
    .init_done          (init_over)         //????????????
    );    

//I2C配置模块
i2c_dri #(
    .CLK_FREQ           (CLK_FREQ  ),              
    .I2C_FREQ           (I2C_FREQ  ) 
    )
u_i2c_dri(
    .clk                (clk),
    .rst_n              (rst_n     ),

    .slave_addr         (SLAVE_ADDR ),
    .i2c_exec           (i2c_exec  ),   
    .bit_ctrl           (BIT_CTRL ),   
    .i2c_rh_wl          (i2c_rh_wl),        //固定为0，只用到了IIC驱动的写操作   
    .i2c_addr           ({i2c_data[15:8],i2c_data[23:16]}),   
    .i2c_data_w         (i2c_data[7:0]),   
    .i2c_data_r         (i2c_data_r),   
    .i2c_done           (i2c_done  ),
    
    .scl                (iic_scl   ),   
    .sda                (iic_sda   ),   

    .dri_clk            (i2c_dri_clk)      //I2C操作时钟
    );	

    
endmodule
