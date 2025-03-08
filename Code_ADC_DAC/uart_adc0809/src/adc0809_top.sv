module adc0809_top#(
    parameter CLK_FRE = 50, //MHz
    parameter ADC_FRE = 1000 //Hz
)(
    input                       clk  ,			
    input                       rst_n ,

    input                       adc0809_start 	,
    output                      adc0809_done, 	
    output      [ 7:0][ 7:0]    adc0809_data,

    output reg  [ 2:0]          adc0809_addr,	
    input       [ 7:0]          adc0809_db,	
    output                      adc0809_oe,
    output reg                  adc0809_clk,	
    output reg                  adc0809_st,	
    input                       adc0809_eoc,	
    output                      adc0809_ale,

    output reg [3:0] adc0809_state	
);

/********************************************************************************/
/**************************    ADC0809时钟分频    ********************************/
/********************************************************************************/
parameter ADC_CLK_FRE = 640; //KHz ADC0809时钟频率

reg [ 9:0] adc0809_clk_cnt;
always @(posedge clk)
    if(adc0809_clk_cnt >= CLK_FRE*500/ADC_CLK_FRE-1)begin
        adc0809_clk <= ~adc0809_clk;
        adc0809_clk_cnt <= 0;
    end
    else
        adc0809_clk_cnt <= adc0809_clk_cnt + 1;

/********************************************************************************/
/**************************    ADC0809逻辑部分   ********************************/
/********************************************************************************/
enum {START,ST,WAIT_EOC_L,WAIT_EOC_H,READ_DATA,NEXT_ADDR,ADC_DELAY}STATE_CODE;
// reg [ 3:0] adc0809_state = 'd0;
reg [23:0] wait_cnt = 'd0;
reg [15:0] clk_delay = 'd0;

assign adc0809_done = (adc0809_state == START);
assign adc0809_oe   = (adc0809_state == READ_DATA);
assign adc0809_ale  = adc0809_st;

always@(posedge clk,negedge rst_n)
    if(!rst_n)begin
        adc0809_addr    <= 'd0;
        adc0809_st      <= 'd0;
        clk_delay       <= 'd0;
        wait_cnt        <= 'd0;

        adc0809_state <= START;
    end
    else 
        case(adc0809_state)
            START:begin
                wait_cnt       <= wait_cnt + 'd1;

                if(adc0809_start && adc0809_clk == 0 && adc0809_clk_cnt == 1)begin
                    adc0809_st      <= 'b1;

                    adc0809_state   <= ST;
                end
            end

            ST:begin // min- typ-100ns max-200ns,但要让CLK采到所以等一个周期
                wait_cnt       <= wait_cnt + 'd1;
               
                if(adc0809_clk == 1 && adc0809_clk_cnt == 1)begin
                    adc0809_st      <= 'b0;

                    adc0809_state   <= WAIT_EOC_L;
                end
                else
                    clk_delay <= clk_delay + 1'b1;
            end

            WAIT_EOC_L:begin
                wait_cnt       <= wait_cnt + 'd1;

                if(!adc0809_eoc)begin
                    clk_delay       <= 'd0;
                    adc0809_state   <= WAIT_EOC_H;
                end
                else if(clk_delay >= CLK_FRE * 10)begin // MAX 10us
                    clk_delay    <= 'd0;
                    adc0809_state   <= ADC_DELAY;
                end
                else
                    clk_delay       <= clk_delay + 1'b1;
            end

            WAIT_EOC_H:begin
                wait_cnt       <= wait_cnt + 'd1;

                if(adc0809_eoc)begin
                    adc0809_state   <= READ_DATA;
                end
            end

            READ_DATA:begin // wait for 2 ADC_CLK
                wait_cnt       <= wait_cnt + 'd1;

                adc0809_data[adc0809_addr] <= adc0809_db;
                
                if(clk_delay >= CLK_FRE*2000/ADC_CLK_FRE-1)begin
                    clk_delay       <= 'd0;
                    adc0809_addr    <= adc0809_addr + 1'b1;
                    adc0809_state   <= NEXT_ADDR;
                end
                else
                    clk_delay       <= clk_delay + 1'b1;
            end

            NEXT_ADDR:begin
                wait_cnt       <= wait_cnt + 'd1;
                
                if(adc0809_addr == 'd0)begin
                    adc0809_state   <= ADC_DELAY;
                end
                else begin
                    adc0809_state   <= START;
                end
            end

            ADC_DELAY:begin
                if(wait_cnt >= 1000_000*CLK_FRE/ADC_FRE-1)begin
                    adc0809_state   <= START;
                    wait_cnt        <= 'd0;
                end
                else begin
                    wait_cnt        <= wait_cnt + 1'b1;
                end
            end
            default:adc0809_state <= ADC_DELAY;
        endcase

endmodule