module immediate_generator (
    input  logic        clk,
    input logic [31:0] current_instruction,
    output logic immediate_value
);

    always_comb begin
        op_code = current_instruction[6:0];
        funct3 = current_instruction[14:12];
        if (op_code == 3 || op_code == 19 || op_code == 103) begin
            instr_type <= I;
        end
        else if (op_code == 23 || op_code == 55) begin
            instr_type <= U;
        end
        else if (op_code == 35) begin
            instr_type <= S;
        end
        else if (op_code ==51) begin
            instr_type <= R;
        end
        else if (op_code == 99) begin
            instr_type <= B;
        end
        else if (op_code == 111) begin
            instr_type <= J;
        end
        else begin
            instr_type <= R; // If the op_code is not any of the defined
            // instruction types, the immediate generator does nothing, which
            // is what it does in the case of instr_type = R so I set it to R
        end

        if (instr_type == I) begin
            short_immed[11:0] <= current_instruction[31:20];
        end
        if (instr_type == U) begin
            short_immed[31:12] <= current_instruction[31:12];
        end
        if (instr_type == S) begin
            short_immed[11:5] <= current_instruction[31:25];
            short_immed[4:0] <= current_instruction[11:7];
        end
        if (instr_type == R) begin
            short_immed <= 0;
        end
        if (instr_type == B) begin
            short_immed[12] <= current_instruction[31];
            short_immed[10:5] <= current_instruction[30:25];
            short_immed[4:1] <= current_instruction[11:8];
            short_immed[11] <= current_instruction[7];
        end
        if (instr_type == J) begin
            short_immed[20] <= current_instruction[31];
            short_immed[10:1] <= current_instruction[30:21];
            short_immed[11] <= current_instruction[20];
            short_immed[19:12] <= current_instruction[19:12];
        end 

        if op_code == 3 begin // I
            // Sign Extend Y
            if short_immed[11] == 1 begin
                long_immed[31:12] <= 20'b11111111111111111111;
            end
            else begin
                long_immed[31:12] <= 20'b00000000000000000000;
            end
            long_immed[11:0] <= short_immed[11:0];
        end
        if op_code == 19 begin // I
            if funct3[2:1] == 01 begin
                // Sign Extend N
                long_immed[31:12] <= 20'b00000000000000000000;
                long_immed[11:1] <= short_immed;
            end
            else begin
                // Sign Extend Y
                if short_immed[11] == 1 begin
                    long_immed[31:12] <= 20'b11111111111111111111;
                end
                else begin
                    long_immed[31:12] <= 20'b00000000000000000000;
                end
                long_immed[11:0] <= short_immed[11:0];
            end
        end
        if op_code == 23 begin // U
            // Upper Immediate
            long_immed[11:0] <= 12'b000000000000;
            long_immed[31:12] <= short_immed[31:12];
        end
        if op_code == 35 begin // S
            // Sign extend Y
            if short_immed[11] == 1 begin
                long_immed[31:12] <= 20'b11111111111111111111;
            end
            else begin
                long_immed[31:12] <= 20'b00000000000000000000;
            end
            long_immed[11:0] <= short_immed[11:0];
        end
        if op_code == 51 begin // R
            // We do nothing
            long_immed <= 32'b00000000000000000000000000000000;
        end
        if op_code == 55 begin // U
            // Upper Immediate
            long_immed[11:0] <= 12'b000000000000;
            long_immed[31:12] <= short_immed[31:12];
        end
        if op_code == 99 begin // B
            // Sign Extend Y
            if short_immed[12] == 1 begin
                long_immed[31:13] <= 19'b1111111111111111111;
            end
            else begin
                long_immed[31:13] <= 19'b00000000000000000000;
            end
            long_immed[12:1] <= short_immed[12:1];
            long_immed[0] <= 1'b0;
        end
        if op_code == 103 begin // I
            // Sign Extend Y
            if short_immed[11] == 1 begin
                long_immed[31:12] <= 20'b11111111111111111111;
            end
            else begin
                long_immed[31:12] <= 20'b00000000000000000000;
            end
            long_immed[11:0] <= short_immed[11:0];
        end
        if op_code == 111 begin // J
            // Sign Extend Y
            if short_immed[20] == 1 begin
                long_immed[31:21] <= 11'b11111111111;
            end
            else begin
                long_immed[31:21] <= 11'b00000000000;
            end
            long_immed[20:1] <= short_immed[20:1];
            long_immed[0] <= 1'b0;
        end
    end

endmodule