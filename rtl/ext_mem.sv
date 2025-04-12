//`timescale 1ns / 1ps


module ext_mem(
  input logic         clk_i,
  input logic         mem_req_i,
  input logic         write_enable_i,
  input logic  [ 3:0] byte_enable_i,
  input logic  [31:0] addr_i,
  input logic  [31:0] write_data_i,
  output logic [31:0] read_data_o,
  output logic        ready_o
);

reg [31:0] MEM [4096];

assign ready_o = 1;

logic [31:0] offset_addr;

assign offset_addr = addr_i >> 2;
//assign addr_i[31:0] = addr_i[31:0];
/*
logic [8:0] byter [4];

always_comb begin
   byter [0] = addr_i[31:2][7:0];
   byter [1] = addr_i[31:2][15:8];
   byter [2] = addr_i[31:2][23:16];
   byter [3] = addr_i[31:2][31:24];
end
*/

    always_ff @(posedge clk_i) begin
     
     if (~mem_req_i || write_enable_i) 
         read_data_o <= 32'hfa11_1eaf;
     
     else if (mem_req_i && ( addr_i < 16384))
         read_data_o <= MEM[offset_addr];
     
     else if (mem_req_i && (addr_i > 32'd16383))
         read_data_o <= 32'hdead_beef;
    
    end
    
   

   always_ff @(posedge clk_i) begin
     if (write_enable_i && mem_req_i) begin
       
       if (byte_enable_i[0])
          MEM[offset_addr][7:0] <= write_data_i [7:0];
      
       if (byte_enable_i[1])
          MEM[offset_addr][15:8] <= write_data_i [15:8];
       
       if (byte_enable_i[2])
          MEM[offset_addr][23:16] <= write_data_i [23:16];
       
       if (byte_enable_i[3])
          MEM[offset_addr][31:24] <= write_data_i [31:24];
     
     end
   end

  
  
  
  
  
  /*
     always_ff @(posedge clk_i) begin
     if(mem_req_i && write_enable_i && byte_enable_i == 4'b0001)
        MEM[byter[0]] <= write_data_i[7:0];  
     
     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b0010)
        MEM[byter[1]] <= write_data_i[15:8];  
     
     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b0100)
        MEM[byter[2]] <= write_data_i[23:16]; 
     
     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b1000)
        MEM[byter[3]] <= write_data_i[31:24];
     
     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b0011)
        MEM[{byter[0], byter[1]}] <= write_data_i[15:0];

     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b0101)
        MEM[{byter[0], byter[2]}] <= {write_data_i[23:16],write_data_i[]};
     
     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b1001)
        MEM[{byter[0], byter[3]}] <= write_data_i;

     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b0110)
        MEM[{byter[1], byter[2]}] <= write_data_i;

     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b1010)
        MEM[{byter[1], byter[4]}] <= write_data_i;

     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b1100)
        MEM[{byter[2], byter[3]}] <= write_data_i;

     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b1110)
        MEM[{byter[1], byter[2], byter[3]}] <= write_data_i;

     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b1101)
        MEM[{byter[0], byter[2], byter[3]}] <= write_data_i;

     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b1011)
        MEM[{byter[0], byter[1], byter[3]}] <= write_data_i;

     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b0111)
        MEM[{byter[0], byter[1], byter[2]}] <= write_data_i;

     else if(mem_req_i && write_enable_i && byte_enable_i == 4'b1111)
        MEM[{byter[0], byter[1], byter[2], byter[3]}] <= write_data_i;
    end
*/

    
endmodule
