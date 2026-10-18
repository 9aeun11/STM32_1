`timescale 1ns/1ps
module tb_piano;
    initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb_piano); end
    reg clk = 0;
    reg rst = 1;
    reg [7:0] key = 0;
    wire piezo;
    always #5 clk = ~clk;

    piano #(.CLK_HZ(10000)) dut(clk, rst, key, piezo);
    integer expected_hz [0:7];
    integer i, cycles;
    reg [31:0] selected_hz;
    wire [31:0] lookup_hz;
    note_select lookup(key, lookup_hz);

    initial begin
        expected_hz[0]=262; expected_hz[1]=294; expected_hz[2]=330;
        expected_hz[3]=349; expected_hz[4]=392; expected_hz[5]=440;
        expected_hz[6]=494; expected_hz[7]=523;
        repeat (2) @(posedge clk);
        @(negedge clk); rst=0;
        for (i=0; i<8; i=i+1) begin
            key = 8'h80 >> i;
            #1;
            if (lookup_hz !== expected_hz[i]) $fatal(1, "note lookup %0d", i);
            @(posedge clk); #1;
            if (piezo !== 0) $fatal(1, "tone must reset on note change");
            selected_hz = expected_hz[i];
            cycles = 10000 / (2 * selected_hz);
            repeat (cycles) @(posedge clk);
            #1;
            if (piezo !== 1) $fatal(1, "first half-cycle for note %0d", i);
            repeat (cycles) @(posedge clk);
            #1;
            if (piezo !== 0) $fatal(1, "second half-cycle for note %0d", i);
            @(negedge clk);
        end
        key = 8'hC0; #1;
        if (lookup_hz !== 0) $fatal(1, "multiple keys must be silent");
        repeat (3) @(posedge clk);
        #1;
        if (piezo !== 0) $fatal(1, "multiple keys tone");
        key = 0;
        repeat (3) @(posedge clk);
        #1;
        if (piezo !== 0) $fatal(1, "no-key tone");
        $display("PASS piano: note lookup, tone edges, silence");
        $finish;
    end

    initial begin
        #100000;
        $fatal(1, "timeout");
    end
endmodule
