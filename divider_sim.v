module divider_sim
(
    input wire OCLK,
    input reset,
    output wire ICLK,
    output wire LCLK,
    output wire DCLK,
    output wire TCLK
);

parameter OF = 50000000, IF = 3051, LF = 381, DF = 762, TF = 1;
reg[16:0] counter;

always @(posedge OCLK or posedge reset) begin
    if (reset)
        counter <= 17'b0;
    else
        counter <= counter + 17'b1;
end

assign ICLK = counter[13];
assign LCLK = counter[16];
assign DCLK = counter[15];
assign TCLK = 1;
endmodule 


// module divider
// (
//     input wire OCLK,
//     output reg ICLK,
//     output reg LCLK,
//     output reg DCLK,
//     output reg TCLK
// );

// parameter OF = 50000000, IF = 4000, LF = 381, DF = 1000, TF = 1;
// reg[24:0] counter;

// always @(posedge OCLK) begin
//     if (counter >= OF / TF - 1)
//         counter <= 0;
//     else
//         counter <= counter + 25'b1;
// end

// always @(posedge OCLK) begin
//     if (counter % (OF / IF / 2) == 0)
//             TCLK <= !TCLK;
//     if (counter % (OF / IF / 2) == 0)
//             ICLK <= !ICLK;
//     if (counter % (OF / LF / 2) == 0)
//             LCLK <= !LCLK;
    
//     if (counter % (OF / DF / 2) == 0)
//             DCLK <= !DCLK;
// end
// endmodule 
