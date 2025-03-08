
module ft232h
(   input          sys_clk,
	input          ft_clk,
	input          rst_n,
	input          ft_rxf_n,  //Data available
	input          ft_txe_n,  //Space available
	output         ft_oe_n,
	output reg     ft_rd_n,
	output         ft_wr_n,
	inout[7:0]     ft_data
);
localparam IDLE   = 0;
localparam READ   = 1;
localparam WRITE  = 2;

reg[3:0]           state;
reg                buf_wr;
reg[7:0]           buf_data;
wire[7:0]          ft_data_out;
wire[9:0]          rd_data_count;
wire[9:0]          wr_data_count;
wire               buf_empty;
wire               buf_full;
wire               buf_rd;

reg               ft_oe_n_d0;
assign ft_oe_n = (state == READ) ? 1'b0 : 1'b1;

assign ft_data = (ft_oe_n == 1'b0) ? 8'hzz : ft_data_out;
assign ft_wr_n = (state == WRITE && ft_txe_n == 1'b0 && buf_empty == 1'b0) ? 1'b0 : 1'b1;
assign buf_rd =  (state == WRITE && ft_txe_n == 1'b0 && buf_empty == 1'b0) ? 1'b1 : 1'b0;
 reg[5:0] cnt_clr;
 reg aclr;
 always@(posedge ft_clk or negedge rst_n)
 begin
     if(rst_n == 1'b0)
         cnt_clr<= 6'b0;
     else if(cnt_clr>10)
         aclr<=1'b0;
     else begin
         aclr <= 1'b1;
         cnt_clr<=cnt_clr+1'b1;
         end
 end

ft_buf ft_buf_m0(
      .wrclk(ft_clk),                    // input wire wr_clk
      .data(buf_data ),                   // input wire [7 : 0] din
      .wrreq(buf_wr),                    // input wire wr_en
      .wrusedw(wr_data_count ),  // output wire [9 : 0] wr_data_count

      .rdclk(ft_clk),                   // input wire rd_clk
      .rdreq(buf_rd),                    // input wire rd_en
      .q(ft_data_out),                    // output wire [7 : 0] dout
      .rdusedw(rd_data_count ),  // output wire [9 : 0] rd_data_count

      .wrfull(buf_full ),                    // output wire full
      .rdempty(buf_empty)                 // output wire empty
       );

always@(posedge ft_clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		ft_oe_n_d0 <= 1'b0;
	else 
		ft_oe_n_d0 <= ft_oe_n;
end

always@(posedge ft_clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		buf_wr <= 1'b0;
	else if(state == READ)
		buf_wr <= ~ft_oe_n_d0 & ~ft_rxf_n;
	else
		buf_wr <= 1'b0;
end

always@(posedge ft_clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		buf_data <= 8'd0;
	else if(state == READ)
		buf_data <= ft_data;
end

always@(posedge ft_clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		ft_rd_n <= 1'b1;
	else if(ft_rxf_n == 1'b1)
		ft_rd_n <= 1'b1;
	else if(state == READ)
		ft_rd_n <= 1'b0;
		
end
always@(posedge ft_clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		state <= IDLE;
	end
	else
		case(state)
			IDLE:
			begin
				if(ft_rxf_n == 1'b0)
				begin
					state <= READ;
				end
				else if(ft_txe_n == 1'b0 && buf_empty == 1'b0)
				begin
					state <= WRITE;
				end
			end
			READ:
			begin
				if(ft_rxf_n == 1'b1)
				begin
					state <= IDLE;
				end
			end
			WRITE:
			begin
				if(ft_txe_n == 1'b1 || buf_empty == 1'b1)
				begin
					state <= IDLE;
				end
			end
			default:
				state <= IDLE;
		endcase
end
               
endmodule