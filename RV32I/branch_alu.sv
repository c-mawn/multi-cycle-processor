module branch_alu (
    input  logic         clk,
    input  logic         rst_n,
    input  logic  [6:0]  opcode,
    input  logic  [2:0]  func3,
    input  logic  [31:0] rs1v,
    input  logic  [31:0] rs2v,
    output logic         branch_taken
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            branch_taken <= 1'b0;
        end else begin

            branch_taken <= 1'b0;

            if (opcode == 7'b1100011) begin // check for B-type
                case (func3) // Check which B-type
                    3'b000: // beq =
                        branch_taken <= (rs1v == rs2v);
                    3'b001: // bne !=
                        branch_taken <= (rs1v != rs2v);
                    3'b100: // blt <
                        branch_taken <= ($signed(rs1v) < $signed(rs2v));
                    3'b101: // bge >=
                        branch_taken <= ($signed(rs1v) >= $signed(rs2v));
                    3'b110: // bltu < (unsigned)
                        branch_taken <= (rs1v < rs2v); // defaults to unsigned
                    3'b111: // bgeu > (unsigned)
                        branch_taken <= (rs1v >= rs2v); // defaults to unsigned
                endcase
            end
        end
    end

endmodule