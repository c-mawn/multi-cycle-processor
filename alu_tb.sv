`timescale 10ns/10ns
`include "alu.sv"

module alu_tb;

    // Parameters
    logic clk = 0;
    logic [31:0]result;
    logic [2:0]func3_wire;
    logic func7_wire;
    logic [6:0]opcode_wire;
    logic [31:0]op1_wire;
    logic [31:0]op2_wire; 

    alu alu0 (
        .func3 (func3_wire),
        .func7 (func7_wire),
        .opcode (opcode_wire),
        .op1 (op1_wire),
        .op2 (op2_wire)
        //.result (result)
    );

    initial begin
        
        func3_wire = 3'b000;
        func7_wire = 1'b1;
        opcode_wire = 7'b0110011;
        op1_wire = 32'h00123456;
        op2_wire = 32'h00123458;
        
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);
        #100ms
        $finish;
    end

    always begin
        #41ns
        clk = ~clk;
    end

    endmodule