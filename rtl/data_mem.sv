`timescale 1ns / 1ps

module data_mem(
     input logic clk_i,
     input logic mem_req_i,
     input logic write_enable_i,
     input logic [31:0] addr_i,
     input logic [31:0] write_data_i,
     output logic [31:0] read_data_o
    );
    
    reg [31:0] MEM [4096];


    //чтение
    always_ff @(posedge clk_i) begin
     if(mem_req_i && (addr_i > 32'd16383))
        read_data_o <= 32'hdead_beef;
     else if(!mem_req_i || write_enable_i)
        read_data_o <= 32'hfa11_1eaf;
     else if (mem_req_i && ( addr_i< 16384))
     read_data_o <= MEM[{addr_i[31:2], 2'b0}]; //обратить внимание
    end
    
    //запись
     always_ff @(posedge clk_i) begin
     if(mem_req_i && write_enable_i)
     MEM[addr_i[31:2]]<=write_data_i;  
    end
endmodule
