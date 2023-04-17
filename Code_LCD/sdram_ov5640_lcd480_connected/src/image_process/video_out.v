//-----------------------------------------------------------------------------
// Author    :    echoscala@qq.com
// File          :    video_out
// Create     :    2022-04-23
// Revise     :    2022-04-23 10:19:22
//Functions :    
//------------------------------------------------------------------------------
//      
//      
//------------------------------------------------------------------------------
module video_out(
    input    video_clk,
    input    rst_n,

    //Ports_Inputs
    input [15:0] cmos_data,
    input  windows,
    input  color,
    input  erode_data,
    input [9:0]     con_data,
    input [47:0]    loc_out1,
    input [47:0]    loc_out2,
    input [47:0]    loc_out3,
    input [11:0]    active_x,
    input [11:0]    active_y,
 
    //Ports_Outputs
    output reg [15:0] data_out
);

    reg windows_out;
    always@(posedge video_clk or negedge rst_n)
    begin
      if(~rst_n)
      begin
          windows_out<=1'b0;
      end
      else if(windows)
      begin
          windows_out<=~windows_out;
      end
    end

    reg color_out;
    always@(posedge video_clk or negedge rst_n)
    begin
      if(~rst_n)
      begin
          color_out<=1'b0;
      end
      else if(color)
      begin
          color_out<=~color_out;
      end
    end

    always@(posedge video_clk or negedge rst_n)
    begin
      if(~rst_n)
      begin
          data_out<=16'd0;
      end
      else 
      begin
          if(windows_out==1'b1)
          begin
            /*   data_out<={16{erode_data}}; */
               	if((active_y == loc_out1[47:36]) && active_x >= loc_out1[23:12] && active_x <= loc_out1[11:0])//上边界
                    data_out <= 16'hF800;
                else if((active_y == loc_out1[35:24]) && active_x >= loc_out1[23:12] && active_x <= loc_out1[11:0])//下边界
                data_out <= 16'hF800;
                else if((active_x == loc_out1[23:12]) && active_y >= loc_out1[47:36] && active_y <= loc_out1[35:24])//左边界
                data_out <= 16'hF800;
                else if((active_x == loc_out1[11:0]) && active_y >= loc_out1[47:36] && active_y <= loc_out1[35:24])//右边界
                data_out <= 16'hF800; 

                else if((active_y == loc_out2[47:36]) && active_x >= loc_out2[23:12] && active_x <= loc_out2[11:0])//上边界
                    data_out <= 16'hF800;
                else if((active_y == loc_out2[35:24]) && active_x >= loc_out2[23:12] && active_x <= loc_out2[11:0])//下边界
                data_out <= 16'hF800;
                else if((active_x == loc_out2[23:12]) && active_y >= loc_out2[47:36] && active_y <= loc_out2[35:24])//左边界
                data_out <= 16'hF800;
                else if((active_x == loc_out2[11:0]) && active_y >= loc_out2[47:36] && active_y <= loc_out2[35:24])//右边界
                data_out <= 16'hF800; 

                else if((active_y == loc_out3[47:36]) && active_x >= loc_out3[23:12] && active_x <= loc_out3[11:0])//上边界
                    data_out <= 16'hF800;
                else if((active_y == loc_out3[35:24]) && active_x >= loc_out3[23:12] && active_x <= loc_out3[11:0])//下边界
                data_out <= 16'hF800;
                else if((active_x == loc_out3[23:12]) && active_y >= loc_out3[47:36] && active_y <= loc_out3[35:24])//左边界
                data_out <= 16'hF800;
                else if((active_x == loc_out3[11:0])  && active_y >= loc_out3[47:36] && active_y <= loc_out3[35:24])//右边界
                data_out <= 16'hF800; 


               else 
                begin
                    if(color_out==1'B1)  
                    begin
                    //     case( con_data[1:0]) 
                    //         2'b00: data_out <= 
                    //     endcase
                    // data_out =
                    data_out[15:11] = con_data[4]*5'h1f;
                    data_out[10: 5] = con_data[3:2]*6'h0f;
                    data_out[ 4: 0] = con_data[1:0]*5'h07;
                    end
                    else
                    begin
                        data_out<={16{erode_data}};
                    end
                end 
            
          end
          else begin
              data_out<=cmos_data;
          end
      end
    end


endmodule
