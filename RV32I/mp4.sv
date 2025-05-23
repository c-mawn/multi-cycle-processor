`include "memory.sv"
`include "instruction_register.sv"
`include "program_counter.sv"
`include "immediate_generator.sv"
`include "scheduler.sv"
`include "register_file.sv"
`include "select_bits.sv"
`include "alu.sv"
`include "branch_alu.sv"

module mp4 (
    input  logic clk,
    input  logic SW,
    output logic LED,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
    );

    logic [31:0] write_address;
    logic [31:0] read_address;
    logic [31:0] write_data;
    logic [31:0] read_data;
    logic [2:0]  func3;
    logic [31:0] read_address_buffered;
    logic [2:0]  func3_buffer;
    logic [2:0]  funct3_mem;
    logic wen_mem;

    // Set up the instruction cycle
    always_ff @(posedge clk) begin
        if (SW == '0) begin
            funct3_mem    <= 3'b010; // Set to read instruction
            read_address  <= 32'b0;
            write_address <= 32'b0;
        end 
    end

    logic [3:0] stage;

    scheduler scheduler (
        // Inputs
        .clk   (clk),
        .rst_n (SW),
        // Outputs
        .stage (stage)
    );

    // Stage 0 - Fetch
    always_ff @(posedge stage[0]) begin
        funct3_mem <= 3'b010; // Allow for reading instructions again
    end

    memory #(
        .INIT_FILE ("test.txt")
    ) mem (
        // Inputs
        .clk           (stage[0]),
        .write_mem     (wen_mem),
        .funct3        (funct3_mem),
        .write_address (write_address),
        .write_data    (write_data),
        .read_address  (read_address),  // PC value
        // Outputs
        .read_data     (read_data),     // the current instruction 
        .led           (LED),
        .red           (RGB_R),
        .green         (RGB_G),
        .blue          (RGB_B)
        );

    // Stage 1 - Decode
    logic [4:0] rs1, rs2, rd;
    logic [6:0] opcode;
    logic [6:0] func7;
    logic [31:0] current_instruction;

    instruction_register ir_module (
        // Inputs
        .clk       (stage[1]),
        .read_data (read_data),
        // Outputs
        .current_instruction (current_instruction),
        .func7     (func7),
        .rs1       (rs1),
        .rs2       (rs2),
        .rd        (rd),
        .opcode    (opcode),
        .func3     (func3_buffer)
    );

    // Only pass funct3 bits from instruction register to memory when it's a load or store instruction
    always_comb begin
        func3 = func3_buffer;
        if (opcode == 7'b0000011 || opcode == 7'b0100011) begin
            funct3_mem = func3;
        end
    end

    // Stage 2 - Execute
    logic select_op1;
    logic select_op2;
    logic wen_reg;
    logic [1:0] select_rdv;
    logic select_pc_value;
    logic select_address_src;

    select_bits select_bit (
        // Inputs
        .opcode             (opcode),
        .stage              (stage),
        // Outputs
        .wen_mem            (wen_mem),
        .select_op1         (select_op1),
        .select_op2         (select_op2),
        .wen_reg            (wen_reg),
        .select_rdv         (select_rdv),
        .select_pc_value    (select_pc_value),
        .select_address_src (select_address_src)
    );

    logic [31:0] op1, op2;
    logic [31:0] rdv;
    logic [31:0] rs1v, rs2v;
    logic [31:0] alu_output;
    logic [31:0] immediate_value;

    always_comb begin
        op1 = select_op1 ? rs1v : read_address_buffered;
        op2 = select_op2 ? rs2v : immediate_value;
        case (select_rdv)
            2'b00: rdv = read_address_buffered + 4; // TODO: Check this value
            2'b01: rdv = alu_output;
            2'b10: rdv = immediate_value;
            2'b11: rdv = read_data;
        endcase
        // select_pc_value; // I think PC already handles this logic
        read_address = select_address_src ? alu_output : read_address_buffered;
        write_data = rs2v;
        write_address = alu_output;
    end

    immediate_generator imm_gen (
        // Inputs
        .clk                 (stage[2]),
        .current_instruction (current_instruction),
        .opcode              (opcode),
        .func3               (func3),
        .rst_n               (SW),
        // Outputs
        .immediate_value     (immediate_value)
    );

    register_file reg_file (
        // Inputs
        .clk            (stage[2]),
        .write_register (wen_reg),
        .rst_n          (SW),
        .rs1            (rs1),
        .rs2            (rs2),
        .rd             (rd),
        .rdv            (rdv), // I think this writes back correctly? Not sure
        // Outputs
        .rs1v           (rs1v),
        .rs2v           (rs2v)
    );

    alu alu (
        // Inputs
        .func3  (func3),
        .opcode (opcode),
        .func7  (func7),
        .op1    (op1),
        .op2    (op2),
        // Outputs
        .result (alu_output)
    );

    logic branch_taken;

    branch_alu b_alu (
        // Inputs
        .clk          (stage[2]),
        .rst_n        (SW),
        .opcode       (opcode),
        .func3        (func3_buffer),
        .rs1v         (rs1v),
        .rs2v         (rs2v),
        // Outputs
        .branch_taken (branch_taken)
    );

    // Stage 3 - Writeback
    program_counter pc_module (
        // Inputs
        .clk              (stage[3]),
        .rst_n            (SW),
        .alu_output       (alu_output),
        .select_pc_value  (select_pc_value),
        .branch_taken     (branch_taken),
        // Outputs
        .pc               (read_address_buffered)
    );


endmodule