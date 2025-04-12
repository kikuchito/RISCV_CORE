`timescale 1ns / 1ps


module led_sb_ctrl(
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        req_i,
  input  logic        write_enable_i,
  input  logic [31:0] addr_i,
  input  logic [31:0] write_data_i,
  output logic [31:0] read_data_o,
  output logic [15:0] led_o
);

logic [15:0] led_val;
logic        led_mode;
logic        write_reg;
logic        read_reg;

assign write_reg = req_i & write_enable_i;
assign read_reg = ~write_enable_i & req_i;

always_comb begin
  case (addr_i)
       32'h0:
       32'h1:
       32'h24:
  endcase
end

endmodule
