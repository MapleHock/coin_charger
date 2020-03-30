module keyboard_sim
(
	input CLK, // scan f 3051hz
	input [3:0] row,
    input rst,
	output reg[3:0] col,
	output reg[3:0] data,
	output reg start, reset, ok, idle,
    output wire[4:0] state_view,
    output wire[4:0] anti_shake_cnt_view,
    output wire[2:0] col_scan_cnt_view
);
localparam CR3 = 4'b0111, CR2 = 4'b1011, CR1 = 4'b1101, CR0 = 4'b1110, CIDLE = 4'b0000, RIDLE = 4'b1111;
localparam IDLE = 5'b00001, PRESS_CHECK = 5'b00010, SCAN = 5'b00100, OUTPUT = 5'b01000, FREE_CHECK = 5'b10000;
localparam CNT_FULL = 5'b11111, CNT_RESET = 5'b00000, CNT_ADD = 5'b00001;
reg[4:0] state,next_state;
reg[4:0] anti_shake_cnt;
reg anti_shake_cnt_reset;
wire is_anti_shake_cnt_full;
reg[2:0] col_scan_cnt;
reg first_output;
wire is_row_idle;
wire pc2scan;
wire pc2pc;

always @(col_scan_cnt) begin
    case(col_scan_cnt)
        3'b000: col = CIDLE;
        3'b001: col = CR3;
        3'b010: col = CR2;
        3'b011: col = CR1;
        3'b100: col = CR0;
        default: col = CIDLE;
    endcase
end

assign is_anti_shake_cnt_full = &anti_shake_cnt;
assign is_row_idle = (row == RIDLE);
assign anti_shake_cnt_view = anti_shake_cnt;
assign pc2scan = is_anti_shake_cnt_full && !is_row_idle;
assign pc2pc = !is_anti_shake_cnt_full && !is_row_idle;

always @(posedge CLK or posedge rst) begin
    if (rst) 
    begin
        state <= IDLE;
        anti_shake_cnt <= 0;
        col_scan_cnt <= 3'b000;
        first_output <= 0;
    end
    else
    begin
        case(state)
            IDLE:
                begin
                    state <= is_row_idle ? IDLE : PRESS_CHECK;
                    anti_shake_cnt <= 0;
                    col_scan_cnt <= 3'b000;
                    first_output <= 0;
                end
            PRESS_CHECK:
                begin
                    anti_shake_cnt <= anti_shake_cnt + 1;
                    first_output <= 0;
                    if (pc2scan)
                    begin
                        state <= SCAN;
                        col_scan_cnt <= 3'b001;
                    end
                    else if (pc2pc)
                    begin
                        state <= PRESS_CHECK;
                        col_scan_cnt <= 3'b000;
                    end
                    else
                    begin
                        state <= IDLE;
                        col_scan_cnt <= 3'b000;
                    end
                end
            SCAN:
                begin
                    anti_shake_cnt <= 0;
                    if (is_row_idle) 
                    begin
                        col_scan_cnt <= col_scan_cnt + 1;
                        state <= SCAN;
                    end        
                    else
                    begin
                        first_output <= 1;
                        state <= OUTPUT;
                        col_scan_cnt <= col_scan_cnt;
                    end
                end
            OUTPUT:
                begin
                    anti_shake_cnt <= 0;
                    col_scan_cnt <= col_scan_cnt;
                    first_output <= 0;
                    if (is_row_idle)
                        state <= FREE_CHECK;
                    else
                        state <= OUTPUT;
                end
            FREE_CHECK:
                begin
                    anti_shake_cnt <= is_row_idle ? anti_shake_cnt + 1 : 0;
                    col_scan_cnt <= col_scan_cnt;
                    first_output <= 0;
                    begin
                        if (is_anti_shake_cnt_full)
                            state <= IDLE;
                        else
                            state <= FREE_CHECK;
                    end
                end
            default:
                begin
                    state <= IDLE;
                    anti_shake_cnt <= 0;
                    col_scan_cnt <= 3'b000; 
                end
        endcase
    end
end

always @(state) begin
    case(state)
        IDLE:
            begin
                idle = 1;
                {data, start, reset, ok} = 7'b1111_000;
            end
        PRESS_CHECK:
            begin
                idle = 1;
                {data, start, reset, ok} = 7'b1111_000;
            end
        SCAN:
            begin
                idle = 1;
                {data, start, reset, ok} = 7'b1111_000;           
            end
        OUTPUT:
            begin
                idle = 0;
                if (first_output)
                begin
                    if (col_scan_cnt == 3'b100)
                    begin
                        {start, reset, ok} = {~row[3:1]};
                        data = 4'b1111;
                    end
                    else if (row == CR0 && col_scan_cnt == 3'b001)
                    begin
                        {start, reset, ok} = 3'b000;
                        data = 0;
                    end
                    else if (row == CR0)
                    begin
                        {start, reset, ok} = 3'b000;
                        data = 4'b1111;
                    end else
                    begin
                        {start, reset, ok} = 3'b0000;
                        data = 4'b1 + 3 * (2 * !row[1] + !row[2]) + 1 * (col_scan_cnt - 1);
                    end
                end
                else
                    {data, start, reset, ok} = {data, start, reset, ok};
            end
        FREE_CHECK:
            begin
                idle = 0;
                {data, start, reset, ok} = 7'b1111_000;
            end
    endcase
end

assign state_view = state;
assign col_scan_cnt_view = col_scan_cnt;

endmodule
