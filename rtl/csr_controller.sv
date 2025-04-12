//`timescale 1ns / 1ps


module csr_controller(
       input  logic        clk_i,
       input  logic        rst_i,
       input  logic [ 2:0] opcode_i,
       input  logic [11:0] addr_i,
       input  logic [31:0] pc_i,
       input  logic [31:0] mcause_i,
       input  logic [31:0] rs1_data_i,
       input  logic [31:0] imm_data_i,
       input  logic        write_enable_i,
       input  logic        trap_i,

       output logic [31:0] read_data_o,
       output logic [31:0] mie_o,
       output logic [31:0] mepc_o,
       output logic [31:0] mtvec_o
    );

    import csr_pkg::*;

    logic [31:0] mux_operation;
    //logic [31:0] read_data;
    logic        enable04; 
    logic        enable05; 
    logic        enable40; 
    logic        enable41; 
    logic        enable42; 
    logic [31:0] addr304;
    logic [31:0] addr305;
    logic [31:0] addr340;
    logic [31:0] addr341;
    logic [31:0] addr342;

    always_comb begin
        case(opcode_i)
             CSR_RW: mux_operation <= rs1_data_i;  
             CSR_RS: mux_operation <= rs1_data_i | read_data_o;
             CSR_RC: mux_operation <= ~rs1_data_i & read_data_o;
             CSR_RWI: mux_operation <= imm_data_i;
             CSR_RSI: mux_operation <= imm_data_i | read_data_o;
             CSR_RCI: mux_operation <= ~imm_data_i & read_data_o;
             default: mux_operation <= '0;
        endcase
    end

    // always_comb begin
    //     case(addr_i)
    //          MIE_ADDR: enable04 <= write_enable_i;
    //          MTVEC_ADDR: enable05 <= write_enable_i;
    //          MSCRATCH_ADDR: enable40 <= write_enable_i;
    //          MEPC_ADDR: enable41 <= write_enable_i;
    //          MCAUSE_ADDR: enable42 <= write_enable_i;
    //          default: begin
    //                     enable04 <= 0;
    //                     enable05 <= 0;
    //                     enable40 <= 0;
    //                     enable41 <= 0;
    //                     enable42 <= 0;
    //                   end
    //     endcase
    // end

    assign enable04 = addr_i == MIE_ADDR      ? write_enable_i : 0;
    assign enable05 = addr_i == MTVEC_ADDR    ? write_enable_i : 0;
    assign enable40 = addr_i == MSCRATCH_ADDR ? write_enable_i : 0;
    assign enable41 = addr_i == MEPC_ADDR     ? write_enable_i : 0;
    assign enable42 = addr_i == MCAUSE_ADDR   ? write_enable_i : 0;

    always_ff @(posedge clk_i) begin
        if (rst_i)
            addr304 <= 0;
        else begin 
            if (enable04) addr304 <= mux_operation;
            else addr304 <= addr304;
        end
    end

   

    always_ff @(posedge clk_i) begin
        if (rst_i)
            addr305 <= 0;
        else begin 
            if (enable05) addr305 <= mux_operation;
            else          addr305 <= addr305;
        end
    end

    

    always_ff @(posedge clk_i) begin
        if (rst_i)
            addr340 <= 0;
        else begin 
            if (enable40) addr340 <= mux_operation;
            else          addr340 <= addr340;
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i)
            addr341 <= 0;
        else begin 
            if (enable41 | trap_i) 
            case (trap_i)
                  1'b0: addr341 <= mux_operation;
                  1'b1: addr341 <= pc_i;
            endcase
            else addr341 <= addr341;
        end
    end

   

    always_ff @(posedge clk_i) begin
        if (rst_i)
            addr342 <= 0;
        else begin 
            if (enable42 | trap_i) 
            case (trap_i)
                  1'b0: addr342 <= mux_operation;
                  1'b1: addr342 <= mcause_i;
            endcase
            else addr342 <= addr342;
        end
    end

    always_comb begin
        case (addr_i)
             MIE_ADDR: read_data_o <= addr304;
             MTVEC_ADDR: read_data_o <= addr305;
             MSCRATCH_ADDR: read_data_o <= addr340;
             MEPC_ADDR: read_data_o <= addr341;
             MCAUSE_ADDR: read_data_o <= addr342;
             default: begin
               read_data_o <= '0;
             end
        endcase
    end

    //assign read_data_o = read_data;
    assign  mepc_o = addr341;
    assign  mie_o = addr304;
    assign  mtvec_o = addr305;
    
endmodule


