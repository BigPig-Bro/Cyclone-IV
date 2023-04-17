module erode(
    input   clk,
    input   thr_hs,thr_vs,thr_de,
    input  thr_out,
    output erode_vs,erode_hs,erode_de,
    output   erode_data
);
    // 矩阵
    reg         p11,p12,p13,
                    p21,p22,p23,
                    p31,p32,p33;

    wire         taps0x,taps1x;

    wire data_in;
    assign data_in = thr_out;

    always@(posedge clk)
    begin
         {p11,p12,p13}<={p12,p13,taps0x};
        {p21,p22,p23}<={p22,p23,taps1x};
        {p31,p32,p33}<={p32,p33,data_in};
    end

    //腐蚀第一步   1clk
    reg elt_1,elt_2,elt_3;
    always@(posedge clk)
    begin
            elt_1<=p11&&p12&&p13;
            elt_2<=p22&&p21&&p23;
            elt_3<=p31&&p32&&p33;
    end
    //腐蚀第二步  1clk
    reg elt;
    always@(posedge clk)
    begin
        elt<=elt_1&&elt_2&&elt_3;
    end

    //打拍
    reg [6:0]      vs_r,hs_r,de_r;
    assign  erode_vs=vs_r[4];
    assign  erode_hs=hs_r[4];
    assign  erode_de=de_r[4];
    always@(posedge clk)
    begin
        vs_r<={vs_r[5:0],thr_vs};
        hs_r<={hs_r[5:0],thr_hs};
        de_r<={de_r[5:0],thr_de}; 
    end
    //输出
    assign erode_data=erode_de?(elt?1'b1:1'b0):1'b0;

       operation opr_2_m0(
        .clock(clk),
        .clken(thr_de),
        .shiftin(data_in),
        .taps0x(taps0x),
        .taps1x(taps1x),
        .shiftout()
    );
endmodule