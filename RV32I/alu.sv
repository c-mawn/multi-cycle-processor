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
    parameter logic[6:0] ITYPE = 7'b0010011,
    parameter logic[6:0] J_ITYPE = 7'b1100111,
    parameter logic[6:0] RTYPE = 7'b0110011,
    parameter logic[6:0] BTYPE = 7'b1100011,
    parameter logic[6:0] UTYPE = 7'b0010111,
    parameter logic[6:0] LTYPE = 7'b0000011,
    parameter logic[6:0] STYPE = 7'b0100011,
    parameter logic[6:0] JTYPE = 7'b1101111
)
(


    input logic[2:0] func3,
    input logic[6:0] opcode,
    input logic func7,
    input logic[31:0] op1,
    input logic[31:0] op2,
    output logic[31:0] result
);
    logic[1:0] fn7;
    assign fn7 = ((opcode == RTYPE) ? {func7,1'b0} : 2'b01);
    // 3 possible states regarding func7 bit:
    // 00: func7 uninitialized
    // 10: func7[5] = 0
    // 11: func7[5] = 1
    logic[1:0] f7 = 2'b00;

    always_comb begin
        // handle func7, whether it is all 0, has a 1, for is unitialized
        if(fn7 == 2'b01) begin
            f7 = 2'b00; //func7 not r type
        end 
        else if(fn7 == 2'b00) begin
            f7 = 2'b10; //func7 r type and 0
        end
        else if(fn7 == 2'b10) begin
            f7 = 2'b01; //func7 r type and 1
        end
        else begin
            f7 = 2'b11; //used for debugging, should never happen
        end
    end

    always_comb begin 
        result = 32'd0;
        // using the func3 and func7 input, performs the correct instruction
        
        case(func3)
            3'b000: begin 
                /* 
                func3 = 000:
                addi (f7 == 00) (opcode == ITYPE)
                lb (f7 == 00) (opcode == LTYPE)
                add (f7 == 10) 
                beq (f7 == 00) (opcode == BTYPE)
                jalr (PC = op1 + Immed, rd = PC + 4) (opcode == J_ITYPE)
                */
                case(f7)
                    2'b00: begin
                        case(opcode)
                            ITYPE: begin
                                result = op1 + op2; //addi
                            end
                            BTYPE: begin
                                result = op1 + op2; //beq
                            end
                            LTYPE: begin
                                result = op1 + op2; //lb
                            end
                            STYPE: begin
                                result = op1 + op2; //sb
                            end
                            J_ITYPE: begin
                                result = op1 + op2; //jalr 
                                result[0] = 1'b0; //set the LSB to 0
                            end
                            default: result = 32'd0;
                        endcase
                    end
                    2'b10: begin
                        result = op1 + op2; //add
                    end
                    2'b01: begin
                        result = op1 - op2; //sub
                    end
                    default: result = 32'd0;
                endcase
            end
            3'b001: begin
                /*
                func3 = 001:
                slli (f7 == 10) (opcode == ITYPE)
                sll (f7 == 10) (opcode == RTYPE)
                bne (f7 == 00) (opcode == BTYPE)
                lh (f7 == 00) (opcode == LTYPE)
                */
                case(f7)
                    2'b00: begin
                        case(opcode)
                            BTYPE: begin
                                result = op1 + op2; //bne 
                            end
                            LTYPE: begin
                                result = op1 + op2; //lh
                            end
                            STYPE: begin
                                result = op1 + op2; //sh
                            end
                            ITYPE: begin
                                result = op1 << op2; //slli 
                            end
                            default: result = 32'd0;
                        endcase
                    end
                    2'b10:begin
                        case(opcode)
                            RTYPE: begin
                                result = op1 << op2; //sll
                            end
                            default: result = 32'd0;
                        endcase
                    end
                    default: result = 32'd0;
                endcase
            end
            3'b010: begin
                /*
                func3 = 010:
                slti (f7 == 00) (opcode == ITYPE)
                slt (f7 == 10)
                lw (f7 == 00) (opcode == LTYPE)
                */
                case(f7)
                    2'b00: begin
                        case(opcode)
                            ITYPE: begin
                                result = (op1 < op2); //slti
                            end
                            LTYPE: begin
                                result = op1 + op2; //lw
                            end
                            STYPE: begin
                                result = op1 + op2; //sw
                            end
                            default: result = 32'd0;
                        endcase
                    end
                    2'b10: begin
                        result = (op1 < op2); //slt
                    end
                    default: result = 32'd0;
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
                        result = (op1 < op2); //sltiu, not sure if this is correct
                    end
                    2'b10:begin
                        result = (op1 < op2); //sltu, not sure if this is correct
                    end
                    default: result = 32'd0;
                endcase
            end
            3'b100: begin
                /*
                func3 = 100:
                xori (f7 == 00) (opcode == ITYPE)
                xor (f7 == 10)
                blt (f7 == 00) (opcode == BTYPE)
                lbu (f7 == 00) (opcode == LTYPE)
                */
                case(f7)
                    2'b00:begin
                        case(opcode)
                            ITYPE:begin
                                result = (op1 ^ op2); //xori
                            end
                            BTYPE:begin
                                result = op1 + op2; //blt
                            end
                            LTYPE:begin
                                result = op1 + op2; //lbu
                            end
                            default: result = 32'd0;
                        endcase
                    end
                    2'b10:begin
                        result = (op1 ^ op2); //xor
                    end
                    default: result = 32'd0;
                endcase
            end
            3'b101: begin
                /*
                func3 = 101:
                srli (f7 == 10) (opcode == ITYPE)
                srai (f7 == 11) (opcode == ITYPE)
                srl (f7 == 10) (opcode == RTYPE)
                sra (f7 == 11) (opcode == RTYPE)
                bge (f7 == 00) (opcode == BTYPE)
                lhu (f7 == 00) (opcode == LTYPE)
                */
                case(f7)
                    2'b00:begin
                        case(opcode)
                            BTYPE: begin
                                result = op1 + op2; //bge
                            end
                            LTYPE:begin
                                result = op1 + op2; //lhu
                            end
                            ITYPE: begin
                                case(func7)
                                    1'b0:result = (op1 >> op2);//srli
                                    1'b1:result = ($signed(op1) >>> $signed(op2)); //srai
                                    default: result = 32'd0;
                                endcase                                
                            end
                            default: result = 32'd0;
                        endcase
                    end
                    2'b10: begin
                        result = (op1 >> op2); //srl
                    end
                    2'b01:begin
                        result = ($signed(op1) >>> $signed(op2)); //sra
                    end
                    default: result = 32'd0;
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
                                result = op1 | op2; //ori
                            end
                            BTYPE: begin
                                result = op1 + op2; //bltu
                            end
                            default: result = 32'd0;
                        endcase
                    end
                    2'b10:begin
                        result = op1 | op2; //or
                    end
                    default: result = 32'd0;
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
                                result = op1 && op2; //andi
                            end
                            BTYPE: begin
                                result = op1 + op2; //bgeu
                            end
                            default: result = 32'd0;
                        endcase
                    end
                    2'b10:begin
                        result = op1 && op2; //and
                    end
                    default: result = 32'd0;
                endcase
            end
            default: result = 32'd0;
        endcase
        if(opcode == UTYPE) begin result = op1+op2; end
        if(opcode == JTYPE) begin result = op1+op2; end
    end
endmodule


