module instruction_register (
    input  logic        clk,
    input  logic [31:0] read_data,
    output logic [31:0] current_instruction,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [6:0]  opcode,
    output logic [2:0]  func3
);

    always_ff @(posedge clk) begin
        current_instruction <= read_data;
        rs1                 <= current_instruction[19:15];
        rs2                 <= current_instruction[24:20];
        rd                  <= current_instruction[11:7];
        opcode              <= current_instruction[6:0];
        func3               <= current_instruction[14:12];
    end

endmodule
