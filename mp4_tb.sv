`timescale 10ns/10ns
`include "mp4.sv"

module mp4_tb;

    // Parameters
    logic clk = 0;
    logic LED;
    logic SW;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    mp4 u0 (
        .clk (clk),
        .LED (LED),
        .SW (SW),
        .RGB_R (RGB_R),
        .RGB_G (RGB_G),
        .RGB_B (RGB_B)
    );

    initial begin
        $dumpfile("mp4.vcd");
        $dumpvars(0, mp4_tb);
        SW = '0; #500ns; SW = '1;
        #5us
        $finish;
    end

    always begin
        #41ns
        clk = ~clk;
    end

    endmodule