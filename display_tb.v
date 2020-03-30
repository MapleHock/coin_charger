
`timescale 1 ms / 1 ms
`define half_cycle 1
`define cycle 2

module display_tb;
localparam ERROR_NUM = 4'b1111;
    reg clock;
    reg[3:0] D3, D2, D1, D0;
    reg rst;
    wire A,B,C,D,E,F,G;
    wire[3:0] DIG; 
    display_sim display_test(.CLK(clock), .D3(D3), .D2(D2), .D1(D1), .D0(D0), .A(A), .B(B), .C(C), .D(D), .E(E), .F(F), .G(G), .DIG(DIG), .rst(rst));

    always #`half_cycle clock = ~clock;
    initial
    begin
        {D3, D2, D1, D0} = 16'b0;
        clock = 0;
        rst = 1;
        #1 rst = 0;
        #`cycle {D3, D2, D1, D0} = {4'b0010, 4'b0000, 4'b0101, 4'b0001};
    end

endmodule
