module my7448
(
    input[3:0] num,
    output reg A,B,C,D,E,F,G
);

always @(num)
    case(num)
        4'h0: {A, B, C, D, E, F, G} = 7'b1111110;
        4'h1: {A, B, C, D, E, F, G} = 7'b0110000;
		4'h2: {A, B, C, D, E, F, G} = 7'b1101101;
		4'h3: {A, B, C, D, E, F, G} = 7'b1111001;
        4'h4: {A, B, C, D, E, F, G} = 7'b0110011;
        4'h5: {A, B, C, D, E, F, G} = 7'b1011011;
        4'h6: {A, B, C, D, E, F, G} = 7'b1011111;
        4'h7: {A, B, C, D, E, F, G} = 7'b1110000;
        4'h8: {A, B, C, D, E, F, G} = 7'b1111111;
        4'h9: {A, B, C, D, E, F, G} = 7'b1111011;
        4'ha: {A, B, C, D, E, F, G} = 7'b0001101;
        4'hb: {A, B, C, D, E, F, G} = 7'b0011001;
        4'hc: {A, B, C, D, E, F, G} = 7'b0100011;
        4'hd: {A, B, C, D, E, F, G} = 7'b1001011;
        4'he: {A, B, C, D, E, F, G} = 7'b0001111;
        4'hf: {A, B, C, D, E, F, G} = 7'b0000000;
    endcase
endmodule 
