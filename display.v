module display
(
    input[3:0] D3,
    input[3:0] D2,
    input[3:0] D1,
    input[3:0] D0,
    input CLK,
    output wire A,B,C,D,E,F,G,
	 output reg[3:0] DIG
);

reg[1:0] cnt;
reg[3:0] cur_num;
my7448 decoder(cur_num,A,B,C,D,E,F,G);

always @(posedge CLK) 
begin
    cnt <= cnt + 2'b1;
end

always @(cnt) 
begin
    case(cnt)
        2'b00: 
		  begin
			cur_num = D0;
			DIG = 4'b0001;
		  end
        2'b01: 
		  begin
			cur_num = D1;
			DIG = 4'b0010;
		  end
		  2'b10: 
		  begin
			cur_num = D2;
			DIG = 4'b0100;
		  end
		  2'b11: 
		  begin
			cur_num = D3;
			DIG = 4'b1000;
		  end
    endcase
end
endmodule // display
