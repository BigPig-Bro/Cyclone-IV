module top (
    input   clk,rst_n,

    output  led
);

parameter CLK_FRE = 50; 

logic [9:0] pwm_duty;
//PWM 占空比控制
pwm_rgb#(
    .CLK_FRE (CLK_FRE    )    
) pwm_rgb_m0(
    .clk      (clk           ), 
    .rst_n    (rst_n         ), 

    .pwm_duty (pwm_duty      )  
);

//PWM 输出
pwm_ctr #(
    .CLK_FRE (CLK_FRE    )    
)pwm_ctr_m0(
    .clk      (clk         	),
    .pwm_duty (pwm_duty		),
    .pwm_rate (10_000      	),
    .pwm_out  (led  		)
);
endmodule