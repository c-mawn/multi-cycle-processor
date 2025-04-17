module program_counter (
    input  logic         clk,
    input  logic         rst_n,
    input  logic  [31:0] alu_output,
    input  logic  [6:0]  opcode,
    input  logic  [2:0]  func3,
    input  logic  [31:0] rs1v,
    input  logic  [31:0] rs2v,
    input  logic         select_pc_value, // Select PC + 4 or ALU Output
    output logic  [31:0] pc, // Program Counter = Read Address
    output logic  [31:0] next_pc
);

    logic select_bit_b_j;
    logic [31:0] pc_storage;
    logic [31:0] pc_4;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_storage <= '0;
            select_bit_b_j <= '0;
        end else begin
            select_bit_b_j <= '0;
            pc_4 <= pc_storage + 4; // Current PC + 4

            if (opcode == 7'b1100011) begin // check for B-type
                case (func3) // Check which B-type
                    3'b000: // 000 beq =
                        select_bit_b_j <= (rs1v == rs2v);
                    3'b001: // 001 bne !=
                        select_bit_b_j <= (rs1v != rs2v);
                    3'b100: // 100 blt <
                        select_bit_b_j <= (rs1v < rs2v);
                    3'b101: // 101 bge >=
                        select_bit_b_j <= (rs1v >= rs2v);
                    3'b110: // 110 bltu < unsigned
                        select_bit_b_j <= (rs1v < rs2v);
                    3'b111: // 111 bgeu > unsigned
                        select_bit_b_j <= (rs1v >= rs2v);
                endcase
            end else if (opcode == 7'b1100111 || opcode == 7'b1101111) begin // check for jalr and jal
                select_bit_b_j <= 1'b1;
            end

            if (select_bit_b_j || select_pc_value) begin
                pc_storage <= alu_output;
            end else begin
                pc_storage <= pc_storage + 4;
            end
        end
    end

    assign pc = pc_storage;
    assign next_pc = pc_4;

endmodule