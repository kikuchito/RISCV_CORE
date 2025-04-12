//`timescale 1ns / 1ps



module riscv_lsu(
     input logic clk_i,
     input logic rst_i,

     // �?нтерфейс с ядром
     input  logic        core_req_i,
     input  logic        core_we_i,
     input  logic [ 2:0] core_size_i,
     input  logic [31:0] core_addr_i,
     input  logic [31:0] core_wd_i,
     output logic [31:0] core_rd_o,
     output logic        core_stall_o,

     // �?нтерфейс с памятью
     output logic        mem_req_o,
     output logic        mem_we_o,
     output logic [ 3:0] mem_be_o,
     output logic [31:0] mem_addr_o,
     output logic [31:0] mem_wd_o,
     input  logic [31:0] mem_rd_i,
     input  logic        mem_ready_i
    );
     
     import riscv_pkg::*;
     import alu_opcodes_pkg::*;
     import csr_pkg::*;
     
     logic stall;
     logic half_offset;
     logic [1:0] byte_offset;
     logic [31:0] SE_mem_rd_70;
     logic [31:0] SE_mem_rd_158;
     logic [31:0] SE_mem_rd_2316;
     logic [31:0] SE_mem_rd_3124;
     
     logic [31:0] ZE_mem_rd_70;
     logic [31:0] ZE_mem_rd_158;
     logic [31:0] ZE_mem_rd_2316;
     logic [31:0] ZE_mem_rd_3124;
     
     logic [31:0] SE_mem_rd_150;
     logic [31:0] SE_mem_rd_3116;

     logic [31:0] ZE_mem_rd_150;
     logic [31:0] ZE_mem_rd_3116;
     logic        st;
     assign mem_we_o = core_we_i;
     assign mem_req_o = core_req_i;
     assign mem_addr_o = core_addr_i;
     
     //SE and ZE
     always_comb begin
        SE_mem_rd_70 = {{24{mem_rd_i[7]}}, mem_rd_i[7:0]};
        SE_mem_rd_158 = {{24{mem_rd_i[15]}}, mem_rd_i[15:8]};
        SE_mem_rd_2316 = {{24{mem_rd_i[23]}}, mem_rd_i[23:16]};
        SE_mem_rd_3124 = {{24{mem_rd_i[31]}}, mem_rd_i[31:24]};
        ZE_mem_rd_70 = {24'd0, mem_rd_i[7:0]};
        ZE_mem_rd_158 = {24'd0, mem_rd_i[15:8]};
        ZE_mem_rd_2316 = {24'd0, mem_rd_i[23:16]};
        ZE_mem_rd_3124 = {24'd0, mem_rd_i[31:24]};
        SE_mem_rd_150 = {{16{mem_rd_i[15]}}, mem_rd_i[15:0]};
        SE_mem_rd_3116 = {{16{mem_rd_i[31]}}, mem_rd_i[31:16]};
        ZE_mem_rd_150 = {16'd0, mem_rd_i[15:0]};
        ZE_mem_rd_3116 = {16'd0, mem_rd_i[31:16]};
     end

     always_ff @(posedge clk_i) begin
         if (rst_i)
          stall = 0;
         else 
         stall = st;
     end
     
     assign st = core_req_i & ~(mem_ready_i & stall);
     assign core_stall_o = st;

     always_comb begin
        case (core_size_i) 
            LDST_B: mem_wd_o = {{4{core_wd_i[7:0]}}};
            LDST_W: mem_wd_o = core_wd_i;
            LDST_H: mem_wd_o = {{2{core_wd_i[15:0]}}};
        endcase
     end
      

      assign half_offset = core_addr_i[1];
      assign byte_offset = core_addr_i[1:0];

      always_comb begin
         case (core_size_i)
             LDST_B: mem_be_o = 4'b0001 << byte_offset;
             LDST_H: case (half_offset) 
                       0: mem_be_o = 4'b0011;
                       1: mem_be_o = 4'b1100;
                     endcase
             LDST_W: mem_be_o = 4'b1111;
         endcase
      end

      always_comb begin
         case (core_size_i)
         LDST_W: core_rd_o = mem_rd_i;
         LDST_B: case (byte_offset)
                    2'b00: core_rd_o = SE_mem_rd_70;
                    2'b01: core_rd_o = SE_mem_rd_158;
                    2'b10: core_rd_o = SE_mem_rd_2316;
                    2'b11: core_rd_o = SE_mem_rd_3124;
                 endcase
         LDST_BU: case (byte_offset)
                    2'b00: core_rd_o = ZE_mem_rd_70;
                    2'b01: core_rd_o = ZE_mem_rd_158;
                    2'b10: core_rd_o = ZE_mem_rd_2316;
                    2'b11: core_rd_o = ZE_mem_rd_3124;
                  endcase
         LDST_H:  case (half_offset)
                    1'b0: core_rd_o = SE_mem_rd_150;
                    1'b1: core_rd_o = SE_mem_rd_3116; 
                  endcase
         LDST_HU: case (half_offset)
                    1'b0: core_rd_o = ZE_mem_rd_150;
                    1'b1: core_rd_o = ZE_mem_rd_3116; 
                  endcase      
         endcase
      end

endmodule