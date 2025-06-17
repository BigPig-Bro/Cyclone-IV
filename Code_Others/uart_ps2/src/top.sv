module top (
    input                i_sys_clk,
    input                i_rst_n,

    //PS2 IO 
    output               o_PS2_a_cs_n,
    output               o_PS2_a_clk,
    output               o_PS2_a_cmd,//DO
    input                i_PS2_a_data,//DI

    //LED DEBUG
    output               o_PS2_key_press, //PS2手柄按键按下标志
    output               o_PS2_key_release, //PS2手柄按键松开标志
    output               o_PS2_data_valid, //PS2手柄数据有效标志

    //串口 IO
    output               o_uart_tx
);

parameter CLK_FRE       = 50; //50MHz
parameter UART_RATE 	= 115200; //波特率
parameter SEND_FRE      = 1; //发送频率 1H

logic           PS2_data_valid; //PS2手柄数据有效标志
logic [15:0]    PS2_key; //SELECT\L3\R3\START\UP\RIGHT\DOWN\LEFT
                         //L2\R2\L1\R1\△\O\X\口
logic [ 7:0]    PS2_RX,PS2_RY,PS2_LX,PS2_LY; //右摇杆X\Y\左摇杆X\Y
logic [ 7:0]    PS2_ID; //ID

//==========================  读取手柄数据 ==================================
PS2_top#(
    .CLK_FRE            (CLK_FRE               ), //系统时钟频率 MHz
    .SCAN_MODE          (1                     )  //0:中断触发（数值不变，valid不拉高） 1:固定轮询（数值不变，valid仍拉高）
)PS2_top_m0( 
    .i_sys_clk          (i_sys_clk            ), 
    .i_rst_n            (i_rst_n              ), //系统复位 低有效

    .o_PS2_data_valid   (o_PS2_data_valid     ), //数据有效标志, 输出模式和SCAN_MODE有关
    .o_PS2_key_press    (o_PS2_key_press      ), //PS2手柄按键按下标志（按下时那个扫描包完成拉高，下个包完成拉低）
    .o_PS2_key_release  (o_PS2_key_release    ), //PS2手柄按键松开标志（松开时那个扫描包完成拉高，下个包完成拉低）
    .o_PS2_key          (PS2_key              ), //PS2手柄按键值
    .o_PS2_RX           (PS2_RX               ), //PS2手柄右摇杆X轴值
    .o_PS2_RY           (PS2_RY               ), //PS2手柄右摇杆Y轴值
    .o_PS2_LX           (PS2_LX               ), //PS2手柄左摇杆X轴值
    .o_PS2_LY           (PS2_LY               ), //PS2手柄左摇杆Y轴值
    .o_PS2_ID           (PS2_ID               ), //PS2手柄ID

    .o_PS2_a_cs_n      (o_PS2_a_cs_n          ),
    .o_PS2_a_clk       (o_PS2_a_clk           ),
    .o_PS2_a_cmd       (o_PS2_a_cmd           ),
    .i_PS2_a_data      (i_PS2_a_data          )
);

//==========================  串口收发数据 ==================================
//中断触发下，自行处理串口响应问题（因为你按下松开可能比一次串口或者等待时间还短，会发不出去）
uart_top#(
    .CLK_FRE            (CLK_FRE              ),
    .UART_RATE          (UART_RATE            ),
    .SEND_FRE           (SEND_FRE             ) //发送频率 1Hz
)uart_top_m0(       
    .i_sys_clk          (i_sys_clk            ),
    .i_rst_n            (i_rst_n              ),

    .i_PS2_data_valid   (o_PS2_data_valid     ), //PS2手柄数据有效标志
    .i_PS2_key          (PS2_key              ),
    .i_PS2_RX           (PS2_RX               ),
    .i_PS2_RY           (PS2_RY               ),
    .i_PS2_LX           (PS2_LX               ),
    .i_PS2_LY           (PS2_LY               ),
    .i_PS2_ID           (PS2_ID               ),

    .i_uart_rx          (                     ),
    .o_uart_tx          (o_uart_tx            )
);


endmodule