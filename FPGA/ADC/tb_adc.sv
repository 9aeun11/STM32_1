`timescale 1ns/1ps
module tb_adc;
    initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb_adc); end
    reg clk=0, rst=1;
    reg [2:0] channel=3'b010;
    reg adc_dout=0;
    always #5 clk=~clk;

    wire sclk, cs_n, din, valid;
    wire [11:0] sample;
    wire [7:0] led;
    adc #(.HALF_CYCLES(2)) dut(
        clk, rst, channel, sclk, cs_n, din, adc_dout, sample, valid, led
    );

    reg [15:0] reply=16'hA5C3;
    reg [15:0] command_seen=0;
    integer rx_index=15;
    integer bit_count=0;
    integer frame_count=0;
    wire [15:0] expected_command = {3'b101, 3'b010, 2'b11, 1'b0, 3'b111, 4'b0000};

    always @(negedge cs_n) begin
        rx_index = 15;
        bit_count = 0;
        command_seen = 0;
    end
    always @(negedge sclk) begin
        if (!cs_n) adc_dout = reply[rx_index];
    end
    always @(posedge sclk) begin
        if (!rst && bit_count < 16) begin
            command_seen = {command_seen[14:0], din};
            bit_count = bit_count + 1;
            rx_index = rx_index - 1;
        end
    end
    always @(posedge valid) begin
        #1;
        if (command_seen !== expected_command) $fatal(1, "ADC command bits");
        if (sample !== 12'h5C3) $fatal(1, "ADC sample %h", sample);
        if (led !== 8'h5C) $fatal(1, "ADC LED mapping %h", led);
        frame_count = frame_count + 1;
    end

    initial begin
        repeat (3) @(posedge clk);
        @(negedge clk); rst=0;
        wait (frame_count == 1);
        $display("PASS ADC: command, 12-bit sample, LED mapping");
        $finish;
    end
    initial begin #100000; $fatal(1, "timeout"); end
endmodule
