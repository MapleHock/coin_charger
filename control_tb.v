
`timescale 1 ms / 1 ms
`define half_cycle 1
`define cycle 2

module control_tb;
localparam ERROR_NUM = 4'b1111;
    reg clock;
    reg[3:0] data;
    reg start, reset, ok, idle;
    reg rst;
    wire[3:0] state_viewer;
    wire[7:0] money, timer;    
    control_sim control_test(.CLK(clock), .data(data), .rst(rst), .start(start), .reset(reset), .ok(ok),.idle(idle), .money(money), .timer(timer), .state_viewer(state_viewer));
    always #`half_cycle clock = ~clock;
    initial
    begin
        {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0001};
        clock = 0;
        rst = 0;
        #1 rst = 1;
        #1 rst = 0;
        repeat(3)
            #`cycle {data, start, reset, ok, idle} = {ERROR_NUM, 4'b1000};
        {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0001};
        repeat(3)
            #`cycle;
        
        repeat(5)
            #`cycle {data, start, reset, ok, idle} = {4'b0010, 4'b0000};
        {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0001};
        repeat(3)
            #`cycle;
        
        repeat(5)
            #`cycle {data, start, reset, ok, idle} = {4'b0010, 4'b0000};
        {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0001};
        repeat(3)
            #`cycle;

        repeat(5)
            #`cycle {data, start, reset, ok, idle} = {4'b0010, 4'b0100};
        {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0001};
        repeat(3)
            #`cycle;

        repeat(5000)
            #`cycle {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0001};

        repeat(3)
            #`cycle {data, start, reset, ok, idle} = {ERROR_NUM, 4'b1000};
        {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0001};
        repeat(3)
            #`cycle;
        
        repeat(5)
            #`cycle {data, start, reset, ok, idle} = {4'b0010, 4'b0000};
        {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0001};
        repeat(3)
            #`cycle;

        repeat(5)
            #`cycle {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0010};
        {data, start, reset, ok, idle} = {ERROR_NUM, 4'b0001};
        repeat(3)
            #`cycle;
    end

endmodule
