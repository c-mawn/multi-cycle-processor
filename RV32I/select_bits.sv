module select_bits (
    input  logic [6:0] opcode,
    input  logic [3:0] stage,
    output logic       wen_mem,
    output logic       select_op1,
    output logic       select_op2,
    output logic       wen_reg,
    output logic [1:0] select_rdv,
    output logic       select_pc_value,
    output logic       select_address_src
);

    always_comb begin
        case (opcode)
            7'b0110011: begin // R-Type
                wen_mem            = 1'b0;
                select_op1         = 1'b1;
                select_op2         = 1'b1;
                wen_reg            = 1'b1;
                select_rdv         = 2'b01;
                select_pc_value    = 1'b0;
                select_address_src = 1'b0;
            end
            7'b0010011: begin // I-Type (ALU)
                wen_mem            = 1'b0;
                select_op1         = 1'b1;
                select_op2         = 1'b0;
                wen_reg            = 1'b1;
                select_rdv         = 2'b01;
                select_pc_value    = 1'b0;
                select_address_src = 1'b0;
            end
            7'b0000011: begin // I-Type (load)
                wen_mem            = 1'b0;
                select_op1         = 1'b1;
                select_op2         = 1'b0;
                wen_reg            = 1'b1;
                select_rdv         = 2'b11;
                select_pc_value    = 1'b0;
                select_address_src = stage[2]; // RA depends on the stage
            end
            7'b1101111: begin // J-Type (jal)
                wen_mem            = 1'b0;
                select_op1         = 1'b0;
                select_op2         = 1'b0;
                wen_reg            = 1'b1;
                select_rdv         = 2'b00;
                select_pc_value    = 1'b1;
                select_address_src = 1'b0;
            end
            7'b0100011: begin // S-Type
                wen_mem            = 1'b1;
                select_op1         = 1'b1;
                select_op2         = 1'b0;
                wen_reg            = 1'b0;
                select_rdv         = 2'b00; // Doesn't matter
                select_pc_value    = 1'b0;
                select_address_src = 1'b0;
            end
            7'b0110111: begin // U-Type (lui)
                wen_mem            = 1'b0;
                select_op1         = 1'b0; // Doesn't matter
                select_op2         = 1'b0; // Doesn't matter
                wen_reg            = 1'b1;
                select_rdv         = 2'b10;
                select_pc_value    = 1'b0;
                select_address_src = 1'b0;
            end
            7'b0010111: begin // U-Type (auipc)
                wen_mem            = 1'b0;
                select_op1         = 1'b0;
                select_op2         = 1'b0;
                wen_reg            = 1'b1;
                select_rdv         = 2'b01;
                select_pc_value    = 1'b0;
                select_address_src = 1'b0;
            end
            7'b1100111: begin // jalr
                wen_mem            = 1'b0;
                select_op1         = 1'b1;
                select_op2         = 1'b0;
                wen_reg            = 1'b1;
                select_rdv         = 2'b00;
                select_pc_value    = 1'b1;
                select_address_src = 1'b0;
            end
            7'b1100011: begin // B-Type
                wen_mem            = 1'b0;
                select_op1         = 1'b0;
                select_op2         = 1'b0;
                wen_reg            = 1'b0;
                select_rdv         = 2'b00; // Doesn't matter
                select_pc_value    = 1'b0; // Another select-bit is decided in PC
                select_address_src = 1'b0;
            end
            default: begin
                wen_mem            = 1'b0;
                select_op1         = 1'b1;
                select_op2         = 1'b1;
                wen_reg            = 1'b0;
                select_rdv         = 2'b00; // Doesn't matter
                select_pc_value    = 1'b0;
                select_address_src = 1'b0;
            end
        endcase
    end

endmodule