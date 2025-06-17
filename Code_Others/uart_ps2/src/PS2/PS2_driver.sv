module PS2_driver #(
    parameter CLK_FRE       = 50, //系统时钟频率 MHz
    parameter PS2_FRE       = 250_000 //PS2手柄时钟频率 Hz
)(
    input                       i_sys_clk,    //系统时钟
    input                       i_rst_n,      //系统复位

    input                       i_send_req,
    output  logic               o_send_busy,
    input           [ 7:0]      i_send_data,
    output  logic   [ 7:0]      o_recv_data,
    output  logic               o_recv_valid,
    output  logic               o_spi_done,

    output  logic               o_PS2_a_cs_n,
    output  logic               o_PS2_a_clk,
    output  logic               o_PS2_a_cmd,
    input                       i_PS2_a_data
);

localparam RATE_CNT = CLK_FRE * 1000000 / PS2_FRE; //周期

typedef enum logic [1:0] {SPI_IDLE, SPI_START, SPI_WR_DATA, SPI_STOP} spi_state_t;
spi_state_t spi_state;

logic [31:0] rate_cnt; //计数器
logic [ 7:0] spi_send_data_r; //SPI发送数据
logic [ 7:0] spi_recv_data_r; //SPI接收数据
logic [ 3:0] spi_send_cnt;   //SPI发送计数器

assign o_send_busy = (spi_state != SPI_IDLE); //如果SPI状态不是空闲，则忙

always@(posedge i_sys_clk)begin
    if (!i_rst_n) begin
        rate_cnt         <= 'd0;
        spi_send_data_r  <= 'd0;
        spi_recv_data_r  <= 'd0;
        spi_send_cnt     <= 'd0;
        o_recv_valid     <= 'd0;
        o_spi_done       <= 'd0;

        o_PS2_a_cs_n    <= 'd1; //片选信号高
        o_PS2_a_clk     <= 'd1; //时钟信号高
        o_PS2_a_cmd     <= 'd1; //数据输出高

        spi_state       <= SPI_IDLE;
    end else begin
        case(spi_state)
            SPI_IDLE:begin
                o_recv_valid <= 1'b0; //接收无效
                o_spi_done   <= 1'b0; //SPI操作未完成
                spi_send_cnt <= 'd0; //发送计数器清零
                spi_recv_data_r <= 'd0; //接收数据寄存器清零
                rate_cnt <= 'd0; //计数器清零

                o_PS2_a_cs_n <= 1'b1; //片选信号高
                o_PS2_a_clk  <= 1'b1; //时钟信号高

                if (i_send_req) begin
                    spi_send_data_r     <= i_send_data; //保存发送数据

                    spi_state           <= SPI_START; //进入启动状态
                end
            end

            SPI_START:begin
                if (rate_cnt < RATE_CNT) begin
                    rate_cnt <= rate_cnt + 1; //计数器加一
                end else begin
                    rate_cnt <= 'd0; //重置计数器

                    o_PS2_a_cs_n <= 1'b0; //片选信号低，准备发送数据

                    spi_state <= SPI_WR_DATA; //进入写数据状态
                end
            end

            SPI_WR_DATA:begin
                o_PS2_a_cmd <= (rate_cnt == RATE_CNT / 2) ? spi_send_data_r[spi_send_cnt] : o_PS2_a_cmd; //发送数据位
                
                if ((rate_cnt == RATE_CNT) || (rate_cnt == RATE_CNT / 2) ) begin
                    o_PS2_a_clk <= ~o_PS2_a_clk; //翻转时钟信号，模拟SPI时钟边沿触发数据传输
                end 

                if (rate_cnt == RATE_CNT) begin
                    spi_recv_data_r <= {i_PS2_a_data, spi_recv_data_r[7:1]}; //读取PS2手柄数据，左移一位
                end

                if (rate_cnt < RATE_CNT) begin
                    rate_cnt <= rate_cnt + 1; //计数器加一
                end else begin
                    rate_cnt        <= 'd0; //重置计数器
                    spi_send_cnt    <= (spi_send_cnt <  7) ? spi_send_cnt + 1 : 0; //发送计数器加一
                    o_recv_valid    <= (spi_send_cnt == 7) ? 1'b1 : 1'b0; //接收有效
                    o_recv_data     <= (spi_send_cnt == 7) ? {i_PS2_a_data, spi_recv_data_r[7:1]} : o_recv_data; //接收数据
                    o_spi_done      <= (spi_send_cnt == 7) ? 1'b1 : 1'b0; //接收有效

                    if (spi_send_cnt == 7) begin
                        spi_state <= SPI_STOP; //如果发送完8位数据，进入停止状态
                    end
                end
            end

            SPI_STOP:begin
                o_spi_done      <= 1'b0; //提前 SPI操作完成
                o_recv_valid    <= 1'b0; //接收有效

                spi_state       <= SPI_IDLE; //返回空闲状态
            end

        endcase
    end
end

endmodule