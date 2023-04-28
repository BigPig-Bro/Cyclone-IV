module fft1024_top#(
    parameter DATA_WIDTH        = 16 //输入数据位宽 0~32，位宽不够时补符号位
)(
    input rst_n,

    //输入接口
    input                       data_in_clk,
    input [DATA_WIDTH - 1:0]    data_in,   

    //输出接口
    output [10:0]               fft_data_cnt,
    output [63:0]               fft_data_amp
    );

    //=============================读入txt文件数据用以测试===============================================

    //=============================      写入数据     =================================================
    reg clk_fft;
    always @(posedge data_in_clk or negedge rst_n) 
        if(~rst_n)
            clk_fft <= 1'b0;
        else
            clk_fft <= ~clk_fft;
    
    reg [63:0] i0;
    reg [63:0] i1;

    //先后输入数据
    always @(posedge data_in_clk or negedge rst_n) 
        if(~rst_n) begin
            i0 <= 0;
            i1 <= 0;
        end
        else begin
            //[63:32] 为虚部，输入为0，[31:0] 为实部
            i0[31:0] <= i1[31:0];
            i1[31:0] <= {{DATA_WIDTH{data_in[DATA_WIDTH - 1]}}, data_in[DATA_WIDTH - 1:0]};
        end

    reg fft_rst;
    reg fft_next;
    wire fft_next_out;
    wire [63:0] o0;
    wire [63:0] o1;

    reg [10:0] fft_cnt;
    reg fft_state;

    //FFT时序驱动
    always @(posedge clk_fft or negedge rst_n) begin
        if(~rst_n) begin
            fft_cnt <= 0;
            fft_state <= 0;
            fft_rst <= 0;
            fft_next <= 0;
        end
        else begin
            case(fft_state)
                0: begin
                    if(fft_cnt == 1892) begin
                        fft_rst <= 1'b1;
                        fft_cnt <= fft_cnt + 1'b1;
                    end
                    else if(fft_cnt == 1894) begin
                        fft_rst <= 1'b0;
                        fft_cnt <= fft_cnt + 1'b1;
                    end
                    if(fft_cnt == 1895) begin
                        fft_next <= 1'b1;
                        fft_state <= fft_state + 1;
                        fft_cnt <= 0;
                    end
                    else begin
                        fft_cnt <= fft_cnt + 1'b1;
                    end
                end
                1: begin
                    if(fft_cnt == 511) begin
                        fft_next <= 1'b1;
                        fft_cnt <= 0;
                    end
                    else begin
                        fft_next <= 1'b0;
                        fft_cnt <= fft_cnt + 1'b1;
                    end
                end
                default: begin
                    fft_state <= 0;
                end
            endcase
        end
    end

    //FFT例化
    fft1024_core fft1024_core_m0 (
        .clk        (clk_fft         ),
        .reset      (fft_rst        ),
        .next       (fft_next       ),
        .i0         (i0             ),
        .i1         (i1             ),

        .next_out   (fft_next_out   ),
        .o0         (o0             ),
        .o1         (o1             )
    );

    reg [63:0] fft_data_out;
    reg fft_out_flag;

    //还原数据输出频率
    always @(posedge data_in_clk or negedge rst_n) 
        if(~rst_n) begin
            fft_out_flag <= 1'b0;
            fft_data_out <= 64'd0;
        end
        else begin
            if(fft_out_flag == 1'b0)
                fft_data_out <= o0;
            else
                fft_data_out <= o1;
            fft_out_flag <= ~fft_out_flag;
        end

//=============================fft实部虚部输出=======================================================
    wire signed [31:0] out_image;
    wire signed [31:0] out_real;
    assign out_real     = fft_data_out[31:0];
    assign out_image    = fft_data_out[63:32];

    assign fft_data_cnt = out_cnt;
    assign fft_data_amp = out_real * out_real + out_image * out_image;
//============================= fft输出计数器 =======================================================
    reg cnt_state;
    reg [10:0] out_cnt;

    always @(posedge data_in_clk or negedge rst_n) 
        if(~rst_n) 
            cnt_state <= 0;
        else 
            case(cnt_state)
                0: 
                    if(fft_next_out) begin
                        out_cnt <= 1;
                        cnt_state <= cnt_state + 1;
                    end
                    else 
                        cnt_state <= cnt_state;
                1: 
                    if(out_cnt == 1024) begin
                        out_cnt <= 1;
                    end
                    else 
                        out_cnt <= out_cnt + 1;
            endcase

endmodule
