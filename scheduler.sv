module scheduler (
    input logic clk,
    input logic rst_n,
    output logic [3:0] stage
);

    logic [3:0] state;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= 0;
        end else begin
            case (state)
                4'b0000: state <= 4'b0001; // 0 - Fetch
                4'b0001: state <= 4'b0010; // 1 - Decode
                4'b0010: state <= 4'b0101; // 2 - Execute (change LSB to enable memory access twice)
                4'b0101: state <= 4'b1000; // 3 - Writeback (if memory accessed twice)
                4'b0100: state <= 4'b1000; // 3 - Writeback (if regular)
                4'b1000: state <= 4'b0001; // 0 - Fetch
            endcase
        end
    end 

    assign stage = state;

endmodule
