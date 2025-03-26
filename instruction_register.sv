module instruction_register #(
    parameter logic [31:0] read_data
) (
    input logic clk,
    output logic [31:0] current_data
);

    always_ff @(posedge clk) begin
        current_data <= read_data;
    end

endmodule
