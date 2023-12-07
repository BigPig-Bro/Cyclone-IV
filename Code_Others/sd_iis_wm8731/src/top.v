module top(
	input                       clk,
	input                       rst_n,
	input                       key_next,key_vol,

	//WM8731 audio codec
	input                       wm8731_bclk,            //audio bit clock
	input                       wm8731_daclrc,          //DAC sample rate left right clock
	output                      wm8731_dacdat,          //DAC audio data output
	input                       wm8731_adclrc,          //ADC sample rate left right clock
	input                       wm8731_adcdat,          //ADC audio data input
	inout                       wm8731_scl,             //I2C clock
	inout                       wm8731_sda,             //I2C data

	//SD card
	output                      sd_ncs,                 //SD card chip select (SPI mode)
	output                      sd_dclk,                //SD card clock
	output                      sd_mosi,                //SD card controller data output
	input                       sd_miso,                //SD card controller data input
	output [5:0]                seg_sel,
	output [7:0]                seg_data
);
wire[9:0]                       lut_index;
wire[31:0]                      lut_data;
wire[3:0]                       state_code;
wire[6:0]                       seg_data_0;

//I2C master controller

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
	.key_next                 	(key_next               ),
	.key_vol                    (key_vol                  ),
	.volume						(volume 				  ),

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
//with a digital display of state_code
// 0:SD card is initializing
// 1:wait for the button to press
// 2:looking for the WAV file
// 3:playing
seg_decoder seg_decoder_m0(
	.bin_data                   (state_code               ),
	.seg_data                   (seg_data_0               )
);

seg_scan seg_scan_m0(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.seg_sel                    (seg_sel                  ),
	.seg_data                   (seg_data                 ),
	.seg_data_0                 ({1'b1,7'b1111_111}       ),
	.seg_data_1                 ({1'b1,7'b1111_111}       ),
	.seg_data_2                 ({1'b1,7'b1111_111}       ),
	.seg_data_3                 ({1'b1,7'b1111_111}       ),
	.seg_data_4                 ({1'b1,7'b1111_111}       ),
	.seg_data_5                 ({1'b1,seg_data_0}        )
);
endmodule