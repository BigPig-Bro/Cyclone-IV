module top(
	input                       clk,
	input                       rst_n,

	//key board
	input                       key_switch,
	input                       key_vol,
	input                       key_rgb,

	//WS2812B RGB LED controller
	output 					 	ws2812_di,        

	//WM8731 audio codec
	input                       wm8731_bclk,            //audio bit clock
	input                       wm8731_daclrc,          //DAC sample rate left right clock
	output                      wm8731_dacdat,          //DAC audio data output
	input                       wm8731_adclrc,          //ADC sample rate left right clock
	input                       wm8731_adcdat,          //ADC audio data input
	inout                       wm8731_scl,             //I2C clock
	inout                       wm8731_sda,             //I2C data

	//SD card controller
	output                      sd_ncs,                 //SD card chip select (SPI mode)
	output                      sd_dclk,                //SD card clock
	output                      sd_mosi,                //SD card controller data output
	input                       sd_miso,                //SD card controller data input
	output [6:0]                HEX0
);

/******************************************************************/
/*******************  SD读取和播放 *********************************/
/******************************************************************/
wire[9:0]                       lut_index;
wire[31:0]                      lut_data;
wire[3:0]                       state_code;
wire[6:0]                       seg_data_0;

//I2C master controller
i2c_config i2c_config_m0(
	.rst                        (~rst_n                   ),
	.clk                        (clk                      ),

	.clk_div_cnt                (16'd99                   ),
	.i2c_addr_2byte             (1'b0                     ),
	.lut_index                  (lut_index                ),
	.lut_dev_addr               (lut_data[31:24]          ),
	.lut_reg_addr               (lut_data[23:8]           ),
	.lut_reg_data               (lut_data[7:0]            ),
	.volume						(volume 				  ),
	.error                      (                         ),
	.done                       (                         ),
	.i2c_scl                    (wm8731_scl               ),
	.i2c_sda                    (wm8731_sda               )
);
//configure look-up table
lut_wm8731 lut_wm8731_m0(
	.lut_index                  (lut_index                ),
	.volume						(volume 				  ),
	.lut_data                   (lut_data                 )
);

wire [6:0] volume;
wire [15:0] fft_data;
wire 	 	fft_data_clkx2;
sd_card_audio  sd_card_audio_m0(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.key_switch                 (key_switch               ),
	.key_vol                    (key_vol                  ),
	.volume						(volume 				  ),

	.fft_data 					(fft_data 				  ),	
	.fft_data_clk 				(fft_data_clk 		  	  ),	

	.state_code                 (state_code               ),
	.bclk                       (wm8731_bclk              ),
	.daclrc                     (wm8731_daclrc            ),
	.dacdat                     (wm8731_dacdat            ),
	.adclrc                     (wm8731_adclrc            ),
	.adcdat                     (wm8731_adcdat            ),

	.sd_ncs                     (sd_ncs                   ),
	.sd_dclk                    (sd_dclk                  ),
	.sd_mosi                    (sd_mosi                  ),
	.sd_miso                    (sd_miso                  )
);

state_decode state_decode_m0(
	.state_code				 (state_code               ),
	.HEX0               	 (HEX0 					)
);

/******************************************************************/
/*******************  音频FFT处理 *********************************/
/******************************************************************/
wire[7:0] [7:0]res_data;
fft_top #(
	.DATA_WIDTH (16 			)
)fft_top_m0(
	.rst_n 		 	(rst_n 			),
	
	.data_in 	 	(fft_data 		),
	.data_in_clk  	(fft_data_clk	),	

	.res_data 	 	(res_data 		)
);

/******************************************************************/
/*******************    显示频谱  *********************************/
/******************************************************************/
ws2812_arry #(
	.CLK_FRE 					(50_000_000 				),
	.WS2812_M 					(8 							),
	.WS2812_N 					(8 							)
) ws2812_arry_m0(
	.clk                        (clk                      ),
	.key_rgb                    (key_rgb                  ),
	.arry_data 					(res_data 				  ),
	.ws2812_di                  (ws2812_di                )
);

endmodule