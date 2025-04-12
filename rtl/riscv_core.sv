 //`timescale 1ns / 1ps



 module riscv_core(
        input logic         clk_i,
        input logic         rst_i,

        input logic         stall_i,
        input logic  [31:0] instr_i,
        input logic  [31:0] mem_rd_i,
        input logic         irq_req_i,

        output logic [31:0] instr_addr_o,
        output logic [31:0] mem_addr_o,
        output logic [ 2:0] mem_size_o,
        output logic        mem_req_o,
        output logic        mem_we_o,
        output logic [31:0] mem_wd_o,
        output logic        irq_ret_o
     );
    
     logic [4:0] RA1;
     logic [4:0] RA2;
     logic [4:0] WA;
     logic [31:0] imm_I;
     logic [31:0] imm_U;
     logic [31:0] imm_S;
     logic [31:0] imm_B;
     logic [31:0] imm_J;
     logic [31:0] imm_Z;
     logic [2:0] flag_mux_imm;
     logic [1:0] flag_mux_rg;
     logic [31:0] Pc;
     logic [4:0] flag_alu;
     logic [1:0] flag_wb_sel;
     logic gpr_we_core;
     logic [31:0] RD1,RD2;
     logic b_core;
     logic jal_core;
     logic jalr_core;
     logic [31:0] mux_rg_out;
     logic [31:0] mux_imm_out;
     logic [31:0] alu_result_core;
     logic flag_core;
     logic [31:0] wb_data;
     logic [31:0] mux_out1;
     logic [31:0] mux_out_flag;
     logic [31:0] mux_out_summ;
     logic [31:0] summ;
     logic        ill_instr;
     logic [31:0] mie;
     logic        mret;
     logic        irq;
     logic        trap;
     logic [31:0] csr_wd;
     logic [31:0] irq_cause;
     logic [ 2:0] csr_op;
     logic [31:0] mcause;
     logic [31:0] mtvec;
     logic [31:0] mepc;
     logic [31:0] Pc_mux;
     logic        mem_req;
     logic        mem_we;
     decoder_riscv DECODER(
         .mem_size_o      (mem_size_o),
         .mem_req_o       (mem_req),
         .mem_we_o        (mem_we),
         .a_sel_o         (flag_mux_rg),
         .b_sel_o         (flag_mux_imm),
         .alu_op_o        (flag_alu),
         .wb_sel_o        (flag_wb_sel),
         .gpr_we_o        (gpr_we_core),
         .fetched_instr_i (instr_i),
         .branch_o        (b_core),
         .jal_o           (jal_core),
         .jalr_o          (jalr_core),
         .illegal_instr_o (ill_instr),
         .mret_o          (mret),
         .csr_op_o        (csr_op),
         .csr_we_o        (csr_we)

     );

    
     rf_riscv RG(
         .clk_i(clk_i),
         .write_enable_i(~(stall_i | trap) & gpr_we_core),
         .write_addr_i(WA),
         .read_addr1_i(RA1),
         .read_addr2_i(RA2),
         .write_data_i(wb_data),
         .read_data1_o(RD1),
         .read_data2_o(RD2)
     );

     alu_riscv ALU(
         .a_i(mux_rg_out),
         .b_i(mux_imm_out),
         .alu_op_i(flag_alu),
         .flag_o(flag_core),
         .result_o(alu_result_core)
     );
    
     irq_controller inst_irq(
         .clk_i(clk_i),
         .rst_i(rst_i),
         .exception_i(ill_instr),
         .irq_req_i(irq_req_i),
         .mie_i(mie[0]),
         .mret_i(mret),
         .irq_ret_o(irq_ret_o),
         .irq_cause_o(irq_cause),
         .irq_o(irq)
     );

     csr_controller inst_csr(
         .clk_i(clk_i),
         .rst_i(rst_i),
         .opcode_i(csr_op),
         .addr_i(instr_i[31:20]),
         .pc_i(Pc),
         .mcause_i(ill_instr ? 32'h0000_0002 : irq_cause),
         .rs1_data_i(RD1),
         .imm_data_i(imm_Z),
         .write_enable_i(csr_we),
         .trap_i(trap),
         .read_data_o(csr_wd),
         .mie_o(mie),
         .mepc_o(mepc),
         .mtvec_o(mtvec)
     );
    
     always_comb begin
         case(ill_instr)
             1'b0: mcause = irq_cause;
             1'b1: mcause = 32'h0000_0002;
         endcase
     end

    

     assign mem_req_o = ~trap & mem_req;
     assign mem_we_o = ~trap & mem_we;
     assign trap = irq | ill_instr;
     assign instr_addr_o = Pc;

     //extentions

         assign RA1 = instr_i[19:15];
         assign RA2 = instr_i[24:20];
         assign WA  = instr_i[11:7];
         assign imm_I = {{20{instr_i[31]}}, instr_i[31:20]};
         assign imm_U = {instr_i[31:12], 12'd0};
         assign imm_S = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]};
         assign imm_B = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'd0};
         assign imm_J = {{11{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'd0}; 
         assign imm_Z = {{27{1'd0}}, instr_i[19:15]};
         assign mem_wd_o = RD2;
         assign mem_addr_o = alu_result_core;
         assign summ = RD1 + imm_I;

 
     //mux RD1
     always_comb begin
     case (flag_mux_rg)
     2'b00: mux_rg_out = RD1;
     2'b01: mux_rg_out = Pc;
     2'b10: mux_rg_out = 32'b0;
     default: mux_rg_out <= '0;
     endcase
     end

     //mux RD2 and imm
     always_comb begin
     case (flag_mux_imm)
     3'b000: mux_imm_out = RD2;
     3'b001: mux_imm_out = imm_I;
     3'b010: mux_imm_out = imm_U;
     3'b011: mux_imm_out = imm_S;
     3'b100: mux_imm_out = 32'd4;
     default: mux_imm_out <= '0;
     endcase
     end

     //mux wb_data
     always_comb begin
     case (flag_wb_sel)
          2'b00: wb_data = alu_result_core;
          2'b01: wb_data = mem_rd_i;
          2'b10: wb_data = csr_wd;
          default: wb_data <= '0;
     endcase
     end
    
     //PC trigger
     always_ff @ (posedge clk_i) begin
         if (rst_i)
             Pc <= '0;
         else if (!stall_i)
                Pc <= Pc_mux;
         else 
             Pc <= Pc;
     end
    
     assign Pc_mux = mret ? mepc : (trap ? mtvec : mux_out_summ);
    
     assign mux_out_summ = jalr_core ? {summ[31:1],1'd0} : Pc + mux_out_flag;
    
     assign mux_out_flag = (jal_core | (flag_core & b_core)) ? mux_out1 : 32'b100;
    
     assign mux_out1 = b_core ? imm_B : imm_J;

     // //Pc
     // always_comb begin
     // case(mret)
     // 1'b0: case (trap)
     //       1'b0: Pc_mux = mux_out_summ;
     //       1'b1: Pc_mux = mtvec;
     //       endcase
     // 1'b1: Pc_mux = mepc;
     // endcase
     // end
    
     //  //two summ
     // always_comb begin
     // case(jalr_core)
     // 1'b0: mux_out_summ = Pc + mux_out_flag;
     // 1'b1: mux_out_summ = {summ[31:1],1'd0};
     // endcase
     // end

     // //mux flag and jal
     // always_comb begin
     // case(jal_core || (flag_core && b_core))
     // 1'b0: mux_out_flag = 32'b100;
     // 1'b1: mux_out_flag = mux_out1;
     // endcase
     // end
        
     // //mux imm_J and imm_B
     // always_comb begin
     // case(b_core)
     // 1'b0: mux_out1 = imm_J;
     // 1'b1: mux_out1 = imm_B;
     // endcase
     // end





 endmodule
