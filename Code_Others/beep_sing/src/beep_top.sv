module beep_top(
	input clk,rst_n,
	input key,
	output beep_out);
	
parameter CLK_FRE = 50; //时钟频率 Mhz
parameter SONG_DATA_CNT = 16'd255; //编码的音符数量

//控制状态机
parameter IDLE = 0;
parameter PLAY = 1;
parameter WAIT = 2;

reg [3:0] state = 'd0;
reg [31:0] state_delay = 'd0;

//音符编码
reg [15:0] song_index = 'd0;//查表计数器
reg [11:0] song_data; 
reg [3:0] data_high,data_level,data_long;

//握手信号
reg       song_data_start = 'd0;
wire  	  song_data_done;

/******************************************************/
/******************** 控制音符播放  *******************/
/******************************************************/
always@(posedge clk)
	if(!rst_n)begin
		song_index <= 16'd0;
		state <= IDLE;
	end
	else
		case(state)
			IDLE: // 延时 10ms
				if(state_delay < CLK_FRE * 10_000)
					state_delay <= state_delay + 1;
				else
				begin
					state_delay = 0;
					state <= PLAY;
				end
			
			PLAY:
				if(song_data_done)
				begin
					song_data_start 	 <= 1'b1;
					data_high  <= song_data[11:8];
					data_level <= song_data[7:4];
					data_long  <= song_data[3:0];
					
					if(song_index < SONG_DATA_CNT)
						song_index <= song_index + 16'd1;
					else
						song_index <= 16'd0;

					state <= WAIT;
				end

			WAIT:
				if(!song_data_done)	state <= PLAY;

			default: state <= IDLE;
		endcase


/******************************************************/
/******************** 按键切换查表  *******************/
/******************************************************/
wire [1:0] key_cnt;
key #(
	.CLK_FRE		(CLK_FRE   		),
	.CNT  			(2 				)
)key_m0(
	.clk 			(clk 			),
	.key_in 		(key 			), 	
	.key_cnt		(key_cnt 		)
	);	

/******************************************************/
/****************** 无源蜂鸣器发声单元  *****************/
/******************************************************/
//无源蜂鸣器发声驱动代码
beep_driver#(
	.CLK_FRE (CLK_FRE 	)
) beep_driver_m0(
	.clk   		(clk				),

	.done  		(song_data_done  	),
	.start 		(song_data_start 	),

	.high  		(data_high   		),
	.level 		(data_level   		),
	.long  		(data_long    		),

	.beep  		(beep_out   		)
);

/******************************************************/
/******************** 使用到简谱编码  *******************/
/******************************************************/
always@(*)
	case(key_cnt)
		2'd0:
		case(song_index)//极乐净土
			16'd0:song_data = 12'h314;
			16'd1:song_data = 12'h514;
			16'd2:song_data = 12'h614;
			16'd3:song_data = 12'h004;
			16'd4:song_data = 12'h004;
			16'd5:song_data = 12'h514;
			16'd6:song_data = 12'h614;
			16'd7:song_data = 12'h004;
			16'd8:song_data = 12'h514;
			16'd9:song_data = 12'h614;
			16'd10:song_data = 12'h124;
			16'd11:song_data = 12'h514;
			16'd12:song_data = 12'h614;
			16'd13:song_data = 12'h314;
			16'd14:song_data = 12'h004;
			16'd15:song_data = 12'h314;
			16'd16:song_data = 12'h514;
			16'd17:song_data = 12'h614;
			16'd18:song_data = 12'h002;
			16'd19:song_data = 12'h514;
			16'd20:song_data = 12'h614;
			16'd21:song_data = 12'h004;
			16'd22:song_data = 12'h004;
			16'd23:song_data = 12'h514;
			16'd24:song_data = 12'h614;
			16'd25:song_data = 12'h324;
			16'd26:song_data = 12'h124;
			16'd27:song_data = 12'h224;
			16'd28:song_data = 12'h614;
			16'd29:song_data = 12'h004;
			16'd30:song_data = 12'h314;
			16'd31:song_data = 12'h514;
			16'd32:song_data = 12'h614;
			16'd33:song_data = 12'h004;
			16'd34:song_data = 12'h004;
			16'd35:song_data = 12'h514;
			16'd36:song_data = 12'h614;
			16'd37:song_data = 12'h004;
			16'd38:song_data = 12'h004;
			16'd39:song_data = 12'h514;
			16'd40:song_data = 12'h614;
			16'd41:song_data = 12'h124;
			16'd42:song_data = 12'h514;
			16'd43:song_data = 12'h614;
			16'd44:song_data = 12'h312;
			16'd45:song_data = 12'h514;
			16'd46:song_data = 12'h114;
			16'd47:song_data = 12'h214;
			16'd48:song_data = 12'h312;
			16'd49:song_data = 12'h122;
			16'd50:song_data = 12'h612;
			16'd51:song_data = 12'h322;
			16'd52:song_data = 12'h224;
			16'd53:song_data = 12'h328;
			16'd54:song_data = 12'h228;
			16'd55:song_data = 12'h124;
			16'd56:song_data = 12'h224;
			16'd57:song_data = 12'h612;
			16'd58:song_data = 12'h002;
			16'd59:song_data = 12'h612;
			16'd60:song_data = 12'h128;
			16'd61:song_data = 12'h228;
			16'd62:song_data = 12'h328;
			16'd63:song_data = 12'h612;
			16'd64:song_data = 12'h612;
			16'd65:song_data = 12'h614;
			16'd66:song_data = 12'h514;
			16'd67:song_data = 12'h614;
			16'd68:song_data = 12'h612;
			16'd69:song_data = 12'h612;
			16'd70:song_data = 12'h612;
			16'd71:song_data = 12'h618;
			16'd72:song_data = 12'h128;
			16'd73:song_data = 12'h228;
			16'd74:song_data = 12'h328;
			16'd75:song_data = 12'h622;
			16'd76:song_data = 12'h514;
			16'd77:song_data = 12'h514;
			16'd78:song_data = 12'h614;
			16'd79:song_data = 12'h612;
			16'd80:song_data = 12'h002;
			16'd81:song_data = 12'h004;
			16'd82:song_data = 12'h614;
			16'd83:song_data = 12'h614;
			16'd84:song_data = 12'h518;
			16'd85:song_data = 12'h518;
			16'd86:song_data = 12'h514;
			16'd87:song_data = 12'h614;
			16'd88:song_data = 12'h514;
			16'd89:song_data = 12'h314;
			16'd90:song_data = 12'h314;
			16'd91:song_data = 12'h518;
			16'd92:song_data = 12'h318;
			16'd93:song_data = 12'h312;
			16'd94:song_data = 12'h002;
			16'd95:song_data = 12'h002;
			16'd96:song_data = 12'h004;
			16'd97:song_data = 12'h614;
			16'd98:song_data = 12'h614;
			16'd99:song_data = 12'h514;
			16'd100:song_data = 12'h614;
			16'd101:song_data = 12'h714;
			16'd102:song_data = 12'h122;
			16'd103:song_data = 12'h712;
			16'd104:song_data = 12'h614;
			16'd105:song_data = 12'h718;
			16'd106:song_data = 12'h618;
			16'd107:song_data = 12'h512;
			16'd108:song_data = 12'h002;
			16'd109:song_data = 12'h004;
			16'd110:song_data = 12'h614;
			16'd111:song_data = 12'h614;
			16'd112:song_data = 12'h514;
			16'd113:song_data = 12'h614;
			16'd114:song_data = 12'h618;
			16'd115:song_data = 12'h518;
			16'd116:song_data = 12'h514;
			16'd117:song_data = 12'h314;
			16'd118:song_data = 12'h314;
			16'd119:song_data = 12'h518;
			16'd120:song_data = 12'h318;
			16'd121:song_data = 12'h312;
			16'd122:song_data = 12'h002;
			16'd123:song_data = 12'h002;
			16'd124:song_data = 12'h004;
			16'd125:song_data = 12'h614;
			16'd126:song_data = 12'h514;
			16'd127:song_data = 12'h614;
			16'd128:song_data = 12'h714;
			16'd129:song_data = 12'h122;
			16'd130:song_data = 12'h712;
			16'd131:song_data = 12'h614;
			16'd132:song_data = 12'h718;
			16'd133:song_data = 12'h618;
			16'd134:song_data = 12'h512;
			16'd135:song_data = 12'h514;
			16'd136:song_data = 12'h614;
			16'd137:song_data = 12'h004;
			16'd138:song_data = 12'h324;
			16'd139:song_data = 12'h222;
			16'd140:song_data = 12'h004;
			16'd141:song_data = 12'h614;
			16'd142:song_data = 12'h004;
			16'd143:song_data = 12'h614;
			16'd144:song_data = 12'h614;
			16'd145:song_data = 12'h324;
			16'd146:song_data = 12'h222;
			16'd147:song_data = 12'h002;
			16'd148:song_data = 12'h004;
			16'd149:song_data = 12'h224;
			16'd150:song_data = 12'h224;
			16'd151:song_data = 12'h124;
			16'd152:song_data = 12'h224;
			16'd153:song_data = 12'h128;
			16'd154:song_data = 12'h618;
			16'd155:song_data = 12'h614;
			16'd156:song_data = 12'h514;
			16'd157:song_data = 12'h514;
			16'd158:song_data = 12'h514;
			16'd159:song_data = 12'h514;
			16'd160:song_data = 12'h614;
			16'd161:song_data = 12'h614;
			16'd162:song_data = 12'h314;
			16'd163:song_data = 12'h314;
			16'd164:song_data = 12'h314;
			16'd165:song_data = 12'h514;
			16'd166:song_data = 12'h514;
			16'd167:song_data = 12'h614;
			16'd168:song_data = 12'h004;
			16'd169:song_data = 12'h324;
			16'd170:song_data = 12'h222;
			16'd171:song_data = 12'h004;
			16'd172:song_data = 12'h614;
			16'd173:song_data = 12'h004;
			16'd174:song_data = 12'h614;
			16'd175:song_data = 12'h324;
			16'd176:song_data = 12'h222;
			16'd177:song_data = 12'h002;
			16'd178:song_data = 12'h004;
			16'd179:song_data = 12'h224;
			16'd180:song_data = 12'h224;
			16'd181:song_data = 12'h124;
			16'd182:song_data = 12'h224;
			16'd183:song_data = 12'h128;
			16'd184:song_data = 12'h618;
			16'd185:song_data = 12'h618;
			16'd186:song_data = 12'h318;
			16'd187:song_data = 12'h514;
			16'd188:song_data = 12'h514;
			16'd189:song_data = 12'h614;
			16'd190:song_data = 12'h614;
			16'd191:song_data = 12'h514;
			16'd192:song_data = 12'h612;
			16'd193:song_data = 12'h004;
			16'd194:song_data = 12'h318;
			16'd195:song_data = 12'h518;
			16'd196:song_data = 12'h614;
			16'd197:song_data = 12'h614;
			16'd198:song_data = 12'h614;
			16'd199:song_data = 12'h324;
			16'd200:song_data = 12'h322;
			16'd201:song_data = 12'h222;
			16'd202:song_data = 12'h004;
			16'd203:song_data = 12'h718;
			16'd204:song_data = 12'h128;
			16'd205:song_data = 12'h224;
			16'd206:song_data = 12'h128;
			16'd207:song_data = 12'h224;
			16'd208:song_data = 12'h324;
			16'd209:song_data = 12'h612;
			16'd210:song_data = 12'h004;
			16'd211:song_data = 12'h518;
			16'd212:song_data = 12'h518;
			16'd213:song_data = 12'h612;
			16'd214:song_data = 12'h324;
			16'd215:song_data = 12'h328;
			16'd216:song_data = 12'h224;
			16'd217:song_data = 12'h124;
			16'd218:song_data = 12'h614;
			16'd219:song_data = 12'h514;
			16'd220:song_data = 12'h612;
			16'd221:song_data = 12'h124;
			16'd222:song_data = 12'h222;
			16'd223:song_data = 12'h002;
			16'd224:song_data = 12'h612;
			16'd225:song_data = 12'h614;
			16'd226:song_data = 12'h514;
			16'd227:song_data = 12'h614;
			16'd228:song_data = 12'h324;
			16'd229:song_data = 12'h004;
			16'd230:song_data = 12'h124;
			16'd231:song_data = 12'h224;
			16'd232:song_data = 12'h128;
			16'd233:song_data = 12'h228;
			16'd234:song_data = 12'h224;
			16'd235:song_data = 12'h324;
			16'd236:song_data = 12'h322;
			16'd237:song_data = 12'h004;
			16'd238:song_data = 12'h514;
			16'd239:song_data = 12'h614;
			16'd240:song_data = 12'h124;
			16'd241:song_data = 12'h004;
			16'd242:song_data = 12'h514;
			16'd243:song_data = 12'h614;
			16'd244:song_data = 12'h324;
			16'd245:song_data = 12'h004;
			16'd246:song_data = 12'h328;
			16'd247:song_data = 12'h228;
			16'd248:song_data = 12'h124;
			16'd249:song_data = 12'h714;
			16'd250:song_data = 12'h614;
			16'd251:song_data = 12'h514;
			16'd252:song_data = 12'h514;
			16'd253:song_data = 12'h612;
			default: song_data = 12'h001;
		endcase 
		2'd1:
		case(song_index)//十年
			16'd0:song_data = 12'h114;
			16'd1:song_data = 12'h214;
			16'd2:song_data = 12'h312;
			16'd3:song_data = 12'h312;
			16'd4:song_data = 12'h212;
			16'd5:song_data = 12'h312;
			16'd6:song_data = 12'h214;
			16'd7:song_data = 12'h114;
			16'd8:song_data = 12'h704;
			16'd9:song_data = 12'h604;
			16'd10:song_data = 12'h001;
			16'd11:song_data = 12'h304;
			16'd12:song_data = 12'h604;
			16'd13:song_data = 12'h502;
			16'd14:song_data = 12'h604;
			16'd15:song_data = 12'h704;
			16'd16:song_data = 12'h604;
			16'd17:song_data = 12'h504;
			16'd18:song_data = 12'h604;
			16'd19:song_data = 12'h001;
			16'd20:song_data = 12'h114;
			16'd21:song_data = 12'h704;
			16'd22:song_data = 12'h604;
			16'd23:song_data = 12'h704;
			16'd24:song_data = 12'h601;
			16'd25:song_data = 12'h001;
			16'd26:song_data = 12'h001;
			16'd27:song_data = 12'h114;
			16'd28:song_data = 12'h214;
			16'd29:song_data = 12'h312;
			16'd30:song_data = 12'h312;
			16'd31:song_data = 12'h212;
			16'd32:song_data = 12'h312;
			16'd33:song_data = 12'h214;
			16'd34:song_data = 12'h314;
			16'd35:song_data = 12'h514;
			16'd36:song_data = 12'h114;
			16'd37:song_data = 12'h001;
			16'd38:song_data = 12'h314;
			16'd39:song_data = 12'h212;
			16'd40:song_data = 12'h212;
			16'd41:song_data = 12'h214;
			16'd42:song_data = 12'h114;
			16'd43:song_data = 12'h704;
			16'd44:song_data = 12'h114;
			16'd45:song_data = 12'h001;
			16'd46:song_data = 12'h114;
			16'd47:song_data = 12'h114;
			16'd48:song_data = 12'h704;
			16'd49:song_data = 12'h604;
			16'd50:song_data = 12'h704;
			16'd51:song_data = 12'h112;
			16'd52:song_data = 12'h602;
			16'd53:song_data = 12'h601;
			16'd54:song_data = 12'h001;
			16'd55:song_data = 12'h304;
			16'd56:song_data = 12'h114;
			16'd57:song_data = 12'h704;
			16'd58:song_data = 12'h604;
			16'd59:song_data = 12'h504;
			16'd60:song_data = 12'h602;
			16'd61:song_data = 12'h702;
			16'd62:song_data = 12'h601;
			16'd63:song_data = 12'h001;
			16'd64:song_data = 12'h001;
			16'd65:song_data = 12'h002;
			16'd66:song_data = 12'h504;
			16'd67:song_data = 12'h312;
			16'd68:song_data = 12'h214;
			16'd69:song_data = 12'h114;
			16'd70:song_data = 12'h212;
			16'd71:song_data = 12'h314;
			16'd72:song_data = 12'h214;
			16'd73:song_data = 12'h212;
			16'd74:song_data = 12'h502;
			16'd75:song_data = 12'h004;
			16'd76:song_data = 12'h114;
			16'd77:song_data = 12'h604;
			16'd78:song_data = 12'h704;
			16'd79:song_data = 12'h114;
			16'd80:song_data = 12'h614;
			16'd81:song_data = 12'h514;
			16'd82:song_data = 12'h114;
			16'd83:song_data = 12'h311;
			16'd84:song_data = 12'h004;
			16'd85:song_data = 12'h314;
			16'd86:song_data = 12'h214;
			16'd87:song_data = 12'h214;
			16'd88:song_data = 12'h411;
			16'd89:song_data = 12'h001;
			16'd90:song_data = 12'h212;
			16'd91:song_data = 12'h314;
			16'd92:song_data = 12'h312;
			16'd93:song_data = 12'h412;
			16'd94:song_data = 12'h311;
			16'd95:song_data = 12'h311;
			16'd96:song_data = 12'h001;
			16'd97:song_data = 12'h114;
			16'd98:song_data = 12'h214;
			16'd99:song_data = 12'h514;
			16'd100:song_data = 12'h312;
			16'd101:song_data = 12'h312;
			16'd102:song_data = 12'h314;
			16'd103:song_data = 12'h314;
			16'd104:song_data = 12'h414;
			16'd105:song_data = 12'h514;
			16'd106:song_data = 12'h614;
			16'd107:song_data = 12'h212;
			16'd108:song_data = 12'h212;
			16'd109:song_data = 12'h214;
			16'd110:song_data = 12'h414;
			16'd111:song_data = 12'h314;
			16'd112:song_data = 12'h214;
			16'd113:song_data = 12'h112;
			16'd114:song_data = 12'h604;
			16'd115:song_data = 12'h604;
			16'd116:song_data = 12'h214;
			16'd117:song_data = 12'h114;
			16'd118:song_data = 12'h704;
			16'd119:song_data = 12'h114;
			16'd120:song_data = 12'h604;
			16'd121:song_data = 12'h602;
			16'd122:song_data = 12'h004;
			16'd123:song_data = 12'h114;
			16'd124:song_data = 12'h704;
			16'd125:song_data = 12'h604;
			16'd126:song_data = 12'h702;
			16'd127:song_data = 12'h414;
			16'd128:song_data = 12'h314;
			16'd129:song_data = 12'h212;
			16'd130:song_data = 12'h704;
			16'd131:song_data = 12'h114;
			16'd132:song_data = 12'h111;
			16'd133:song_data = 12'h004;
			16'd134:song_data = 12'h114;
			16'd135:song_data = 12'h214;
			16'd136:song_data = 12'h314;
			16'd137:song_data = 12'h612;
			16'd138:song_data = 12'h314;
			16'd139:song_data = 12'h412;
			16'd140:song_data = 12'h514;
			16'd141:song_data = 12'h314;
			16'd142:song_data = 12'h312;
			16'd143:song_data = 12'h114;
			16'd144:song_data = 12'h214;
			16'd145:song_data = 12'h514;
			16'd146:song_data = 12'h312;
			16'd147:song_data = 12'h312;
			16'd148:song_data = 12'h314;
			16'd149:song_data = 12'h314;
			16'd150:song_data = 12'h414;
			16'd151:song_data = 12'h514;
			16'd152:song_data = 12'h614;
			16'd153:song_data = 12'h212;
			16'd154:song_data = 12'h212;
			16'd155:song_data = 12'h214;
			16'd156:song_data = 12'h414;
			16'd157:song_data = 12'h314;
			16'd158:song_data = 12'h214;
			16'd159:song_data = 12'h112;
			16'd160:song_data = 12'h304;
			16'd161:song_data = 12'h304;
			16'd162:song_data = 12'h214;
			16'd163:song_data = 12'h114;
			16'd164:song_data = 12'h704;
			16'd165:song_data = 12'h114;
			16'd166:song_data = 12'h604;
			16'd167:song_data = 12'h602;
			16'd168:song_data = 12'h004;
			16'd169:song_data = 12'h114;
			16'd170:song_data = 12'h704;
			16'd171:song_data = 12'h604;
			16'd172:song_data = 12'h702;
			16'd173:song_data = 12'h414;
			16'd174:song_data = 12'h314;
			16'd175:song_data = 12'h212;
			16'd176:song_data = 12'h314;
			16'd177:song_data = 12'h214;
			16'd178:song_data = 12'h214;
			16'd179:song_data = 12'h112;
			16'd180:song_data = 12'h004;
			16'd181:song_data = 12'h114;
			16'd182:song_data = 12'h214;
			16'd183:song_data = 12'h314;
			16'd184:song_data = 12'h612;
			16'd185:song_data = 12'h612;
			16'd186:song_data = 12'h312;
			16'd187:song_data = 12'h114;
			16'd188:song_data = 12'h212;
			16'd189:song_data = 12'h211;
			16'd190:song_data = 12'h114;
			16'd191:song_data = 12'h704;
			16'd192:song_data = 12'h111;
			16'd193:song_data = 12'h111;
			16'd194:song_data = 12'h001;
			16'd195:song_data = 12'h001;
			16'd196:song_data = 12'h114;
			16'd197:song_data = 12'h214;
			16'd198:song_data = 12'h312;
			16'd199:song_data = 12'h312;
			16'd200:song_data = 12'h323;
			16'd201:song_data = 12'h312;
			16'd202:song_data = 12'h214;
			16'd203:song_data = 12'h314;
			16'd204:song_data = 12'h514;
			16'd205:song_data = 12'h114;
			16'd206:song_data = 12'h001;
			16'd207:song_data = 12'h314;
			16'd208:song_data = 12'h212;
			16'd209:song_data = 12'h212;
			16'd210:song_data = 12'h214;
			16'd211:song_data = 12'h114;
			16'd212:song_data = 12'h702;
			16'd213:song_data = 12'h112;
			16'd214:song_data = 12'h114;
			16'd215:song_data = 12'h114;
			16'd216:song_data = 12'h114;
			16'd217:song_data = 12'h114;
			16'd218:song_data = 12'h704;
			16'd219:song_data = 12'h604;
			16'd220:song_data = 12'h114;
			16'd221:song_data = 12'h601;
			16'd222:song_data = 12'h601;
			16'd223:song_data = 12'h001;
			16'd224:song_data = 12'h504;
			16'd225:song_data = 12'h314;
			16'd226:song_data = 12'h214;
			16'd227:song_data = 12'h114;
			16'd228:song_data = 12'h214;
			16'd229:song_data = 12'h111;

			default: song_data = 12'h008;
		endcase 
		2'd2:
		case(song_index)//千本樱
			16'd0:song_data = 12'h606;
			16'd1:song_data = 12'h603;
			16'd2:song_data = 12'h506;
			16'd3:song_data = 12'h606;
			16'd4:song_data = 12'h603;
			16'd5:song_data = 12'h606;
			16'd6:song_data = 12'h503;
			16'd7:song_data = 12'h603;
			16'd8:song_data = 12'h113;
			16'd9:song_data = 12'h606;
			16'd10:song_data = 12'h603;
			16'd11:song_data = 12'h503;
			16'd12:song_data = 12'h606;
			16'd13:song_data = 12'h603;
			16'd14:song_data = 12'h503;
			16'd15:song_data = 12'h603;
			16'd16:song_data = 12'h113;
			16'd17:song_data = 12'h213;
			16'd18:song_data = 12'h313;
			16'd19:song_data = 12'h216;
			16'd20:song_data = 12'h316;
			16'd21:song_data = 12'h60C;//6565
			16'd22:song_data = 12'h50C;
			16'd23:song_data = 12'h60C;
			16'd24:song_data = 12'h50C;
			16'd25:song_data = 12'h216;
			16'd26:song_data = 12'h316;
			16'd27:song_data = 12'h60C;//6565
			16'd28:song_data = 12'h50C;
			16'd29:song_data = 12'h60C;
			16'd30:song_data = 12'h50C;
			16'd31:song_data = 12'h216;
			16'd32:song_data = 12'h316;
			16'd33:song_data = 12'h60C;//6565
			16'd34:song_data = 12'h50C;
			16'd35:song_data = 12'h60C;
			16'd36:song_data = 12'h50C;
			16'd37:song_data = 12'h116;
			16'd38:song_data = 12'h706;
			16'd39:song_data = 12'h606;
			16'd40:song_data = 12'h506;
			16'd41:song_data = 12'h216;
			16'd42:song_data = 12'h316;
			16'd43:song_data = 12'h60C;//6565
			16'd44:song_data = 12'h50C;
			16'd45:song_data = 12'h60C;
			16'd46:song_data = 12'h50C;
			16'd47:song_data = 12'h216;
			16'd48:song_data = 12'h316;
			16'd49:song_data = 12'h60C;//6565
			16'd50:song_data = 12'h50C;
			16'd51:song_data = 12'h60C;
			16'd52:song_data = 12'h50C;
			16'd53:song_data = 12'h216;
			16'd54:song_data = 12'h316;
			16'd55:song_data = 12'h516;
			16'd56:song_data = 12'h126;
			16'd57:song_data = 12'h70C;
			16'd58:song_data = 12'h12C;
			16'd59:song_data = 12'h70C;
			16'd60:song_data = 12'h60C;
			16'd61:song_data = 12'h516;
			16'd62:song_data = 12'h316;
			16'd63:song_data = 12'h216;
			16'd64:song_data = 12'h316;
			16'd65:song_data = 12'h60C;//6565
			16'd66:song_data = 12'h50C;
			16'd67:song_data = 12'h60C;
			16'd68:song_data = 12'h50C;
			16'd69:song_data = 12'h216;
			16'd70:song_data = 12'h316;
			16'd71:song_data = 12'h60C;//6565
			16'd72:song_data = 12'h50C;
			16'd73:song_data = 12'h60C;
			16'd74:song_data = 12'h50C;
			16'd75:song_data = 12'h216;
			16'd76:song_data = 12'h316;
			16'd77:song_data = 12'h60C;//6565
			16'd78:song_data = 12'h50C;
			16'd79:song_data = 12'h60C;
			16'd80:song_data = 12'h50C;
			16'd81:song_data = 12'h116;
			16'd82:song_data = 12'h706;
			16'd83:song_data = 12'h606;
			16'd84:song_data = 12'h506;
			16'd85:song_data = 12'h116;
			16'd86:song_data = 12'h60C;
			16'd87:song_data = 12'h11C;
			16'd88:song_data = 12'h216;
			16'd89:song_data = 12'h11C;
			16'd90:song_data = 12'h21C;
			16'd91:song_data = 12'h316;
			16'd92:song_data = 12'h21C;
			16'd93:song_data = 12'h31C;
			16'd94:song_data = 12'h51C;
			16'd95:song_data = 12'h12C;
			16'd96:song_data = 12'h31C;
			16'd97:song_data = 12'h51C;
			16'd98:song_data = 12'h126;
			16'd99:song_data = 12'h716;
			16'd100:song_data = 12'h616;
			16'd101:song_data = 12'h516;
			16'd102:song_data = 12'h613;
			16'd103:song_data = 12'h616;
			16'd104:song_data = 12'h126;
			16'd105:song_data = 12'h226;
			16'd106:song_data = 12'h326;
			16'd107:song_data = 12'h61C;//6565
			16'd108:song_data = 12'h51C;
			16'd109:song_data = 12'h61C;
			16'd110:song_data = 12'h51C;
			16'd111:song_data = 12'h226;
			16'd112:song_data = 12'h326;
			16'd113:song_data = 12'h61C;//6565
			16'd114:song_data = 12'h51C;
			16'd115:song_data = 12'h61C;
			16'd116:song_data = 12'h51C;
			16'd117:song_data = 12'h226;
			16'd118:song_data = 12'h326;
			16'd119:song_data = 12'h61C;//6565
			16'd120:song_data = 12'h51C;
			16'd121:song_data = 12'h61C;
			16'd122:song_data = 12'h51C;
			16'd123:song_data = 12'h126;
			16'd124:song_data = 12'h716;
			16'd125:song_data = 12'h616;
			16'd126:song_data = 12'h516;
			16'd127:song_data = 12'h226;
			16'd128:song_data = 12'h326;
			16'd129:song_data = 12'h61C;//6565
			16'd130:song_data = 12'h51C;
			16'd131:song_data = 12'h61C;
			16'd132:song_data = 12'h51C;
			16'd133:song_data = 12'h226;
			16'd134:song_data = 12'h326;
			16'd135:song_data = 12'h61C;//6565
			16'd136:song_data = 12'h51C;
			16'd137:song_data = 12'h61C;
			16'd138:song_data = 12'h51C;
			16'd139:song_data = 12'h226;
			16'd140:song_data = 12'h326;
			16'd141:song_data = 12'h526;
			16'd142:song_data = 12'h136;
			16'd143:song_data = 12'h72C;//7176
			16'd144:song_data = 12'h13C;
			16'd145:song_data = 12'h72C;
			16'd146:song_data = 12'h62C;
			16'd147:song_data = 12'h526;
			16'd148:song_data = 12'h326;
			16'd149:song_data = 12'h226;
			16'd150:song_data = 12'h326;
			16'd151:song_data = 12'h61C;//5_6565
			16'd152:song_data = 12'h51C;
			16'd153:song_data = 12'h61C;
			16'd154:song_data = 12'h51C;
			16'd155:song_data = 12'h226;
			16'd156:song_data = 12'h326;
			16'd157:song_data = 12'h61C;//6565
			16'd158:song_data = 12'h51C;
			16'd159:song_data = 12'h61C;
			16'd160:song_data = 12'h51C;
			16'd161:song_data = 12'h226;
			16'd162:song_data = 12'h326;
			16'd163:song_data = 12'h61C;//6565
			16'd164:song_data = 12'h51C;
			16'd165:song_data = 12'h61C;
			16'd166:song_data = 12'h51C;
			16'd167:song_data = 12'h126;
			16'd168:song_data = 12'h716;
			16'd169:song_data = 12'h616;
			16'd170:song_data = 12'h516;
			16'd171:song_data = 12'h32C;
			16'd172:song_data = 12'h22C;
			16'd173:song_data = 12'h32C;
			16'd174:song_data = 12'h52C;
			16'd175:song_data = 12'h62C;
			16'd176:song_data = 12'h52C;
			16'd177:song_data = 12'h32C;
			16'd178:song_data = 12'h22C;
			16'd179:song_data = 12'h616;
			16'd180:song_data = 12'h126;
			16'd181:song_data = 12'h326;
			16'd182:song_data = 12'h526;
			16'd183:song_data = 12'h626;
			16'd184:song_data = 12'h623;
			16'd185:song_data = 12'h526;
			16'd186:song_data = 12'h623;
			16'd187:song_data = 12'h623;//5_OVER
			16'd188:song_data = 12'h613;
			16'd189:song_data = 12'h616;
			16'd190:song_data = 12'h51C;
			16'd191:song_data = 12'h616;
			16'd192:song_data = 12'h126;
			16'd193:song_data = 12'h226;
			16'd194:song_data = 12'h326;
			16'd195:song_data = 12'h613;
			16'd196:song_data = 12'h616;
			16'd197:song_data = 12'h51C;
			16'd198:song_data = 12'h616;
			16'd199:song_data = 12'h516;
			16'd200:song_data = 12'h316;
			16'd201:song_data = 12'h516;
			16'd202:song_data = 12'h613;
			16'd203:song_data = 12'h616;
			16'd204:song_data = 12'h51C;
			16'd205:song_data = 12'h616;
			16'd206:song_data = 12'h126;
			16'd207:song_data = 12'h226;
			16'd208:song_data = 12'h326;
			16'd209:song_data = 12'h323;
			16'd210:song_data = 12'h223;
			16'd211:song_data = 12'h123;
			16'd212:song_data = 12'h613;//6_OVER
			16'd213:song_data = 12'h613;
			16'd214:song_data = 12'h616;
			16'd215:song_data = 12'h51C;
			16'd216:song_data = 12'h616;
			16'd217:song_data = 12'h126;
			16'd218:song_data = 12'h226;
			16'd219:song_data = 12'h326;
			16'd220:song_data = 12'h613;
			16'd221:song_data = 12'h616;
			16'd222:song_data = 12'h51C;
			16'd223:song_data = 12'h616;
			16'd224:song_data = 12'h516;
			16'd225:song_data = 12'h316;
			16'd226:song_data = 12'h516;
			16'd227:song_data = 12'h613;
			16'd228:song_data = 12'h616;
			16'd229:song_data = 12'h51C;
			16'd230:song_data = 12'h616;
			16'd231:song_data = 12'h126;
			16'd232:song_data = 12'h226;
			16'd233:song_data = 12'h326;
			16'd234:song_data = 12'h323;
			16'd235:song_data = 12'h223;
			16'd236:song_data = 12'h123;
			16'd237:song_data = 12'h613;//7_OVER
			16'd238:song_data = 12'h123;
			16'd239:song_data = 12'h713;
			16'd240:song_data = 12'h613;
			16'd241:song_data = 12'h513;
			16'd242:song_data = 12'h516;
			16'd243:song_data = 12'h51C;
			16'd244:song_data = 12'h61C;
			16'd245:song_data = 12'h316;
			16'd246:song_data = 12'h216;
			16'd247:song_data = 12'h313;
			16'd248:song_data = 12'h313;
			16'd249:song_data = 12'h316;
			16'd250:song_data = 12'h516;
			16'd251:song_data = 12'h613;
			16'd252:song_data = 12'h223;
			16'd253:song_data = 12'h713;
			16'd254:song_data = 12'h123;
			16'd255:song_data = 12'h716;
			default: song_data = 12'h001;
		endcase 
		default:song_data=12'h004;
	endcase

endmodule 
