`timescale 1ns / 1ps

module instr_mem(
  input logic [31:0] addr_i,
  output logic [31:0] read_data_o
    );
    
reg [31:0] RAM [1024];
initial $readmemh("program.txt", RAM);

always_comb begin
  if(addr_i > 32'd4095)  
    read_data_o = 32'd0;
  else 
    read_data_o = RAM[addr_i[31:2]];
end

endmodule
