`timescale 1ns/1ps
// Board top: the full 12-bit sample and data_valid remain observable in
// simulation; only the actual converter pins and 8 LEDs leave the FPGA.
module adc_board(
    input wire clk_50mhz, rst_p,
    input wire [2:0] add_sel,
    output wire adc_sclk, adc_ncs, adc_din,
    input wire adc_dout,
    output wire [7:0] led_out
);
    wire [11:0] sample;
    wire data_valid;
    adc u_adc(clk_50mhz, rst_p, add_sel,
              adc_sclk, adc_ncs, adc_din, adc_dout,
              sample, data_valid, led_out);
endmodule
