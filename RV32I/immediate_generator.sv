module immediate_generator (
    input  logic clk,
    input  logic [31:0] current_instruction,
    input  logic [6:0] opcode,
    input  logic [2:0] func3,
    input  logic rst_n,
    output logic [31:0] immediate_value
);

    logic [31:0] short_immed;
    logic [31:0] long_immed;
    logic [6:0] func7;

    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n == 0) begin
            short_immed <= 32'd0;
            long_immed <= 32'd0;
            func7 <= 7'd0;
            immediate_value <= 32'd0;
        end
    end

    // TODO: Maybe splice outside of always_comb block?
    always_comb begin

        case (opcode)
            7'b0110111, 7'b0010111: begin // U-type (lui and auipc)
                short_immed[31:12] = current_instruction[31:12];
                short_immed[11:0] = 12'b0;
                long_immed = {short_immed[31:12], 12'b0}; // Upper immediate
            end
            7'b0000011: begin // I-type (load)
                short_immed[11:0] = current_instruction[31:20];
                long_immed = {{20{short_immed[11]}}, short_immed[11:0]}; // Sign extend
            end
            7'b1100111: begin // I-Type (jalr)
                short_immed[11:0] = current_instruction[31:20];
                long_immed = {{20{short_immed[11]}}, short_immed[11:0]}; // Sign extend
            end
            7'b0010011: begin // I-Type (ALU)
                case (func3)
                    3'b000, 3'b010, 3'b011, 3'b100, 3'b110, 3'b111: begin // addi, slti, sltiu, xori, ori, andi
                        short_immed[11:0] = current_instruction[31:20];
                        long_immed = {{20{short_immed[11]}}, short_immed[11:0]};
                    end
                    3'b001: begin // slli
                        short_immed[4:0] = current_instruction[24:20];
                        long_immed = {27'b0, short_immed[4:0]};
                    end
                    3'b101: begin // srli, srai
                        short_immed[4:0] = current_instruction[24:20]; 
                        func7 = current_instruction[31:25];
                        case (func7)
                            7'b0000000: long_immed = {27'b0, short_immed[4:0]}; // Zero-extend for srli
                            7'b0100000: long_immed = {27'b0, short_immed[4:0]}; // Zero-extend for srai
                            default: long_immed = 32'd0;
                        endcase
                    end

                endcase
            end
            7'b0100011: begin // S-Type (store)
                short_immed[11:5] = current_instruction[31:25];
                short_immed[4:0] = current_instruction[11:7];
                long_immed = {{20{short_immed[11]}}, short_immed[11:0]};
            end
            7'b1100011: begin // B-type (branch)
                short_immed[12] = current_instruction[31];
                short_immed[10:5] = current_instruction[30:25];
                short_immed[4:1] = current_instruction[11:8];
                short_immed[11] = current_instruction[7];
                long_immed = {{19{short_immed[12]}}, short_immed[12:1], 1'b0};
            end
            7'b1101111: begin // J-Type (hal)
                short_immed[20] = current_instruction[31];
                short_immed[10:1] = current_instruction[30:21];
                short_immed[11] = current_instruction[20];
                short_immed[19:12] = current_instruction[19:12];
                long_immed = {{11{short_immed[20]}}, short_immed[20:1], 1'b0};
            end
            7'b0110011: begin // R-type
                long_immed = 32'd0; // No immediate for R type
            end
            default: begin
                long_immed = 32'd0;
            end
        endcase

        immediate_value = long_immed;

    end
endmodule