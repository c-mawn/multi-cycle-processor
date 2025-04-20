module instruction_register (
    input  logic        clk,
    input  logic [31:0] read_data,
    output logic [31:0] current_instruction,
    output logic [6:0]  func7,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [6:0]  opcode,
    output logic [2:0]  func3
);

    always_ff @(posedge clk) begin
        current_instruction <= read_data;
    end

    assign { func7, rs2, rs1, func3, rd, opcode } = current_instruction;

endmodule
