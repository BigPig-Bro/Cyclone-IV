module pwm_rgb #(
    parameter CLK_FRE = 50
    ) (
    input                clk,rst_n,

    output reg [9:0]     pwm_duty
);

//将输入时钟 CLK * 1MHz 分频为 100Hz
reg [17:0] pwm_clk_cnt = 0;
always@(posedge clk) pwm_clk_cnt <=  (pwm_clk_cnt == CLK_FRE * 10_000 - 1)? 'D0 : pwm_clk_cnt + 1;

//根据时钟计数值，输出PWM占空比
logic clk_100hz;
assign clk_100hz = (pwm_clk_cnt == 0);

logic [2:0] state = 0;
always@(posedge clk_100hz)
    if(!rst_n)begin
        state = 0;

        pwm_duty <= 0;
    end
    else
        case(state)
            3'd0:begin
                if(pwm_duty <= 99)
                    pwm_duty <= pwm_duty + 1;
                else
                    state <= 3'd1;
            end

            3'd1:begin
                if(pwm_duty >= 1)
                    pwm_duty <= pwm_duty - 1;
                else
                    state <= 3'd0;
            end 
        endcase

endmodule