module program_counter (
    input  logic         clk,
    input  logic         rst_n,
    input  logic  [31:0] alu_output,
    input  logic         select_pc_value, // Select PC + 4 or ALU Output
    input  logic         branch_taken,
    output logic  [31:0] pc // Program Counter = Read Address
);

    logic select_bit_b_j;
    logic [31:0] pc_storage;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_storage <= '0;
        end else begin
    
            if (branch_taken || select_pc_value) begin
                pc_storage <= alu_output;
            end else begin
                pc_storage <= pc_storage + 4;
            end
        end
    end

    assign pc = pc_storage;

endmodule