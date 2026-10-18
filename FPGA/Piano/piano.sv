`timescale 1ns/1ps

module piano #(parameter integer CLK_HZ = 50_000_000)(
    input  wire       clk_50mhz,
    input  wire       rst_p,
    input  wire [7:0] key,
    output wire       piezo
);
    wire [31:0] frequency_hz;
    note_select u_note(key, frequency_hz);
    square_tone #(.CLK_HZ(CLK_HZ)) u_tone(
        clk_50mhz, rst_p, frequency_hz, piezo
    );
endmodule

module note_select(input wire [7:0] key, output reg [31:0] frequency_hz);
    always @* begin
        case (key)
            8'h80: frequency_hz = 262;
            8'h40: frequency_hz = 294;
            8'h20: frequency_hz = 330;
            8'h10: frequency_hz = 349;
            8'h08: frequency_hz = 392;
            8'h04: frequency_hz = 440;
            8'h02: frequency_hz = 494;
            8'h01: frequency_hz = 523;
            default: frequency_hz = 0;
        endcase
    end
endmodule

module square_tone #(parameter integer CLK_HZ = 50_000_000)(
    input  wire        clk_50mhz,
    input  wire        rst_p,
    input  wire [31:0] frequency_hz,
    output reg         tone
);
    reg [31:0] count;
    reg [31:0] previous_hz;
    wire [31:0] half_cycles = frequency_hz == 0 ? 1 :
                              CLK_HZ / (2 * frequency_hz);

    always @(posedge clk_50mhz) begin
        if (rst_p) begin
            count       <= 0;
            tone        <= 0;
            previous_hz <= 0;
        end else if (frequency_hz == 0 || frequency_hz != previous_hz) begin
            count       <= 0;
            tone        <= 0;
            previous_hz <= frequency_hz;
        end else if (count >= half_cycles - 1) begin
            count <= 0;
            tone  <= ~tone;
        end else begin
            count <= count + 1;
        end
    end
endmodule
