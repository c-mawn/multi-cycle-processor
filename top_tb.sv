`timescale 10ns/10ns
`include "mp4.sv"

module top_tb;

    // Parameters
    logic clk = 0;
    logic LED;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    top u0 (
        .clk (clk),
        .led (LED),
        .red (RGB_R),
        .green (RGB_G),
        .blue (RGB_B)
    );

    initial begin
        $dumpfile("mp4.vcd");
        $dumpvars(0, mp4_tb);
        #100ms
        $finish;
    end

    always begin
        #41ns
        clk = ~clk;
    end

    endmodule