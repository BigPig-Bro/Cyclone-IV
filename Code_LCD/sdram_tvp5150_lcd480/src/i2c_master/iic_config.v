`timescale 1ns/100ps
module iic_config (	//	Host Side
	input 			clk,
	input 			rst_n,
	//	I2C Side
	output 			iic_scl,
	inout			iic_sda
);

//	Internal Registers/Wires
reg	[15:0]	iic_CLK_DIV;
reg	[23:0]	iic_DATA;
reg			iic_CTRL_CLK;
reg			iic_GO;
wire		iic_END;
wire		iic_ACK;
reg	[15:0]	LUT_DATA;
reg	[7:0]	LUT_INDEX;
reg	[3:0]	mSetup_ST;

//	Clock Setting
parameter	CLK_Freq	=	50_000_000;	//	50	M Hz
parameter	I2C_Freq	=	2000;	//	100	K Hz x 2
//	LUT Data Number
parameter	LUT_SIZE	=	100;
//	Audio Data Index
parameter	SET_LIN_L	=	0;
parameter	SET_LIN_R	=	1;
parameter	SET_HEAD_L	=	2;
parameter	SET_HEAD_R	=	3;
parameter	A_PATH_CTRL	=	4;
parameter	D_PATH_CTRL	=	5;
parameter	POWER_ON	=	6;
parameter	SET_FORMAT	=	7;
parameter	SAMPLE_CTRL	=	8;
parameter	SET_ACTIVE	=	9;
//	Video Data Index
parameter	SET_VIDEO	=	10;

/////////////////////	I2C Control Clock	////////////////////////
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		iic_CTRL_CLK	<=	0;
		iic_CLK_DIV		<=	0;
	end
	else
	begin
		if( iic_CLK_DIV	< (CLK_Freq / I2C_Freq) )
			iic_CLK_DIV	<=	iic_CLK_DIV + 1'b1;
		else
		begin
			iic_CLK_DIV	<=	0;
			iic_CTRL_CLK	<=	~iic_CTRL_CLK;
		end
	end
end
////////////////////////////////////////////////////////////////////
I2C_Controller 	iic_controller_m0(	
	.CLOCK(iic_CTRL_CLK),		//	Controller Work Clock
	.I2C_SCLK(iic_scl),		//	I2C CLOCK
 	 .I2C_SDAT(iic_sda),		//	I2C DATA
	.I2C_DATA(iic_DATA),		//	DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
	.GO(iic_GO),      			//	GO transfor
	.END(iic_END),				//	END transfor 
	.ACK(iic_ACK),				//	ACK
	.RESET(rst_n)	
	);
////////////////////////////////////////////////////////////////////
//////////////////////	Config Control	////////////////////////////
always@(posedge 	iic_CTRL_CLK or negedge rst_n)
begin
	if(!rst_n)
	begin
		LUT_INDEX	<=	0;
		mSetup_ST	<=	0;
		iic_GO		<=	0;
		iic_DATA	<=	0;
	end
	else
	begin
		if(LUT_INDEX<LUT_SIZE)
		begin
			case(mSetup_ST)
			0:	begin
					if(LUT_INDEX<(SET_VIDEO+89))
						iic_DATA	<=	{8'hBA,LUT_DATA};
					else
						iic_DATA	<=	{8'hB9,LUT_DATA};
					iic_GO		<=	1;
					mSetup_ST	<=	1;
				end
			1:	begin
					if(iic_END)
					begin
						if(!iic_ACK)
						begin
							
							mSetup_ST	<=	2;
						end
						else
							mSetup_ST	<=	0;							
						iic_GO		<=	0;	
					end
					
				end
			2:	begin
					LUT_INDEX	<=	LUT_INDEX + 1'b1;
					mSetup_ST	<=	0;
				end
			default:mSetup_ST	<=  0;
			endcase
		end
	end
end
////////////////////////////////////////////////////////////////////
/////////////////////	Config Data LUT	  //////////////////////////	
always @*
begin
	case(LUT_INDEX)
	//	Audio Config Data
	SET_LIN_L	:	LUT_DATA	=	16'h0000;
	SET_LIN_R	:	LUT_DATA	=	16'h0115;
	SET_HEAD_L	:	LUT_DATA	=	16'h0200;
	SET_HEAD_R	:	LUT_DATA	=	16'h036d;
	A_PATH_CTRL	:	LUT_DATA	=	16'h0400;
	D_PATH_CTRL	:	LUT_DATA	=	16'h0500;
	POWER_ON	:	LUT_DATA	=	16'h0610;
	SET_FORMAT	:	LUT_DATA	=	16'h0720;
	SAMPLE_CTRL	:	LUT_DATA	=	16'h0800;
	SET_ACTIVE	:	LUT_DATA	=	16'h0980;
	//	Video Config Data
	SET_VIDEO+0	:	LUT_DATA	=	16'h0A80;
	SET_VIDEO+1	:	LUT_DATA	=	16'h0B00;
	SET_VIDEO+2	:	LUT_DATA	=	16'h0C80;
	SET_VIDEO+3	:	LUT_DATA	=	16'h0D47;
	SET_VIDEO+4	:	LUT_DATA	=	16'h0E00;
	SET_VIDEO+5	:	LUT_DATA	=	16'h0F02;
	SET_VIDEO+6	:	LUT_DATA	=	16'h1104;
	SET_VIDEO+7	:	LUT_DATA	=	16'h1200;
	SET_VIDEO+8	:	LUT_DATA	=	16'h1304;
	SET_VIDEO+9	:	LUT_DATA	=	16'h1400;
	SET_VIDEO+10:	LUT_DATA	=	16'h1501;
	SET_VIDEO+11:	LUT_DATA	=	16'h1680;
	SET_VIDEO+12:	LUT_DATA	=	16'h1800;
	SET_VIDEO+13:	LUT_DATA	=	16'h1900;
	SET_VIDEO+14:	LUT_DATA	=	16'h1A0c;
	SET_VIDEO+15:	LUT_DATA	=	16'h1B14;
	SET_VIDEO+16:	LUT_DATA	=	16'h1C00;
	SET_VIDEO+17:	LUT_DATA	=	16'h1D00;
	SET_VIDEO+18:	LUT_DATA	=	16'h1E00;
	SET_VIDEO+19:	LUT_DATA	=	16'h2800;
	SET_VIDEO+20:	LUT_DATA	=	16'hB100;
	SET_VIDEO+21:	LUT_DATA	=	16'hB200;
	SET_VIDEO+22:	LUT_DATA	=	16'hB300;
	SET_VIDEO+23:	LUT_DATA	=	16'hB400;
	SET_VIDEO+24:	LUT_DATA	=	16'hB500;
	SET_VIDEO+25:	LUT_DATA	=	16'hB600;
	SET_VIDEO+26:	LUT_DATA	=	16'hB700;
	SET_VIDEO+27:	LUT_DATA	=	16'hB800;
	SET_VIDEO+28:	LUT_DATA	=	16'hB900;
	SET_VIDEO+29:	LUT_DATA	=	16'hBA00;
	SET_VIDEO+30:	LUT_DATA	=	16'hBB00;
	SET_VIDEO+31:	LUT_DATA	=	16'hC000;
	SET_VIDEO+32:	LUT_DATA	=	16'hC100;
	SET_VIDEO+33:	LUT_DATA	=	16'hC204;
	SET_VIDEO+34:	LUT_DATA	=	16'hC3DC;
	SET_VIDEO+35:	LUT_DATA	=	16'hC40F;
	SET_VIDEO+36:	LUT_DATA	=	16'hC500;
	SET_VIDEO+37:	LUT_DATA	=	16'hC880;
	SET_VIDEO+38:	LUT_DATA	=	16'hC900;
	SET_VIDEO+39:	LUT_DATA	=	16'hCA00;
	SET_VIDEO+40:	LUT_DATA	=	16'hCB59;
	SET_VIDEO+41:	LUT_DATA	=	16'hCC03;
	SET_VIDEO+42:	LUT_DATA	=	16'hCD01;
	SET_VIDEO+43:	LUT_DATA	=	16'hCE00;
	SET_VIDEO+44:	LUT_DATA	=	16'hCF00;
	SET_VIDEO+45:	LUT_DATA	=	16'hD0FF;
	SET_VIDEO+46:	LUT_DATA	=	16'hD1FF;
	SET_VIDEO+47:	LUT_DATA	=	16'hD2FF;
	SET_VIDEO+48:	LUT_DATA	=	16'hD3FF;
	SET_VIDEO+49:	LUT_DATA	=	16'hD4FF;
	SET_VIDEO+50:	LUT_DATA	=	16'hD5FF;
	SET_VIDEO+51:	LUT_DATA	=	16'hD6FF;
	SET_VIDEO+52:	LUT_DATA	=	16'hD7FF;
	SET_VIDEO+53:	LUT_DATA	=	16'hD8FF;
	SET_VIDEO+54:	LUT_DATA	=	16'hD9FF;
	SET_VIDEO+55:	LUT_DATA	=	16'hDAFF;
	SET_VIDEO+56:	LUT_DATA	=	16'hDBFF;
	SET_VIDEO+57:	LUT_DATA	=	16'hDCFF;
	SET_VIDEO+58:	LUT_DATA	=	16'hDDFF;
	SET_VIDEO+59:	LUT_DATA	=	16'hDEFF;
	SET_VIDEO+60:	LUT_DATA	=	16'hDFFF;
	SET_VIDEO+61:	LUT_DATA	=	16'hE0FF;
	SET_VIDEO+62:	LUT_DATA	=	16'hE1FF;
	SET_VIDEO+63:	LUT_DATA	=	16'hE2FF;
	SET_VIDEO+64:	LUT_DATA	=	16'hE3FF;
	SET_VIDEO+65:	LUT_DATA	=	16'hE4FF;
	SET_VIDEO+66:	LUT_DATA	=	16'hE5FF;
	SET_VIDEO+67:	LUT_DATA	=	16'hE6FF;
	SET_VIDEO+68:	LUT_DATA	=	16'hE7FF;
	SET_VIDEO+69:	LUT_DATA	=	16'hE8FF;
	SET_VIDEO+70:	LUT_DATA	=	16'hE9FF;
	SET_VIDEO+71:	LUT_DATA	=	16'hEAFF;
	SET_VIDEO+72:	LUT_DATA	=	16'hEBFF;
	SET_VIDEO+73:	LUT_DATA	=	16'hECFF;
	SET_VIDEO+74:	LUT_DATA	=	16'hEDFF;
	SET_VIDEO+75:	LUT_DATA	=	16'hEEFF;
	SET_VIDEO+76:	LUT_DATA	=	16'hEFFF;
	SET_VIDEO+77:	LUT_DATA	=	16'hF0FF;
	SET_VIDEO+78:	LUT_DATA	=	16'hF1FF;
	SET_VIDEO+79:	LUT_DATA	=	16'hF2FF;
	SET_VIDEO+80:	LUT_DATA	=	16'hF3FF;
	SET_VIDEO+81:	LUT_DATA	=	16'hF4FF;
	SET_VIDEO+82:	LUT_DATA	=	16'hF5FF;
	SET_VIDEO+83:	LUT_DATA	=	16'hF6FF;
	SET_VIDEO+84:	LUT_DATA	=	16'hF7FF;
	SET_VIDEO+85:	LUT_DATA	=	16'hF8FF;
	SET_VIDEO+86:	LUT_DATA	=	16'hF9FF;
	SET_VIDEO+87:	LUT_DATA	=	16'hFAFF;
	SET_VIDEO+88:	LUT_DATA	=	16'hFBFF;
	SET_VIDEO+89:	LUT_DATA	=	16'hFC7F;
	default:		LUT_DATA	=	16'hxxxx;
	endcase

end
////////////////////////////////////////////////////////////////////
endmodule

