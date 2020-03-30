module control_sim
(
    input idle,
    input[3:0] data,
    input start,
    input reset,
    input ok,
    input CLK, // 381Hz
    input rst,
    output reg[7:0] money,
    output reg[7:0] timer,
	output reg[3:0] state_viewer 
);

localparam TEN_FULL = 12'hfff, ONE_FULL = 8'hff;
localparam INIT = 2'b00, START = 2'b01, INPUT = 2'b10, CHARGE =2'b11;
reg[1:0] state;
reg[11:0] ten_cnt;
reg[7:0] one_cnt;
reg ten_cnt_reset;
reg one_cnt_reset;
wire is_ten_full;
wire is_one_full;
wire is_charge_over;
reg money_change;
reg hide_time_money, reset_money, reset_time, hold_money, set_by_money;
reg idle_last;
localparam HIDE_NUM = 4'b1111;
localparam ERROR_NUM = 4'b1111;

assign is_charge_over = !(|timer);
assign is_ten_full = &ten_cnt;
assign is_one_full = &one_cnt;

always @(posedge CLK or posedge rst) begin
    if (rst) 
    begin
        state <= INIT;
        idle_last <= 1;
        ten_cnt <= 0;
        one_cnt <= 0;
        money <= {HIDE_NUM, HIDE_NUM};
        timer <= {HIDE_NUM, HIDE_NUM};
    end
    else
    begin
        idle_last <= idle;
        case (state)
        INIT:
            begin
                ten_cnt <= 0;
                one_cnt <= 0;
                money <= {HIDE_NUM, HIDE_NUM};
                timer <= {HIDE_NUM, HIDE_NUM};
                if (start)
                    state <= START;
                else
                    state <= INIT;
            end
        START:
            begin
                ten_cnt <= 0;
                one_cnt <= 0;
                money <= 0;
                timer <= 0;
                state <= INPUT;
            end
        INPUT:
            begin
                ten_cnt <= idle ? ten_cnt + 1 : 0; 
                one_cnt <= 0;
                if (is_ten_full)
                    state <= INIT;
                else if (!ok)
                    state <= INPUT;
                else
                    state <= CHARGE;
                if (data != ERROR_NUM && idle_last == 1 && idle == 0)
                begin
                    // if (money[3:0] <= 1)
                    //     money[7:0] <= {money[3:0] ,data}; 
                    // else
                    //     money[7:0] <= 8'b0010_0000;
                    if (money[7:4] != 0)
                    begin
                        money <= money;
                    end
                    else
                    begin
                        if (money[3:0] <= 1)
								begin
									money[7:0] <= {money[3:0] ,data}; 
									timer[7:4] <= timer[3:0] + (data > 4);
									timer[3:0] <=  2 * data + 6 * (data > 4);
								end
                        else
								begin
									money[7:0] <= 8'b0010_0000;
									timer[7:0] <= 8'b0100_0000;
								end
                    end
                end
                else if (reset) 
					 begin
                    money <= 0;
						  timer <= 0;
					 end
                else
					 begin
                    money <= money;
						  timer <= timer;
					 end
                /*timer[7:4] <= 2 * money[7:4] + (money[3:0] > 4'b0100);
                timer[3:0] <= 2 * money[3:0] + 6 * (money[3:0] > 4'b0100);*/
            end
        CHARGE:
            begin
                ten_cnt <= 0;
                one_cnt <= one_cnt + 1;
                money <= money;
                timer <= is_one_full ? timer - 1 : timer;
                if (is_charge_over)
                    state <= START;
                else
                    state <= CHARGE;
            end
		default:
				state <= INIT;
    endcase
    end
end

always @(state) begin
    case (state)
        INIT:
            begin
				state_viewer = 4'b0001;
            end
        START:
            begin
				state_viewer = 4'b0010;
            end
        INPUT:
            begin
				state_viewer = 4'b0100;
            end
        CHARGE:
            begin
				state_viewer = 4'b1000;
            end
    endcase
end

endmodule
