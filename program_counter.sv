module program_counter (
    // Inputs and Outputs
    input  logic  [31:0] alu_output,
    input  logic         clk,
    input  logic  [6:0]  opcode,
    input  logic  [2:0]  func3,
    input  logic  [31:0] rs1v,
    input  logic  [31:0] rs2v,
    output logic  [31:0] pc
);

// Decide select bits
logic select_bit;

always_ff @(posedge clk) begin

    select_bit <= 1'b0;

    if (opcode == 7'b1100011) begin // check for B-type
        case (func3) // Check which B-type
            3'b000: // 000 beq =
                select_bit <= (rs1v == rs2v);
            3'b001: // 001 bne !=
                select_bit <= (rs1v != rs2v);
            3'b100: // 100 blt <
                select_bit <= (rs1v < rs2v);
            3'b101: // 101 bge >=
                select_bit <= (rs1v >= rs2v);
            3'b110: // 110 bltu < unsigned
                select_bit <= (rs1v < rs2v);
            3'b111: // 111 bgeu > unsigned
                select_bit <= (rs1v >= rs2v);
        endcase
    end

    if (opcode == 7'1100111) begin // check for jalr
        select_bit <= 1'b1;
    end

    case (select_bit)
        1'b0: 
            pc <= pc + 4;
        1'b1: 
            pc <= alu_output;
    endcase
end

endmodule