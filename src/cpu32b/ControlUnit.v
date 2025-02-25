`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/13/2024 06:47:58 PM
// Design Name: 
// Module Name: ControlUnit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ControlUnit(
    // from instr mem
    input wire [6:0] opcode,
    output reg branch, MemRead, MemtoReg, MemWrite, ALUsrc, ALUsrc1, RegWrite, ResultSrc, PCsrc,
    output reg [3:0] ALUop,
    output reg [2:0] immsel,
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire [4:0] rs1, rs2,
    input wire brEq, brLt
    );
    
    always @(*) begin
        // Default values for control signals
        branch <= 0;
        immsel <= 3'b000;
        MemRead <= 0;
        MemtoReg <= 0;
        MemWrite <= 0;
        ALUsrc <= 0;
        ALUsrc1 <= 0;
        ResultSrc <= 0;
        RegWrite <= 0;
        ALUop <= 4'b0000;
        PCsrc <= 0;

        case (opcode)
            7'b0110011: begin  // R-type instruction (e.g., add, sub, etc.)
                branch <= 0;
                MemRead <= 0;
                MemtoReg <= 0;
                ALUsrc <= 0;    // Use registers, not immediate
                ALUsrc1 <= 0;
                RegWrite <= 1;  // Write to register
                case (funct3)
                    3'b000: begin  // ADD or SUB
                        case (funct7)
                            7'b0000000: ALUop <= 4'b0000;  // ADD
                            7'b0100000: ALUop <= 4'b0001;  // SUB
                        endcase
                    end
                    3'b100: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b0110; //XOR
                        endcase 
                    end
                    3'b110: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b0101; //OR
                        endcase 
                    end
                    3'b111: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b0100; //AND
                        endcase 
                    end
                    3'b001: begin  
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b1001; //SLL
                        endcase 
                    end
                    3'b101: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b1010; //SRL
                            7'b0100000: ALUop <= 4'b1011; //SRA
                        endcase
                    end
                    3'b010: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b1101; //SLT
                        endcase
                    end
                    3'b011: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b1110; //SLTU
                        endcase
                    end
                    default: ALUop <= 4'bxxxx;  // Undefined operation
                endcase
            end
            
            7'b0010011: begin
                branch <= 0;
                MemRead <= 0;
                MemtoReg <= 0;   // Select data from memory
                ALUsrc <= 1;     // Use immediate for ALU input
                RegWrite <= 1;   // Write to register
                ALUop <= 4'b0000;
                immsel <= 3'b000;
                case (funct3)
                    3'b000: begin  // ADD or SUB
                        case (funct7)
                            7'b0000000: ALUop <= 4'b0000;  // ADDI
                        endcase
                    end
                    3'b100: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b0110; //XORI
                        endcase 
                    end
                    3'b110: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b0101; //ORI
                        endcase 
                    end
                    3'b111: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b0100; //ANDI
                        endcase 
                    end
                    3'b001: begin  
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b1001; //SLLI
                        endcase 
                    end
                    3'b101: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b1010; //SRLI
                            7'b0100000: ALUop <= 4'b1011; //SRAI
                        endcase
                    end
                    3'b010: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b1101; //SLTI
                        endcase
                    end
                    3'b011: begin 
                        case (funct7) 
                            7'b0000000: ALUop <= 4'b1110; //SLTUI
                        endcase
                    end
                    default: ALUop <= 4'bxxxx;  // Undefined operation
                endcase
            end
            
            7'b0000011: begin  // Load (e.g., LW)
                branch <= 0;
                MemRead <= 1;
                MemtoReg <= 1;    // Select data from memory
                ALUsrc <= 1;      // Use immediate for ALU input
                RegWrite <= 1;    // Write to register
                ALUop <= 4'b0000; // Perform ADD to calculate address
                immsel <= 3'b000;  // Use I-type immediate               
            end

            7'b0100011: begin  // Store (e.g., SW)
                branch <= 0;
                MemRead <= 0;
                MemWrite <= 1;
                ALUsrc <= 1;     // Use immediate for address calculation
                RegWrite <= 0;   // No register write for store
                ALUop <= 4'b0000; // Perform ADD to calculate address
                immsel <= 3'b001;  // Use S-type immediate
            end
            
            7'b0110111: begin  // LUI instruction
                branch <= 0;
                MemRead <= 0;
                MemtoReg <= 0;
                MemWrite <= 0;
                ALUsrc <= 1;          // Use immediate for ALU input
                RegWrite <= 1;        // Write to register
                ResultSrc <= 1;       // Select immediate value as result
                ALUop <= 4'b0000;     // No operation needed in ALU for LUI
                immsel <= 3'b100;     // Select 20-bit immediate shifted to upper bits
            end

            // Example for branch instruction (e.g., BEQ):
            7'b1100011: begin  // Branch instructions
                ALUsrc <= 1;  // Both operands come from registers
                ALUsrc1 <= 1;
                immsel <= 3'b010;  // Branch immediate
                RegWrite <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                case (funct3)
                    3'b000: PCsrc <= brEq;         // BEQ
                    3'b001: PCsrc <= !brEq;        // BNE
                    3'b100: PCsrc <= brLt;         // BLT (signed)
                    3'b101: PCsrc <= !brLt || brEq; // BGE (signed)
                    3'b110: PCsrc <= brLt;         // BLTU (unsigned)
                    3'b111: PCsrc <= !brLt || brEq; // BGEU (unsigned)
                    default: PCsrc <= 0;           // Undefined branch operation
                endcase
            end 

            default: begin
                branch <= 0;
                MemRead <= 0;
                MemtoReg <= 0;
                MemWrite <= 0;
                ALUsrc <= 0;
                RegWrite <= 0;
                ResultSrc <= 0;
                ALUop <= 4'b0000;  
            end 
        endcase
    end
                
    
endmodule
            

