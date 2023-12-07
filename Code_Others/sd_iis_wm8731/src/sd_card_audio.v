module sd_card_audio(
	input                       clk,
	input                       rst_n,
	input                       key_next,
	input                       key_vol,
	output [6:0]                 volume,
	output[3:0]                 state_code,

	//FFT interface
	output [15:0] 			 	fft_data,
	output 						fft_data_clk,
	
	//audio interface
	input                       bclk,         //audio bit clock
	input                       daclrc,       //DAC sample rate left right clock
	output                      dacdat,       //DAC audio data output 
	input                       adclrc,       //ADC sample rate left right clock
	input                       adcdat,       //ADC audio data input

	//SD card interface
	output                      sd_ncs,       //SD card chip select (SPI mode)  
	output                      sd_dclk,      //SD card clock
	output                      sd_mosi,      //SD card controller data output
	input                       sd_miso       //SD card controller data input
);
wire             sd_sec_read;                 //SD card sector read
wire[31:0]       sd_sec_read_addr;            //SD card sector read address
wire[7:0]        sd_sec_read_data;            //SD card sector read data
wire             sd_sec_read_data_valid;      //SD card sector read data valid
wire             sd_sec_read_end;             //SD card sector read end
wire             wav_data_wr_en;              //wav audio data write enable
wire[7:0]        wav_data;                    //wav audio data
wire[15:0]       wrusedw;                     //fifo write Used Words
wire[31:0]       read_data;                   //fifo read data
wire             read_data_en;                //fifo read enable
wire             rdempty;                     //fifo read empty
wire[31:0]       tx_left_data;                //left channel audio data
wire[31:0]       tx_right_data;               //right channel audio data
wire             sd_init_done;                //SD card initialization completed
assign tx_left_data =  {16'd0,read_data[15:0]};
assign tx_right_data = {16'd0,read_data[31:16]};

wire key_clk;
ax_debounce#(.FREQ(100)) ax_debounce_m2
(
	.clk             (clk),
	.rst             (~rst_n),
	.button_in       (key_vol),
	.button_posedge  (),
	.button_negedge  (key_clk),
	.button_out      ()
);

reg [ 1:0] key_vol_cnt = 2'd0;
always@(posedge key_clk) key_vol_cnt <= key_vol_cnt + 1'b1;
assign volume = (key_vol_cnt == 0)? 7'd70 : (key_vol_cnt == 1)? 7'd90 : (key_vol_cnt == 2)? 7'd108 : 7'd127	;

assign fft_data = tx_right_data; //仅仅对右声道处理,减少FFT计算量 
assign fft_data_clk = adclrc;
audio_tx audio_tx_m0
(
	.rst                       (~rst_n                     ),        
	.clk                       (clk                        ),
	.sck_bclk                  (bclk                       ),
	.ws_lrc                    (adclrc                     ),
	.sdata                     (dacdat                     ),
	.left_data                 (tx_left_data               ),
	.right_data                (tx_right_data              ),
	.read_data_en              (read_data_en               )
);

afifo_8i_32o_1024 audio_buf
	(
	.rdclk                     (clk                        ),          // Read side clock
	.wrclk                     (clk                        ),          // Write side clock
	.aclr                      (1'b0                       ),          // Asynchronous clear
	.wrreq                     (wav_data_wr_en             ),          // Write Request
	.rdreq                     (read_data_en & ~rdempty    ),          // Read Request
	.data                      (wav_data                   ),          // Input Data
	.rdempty                   (rdempty                    ),          // Read side Empty flag
	.wrfull                    (                           ),          // Write side Full flag
	.rdusedw                   (                           ),          // Read Used Words
	.wrusedw                   (wrusedw[9:0]               ),          // Write Used Words
	.q                         (read_data                  )
);

wav_read wav_read_m0(
	.clk                       (clk                        ),
	.rst                       (~rst_n                     ),
	.ready                     (                           ),
	.find                      (!key_next             	 	),
	.sd_init_done              (sd_init_done               ),
	.state_code                (state_code                 ),
	.sd_sec_read               (sd_sec_read                ),
	.sd_sec_read_addr          (sd_sec_read_addr           ),
	.sd_sec_read_data          (sd_sec_read_data           ),
	.sd_sec_read_data_valid    (sd_sec_read_data_valid     ),
	.sd_sec_read_end           (sd_sec_read_end            ),
	.fifo_wr_cnt               (wrusedw                    ),
	.wav_data_wr_en            (wav_data_wr_en             ),
	.wav_data                  (wav_data                   )
);
sd_card_top  sd_card_top_m0(
	.clk                       (clk                        ),
	.rst                       (~rst_n                     ),
	.SD_nCS                    (sd_ncs                     ),
	.SD_DCLK                   (sd_dclk                    ),
	.SD_MOSI                   (sd_mosi                    ),
	.SD_MISO                   (sd_miso                    ),
	.sd_init_done              (sd_init_done               ),
	.sd_sec_read               (sd_sec_read                ),
	.sd_sec_read_addr          (sd_sec_read_addr           ),
	.sd_sec_read_data          (sd_sec_read_data           ),
	.sd_sec_read_data_valid    (sd_sec_read_data_valid     ),
	.sd_sec_read_end           (sd_sec_read_end            ),
	.sd_sec_write              (1'b0                       ),
	.sd_sec_write_addr         (32'd0                      ),
	.sd_sec_write_data         (                           ),
	.sd_sec_write_data_req     (                           ),
	.sd_sec_write_end          (                           )
);
endmodule 