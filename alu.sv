/*
arithetic logic unit module:

inputs:
    func3: 3 bits
    func7: 7 bits
    opcode: 7 bits
    op1: 32 bits
    op2: 32 bits

outputs:
    result: 32 bits

based on the func3 and func7, decide which operation to perform on the 2
inputs, then output the result. 
*/

module alu #(
    parameter logic ITYPE = 7'b0010011,
    parameter logic J_ITYPE = 7'b1100111,
    parameter logic RTYPE = 7'b0110011,
    parameter logic BTYPE = 7'b1100011
)
(


    input logic[2:0] func3,
    input logic func7,
    input logic[6:0] opcode,
    input logic[31:0] op1,
    input logic[31:0] op2,
    output logic[31:0] result
);

(
    // 3 possible states regarding func7 bit:
    // 00: func7 uninitialized
    // 10: func7[5] = 0
    // 11: func7[5] = 1
    logic f7 = 2'b00

    initial begin
        // handle func7, whether it is all 0, has a 1, for is unitialized
        if(func7 === 'bx) begin // this === will not work on fpga, only tb
            f7 <= 2'b00
        end 
        else if(func7 == 0) begin
            f7 <= 2'b10
        end
        else begin
            f7 <= 2'b11
        end

        


        

    end

    always_comb begin //add default statements
        // using the func3 and func7 input, performs the correct instruction
        case(func3)
            3'b000: begin 
                /* 
                func3 = 000:
                addi (f7 == 00) (opcode == ITYPE)
                add (f7 == 10) 
                beq (f7 == 00) (opcode == BTYPE)
                jalr (PC = op1 + Immed, rd = PC + 4) (opcode == J_ITYPE)
                */
                case(f7)
                    2'b00: begin
                        case(opcode)
                            ITYPE: begin
                                result = op1 + op2 //addi
                            end
                            BTYPE: begin
                                result = op1 + op2 //beq
                            end
                            J_ITYPE: begin
                                result = op1 + op2 //jalr 
                            end
                        endcase
                    end
                    2'b10: begin
                        result = op1 + op2 //add
                    end
                endcase
            end
            3'b001: begin
                /*
                func3 = 001:
                slli (f7 == 10) (opcode == ITYPE)
                sll (f7 == 10) (opcode == RTYPE)
                bne (f7 == 00)
                */
                case(f7)
                    2'b00: begin
                        result = op1 + op2 //bne
                    end
                    2'b10:begin
                        case(opcode)
                            ITYPE: begin
                                result = op1 << op2 //slli 
                            end
                            RTYPE: begin
                                result = op1 << op2 //sll
                            end
                        endcase
                    end
                endcase
            end
            3'b010: begin
                /*
                func3 = 010:
                slti (f7 == 00)
                slt (f7 == 10)
                */
                case(f7)
                    2'b00: begin
                        result = (op1 < op2) //slti, not sure if this is correct
                    end
                    2'b10: begin
                        result = (op1 < op2) //slt, not sure if this is correct
                    end
                endcase
            end
            3'b011: begin
                /*
                func3 = 011:
                sltiu (f7 == 00)
                sltu (f7 == 10)
                */
                case(f7)
                    2'b00:begin
                        result = (op1 < op2) //sltiu, not sure if this is correct
                    end
                    2'b10:begin
                        result = (op1 < op2) //sltu, not sure if this is correct
                    end
                endcase
            end
            3'b100: begin
                /*
                func3 = 100:
                xori (f7 == 00) (opcode == ITYPE)
                xor (f7 == 10)
                blt (f7 == 00) (opcode == BTYPE)
                */
                case(f7)
                    2'b00:begin
                        case(opcode)
                            ITYPE:begin
                                result = (op1 ^ op2) //xori
                            end
                            BTYPE:begin
                                result = op1 + op2 //blt
                            end
                        endcase
                    end
                    2'b10:begin
                        result = (op1 ^ op2) //xor
                    end
                endcase
            end
            3'b101: begin
                /*
                func3 = 101:
                srli (f7 == 10) (opcode == ITYPE)
                srai (f7 == 11) (opcode == ITYPE)
                srl (f7 == 10) (opcode == RTYPE)
                sra (f7 == 11) (opcode == RTYPE)
                bge (f7 == 00)
                */
                case(f7)
                    2'b00:begin
                        result = op1 + op2 //bge
                    end
                    2'b10:begin
                        case(opcode)
                            ITYPE: begin
                                result = (op1 >> op2) //srli
                            end
                            RTYPE:begin
                                result = (op1 >> op2) //srl
                            end
                        endcase
                    end
                    2'b11:begin
                        case(opcode)
                            ITYPE:begin
                                result = (op1 >>> op2) //srai
                            end
                            RTYPE:begin
                                result = (op1 >>> op2) //sra
                            end
                        endcase
                    end
                endcase
            end
            3'b110: begin
                /*
                func3 = 110:
                ori (f7 == 00) (opcode == ITYPE)
                or (f7 == 10)
                bltu (f7 == 00) (opcode == BTYPE)
                */
                case(f7)
                    2'b00: begin
                        case(opcode)
                            ITYPE: begin
                                result = op1 | op2 //ori
                            end
                            BTYPE: begin
                                result = op1 + op2 //bltu
                            end
                        endcase
                    end
                    2'b10:begin
                        result = op1 | op2 //or
                    end
                endcase
            end
            3'b111: begin
                /*
                func3 = 111:
                andi (f7 == 00) (opcode == ITYPE)
                and (f7 == 10)
                bgeu (f7 == 00) (opcode == BTYPE)
                */
                case(f7)
                    2'b00:begin
                        case(opcode)
                            ITYPE: begin
                                result = op1 & op2 //andi
                            end
                            BTYPE: begin
                                result = op1 + op2 //bgeu
                            end
                        endcase
                    end
                    2'b10:begin
                        result = op1 & op2 //and
                    end
                endcase
            end
        endcase
    end
)
endmodule


