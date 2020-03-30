module keyboard
(
	input CLK, // scan f 3051hz
	input [3:0] row,
	output reg[3:0] col,
	output reg[3:0] data,
	output reg start, reset, ok, idle
);
localparam CR3 = 4'b0111, CR2 = 4'b1011, CR1 = 4'b1101, CR0 = 4'b1110, CIDLE = 4'b0000, RIDLE = 4'b1111; // 用于定位行列，由于是列扫描所以列的闲置状态为0000， 而行为1111 
localparam IDLE = 5'b00001, PRESS_CHECK = 5'b00010, SCAN = 5'b00100, OUTPUT = 5'b01000, FREE_CHECK = 5'b10000; // 定义键盘模块的状态，分别为闲置、闭合防抖、扫描、释放防抖
localparam CNT_FULL = 5'b11111, CNT_RESET = 5'b00000, CNT_ADD = 5'b00001; // 给防抖计数器的参数
reg[4:0] state,next_state;
/* 防抖计数器和其置位端，和反映防抖计数满用于键盘状态机跳转的变量 */
reg[3:0] anti_shake_cnt;
reg anti_shake_cnt_reset;
wire is_anti_shake_cnt_full;
/* `扫描用的变量，前两个为扫描计数器的使能端和复位端，后为扫描计数器，用它的数确定列输出，也即扫描的模式`*/
reg col_scan_hold;
reg col_scan_end;
reg[2:0] col_scan_cnt;
/* `译码用变量，reset\_out用于把输出的数复位到无效，idle\_last用于判断是否第一次进入OUTPUT状态并开启译码`*/
reg reset_out;
reg idle_last;

// 防抖计数器
always @(posedge CLK or posedge anti_shake_cnt_reset) begin
    if (anti_shake_cnt_reset)
        anti_shake_cnt <= CNT_RESET;
    else
        anti_shake_cnt <= anti_shake_cnt + CNT_ADD;
end
assign is_anti_shake_cnt_full = &anti_shake_cnt;

// 扫描计数器
always @(posedge CLK or posedge col_scan_end) begin
    if (col_scan_end)
        col_scan_cnt <= 3'b000;
    else if (col_scan_hold)
        col_scan_cnt <= col_scan_cnt;
    else
    begin
        if (col_scan_cnt < 3'b100)
            col_scan_cnt <= col_scan_cnt + 1;
        else
            col_scan_cnt <= 3'b000;
    end
end

// 扫描计数器的驱动方程
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

// 键盘状态机
always @(posedge CLK) begin
    state <= next_state;
end

always @(state) begin
    case(state)
        IDLE:
            next_state = (row != RIDLE) ? PRESS_CHECK : IDLE;
        PRESS_CHECK:
            begin
                if (is_anti_shake_cnt_full && row != RIDLE)
                    next_state = SCAN;
                else if (!is_anti_shake_cnt_full && row != RIDLE)
                    next_state = PRESS_CHECK;
                else
                    next_state = IDLE;
            end
        SCAN:
            if (row == RIDLE)
                next_state = SCAN;
            else
                next_state = OUTPUT;
        OUTPUT:
            if (row == RIDLE)
                next_state = FREE_CHECK;
            else
                next_state = OUTPUT;
        FREE_CHECK:
            begin
                if (is_anti_shake_cnt_full)
                    next_state = IDLE;
                else
                    next_state = FREE_CHECK;
            end
        default:
            next_state = IDLE; 
    endcase
end

always @(state) begin
    case(state)
        IDLE:
            begin
                idle = 1;
                reset_out = 1;
                anti_shake_cnt_reset = 1;
                col_scan_end = 1;
                col_scan_hold = 0;
            end
        PRESS_CHECK:
            begin
                idle = 1;
                reset_out = 1;
                anti_shake_cnt_reset = 0;
                col_scan_end = 0;
                col_scan_hold = (row != RIDLE && is_anti_shake_cnt_full) ? 0 : 1;
            end
        SCAN:
            begin
                idle = 1;
                reset_out = 1;
                col_scan_hold = (row != RIDLE) ? 1 : 0;
                col_scan_end = 0;
                anti_shake_cnt_reset = 1;              
            end
        OUTPUT:
            begin
                idle = 0;
                reset_out = 0;
                col_scan_hold = 1;
                col_scan_end = 0;
                anti_shake_cnt_reset = 1;
            end
        FREE_CHECK:
            begin
                idle = 0;
                reset_out = 0;
                anti_shake_cnt_reset = (row == RIDLE) ? 0 : 1;
                col_scan_end = 1;
                col_scan_hold = 0;
            end
    endcase
end

always @(posedge CLK) begin
    idle_last <= idle;
end

// 译码部分，为防止键盘抬起时未到下一个时钟沿，使用时序电路译码，在进入OUTPUT的第一个周期译码，之后都保持
// 错误代码为data 1111,其他控制信号start,reset,ok为0
// 当控制信号给出时，数据部分亦给出错误代码1111
always @(posedge CLK or posedge reset_out)begin
    if (reset_out)
        {data, start, reset, ok} <= 7'b1111_000;
    else if (idle == 0 & idle_last == 1)
    begin
        if (col_scan_cnt == 3'b100)
        begin
            {start, reset, ok} <= {~row[3:1]};
            data <= 4'b1111;
        end
        else if (row == CR0 && col_scan_cnt == 3'b001)
        begin
            {start, reset, ok} <= 3'b000;
            data <= 0;
        end
        else if (row == CR0)
        begin
            {start, reset, ok} <= 3'b000;
            data <= 4'b1111;
        end else
        begin
            {start, reset, ok} <= 3'b0000;
            data <= 4'b1 + 3 * (2 * !row[1] + !row[2]) + 1 * (col_scan_cnt - 1);
        end
    end
    else
        {data, start, reset, ok} <= {data, start, reset, ok};
end

endmodule

