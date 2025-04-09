module top #(
    parameter cycle_length;
)(
    input logic clk,
    output logic led,
    output logic red,
    output logic green,
    output logic blue,
);

    logic [31:0] alu_output;
    logic [6:0] opcode;
    logic [31:0] rs1v, rs2v, pc_value;
    logic [2:0] func3;
    logic [6:0] func7;
    logic [31:0] write_address, read_address;
    logic [31:0] read_data, write_data;
    logic [4:0] rs1, rs2, rd;
    logic [31:0] rdv;
    logic [31:0] current_instruction;
    logic [31:0] immediate_value;


    logic [7:0] selection_string;
    logic write_enable_register;
    logic select_alu_op1;
    logic select_alu_op2;
    logic write_enable_memory;
    logic [1:0] select_rdv;
    logic select_pc_value;
    logic select_address_source;

    logic [31:0] registers [31:0]; // Create 32 32-bit registers

    initial begin
        for (int i=0, i < 32, i++) begin
            registers[i] = 32'd0; // Set each register value to 32 0s
        end
        read_address = 32'b0;
        func3 = 3'b010;
    end

    always_ff @(posedge clk) begin
        case (opcode)
            7'b0110011: selection_string <= 8'b11100100; // R-Type
            7'b0010011: selection_string <= 8'b1100010x; // I-Type - Majority
            7'b0000011: selection_string <= 8'b11001101; // I-Type - Load
            7'b1101111: selection_string <= 8'b10000010; // J-Type (jal)
            7'b0100011: selection_string <= 8'b0101xx01; // S-Type
            7'b0110111: selection_string <= 8'b1xx01000; // U-Type - lui
            7'b0010111: selection_string <= 8'b10000101; // U-Type - auipc
            7'b1100111: selection_string <= 8'b11000010; // jalr
            7'b1100011: selection_string <= 8'b0110xxxx; // B-Type
            default:    selection_string <= 8'b11100100;
        endcase
        write_enable_register <= selection_string[7];
        select_alu_op1        <= selection_string[6];
        select_alu_op2        <= selection_string[5];
        write_enable_memory   <= selection_string[4];
        select_rdv            <= selection_string[3:2];
        select_pc_value       <= selection_string[1];
        select_address_source <= selection_string[0];
    end

    always_comb begin
        // write_enable_register = write_enable_register; // Enable signal logic is built into memory
        op1 = select_alu_op1 ? rs1v : pc_value; // Select rs1v if select_alu_op1 is 1, otherwise select pc_value
        op2 = select_alu_op2 ? rs2v : immediate_value;
        // write_enable_memory = write_enable_memory; // Enable signal logic is built into program counter
        case (select_rdv)
            2'b00: rdv <= pc_value;
            2'b01: rdv <= alu_output;
            2'b10: rdv <= immediate_value;
            2'b11: rdv <= read_data;
        endcase
        // select_pc_value = select_pc_value; // Selection logic is built into program counter
        read_address = select_address_source ? alu_output : pc_value;
    end

    always_ff @(posedge clk) begin
        write_data <= rs2v;
        write_address <= alu_output;
    end

    // Processor Logic Begin

    // Determine ALU output or PC into memory RA
    // ALU output into memory WA 
    // rs2v into WD

    program_counter program_count (
        .clk        (clk),
        .alu_output (alu_output),
        .opcode     (opcode),
        .rs1v       (rs1v),
        .rs2v       (rs2v),
        .select_pc_value (select_pc_value),
        .pc         (pc_value),
    )

    memory mem #(
        .INIT_FILE ("test.txt")
    )(
        .clk (clk),
        .write_mem (write_enable_memory),
        .funct3 (func3),
        .write_address (write_address),
        .write_data (write_data),
        .read_address (read_address),
        .read_data (read_data), // This is the current instruction
        .led (led),
        .red (red),
        .green (green),
        .blue (blue)
    )

    instruction_register instruction_reg (
        .clk (clk),
        .read_data (read_data),
        .current_instruction (current_instruction),
        .rs1 (rs1),
        .rs2 (rs2),
        .rd (rd),
        .opcode (opcode),
        .func3 (fun3)
    )

    // Determine rdv from imm, ALU output, rd, or PC + 4
    register_file reg_file #(
        .source_register_1 (rs1),
        .source_register_2 (rs2),
        .destination_register (rd),
    )(
        .clk (clk),
        .write_enable (write_enable_register),
        .destination_value (rdv),
        .source_value_1 (rs1v),
        .source_value_2 (rs2v)
    )

    // Select either rs2v or imm into op2
    // Select either rs1 or PC into op1
    alu alu #(

        )(
        .func3 (func3),
        .func7 (func7),
        .opcode (opcode),
        .op1 (op1),
        .op2 (op2),
        .result (alu_output),
    )

    immediate_generator imm_gen (
        .clk (clk),
        .current_instruction (current_instruction),
        .immediate_value (immediate_value)

    )

endmodule