module eeprom_test#(
    parameter   CLK_FRE  = 50, //MHz
    parameter   TEST_FRE = 1, //HZ
    parameter   IIC_SLAVE_ADDR_EX 	= 0,
	parameter   IIC_SLAVE_REG_EX 	= 1
)(
    input                                       clk,            
    input                                       rst_n,

    output reg                                  iic_start,      
    input                                       iic_busy,       
    output reg                                  reg_rw,         
    output reg [7 + IIC_SLAVE_REG_EX  * 8 :0]   reg_addr,       
    output reg [ 7:0]                           send_data,      
    input      [ 7:0]                           recv_data,  

    output reg                                  data_beat      
);

enum {WRITE_WAIT,WRITE_DATA,WRITE_ACK,READ_WAIT,READ_DATA,READ_ACK,VERIFY}STATE_TEST;
reg [ 3:0] state = 'd0;
reg [31:0] wait_cnt = 'd0;

reg [7:0] test_data = 'd0;

reg iic_busy_r = 'd0;
wire iic_done = !iic_busy & iic_busy_r;
wire iic_start_ack = iic_busy & iic_busy_r;
always@(posedge clk) iic_busy_r <= iic_busy;

always@(posedge clk or negedge rst_n)
    if(!rst_n)begin
        iic_start   <= 'b0;
        test_data   <= 'd0;        

        state <= WRITE_WAIT;
    end
    else
        case(state)
            WRITE_WAIT: begin
                if(wait_cnt >= CLK_FRE * 500_000 / TEST_FRE)begin
                    wait_cnt <= 'd0;
                    iic_start <= 'b1;
                    state <= WRITE_DATA;
                end
                else begin
                    wait_cnt <= wait_cnt + 'd1;
                end
            end

            WRITE_DATA: begin
                if(!iic_busy) begin
                    iic_start <= 'b1;
                    reg_rw <= 'b0;
                    reg_addr <= 'd1; // 仅对地址 1 读写验证
                    send_data <= test_data;
                    state <= WRITE_ACK;
                end
                else 
                    state <= WRITE_DATA;
            end

            WRITE_ACK:begin
                if(iic_start_ack)
                    iic_start <= 'b0;
                else if(iic_done) begin
                    state <= READ_WAIT;
                end 
                else if(wait_cnt >= CLK_FRE * 1000_000 / TEST_FRE)begin
                    wait_cnt <= 'd0;
                    iic_start <= 'b1;
                    state <= WRITE_WAIT;
                end
                else begin
                    wait_cnt <= wait_cnt + 'd1;
                end
            end

            READ_WAIT: begin
                if(wait_cnt >= CLK_FRE * 500_000 / TEST_FRE)begin
                    wait_cnt <= 'd0;
                    iic_start <= 'b1;
                    state <= READ_DATA;
                end
                else begin
                    wait_cnt <= wait_cnt + 'd1;
                end
            end

            READ_DATA : begin
                if(!iic_busy) begin
                    iic_start <= 'b1;
                    reg_rw <= 'b1;
                    reg_addr <= 'd1; // 仅对地址 1 读写验证
                    // send_data <= test_data; //读取数据不需要发送数据
                    state <= READ_ACK;
                end
                else
                    state <= READ_DATA;
            end

            READ_ACK:begin
                if(iic_start_ack)
                    iic_start <= 'b0;
                else if(iic_done) begin
                    state <= VERIFY;
                end 
                else if(wait_cnt >= CLK_FRE * 1000_000 / TEST_FRE)begin
                    wait_cnt <= 'd0;
                    iic_start <= 'b1;
                    state <= WRITE_WAIT;
                end
                else begin
                    wait_cnt <= wait_cnt + 'd1;
                end
            end

            VERIFY:begin
                if(recv_data == test_data)begin
                    data_beat <= ~data_beat;
                end
                test_data <= test_data + 1;
                state <= WRITE_WAIT;
            end

            default : state <= WRITE_WAIT;
        endcase
endmodule 