module divider
(
    input OCLK,
    input rst,
    output wire ICLK,
    output wire LCLK,
    output wire DCLK
);

parameter OF = 50000000, IF = 3051, LF = 381, DF = 762, TF = 1;
reg[16:0] counter;

always @(posedge OCLK or posedge rst) begin
    if (rst)
        counter <= 0;
    else
        counter <= counter + 17'b1;
end

assign ICLK = counter[13];
assign LCLK = counter[16];
assign DCLK = counter[15];
endmodule 


// module divider
// (
//     input wire OCLK,
//     output reg ICLK,
//     output reg LCLK,
//     output reg DCLK,
// );

// parameter OF = 50000000, IF = 4000, LF = 500, DF = 1000, TF = 1;
// reg[17:0] counter;

// always @(posedge OCLK) begin
//     if (counter >= OF / LF - 1)
//         counter <= 0;
//     else
//         counter <= counter + 18'b1;
// end

// always @(posedge OCLK) begin
//     if (counter % (OF / IF / 2) == 0)
//             ICLK <= !ICLK;
//     if (counter % (OF / LF / 2) == 0)
//             LCLK <= !LCLK;
//     if (counter % (OF / DF / 2) == 0)
//             DCLK <= !DCLK;
// end
// endmodule 
