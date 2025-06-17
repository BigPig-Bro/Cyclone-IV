module PS2_top #(
    parameter CLK_FRE       = 50, //系统时钟频率 MHz
    parameter PS2_FRE       = 250_000, //PS2手柄时钟频率 Hz
    parameter SCAN_MODE     = 1 //0:中断触发, 1:固定轮询
)(
    input                       i_sys_clk,    //系统时钟
    input                       i_rst_n,      //系统复位

    // 初始化较为麻烦，暂不支持
    // input        [ 7:0]        i_PS2_Motor_L, //PS2手柄左马达
    // input        [ 7:0]        i_PS2_Motor_R, //PS2手柄右马达

    output logic               o_PS2_data_valid,   //PS2手柄数据有效标志
    output logic               o_PS2_key_press,    //PS2手柄按键按下标志
    output logic               o_PS2_key_release,  //PS2手柄按键松开标志
    output logic [15:0]        o_PS2_key,          //PS2手柄按键值 
    output logic [ 7:0]        o_PS2_RX,           //PS2手柄右摇杆X轴值
    output logic [ 7:0]        o_PS2_RY,           //PS2手柄右摇杆Y轴值
    output logic [ 7:0]        o_PS2_LX,           //PS2手柄左摇杆X轴值
    output logic [ 7:0]        o_PS2_LY,           //PS2手柄左摇杆Y轴值
    output logic [ 7:0]        o_PS2_ID,           //PS2手柄ID

    output logic               o_PS2_a_cs_n, //PS2手柄片选信号
    output                     o_PS2_a_clk,  //PS2手柄时钟信号
    output                     o_PS2_a_cmd,  //PS2手柄数据输出
    input                      i_PS2_a_data  //PS2手柄数据输入
);
`include "PS2_define.sv"

localparam TIME_10US = CLK_FRE * 10; //10us计数值

typedef enum logic [4:0] {IDLE, CS_START , START, READ_ID, READ_5A, READ_WW, READ_YY, READ_RX, READ_RY, READ_LX, READ_LY, OUTPUT_DATA, CS_END, READ_DELAY} STATE_PS2;
STATE_PS2 state_ps2;

logic           spi_send_req; //SPI发送请求
logic           spi_send_busy; //SPI发送忙信号
logic           spi_recv_valid; //SPI接收有效信号
logic [ 7:0]    spi_recv_data; //SPI接收数据
logic [ 7:0]    spi_send_data; //SPI发送数据
logic           spi_done; //SPI操作完成信号
logic [ 7:0]    NULL; //空数据
logic [31:0]    delay_cnt; //延时计数器

logic [ 7:0] o_PS2_ID_r; //PS2手柄ID寄存器
logic [15:0] o_PS2_key_r; //PS2手柄按键寄存器
logic [ 7:0] o_PS2_RX_r; //PS2手柄右摇杆X轴寄存器
logic [ 7:0] o_PS2_RY_r; //PS2手柄右摇杆Y轴寄存器
logic [ 7:0] o_PS2_LX_r; //PS2手柄左摇杆X轴寄存器
logic [ 7:0] o_PS2_LY_r; //PS2手柄左摇杆Y轴寄存器

always@(posedge i_sys_clk) begin
    if (!i_rst_n) begin
        o_PS2_data_valid   <= 'd0;
        o_PS2_key_press    <= 'd0;
        o_PS2_key_release  <= 'd0;
        o_PS2_key          <= 'd0;
        o_PS2_RX           <= 'd0;
        o_PS2_RY           <= 'd0;
        o_PS2_LX           <= 'd0;
        o_PS2_LY           <= 'd0;
        o_PS2_ID           <= 'd0;

        delay_cnt          <= 'd0;
        spi_send_req       <= 'd0;
        spi_send_data      <= 'd0;

        state_ps2          <= IDLE;
    end else begin
       case(state_ps2)
            IDLE:begin
                o_PS2_data_valid   <= 1'b0;

                delay_cnt          <= 'd0;
                spi_send_req       <= 'd0;
                spi_send_data      <= 'd0;

                state_ps2 <= CS_START;
            end

            CS_START:begin
                o_PS2_a_cs_n <= 'b0; //片选信号拉低

                if (delay_cnt >= TIME_10US) begin //延时10us
                    delay_cnt <= 'd0;
                    state_ps2 <= START;
                end else begin
                    delay_cnt <= delay_cnt + 'd1;
                end
            end

            START:begin
                RW_PS2_1Byte(PS2_START_A, NULL, `SPI_DRIVER_BUS);

                state_ps2 <= spi_done ? READ_ID : state_ps2;
            end

            READ_ID:begin
                RW_PS2_1Byte(PS2_START_B, o_PS2_ID_r, `SPI_DRIVER_BUS);

                state_ps2 <= spi_done ? READ_5A : state_ps2;
            end

            READ_5A:begin
                RW_PS2_1Byte(PS2_IDLE, NULL, `SPI_DRIVER_BUS);

                state_ps2 <= spi_done ? READ_WW : state_ps2;
            end

            READ_WW:begin
                RW_PS2_1Byte(PS2_IDLE, o_PS2_key_r[15:8], `SPI_DRIVER_BUS);

                state_ps2 <= spi_done ? READ_YY : state_ps2;
            end

            READ_YY:begin
                RW_PS2_1Byte(PS2_IDLE, o_PS2_key_r[ 7:0], `SPI_DRIVER_BUS);

                state_ps2 <= spi_done ? READ_RX : state_ps2;
            end

            READ_RX:begin
                RW_PS2_1Byte(PS2_IDLE, o_PS2_RX_r, `SPI_DRIVER_BUS);

                state_ps2 <= spi_done ? READ_RY : state_ps2;
            end

            READ_RY:begin
                RW_PS2_1Byte(PS2_IDLE, o_PS2_RY_r, `SPI_DRIVER_BUS);

                state_ps2 <= spi_done ? READ_LX : state_ps2;
            end

            READ_LX:begin
                RW_PS2_1Byte(PS2_IDLE, o_PS2_LX_r, `SPI_DRIVER_BUS);

                state_ps2 <= spi_done ? READ_LY : state_ps2;
            end

            READ_LY:begin
                RW_PS2_1Byte(PS2_IDLE, o_PS2_LY_r, `SPI_DRIVER_BUS);

                state_ps2 <= spi_done ? OUTPUT_DATA : state_ps2;
            end
            OUTPUT_DATA:begin
                //根据SCAN_MODE选择是否拉高数据有效标志
                if (SCAN_MODE) begin
                    o_PS2_data_valid <= 1'b1; //固定轮询模式，数据不变，valid仍拉高
                end else begin //中断触发模式，数据不变，valid不拉高
                    if ((o_PS2_key ^ o_PS2_key_r) || (o_PS2_RX ^ o_PS2_RX_r) || (o_PS2_RY ^ o_PS2_RY_r) || (o_PS2_LX ^ o_PS2_LX_r) 
                    || (o_PS2_LY ^ o_PS2_LY_r) || (o_PS2_ID ^ o_PS2_ID_r)) begin
                        o_PS2_data_valid <= 1'b1;
                    end else begin
                        o_PS2_data_valid <= 1'b0; //数据未变化，valid不拉高
                    end
                end

                //更新按键状态(按下 0, 松开 1)
                if (o_PS2_key_r < o_PS2_key) begin
                    o_PS2_key_press    <= 1'b1; //按键按下
                    o_PS2_key_release  <= 1'b0; //按键未松开
                end else if (o_PS2_key_r > o_PS2_key) begin
                    o_PS2_key_press    <= 1'b0; //按键未按下
                    o_PS2_key_release  <= 1'b1; //按键松开
                end else begin
                    o_PS2_key_press    <= 1'b0; //按键未按下
                    o_PS2_key_release  <= 1'b0; //按键未松开
                end

                //更新寄存器
                o_PS2_key  <= o_PS2_key_r;
                o_PS2_RX   <= o_PS2_RX_r;
                o_PS2_RY   <= o_PS2_RY_r;
                o_PS2_LX   <= o_PS2_LX_r;
                o_PS2_LY   <= o_PS2_LY_r;
                o_PS2_ID   <= o_PS2_ID_r;

                state_ps2  <= CS_END; //进入片选结束状态;
            end

            CS_END:begin
                o_PS2_a_cs_n <= (delay_cnt >= TIME_10US)? 'b1 : 'b0; //片选信号拉高

                o_PS2_data_valid   <= 1'b0;

                delay_cnt          <= 'd0;
                spi_send_req       <= 'd0;
                spi_send_data      <= 'd0;

                if (delay_cnt >= TIME_10US * 3) begin //延时20us
                    delay_cnt <= 'd0;
                    state_ps2 <= IDLE; 
                end else begin
                    delay_cnt <= delay_cnt + 'd1;
                end
            end

            default:begin
                state_ps2 <= IDLE;
            end
       endcase
    end
end 

//spi 驱动
PS2_driver #(
    .CLK_FRE            (CLK_FRE        ),
    .PS2_FRE            (PS2_FRE        )
) ps2_driver_m0 (
    .i_sys_clk          (i_sys_clk      ),
    .i_rst_n            (i_rst_n        ),   

    .i_send_req         (spi_send_req   ),
    .o_send_busy        (spi_send_busy  ),
    .i_send_data        (spi_send_data  ),
    .o_recv_data        (spi_recv_data  ),
    .o_recv_valid       (spi_recv_valid ),
    .o_spi_done         (spi_done       ),

    .o_PS2_a_cs_n       (               ),//全程拉低
    .o_PS2_a_clk        (o_PS2_a_clk    ),
    .o_PS2_a_cmd        (o_PS2_a_cmd    ),
    .i_PS2_a_data       (i_PS2_a_data   )
);

endmodule