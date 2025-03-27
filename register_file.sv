module register_file #(
    parameter logic [4:0] source_register_1,
    parameter logic [4:0] source_register_2,
    parameter logic [4:0] destination_register
) (
    input logic clk,
    input logic write_enable,
    input logic [31:0] destination_value,
    output logic [31:0] source_value_1,
    output logic [31:0] source_value_2
);
    logic [31:0] register_memory [0:31]

    always_ff @(posedge clk) begin
        source_value_1 <= register_memory[source_register_1];
        source_value_2 <= register_memory[source_register_2];
    end

    always_ff @(negedge clk) begin
        if write_enable == 1
            register_memory[destination_register] <= destination_value;
    end

endmodule