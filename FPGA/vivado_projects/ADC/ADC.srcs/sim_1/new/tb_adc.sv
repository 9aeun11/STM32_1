`timescale 1ns/1ps
module tb_adc;
    parameter HC=2;
    initial begin $dumpfile("wave.vcd"); $dumpvars(0, tb_adc); end
    reg clk=0,rst=1;
    always #5 clk=~clk;
    reg [2:0] channel=0;
    reg miso=0;
    wire sclk,cs_n,mosi,valid;
    wire [11:0] sample;
    wire [7:0] led;
    adc #(.HALF_CYCLES(HC)) dut(clk,rst,channel,sclk,cs_n,mosi,miso,led);
    assign sample = dut.sample;
    assign valid = dut.data_valid;
    reg [15:0] received_command,reply;
    reg [2:0] frame_channel,selected_channel=0;
    reg din_before_edge;
    integer received_bits=0,frames=0,k;
    time last_din_change;
    // Model normal-mode serial timing only, not power-up or analog conversion.
    // The current result belongs to the previously selected channel.
    always @(mosi) last_din_change=$time;
    always @(negedge clk) din_before_edge=mosi;
    always @(negedge cs_n) begin
        received_bits=0; received_command=0; frame_channel=channel;
        reply={1'b0,selected_channel,12'h123 + {selected_channel,8'h00}};
        miso=reply[15];
    end
    always @(negedge sclk) begin
        if(!rst && !cs_n) begin
            if(received_bits>=16) $fatal(1,"too many serial clocks");
            received_command={received_command[14:0],din_before_edge};
            received_bits=received_bits+1;
            // Model nonzero clock-to-output delay. Last edge releases DOUT.
            #1;
            if(last_din_change >= $time-1) $fatal(1,"DIN changed at falling SCLK");
            if(received_bits<16) miso=reply[15-received_bits];
            else miso=1'bz;
        end
    end
    always @(posedge cs_n) if(!rst) begin
        if(received_bits!=16) $fatal(1,"ADC frame length");
        if(received_command !== (16'hA370 | ({13'b0,frame_channel} << 10)))
            $fatal(1,"ADC command channel=%0d cmd=%h",frame_channel,received_command);
        selected_channel=received_command[12:10];
    end
    always @(posedge valid) begin
        #1;
        if(dut.rx_word !== reply) $fatal(1,"full RX word shifted: got=%h expected=%h",dut.rx_word,reply);
        if(sample !== reply[11:0] || led !== reply[11:4]) $fatal(1,"ADC sample");
        frames=frames+1;
    end
    initial begin
        repeat(2) @(negedge clk);
        if(cs_n!==1 || sclk!==1 || sample!==0) $fatal(1,"ADC reset");
        rst=0;
        for(k=0;k<8;k=k+1) begin
            wait(frames==k+1);
            @(negedge clk); channel=channel+1'b1;
        end
        // Complete one extra frame to observe the result for channel 7.
        wait(frames==9); @(negedge clk); rst=1;
        @(posedge clk); #1;
        if(cs_n!==1 || sclk!==1 || sample!==0 || valid!==0) $fatal(1,"reset after data");
        $display("PASS ADC: all 8 channel commands, DIN setup, 16-bit RX, channel latency, LED, reset (HC=%0d)",HC);
        $finish;
    end
    initial begin #1000000; $fatal(1,"timeout"); end
endmodule
