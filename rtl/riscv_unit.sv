//`timescale 1ns / 1ps


module riscv_unit(
input logic          clk_i,
input logic          resetn_i,

input logic   [15:0] sw_i,

output logic  [15:0] led_o,

input logic          kclk_i,
input logic          kdata_i,

output logic  [6:0]  hex_led_o,
output logic  [7:0]  hex_sel_o,

input logic          rx_i,
output logic         tx_o,

output logic  [3:0]  vga_r_o,
output logic  [3:0]  vga_g_o,
output logic  [3:0]  vga_b_o,
output logic         vga_hs_o,
output logic         vga_vs_o
    );

  logic [31:0] instr;
  logic [31:0] instr_addr;
  logic [31:0] mem_rd;
  logic        mem_req;
  logic        mem_we;
  logic [31:0] mem_wd;
  logic [31:0] mem_addr;
  logic        stall_inst;
  logic [02:0] size;
  
  logic [03:0] BE;
  logic [31:0] WD;
  logic [31:0] A;
  logic [31:0] RD;
  logic [31:0] RD_data;
  logic [31:0] RD_rx;
  logic [31:0] RD_tx;
  logic        READY;
  logic        WE;
  logic        req;
  logic         irq_req;
  logic         irq_ret;
  logic [255:0] out;     
  logic sysclk, rst;

 sys_clk_rst_gen divider(
      .ex_clk_i(clk_i),
      .ex_areset_n_i(resetn_i),
      .div_i(5),
      .sys_clk_o(sysclk),
      .sys_reset_o(rst)
);
  
  instr_mem IM (
     .addr_i(instr_addr),
     .read_data_o(instr)
  );  

  riscv_core CORE (
     .instr_i(instr),
     .mem_rd_i(mem_rd),
     .instr_addr_o(instr_addr),
     .mem_req_o(mem_req),
     .mem_we_o(mem_we),
     .mem_size_o(size),
     .mem_wd_o(mem_wd),
     .mem_addr_o(mem_addr),
     .clk_i(sysclk),
     .rst_i(rst),
     .stall_i(stall_inst),
     .irq_req_i(irq_req),
     .irq_ret_o(irq_ret)
  );

  ext_mem DATA_inst (
      .clk_i(sysclk),
      .mem_req_i(req & out[0]),
      .write_enable_i(WE),
      .addr_i({8'd0, A[23:0]}),
      .write_data_i(WD),
      .read_data_o(RD_data),
      .ready_o(READY),
      .byte_enable_i(BE)
  );

  riscv_lsu lsu_inst(
    .core_req_i(mem_req),
    .core_we_i(mem_we),
    .core_size_i(size),
    .core_addr_i(mem_addr),
    .core_wd_i(mem_wd),
    .core_rd_o(mem_rd),
    .core_stall_o(stall_inst),
    .mem_req_o(req),
    .mem_we_o(WE),
    .mem_be_o(BE),
    .mem_addr_o(A),
    .mem_wd_o(WD),
    .mem_rd_i(RD),
    .mem_ready_i(READY),
    .rst_i(rst),
    .clk_i(sysclk)
  );

  uart_rx_sb_ctrl uart_rx_inst(
     .clk_i(sysclk),
     .rst_i(rst),
     .addr_i({8'd0,A[23:0]}),
     .req_i(req & out[5]),
     .write_data_i(WD),
     .write_enable_i(WE),
     .read_data_o(RD_rx),
     .interrupt_request_o(irq_req),
     .interrupt_return_i(irq_ret),
     .rx_i(rx_i)
  );

  uart_tx_sb_ctrl uart_tx_inst(
     .clk_i(sysclk),
     .rst_i(rst),
     .addr_i({8'd0,A[23:0]}),
     .req_i(req & out[6]),
     .write_data_i(WD),
     .write_enable_i(WE),
     .read_data_o(RD_tx),
     .tx_o(tx_o)
  );
  
  assign out = 256'd1 << A[31:24];

  always_comb begin
    case (A[31:24])
        8'h0: RD <= RD_data;
        8'h5: RD <= RD_rx;
        8'h6: RD <= RD_tx;
        default: RD <= RD;
    endcase
  end
/*
  data_mem DATA (
      .clk_i(clk_i),
      .mem_req_i(mem_req),
      .write_enable_i(mem_we),
      .addr_i(mem_addr),
      .write_data_i(mem_wd),
      .read_data_o(mem_rd)
  );

  always_ff @ ( posedge clk_i ) begin
        if(rst_i)
        stall <= 0;
        else
        stall <= mem_req && !stall;
  end
*/
endmodule






