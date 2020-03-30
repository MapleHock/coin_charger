module control
(
    input idle,
    input[3:0] data,
    input start,
    input reset,
    input ok,
    input CLK, // 381Hz
    output reg[7:0] money,
    output reg[7:0] timer,
	output reg[3:0] state_viewer 
);


localparam INIT = 2'b00, START = 2'b01, INPUT = 2'b10, CHARGE =2'b11; // `定义四个状态初始、开始、输入、充电，开始状态仅用于把输出初始化为0，会无条件跳转到输入状态`
// `输出全1会被译码为数码管全灭，而错误数是和键盘模块约定好的错误数码`
localparam HIDE_NUM = 4'b1111;
localparam ERROR_NUM = 4'b1111;
reg[1:0] current_state, next_state;
//`10s和1s的计数器和他们的相关控制反馈变量，分别用于判断是否需要回到初始状态和充电的倒计时`
reg[11:0] ten_cnt;
reg[7:0] one_cnt;
reg ten_cnt_reset;
reg one_cnt_reset;
wire is_ten_full;
wire is_one_full;
wire is_charge_over;
// `关于显示的一些中间变量，hide_time_money为1 ，输出的四组数全为1111，被后端译码为全灭， reset_money, reset_time对应键盘输入reset，hold_money在充电状态保证钱不变, set_by_money让INPUT态下timer随输入的数变化`
reg hide_time_money, reset_money, reset_time, hold_money, set_by_money;
//`用于判定是否是第一次读到数据，并做对应更新`
reg idle_last;


always @(posedge CLK) begin
    idle_last <= idle;
end

// 金钱部分控制电路
// 控制优先级为全灭，置零，保持，更新；在状态机的输出方程中驱动这些控制变量
always @(posedge CLK) begin
    if (hide_time_money)
        money <= {HIDE_NUM, HIDE_NUM};
    else if (reset_money)
        money <= 0;
    else if (hold_money)
        money <= money;
    else if (data != ERROR_NUM && idle_last == 1 && idle == 0)
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
            money[7:0] <= {money[3:0] ,data}; 
            else
            money[7:0] <= 8'b0010_0000;
        end
    end
    else
        money <= money;
end

// 时间部分控制电路
// 控制优先级为，全灭，重置，根据读入钱款更新，根据倒计时更新；在状态机的输出方程中驱动这些控制变量
always @(posedge CLK) begin
    if (hide_time_money)
        timer <= {HIDE_NUM, HIDE_NUM};
    else if (reset_time)
        timer <= 0;
    else if (set_by_money) 
    begin
    if (data != ERROR_NUM && idle_last == 1 && idle == 0)
    begin
        if (timer[7:4] != 0 || timer[3:0] >= 4)
            timer <= 8'b0100_0000;
        else
        begin
            timer[7:4] <= timer[3:0] + (data > 4);
            timer[3:0] <=  2 * data + 6 * (data > 4);
        end
    end
    else
        timer <= timer;
    end 
    else if (is_one_full) begin
        if (timer[3:0] == 0) 
        begin
            timer [3:0] <= 4'b1001;
            timer [7:4] <= timer[7:4] - 1;
        end
        else
            timer <= timer - 1;
    end
end
assign is_charge_over = !(|timer);

// 10s计数器和1s计数器
always @(posedge CLK or posedge ten_cnt_reset) begin
    if (ten_cnt_reset)
        ten_cnt <= 0;
    else
        ten_cnt <= ten_cnt + 1;
end
assign is_ten_full = &ten_cnt;

always @(posedge CLK or posedge one_cnt_reset) begin
    if (one_cnt_reset)
        one_cnt <= 0;
    else
        one_cnt <= one_cnt + 1;
end
assign is_one_full = &one_cnt;

// 状态机部分
// 主工作流程为INIT->START->INPUT->CHARGE->START->INPUT->INIT
// START状态仅用于将money,timer归零，输入数字和复位均在INPUT进行
always @(posedge CLK) begin
    current_state <= next_state;
end

always @(current_state) begin
    case (current_state)
        INIT:
            begin
                if (start)
                    next_state = START;
                else
                    next_state = INIT;
            end
        START:
            next_state = INPUT;
        INPUT:
            begin
                if (is_ten_full)
                    next_state = INIT;
                else if (!ok)
                    next_state = INPUT;
                else
                    next_state = CHARGE;
            end
        CHARGE:
            begin
                if (is_charge_over)
                    next_state = START;
                else
                    next_state = CHARGE;
            end
		default:
				next_state = INIT;
    endcase
end

always @(current_state) begin
    case (current_state)
        INIT:
            begin
                ten_cnt_reset = 1;
                one_cnt_reset = 1;
                hide_time_money = 1;
                hold_money = 0;
                reset_money = 0;
                set_by_money = 0;
				state_viewer = 4'b0001;
            end
        START:
            begin
                ten_cnt_reset = idle ? 0 : 1;
                one_cnt_reset = 1;
                hide_time_money = 0;
                hold_money = 0;
                reset_money = 1;
                reset_time = 1;
                set_by_money = 0;
				state_viewer = 4'b0010;
            end
        INPUT:
            begin
                ten_cnt_reset = (idle && is_charge_over) ? 0 : 1;
                one_cnt_reset = 1;
                hide_time_money = 0;
                hold_money = 0;
                reset_money = reset ? 1 : 0;
                reset_time = reset ? 1 : 0;
                set_by_money = 1;
				state_viewer = 4'b0100;
            end
        CHARGE:
            begin
                ten_cnt_reset = 1;
                one_cnt_reset = 0;
                hide_time_money = 0;
                hold_money = 1;
                reset_money = 0;
                set_by_money = 0;
				state_viewer = 4'b1000;
            end
    endcase
end

endmodule
