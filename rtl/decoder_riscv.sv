//`timescale 1ns / 1ps

module decoder_riscv (
  input  logic [31:0]  fetched_instr_i, 
  output logic [1:0]   a_sel_o,         
  output logic [2:0]   b_sel_o,         
  output logic [4:0]   alu_op_o,        
  output logic [2:0]   csr_op_o,        
  output logic         csr_we_o,       
  output logic         mem_req_o,       
  output logic         mem_we_o,        
  output logic [2:0]   mem_size_o,      
  output logic         gpr_we_o,        
  output logic [1:0]   wb_sel_o,        
  output logic         illegal_instr_o, 
  output logic         branch_o,        
  output logic         jal_o,           
  output logic         jalr_o,          
  output logic         mret_o           
);
  import riscv_pkg::*;
  import alu_opcodes_pkg::*;
  import csr_pkg::*;

logic [6:0] opcode;
logic [2:0] func3;
logic [6:0] func7;

assign opcode = fetched_instr_i[6:0];
assign func3  = fetched_instr_i[14:12];
assign func7  = fetched_instr_i[31:25];

always_comb begin
  a_sel_o         <= 2'd0;
  b_sel_o         <= 3'd0;
  wb_sel_o        <= 2'd0;
  alu_op_o        <= 5'd0;
  csr_we_o        <= 1'd0;
  csr_op_o        <= 3'd0;
  mem_req_o       <= 1'd0;
  mem_we_o        <= 1'd0;
  gpr_we_o        <= 1'd0;
  illegal_instr_o <= 1'd0;
  branch_o        <= 1'd0;
  jal_o           <= 1'd0;
  jalr_o          <= 1'd0;
  mret_o          <= 1'd0;
  if ( opcode[1:0] == 2'b11 ) begin
    case (opcode[6:2])
      LOAD_OPCODE:      case (func3) 
                        LDST_B: begin 
                                  a_sel_o    <= 2'd0;
                                  b_sel_o    <= 3'd1;
                                  wb_sel_o   <= 2'd1;
                                  gpr_we_o   <= 1'd1;
                                  alu_op_o   <= ALU_ADD;
                                  mem_size_o <= LDST_B;
                                  mem_req_o  <= 1'd1;
                                end
                        LDST_H: begin 
                                  a_sel_o    <= 2'd0;
                                  b_sel_o    <= 3'd1;
                                  wb_sel_o   <= 2'd1;
                                  gpr_we_o   <= 1'd1;
                                  alu_op_o   <= ALU_ADD;
                                  mem_size_o <= LDST_H;
                                  mem_req_o  <= 1'd1;
                                end
                        LDST_W: begin 
                                  a_sel_o    <= 2'd0;
                                  b_sel_o    <= 3'd1;
                                  wb_sel_o   <= 2'd1;
                                  gpr_we_o   <= 1'd1;
                                  alu_op_o   <= ALU_ADD;
                                  mem_size_o <= LDST_W;
                                  mem_req_o  <= 1'd1;
                                end
                        LDST_BU:begin 
                                  a_sel_o    <= 2'd0;
                                  b_sel_o    <= 3'd1;
                                  wb_sel_o   <= 2'd1;
                                  gpr_we_o   <= 1'd1;
                                  alu_op_o   <= ALU_ADD;
                                  mem_size_o <= LDST_BU;
                                  mem_req_o  <= 1'd1;
                                end
                        LDST_HU:begin 
                                  a_sel_o    <= 2'd0;
                                  b_sel_o    <= 3'd1;
                                  wb_sel_o   <= 2'd1;
                                  gpr_we_o   <= 1'd1;
                                  alu_op_o   <= ALU_ADD;
                                  mem_size_o <= LDST_HU;
                                  mem_req_o  <= 1'd1;
                                end
                        default: illegal_instr_o <= 1'd1;
                        endcase
      MISC_MEM_OPCODE:  if (func3 == 3'd0) begin
                        end
                        else illegal_instr_o <= 1'd1;
      OP_IMM_OPCODE:    case (func3) 
                        ALU_ADD:begin 
                                  a_sel_o  <= 2'd0;
                                  b_sel_o  <= 3'd1;
                                  alu_op_o <= ALU_ADD;
                                  gpr_we_o <= 1'd1;
                                end 
                        ALU_XOR:begin 
                                  a_sel_o  <= 2'd0;
                                  b_sel_o  <= 3'd1;
                                  alu_op_o <= ALU_XOR;
                                  gpr_we_o <= 1'd1;
                                end 
                        ALU_OR: begin 
                                  a_sel_o  <= 2'd0;
                                  b_sel_o  <= 3'd1;
                                  alu_op_o <= ALU_OR;
                                  gpr_we_o <= 1'd1;
                                end 
                        ALU_AND:begin 
                                  a_sel_o  <= 2'd0;
                                  b_sel_o  <= 3'd1;
                                  alu_op_o <= ALU_AND;
                                  gpr_we_o <= 1'd1;
                                end 
                        ALU_SLL:begin 
                                    if (func7 == 7'd0) begin
                                      a_sel_o  <= 2'd0;
                                      b_sel_o  <= 3'd1;
                                      alu_op_o <= ALU_SLL;
                                      gpr_we_o <= 1'd1;
                                    end
                                    else illegal_instr_o <= 1'd1;
                                end
                        3'd5:   begin 
                                    case (func7)
                                      7'd0: begin //srli
                                              a_sel_o  <= 2'd0;
                                              b_sel_o  <= 3'd1;
                                              alu_op_o <= ALU_SRL;
                                              gpr_we_o <= 1;
                                            end
                                      7'h20: begin //srai
                                              a_sel_o  <= 2'd0;
                                              b_sel_o  <= 3'd1;
                                              alu_op_o <= ALU_SRA;
                                              gpr_we_o <= 1'd1;
                                            end
                                    default illegal_instr_o <= 1'd1;
                                    endcase
                                end
                        ALU_SLTS: begin 
                                      a_sel_o  <= 2'd0;
                                      b_sel_o  <= 3'd1;
                                      alu_op_o <= ALU_SLTS;
                                      gpr_we_o <= 1'd1;
                                  end
                        ALU_SLTU: begin 
                                    a_sel_o  <= 2'd0;
                                    b_sel_o  <= 3'd1;
                                    alu_op_o <= ALU_SLTU;
                                    gpr_we_o <= 1'd1;
                                  end 
                        default: illegal_instr_o <= 1'd1;
                        endcase
      AUIPC_OPCODE:   begin  
                        a_sel_o  <= 2'd1; 
                        b_sel_o  <= 3'd2;
                        alu_op_o <= ALU_ADD;
                        gpr_we_o <= 1'd1;
                      end 
      STORE_OPCODE: case (func3) 
                      3'd0: begin //sb
                              b_sel_o    <= 3'd3;
                              mem_req_o  <= 1'd1;
                              mem_we_o   <= 1'd1;
                              mem_size_o <= LDST_B;
                            end
                      3'd1: begin //sh
                              mem_req_o  <= 1'd1;
                              mem_we_o   <= 1'd1;
                              mem_size_o <= LDST_H;
                              b_sel_o    <= 3'd3;
                            end
                      3'd2: begin //sw
                              b_sel_o    <= 3'd3;
                              mem_req_o  <= 1'd1;
                              mem_we_o   <= 1'd1;
                              mem_size_o <= LDST_W;
                            end
                      default:illegal_instr_o <= 1'd1;
                    endcase
      OP_OPCODE: case (func3) 
                  3'd0: begin
                        case (func7)
                          7'd0: begin //add
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_ADD;
                                  gpr_we_o  <= 1'd1;
                                end
                          7'h20:begin //sub
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_SUB;
                                  gpr_we_o  <= 1'd1;
                                end
                          default: illegal_instr_o <= 1'd1;
                        endcase
                        end
                  ALU_XOR: begin 
                        case (func7)
                          7'd0: begin
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_XOR;
                                  gpr_we_o  <= 1'd1;
                                end
                          default: illegal_instr_o <= 1'd1;
                        endcase 
                        end
                  ALU_OR: begin 
                        case (func7)
                          7'd0: begin
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_OR;
                                  gpr_we_o  <= 1'd1;
                                end
                        default: illegal_instr_o <= 1'd1;
                        endcase 
                          end
                  ALU_AND: begin 
                        case (func7)
                          7'd0: begin
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_AND;
                                  gpr_we_o  <= 1'd1;
                                end
                          default: illegal_instr_o <= 1'd1;
                        endcase 
                        end
                  ALU_SLL:begin 
                        case (func7)
                          7'd0: begin
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_SLL;
                                  gpr_we_o  <= 1'd1;
                                end
                          default: illegal_instr_o <= 1'd1;
                        endcase 
                          end
                  3'd5: begin
                        case (func7)
                          7'd0: begin //srl
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_SRL;
                                  gpr_we_o  <= 1'd1;
                                end
                          7'h20: begin //sra
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_SRA;
                                  gpr_we_o  <= 1'd1;
                                end
                        default: illegal_instr_o <= 1'd1;
                        endcase 
                        end
                  ALU_SLTS: begin
                        case (func7)
                          7'd0: begin 
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_SLTS;
                                  gpr_we_o  <= 1'd1;
                                end
                          default: illegal_instr_o <= 1'd1;
                        endcase 
                            end
                  ALU_SLTU: begin
                        case (func7)
                          7'd0: begin 
                                  a_sel_o   <= 2'd0;
                                  b_sel_o   <= 3'd0;
                                  alu_op_o  <= ALU_SLTU;
                                  gpr_we_o  <= 1'd1;
                                end
                          default: illegal_instr_o <= 1'd1;
                        endcase 
                        end
                      endcase
      LUI_OPCODE: begin 
                    a_sel_o  <= 2'd2;
                    b_sel_o  <= 3'd2;
                    gpr_we_o <= 1'd1;
                    wb_sel_o <= 2'd0;
                  end
      BRANCH_OPCODE: case (func3) 
                      3'd0: begin //beq
                              a_sel_o  <= 2'd0;
                              b_sel_o  <= 3'd0;
                              alu_op_o <= ALU_EQ;
                              branch_o <= 1'd1;
                            end
                      3'd1: begin //bne
                              a_sel_o  <= 2'd0;
                              b_sel_o  <= 3'd0;
                              alu_op_o <= ALU_NE;
                              branch_o <= 1'd1;
                            end
                      3'd4: begin //blt
                              a_sel_o  <= 2'd0;
                              b_sel_o  <= 3'd0;
                              alu_op_o <= ALU_LTS;
                              branch_o <= 1'd1;
                            end
                      3'd5: begin //bge
                              a_sel_o  <= 2'd0;
                              b_sel_o  <= 3'd0;
                              alu_op_o <= ALU_GES;
                              branch_o <= 1'd1;
                            end
                      3'd6: begin //bltu
                              a_sel_o  <= 2'd0;
                              b_sel_o  <= 3'd0;
                              alu_op_o <= ALU_LTU;
                              branch_o <= 1'd1;
                            end
                      3'd7: begin //bgeu
                              a_sel_o  <= 2'd0;
                              b_sel_o  <= 3'd0;
                              alu_op_o <= ALU_GEU;
                              branch_o <= 1'd1;
                            end
                      default: illegal_instr_o <= 1'd1;
                      endcase
      JALR_OPCODE:begin
                    case (func3)
                      3'd0: begin 
                              a_sel_o  <= 2'd1;
                              b_sel_o  <= 3'd4;
                              jalr_o   <= 1'd1;
                              gpr_we_o <= 1'd1;
                            end
                      default: illegal_instr_o <= 1'd1;
                    endcase 
                  end
      JAL_OPCODE: begin 
                    a_sel_o  <= 2'd1;
                    b_sel_o  <= 3'd4;
                    alu_op_o <= 5'd0;
                    jal_o    <= 1'd1;
                    gpr_we_o <= 1'd1;
                  end
      SYSTEM_OPCODE:begin
                      case (func3)
                        3'd0: begin
                                case (func7)
                                  7'd0: begin //ecall
                                          illegal_instr_o <= 1'd1;
                                        end
                                  7'd1: begin //ebreak
                                          illegal_instr_o <= 1'd1;
                                        end
                                  7'b0011000: begin //mret
                                          mret_o <= 1'd1;
                                        end
                                  default illegal_instr_o  <= 1'd1;
                                endcase
                              end
                        CSR_RW: begin 
                                  a_sel_o  <= 2'd0;
                                  csr_op_o <= CSR_RW;
                                  csr_we_o <= 1'd1;
                                  gpr_we_o <= 1'd1;
                                  wb_sel_o <= 2'd2;
                                end
                        CSR_RS: begin 
                                  a_sel_o  <= 2'd0;
                                  csr_op_o <= CSR_RS;
                                  csr_we_o <= 1'd1;
                                  gpr_we_o <= 1'd1;
                                  wb_sel_o <= 2'd2;
                                end
                        CSR_RC: begin 
                                  a_sel_o  <= 2'd0;
                                  csr_op_o <= CSR_RC;
                                  csr_we_o <= 1'd1;
                                  gpr_we_o <= 1'd1;
                                  wb_sel_o <= 2'd2;
                                end
                        CSR_RWI:begin 
                                  b_sel_o  <= 3'd1;
                                  csr_op_o <= CSR_RWI;
                                  csr_we_o <= 1'd1;
                                  gpr_we_o <= 1'd1;
                                  wb_sel_o <= 2'd2;
                                end
                        CSR_RSI:begin 
                                  b_sel_o  <= 3'd1;
                                  csr_op_o <= CSR_RSI;
                                  csr_we_o <= 1'd1;
                                  gpr_we_o <= 1'd1;
                                  wb_sel_o <= 2'd2;
                                end
                        CSR_RCI:begin 
                                  b_sel_o  <= 3'd1;
                                  csr_op_o <= CSR_RCI;
                                  csr_we_o <= 1'd1;
                                  gpr_we_o <= 1'd1;
                                  wb_sel_o <= 2'd2;
                                end
                        default: illegal_instr_o <= 1'd1;
                      endcase 
                    end
    default: illegal_instr_o <= 1'd1;
    endcase
  end
  else illegal_instr_o <= 1'd1;
end


endmodule
