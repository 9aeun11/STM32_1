`timescale 1ns/1ps
// AD7908/AD7918/AD7928-style 16-bit interface, idle SCLK HIGH.
// DIN is prepared BEFORE falling SCLK; subsequent bits change on rising SCLK.
// DOUT's leading bit is available after CS falls. Capture each bit immediately
// before driving SCLK LOW, before the ADC advances DOUT to its next bit.
// HALF_CYCLES must be >= 1. Board default: 25 at 50 MHz -> 1 MHz SCLK.
module serial_frame16 #(parameter HALF_CYCLES=25)(
    input wire clk_50mhz,rst_p,start,
    input wire [15:0] tx_word,
    input wire miso,
    output reg sclk,cs_n,mosi,busy,done,
    output reg [15:0] rx_word
);
    reg [31:0] count;
    reg [4:0] bit_index;
    reg [15:0] tx_latched;
    always @(posedge clk_50mhz) begin
        if(rst_p) begin
            sclk<=1; cs_n<=1; mosi<=0; busy<=0; done<=0;
            count<=0; bit_index<=15; tx_latched<=0; rx_word<=0;
        end else begin
            done<=0;
            if(!busy) begin
                if(start) begin
                    cs_n<=0; busy<=1; count<=0; bit_index<=15;
                    tx_latched<=tx_word; rx_word<=0; mosi<=tx_word[15];
                end
            end else if(count==HALF_CYCLES-1) begin
                count<=0;
                if(sclk) begin
                    // Keep DIN unchanged at the ADC's sampling edge.
                    rx_word<={rx_word[14:0],miso};
                    sclk<=0;
                end else begin
                    sclk<=1;
                    if(bit_index==0) begin
                        // Hold CS LOW for a half-period after the final falling edge.
                        busy<=0; cs_n<=1; done<=1;
                    end else begin
                        bit_index<=bit_index-1'b1;
                        mosi<=tx_latched[bit_index-1'b1];
                    end
                end
            end else count<=count+1;
        end
    end
endmodule
