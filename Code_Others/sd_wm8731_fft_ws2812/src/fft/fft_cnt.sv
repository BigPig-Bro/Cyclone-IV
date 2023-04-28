module fft_cnt (
    input        fft_clk,

    input [10:0] fft_data_cnt,
    input [63:0] fft_data_amp,

    output reg [7:0][7:0] res_data
);

reg [1:0]       state = 0;
reg [7:0][19:0] fft_data_amp_sum;

//量化分段
parameter QUANT_0 = 20;
parameter QUANT_1 = 50;
parameter QUANT_2 = 100;
parameter QUANT_3 = 300;
parameter QUANT_4 = 600;
parameter QUANT_5 = 1400;
parameter QUANT_6 = 3200;
parameter QUANT_7 = 6400;//最大值

always@(posedge fft_clk)
    case(state)
        'd0: //等待数据cnt 到达1024 跳过左半轴
            if(fft_data_cnt == 1024)begin
                fft_data_amp_sum[0] <= 0;
                fft_data_amp_sum[1] <= 0;
                fft_data_amp_sum[2] <= 0;
                fft_data_amp_sum[3] <= 0;
                fft_data_amp_sum[4] <= 0;
                fft_data_amp_sum[5] <= 0;
                fft_data_amp_sum[6] <= 0;
                fft_data_amp_sum[7] <= 0;
                state <= 'd1;
            end
        'd1: //统计数据
            //八段不等划分
            if(fft_data_cnt > 512) state <= 'd2; //跳过对称轴
            else if(fft_data_cnt > 448) fft_data_amp_sum[7] <= fft_data_amp_sum[6] + fft_data_amp[44:31];
            else if(fft_data_cnt > 384)  fft_data_amp_sum[6] <= fft_data_amp_sum[5] + fft_data_amp[44:31];
            else if(fft_data_cnt > 320)  fft_data_amp_sum[5] <= fft_data_amp_sum[4] + fft_data_amp[44:31];
            else if(fft_data_cnt > 256)  fft_data_amp_sum[4] <= fft_data_amp_sum[3] + fft_data_amp[44:31];
            else if(fft_data_cnt > 192)  fft_data_amp_sum[3] <= fft_data_amp_sum[2] + fft_data_amp[44:31];
            else if(fft_data_cnt > 128)   fft_data_amp_sum[2] <= fft_data_amp_sum[1] + fft_data_amp[44:31];
            else if(fft_data_cnt > 64)   fft_data_amp_sum[1] <= fft_data_amp_sum[1] + fft_data_amp[44:31];
            else                        fft_data_amp_sum[0] <= fft_data_amp_sum[0] + fft_data_amp[44:31];

        'd2://跳过对称轴
            if(fft_data_cnt == 1024)
                state <= 'd0;
    endcase

reg [7:0][11:0] res_data_r;
always@(posedge fft_clk)
    if(state == 'd2)begin//在跳过的时候进行数值转换
        res_data_r[0] <= fft_data_amp_sum[0][19:2];
        res_data_r[1] <= fft_data_amp_sum[1][19:2];
        res_data_r[2] <= fft_data_amp_sum[2][19:2];
        res_data_r[3] <= fft_data_amp_sum[3][19:2];
        res_data_r[4] <= fft_data_amp_sum[4][19:2];
        res_data_r[5] <= fft_data_amp_sum[5][19:2];
        res_data_r[6] <= fft_data_amp_sum[6][19:2];
        res_data_r[7] <= fft_data_amp_sum[7][19:2];
    end
    else begin
        if(res_data_r[0] <= QUANT_0) res_data[0] <= 8'b00000000;
        else if(res_data_r[0] <= QUANT_1) res_data[0] <= 8'b00000001;
        else if(res_data_r[0] <= QUANT_2) res_data[0] <= 8'b00000011;
        else if(res_data_r[0] <= QUANT_3) res_data[0] <= 8'b00000111;
        else if(res_data_r[0] <= QUANT_4) res_data[0] <= 8'b00001111;
        else if(res_data_r[0] <= QUANT_5) res_data[0] <= 8'b00011111;
        else if(res_data_r[0] <= QUANT_6) res_data[0] <= 8'b00111111;
        else if(res_data_r[0] <= QUANT_7) res_data[0] <= 8'b01111111;
        else                          res_data[0] <= 8'b11111111;

        if(res_data_r[1] <= QUANT_0) res_data[1] <= 8'b00000000;
        else if(res_data_r[1] <= QUANT_1) res_data[1] <= 8'b00000001;
        else if(res_data_r[1] <= QUANT_2) res_data[1] <= 8'b00000011;
        else if(res_data_r[1] <= QUANT_3) res_data[1] <= 8'b00000111;
        else if(res_data_r[1] <= QUANT_4) res_data[1] <= 8'b00001111;
        else if(res_data_r[1] <= QUANT_5) res_data[1] <= 8'b00011111;
        else if(res_data_r[1] <= QUANT_6) res_data[1] <= 8'b00111111;
        else if(res_data_r[1] <= QUANT_7) res_data[1] <= 8'b01111111;
        else                          res_data[1] <= 8'b11111111;

        if(res_data_r[2] <= QUANT_0) res_data[2] <= 8'b00000000;
        else if(res_data_r[2] <= QUANT_1) res_data[2] <= 8'b00000001;
        else if(res_data_r[2] <= QUANT_2) res_data[2] <= 8'b00000011;
        else if(res_data_r[2] <= QUANT_3) res_data[2] <= 8'b00000111;
        else if(res_data_r[2] <= QUANT_4) res_data[2] <= 8'b00001111;
        else if(res_data_r[2] <= QUANT_5) res_data[2] <= 8'b00011111;
        else if(res_data_r[2] <= QUANT_6) res_data[2] <= 8'b00111111;
        else if(res_data_r[2] <= QUANT_7) res_data[2] <= 8'b01111111;
        else                          res_data[2] <= 8'b11111111;

        if(res_data_r[3] <= QUANT_0) res_data[3] <= 8'b00000000;
        else if(res_data_r[3] <= QUANT_1) res_data[3] <= 8'b00000001;
        else if(res_data_r[3] <= QUANT_2) res_data[3] <= 8'b00000011;
        else if(res_data_r[3] <= QUANT_3) res_data[3] <= 8'b00000111;
        else if(res_data_r[3] <= QUANT_4) res_data[3] <= 8'b00001111;
        else if(res_data_r[3] <= QUANT_5) res_data[3] <= 8'b00011111;
        else if(res_data_r[3] <= QUANT_6) res_data[3] <= 8'b00111111;
        else if(res_data_r[3] <= QUANT_7) res_data[3] <= 8'b01111111;
        else                          res_data[3] <= 8'b11111111;

        if(res_data_r[4] <= QUANT_0) res_data[4] <= 8'b00000000;
        else if(res_data_r[4] <= QUANT_1) res_data[4] <= 8'b00000001;
        else if(res_data_r[4] <= QUANT_2) res_data[4] <= 8'b00000011;
        else if(res_data_r[4] <= QUANT_3) res_data[4] <= 8'b00000111;
        else if(res_data_r[4] <= QUANT_4) res_data[4] <= 8'b00001111;
        else if(res_data_r[4] <= QUANT_5) res_data[4] <= 8'b00011111;
        else if(res_data_r[4] <= QUANT_6) res_data[4] <= 8'b00111111;
        else if(res_data_r[4] <= QUANT_7) res_data[4] <= 8'b01111111;
        else                          res_data[4] <= 8'b11111111;

        if(res_data_r[5] <= QUANT_0) res_data[5] <= 8'b00000000;
        else if(res_data_r[5] <= QUANT_1) res_data[5] <= 8'b00000001;
        else if(res_data_r[5] <= QUANT_2) res_data[5] <= 8'b00000011;
        else if(res_data_r[5] <= QUANT_3) res_data[5] <= 8'b00000111;
        else if(res_data_r[5] <= QUANT_4) res_data[5] <= 8'b00001111;
        else if(res_data_r[5] <= QUANT_5) res_data[5] <= 8'b00011111;
        else if(res_data_r[5] <= QUANT_6) res_data[5] <= 8'b00111111;
        else if(res_data_r[5] <= QUANT_7) res_data[5] <= 8'b01111111;
        else                          res_data[5] <= 8'b11111111;

        if(res_data_r[6] <= QUANT_0) res_data[6] <= 8'b00000000;
        else if(res_data_r[6] <= QUANT_1) res_data[6] <= 8'b00000001;
        else if(res_data_r[6] <= QUANT_2) res_data[6] <= 8'b00000011;
        else if(res_data_r[6] <= QUANT_3) res_data[6] <= 8'b00000111;
        else if(res_data_r[6] <= QUANT_4) res_data[6] <= 8'b00001111;
        else if(res_data_r[6] <= QUANT_5) res_data[6] <= 8'b00011111;
        else if(res_data_r[6] <= QUANT_6) res_data[6] <= 8'b00111111;
        else if(res_data_r[6] <= QUANT_7) res_data[6] <= 8'b01111111;
        else                          res_data[6] <= 8'b11111111;

        if(res_data_r[7] <= QUANT_0) res_data[7] <= 8'b00000000;
        else if(res_data_r[7] <= QUANT_1) res_data[7] <= 8'b00000001;
        else if(res_data_r[7] <= QUANT_2) res_data[7] <= 8'b00000011;
        else if(res_data_r[7] <= QUANT_3) res_data[7] <= 8'b00000111;
        else if(res_data_r[7] <= QUANT_4) res_data[7] <= 8'b00001111;
        else if(res_data_r[7] <= QUANT_5) res_data[7] <= 8'b00011111;
        else if(res_data_r[7] <= QUANT_6) res_data[7] <= 8'b00111111;
        else if(res_data_r[7] <= QUANT_7) res_data[7] <= 8'b01111111;
        else                          res_data[7] <= 8'b11111111;
    end
endmodule