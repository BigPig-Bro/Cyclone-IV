module top(
    input       clk,rst_n,

    input       key_rgb,key_cnt,
    
    output      ws2812_di
);

reg key_cnt_reg;
always@(posedge clk ) key_cnt_reg <= key_cnt;

reg [7:0][7:0] arry_data ;
always@(posedge clk,negedge rst_n)
    if(!rst_n)
        arry_data[0] <= 8'd3;
    else
        if(key_cnt && !key_cnt_reg)begin
            arry_data[0] <= {arry_data[0][6:0],arry_data[0][7]};
            arry_data[1] <=  arry_data[0];
            arry_data[2] <=  arry_data[1];
            arry_data[3] <=  arry_data[2];  
            arry_data[4] <=  arry_data[3];
            arry_data[5] <=  arry_data[4];
            arry_data[6] <=  arry_data[5];
            arry_data[7] <=  arry_data[6];
        end

ws2812_arry #(
	.CLK_FRE 					(50_000_000 			  ),
	.WS2812_M 					(8 						  ),
	.WS2812_N 					(8 						  )
) ws2812_arry_m0(
	.clk                        (clk                      ),
	.key_rgb                    (key_rgb                  ),
	.arry_data 					(arry_data 				  ),
	.ws2812_di                  (ws2812_di                )
);

endmodule