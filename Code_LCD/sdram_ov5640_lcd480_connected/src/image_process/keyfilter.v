//-----------------------------------------------------------------------------
// Author    :    echoscala@qq.com
// File          :    keyfilter
// Create     :    2021-11-26
// Revise     :    2021-11-26 23:45:56
//Functions : 实现按键消抖（双边沿）   
//------------------------------------------------------------------------------
//      
//      
//------------------------------------------------------------------------------
module keyfilter(
    input    clk,
    input    rst_n,

    //Ports_Inputs
    input       keyin,
    //Ports_Outputs
    output reg keyout
);
    localparam CNT_20MS =65*1_000_000 /50 ;     //todo
    reg key_r0,key_r1;
    reg [31:0] cnt;
    reg [2:0]   current_state;
    reg [2:0]   next_state;
    parameter S_negedge =1 ;
    parameter S_nge_cnt =2 ;
    parameter S_posedge =3 ;
    parameter S_pos_cnt =4 ;
    parameter S_out =5 ;

    always@(posedge clk or negedge rst_n)
    begin
      if(~rst_n)
      begin
          key_r0<=0;
          key_r1<=0;
      end
      else
      begin
          key_r0<=keyin;
          key_r1<=key_r0;
       end
    end

    always@(posedge clk or negedge rst_n)
    begin
      if(~rst_n)
      begin
          current_state<=S_negedge;
      end
      else
      begin
          current_state<=next_state;
       end
    end

    wire key_negedge,key_posedge;
    assign key_negedge =key_r1&&~key_r0 ;
    assign key_posedge =~key_r1&&key_r0 ;
    always @(*) 
    begin
        case (current_state)
            S_negedge:
            begin
                if(key_negedge)
                begin
                    next_state = S_nge_cnt;
                end
                else begin
                    next_state = S_negedge;
                end
            end
            S_nge_cnt:
            begin
                if(cnt == CNT_20MS-1)
                begin
                    next_state = S_posedge;                    
                end
                else begin
                    next_state = S_nge_cnt;
                end
            end
            S_posedge:
            begin
                if(key_posedge)
                begin
                    next_state = S_pos_cnt;
                end
                else begin
                    next_state = S_posedge;
                end
            end
            S_pos_cnt:
            begin
                if(cnt == CNT_20MS-1)
                begin
                    next_state = S_out;
                end
                else begin
                    next_state = S_pos_cnt;
                end
            end
            S_out:
            begin
                next_state = S_negedge;
            end
        endcase    
    end


    always@(posedge clk or negedge rst_n)
    begin
      if(~rst_n)
      begin
          cnt <=0;
      end
      else if(current_state == S_nge_cnt)
      begin
          cnt<=cnt+1'b1;
       end
       else if(current_state == S_pos_cnt)
       begin
           cnt<=cnt+1'b1;
       end
       else begin
           cnt<=0;
       end
    end

    always@(posedge clk or negedge rst_n)
    begin
      if(~rst_n)
      begin
          keyout<=0;
      end
      else if(current_state==S_out)
      begin
          keyout <=1;
      end
      else begin
          keyout<=0;
      end
    end
endmodule