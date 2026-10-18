`timescale 1ns/1ps
module tb_traffic;
    initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb_traffic); end
    reg clk=0, rst=1, flicker=0;
    always #5 clk=~clk;
    wire [3:0] red, yellow, green, left, walk_red, walk_green;
    traffic #(.CLK_HZ(4)) dut(clk, rst, flicker,
        red, yellow, green, left, walk_red, walk_green);
    integer i;

    initial begin
        repeat (2) @(posedge clk);
        @(negedge clk); rst=0;
        #1;
        if (green !== 4'b1000 || red !== 4'b0111) $fatal(1, "direction 0 green");
        if (walk_green !== 4'b0100) $fatal(1, "pedestrian green");

        /* One phase lasts CLK_HZ clocks. Check green, yellow, next direction. */
        repeat (11*4) @(posedge clk);
        #1;
        if (yellow !== 4'b1000 || green !== 0) $fatal(1, "vehicle yellow phase");
        repeat (2*4) @(posedge clk);
        #1;
        if (green !== 4'b0100 || red !== 4'b1011) $fatal(1, "direction 1 starts");

        @(negedge clk); flicker=1;
        repeat (2) @(posedge clk);
        #1;
        if (red !== 0 || green !== 0) $fatal(1, "flicker mode");
        @(negedge clk); flicker=0;
        repeat (2) @(posedge clk);
        #1;
        if (green !== 4'b1000) $fatal(1, "flicker reset sequence");
        $display("PASS traffic: sequence, yellow, pedestrian, flicker reset");
        $finish;
    end

    initial begin #100000; $fatal(1, "timeout"); end
endmodule
