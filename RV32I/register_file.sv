module register_file (
    input  logic clk,
    input  logic write_register,
    input  logic rst_n,
    input  logic [4:0] rs1,
    input  logic [4:0] rs2,
    input  logic [4:0] rd,
    input  logic [31:0] rdv,
    output logic [31:0] rs1v,
    output logic [31:0] rs2v
);
    // logic [31:0] register_memory [0:31]; 
    logic [31:0][31:0] register_memory;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 32; i++) begin
                register_memory[i] = 32'd0; // Initialize all registers to 0
            end
        end
    end

    always_comb begin
        rs1v = register_memory[rs1];
        rs2v = register_memory[rs2];
    end

    always_ff @(negedge clk) begin // kind of a hack because yes.
        if (write_register) begin
            if (rd > 0) begin
                register_memory[rd] <= rdv;
            end
        end
    end

endmodule