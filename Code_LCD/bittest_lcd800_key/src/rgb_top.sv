module rgb_top (
    input               	 i_rgb_clk         ,

	input 			 [ 7:0]	 i_reg_A, i_reg_B,

    output  logic    [23:0]  o_lcd_rgb   ,
    output  logic            o_lcd_hs    ,
    output  logic            o_lcd_vs    ,
    output  logic            o_lcd_de    ,
    output  logic            o_lcd_clk   
);

parameter PIXEL_NUM = 800 ;

logic [9:0] lcd_x, lcd_y;
logic o_lcd_de_r, o_lcd_hs_r, o_lcd_vs_r;

assign o_lcd_clk = ~i_rgb_clk;

always@(posedge i_rgb_clk)begin
	o_lcd_de <= o_lcd_de_r;
	o_lcd_vs <= o_lcd_vs_r;
	o_lcd_hs <= o_lcd_hs_r;

	if((lcd_y >= 100) && (lcd_y < 140) && (lcd_x > (i_reg_A + 100)) && (lcd_x < (i_reg_A + 140)))begin //A
        o_lcd_rgb <= 24'HFF0000;
    end else if((lcd_y >= 200) && (lcd_y < 240) && (lcd_x > (i_reg_B + 100)) && (lcd_x < (i_reg_B + 140)))begin //B
        o_lcd_rgb <= 24'H00FF00;
    end else begin
        o_lcd_rgb <= o_lcd_de? 
                    (lcd_x < PIXEL_NUM *  1 / 24	)? 24'H800000: (lcd_x < PIXEL_NUM *  2 / 24 )? 24'H400000: 
                    (lcd_x < PIXEL_NUM *  3 / 24	)? 24'H200000: (lcd_x < PIXEL_NUM *  4 / 24 )? 24'H100000:
                    (lcd_x < PIXEL_NUM *  5 / 24	)? 24'H080000: (lcd_x < PIXEL_NUM *  6 / 24 )? 24'H040000:
                    (lcd_x < PIXEL_NUM *  7 / 24	)? 24'H020000: (lcd_x < PIXEL_NUM *  8 / 24 )? 24'H010000:
                    (lcd_x < PIXEL_NUM *  9 / 24	)? 24'H008000: (lcd_x < PIXEL_NUM * 10 / 24 )? 24'H004000:
                    (lcd_x < PIXEL_NUM * 11 / 24	)? 24'H002000: (lcd_x < PIXEL_NUM * 12 / 24 )? 24'H001000:
                    (lcd_x < PIXEL_NUM * 13 / 24	)? 24'H000800: (lcd_x < PIXEL_NUM * 14 / 24 )? 24'H000400:
                    (lcd_x < PIXEL_NUM * 15 / 24	)? 24'H000200: (lcd_x < PIXEL_NUM * 16 / 24 )? 24'H000100:
                    (lcd_x < PIXEL_NUM * 17 / 24	)? 24'H000080: (lcd_x < PIXEL_NUM * 18 / 24 )? 24'H000040:
                    (lcd_x < PIXEL_NUM * 19 / 24	)? 24'H000020: (lcd_x < PIXEL_NUM * 20 / 24 )? 24'H000010:
                    (lcd_x < PIXEL_NUM * 21 / 24	)? 24'H000008: (lcd_x < PIXEL_NUM * 22 / 24 )? 24'H000004:
                    (lcd_x < PIXEL_NUM * 23 / 24	)? 24'H000002: 24'H000001 : 24'H000000;
    end
end

rgb_timing rgb_timing_m0(
	.i_rgb_clk			(i_rgb_clk		),	
	.i_rgb_rst_n		(1'b1			),	
	.o_rgb_hs			(o_lcd_hs_r		),
	.o_rgb_vs			(o_lcd_vs_r		),
	.o_rgb_de			(o_lcd_de_r		),
	.o_rgb_x			(lcd_x			),
	.o_rgb_y			(lcd_y			)
);
endmodule 