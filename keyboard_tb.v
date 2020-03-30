
`timescale 10 us / 10 us
`define half_cycle 15
`define cycle 30

module keyboard_tb;
localparam CR3 = 4'b0111, CR2 = 4'b1011, CR1 = 4'b1101, CR0 = 4'b1110, CIDLE = 4'b0000, RIDLE = 4'b1111;
localparam IDLE = 5'b00001, PRESS_CHECK = 5'b00010, SCAN = 5'b00100, OUTPUT = 5'b01000, FREE_CHECK = 5'b10000;


    reg clock;
    reg[3:0] row;
    reg rst;
    wire[4:0] state_view;
    wire[3:0] data;
    wire[4:0] anti_shake_cnt_view;
    wire[2:0] col_scan_cnt_view;
    wire[3:0] col;
    wire start, reset, ok, idle;
    keyboard_sim keyboard_test(.CLK(clock), .row(row), .data(data), .start(start), .reset(reset), .ok(ok), .idle(idle), .rst(rst), .state_view(state_view), .anti_shake_cnt_view(anti_shake_cnt_view), .col(col), .col_scan_cnt_view(col_scan_cnt_view));
    always #`half_cycle clock = ~clock;
    initial
    begin
        row = RIDLE;
        clock = 0;
        rst = 1;
        #1 rst = 0;
        repeat (15)
        begin
            #`cycle row = RIDLE;
            #`cycle row = CR3; 
        end
        repeat (60)
        #`cycle row = CR3;
        repeat (15)
        begin
            #`cycle row = RIDLE;
            #`cycle row = CR3; 
        end
        #`half_cycle row = RIDLE;
        repeat (40)
            #`cycle;

        repeat (40)
            #`cycle;
        repeat (15)
        begin
            #`cycle row = RIDLE;
            #`cycle row = CR2; 
        end
        repeat (60)
        #`cycle row = CR2;
        repeat (15)
        begin
            #`cycle row = RIDLE;
            #`cycle row = CR2; 
        end
        #`half_cycle row = RIDLE;
        repeat (40)
            #`cycle;

        repeat (40)
            #`cycle;
        repeat (15)
        begin
            #`cycle row = RIDLE;
            #`cycle row = CR2; 
        end
        repeat (60)
        #`cycle 
            if (state_view == PRESS_CHECK || (state_view == OUTPUT) || (state_view == SCAN && col == CR0)) row = CR2;
            else row = RIDLE;
        repeat (15)
        begin
            #`cycle row = RIDLE;
            #`cycle row = CR2; 
        end
        #`half_cycle row = RIDLE;
        repeat (40)
            #`cycle;

        repeat (40)
            #`cycle;
        repeat (15)
        begin
            #`cycle row = RIDLE;
            #`cycle row = CR0; 
        end
        repeat (60)
        #`cycle 
            if (state_view == PRESS_CHECK || (state_view == OUTPUT) || (state_view == SCAN && col == CR0)) row = CR0;
            else row = RIDLE;
        repeat (15)
        begin
            #`cycle row = RIDLE;
            #`cycle row = CR0; 
        end
        #`half_cycle row = RIDLE;
        repeat (40)
            #`cycle;      
    end

endmodule
