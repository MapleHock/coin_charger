
`timescale 10 ns / 10 ns

module divider_tb;
    reg clock;
    reg reset;
    wire ICLK;
    wire LCLK;
    wire DCLK;
    wire TCLK;
    divider_sim divider_test(.OCLK(clock), .reset(reset), .ICLK(ICLK), .LCLK(LCLK), .DCLK(DCLK), .TCLK(TCLK));

    always #1 clock = ~clock;
    initial
    begin
        reset = 1;
        clock = 0;
        #1 reset =0;
    end

endmodule
