module top #(
    parameter cycle_length;
)(
    input logic clk,
    output logic led,
    output logic red,
    output logic green,
    output logic blue,
);

    pc u1 (
        .clk        (clk),
        .alu_output (alu_output),
        .opcode     (opcode),
        .rs1v       (rs1v),
        .rs2v       (rs2v),
        .pc         (pc),
    )

    // Determine ALU output or PC into memory RA
    // ALU output into memory WA 
    // rs2v into WD
    memory u2 (
        .clk (clk),
        .write_mem (mem_write),
        .funct3 (func3),
        .write_address (write_address),
        .write_data (write_data),
        .read_address (read_address),
        .read_data (read_data),
        .led (led),
        .red (red),
        .green (green),
        .blue (blue)
    )

    // Determine rdv from imm, ALU output, rd, or PC + 4
    register_file u3 #(
        .source_register_1 (rs1),
        .source_register_2 (rs2),
        .destination_register (rd),
    )(
        .clk (clk),
        .write_enable (write_enable),
        .destination_value (rdv),
        .source_value_1 (rs1v),
        .source_value_2 (rs2v)
    )

    instruction_register u4 (
        .clk (clk),
        .read_data (read_data),
        .current_instruction (current_instruction),
        .rs1 (rs1),
        .rs2 (rs2),
        .rd (rd),
        .opcode (opcode),
        .func3 (fun3)
    )

    // Select either rs2v or imm into op2
    // Select either rs1 or PC into op1
    alu u5 #(

        )(
        .func3 (func3),
        .func7 (func7),
        .opcode (opcode),
        .op1 (op1),
        .op2 (op2),
        .result (alu_output),
    )

endmodule