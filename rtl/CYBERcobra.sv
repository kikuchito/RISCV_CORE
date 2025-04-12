`timescale 1ns / 1ps


module CYBERcobra(
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic [15:0] sw_i,
  output logic [31:0] out_o
    );
    
//logic RA1    [4:0];
//logic RA2    [4:0];
logic [31:0] WD;
//logic WA     [4:0];
logic [31:0] RD1,RD2;
logic WE; 
logic [31:0] pc_in;
logic [31:0] pc_out;
//logic ALUop  [5];
logic [31:0] RDO;
logic flag;
logic [31:0] alu_o;
logic [31:0] SE_MUX;
logic [31:0] SE_PC;
logic [31:0] SE_SW;
logic pc_flag;

instr_mem IM(
        .addr_i(pc_out),
        .read_data_o(RDO)
    );
    
rf_riscv RG(
        .clk_i(clk_i),
        .write_enable_i(!(RDO[30] | RDO[31])),
        .write_addr_i(RDO[4:0]),
        .read_addr1_i(RDO[22:18]),
        .read_addr2_i(RDO[17:13]),
        .write_data_i(WD),
        .read_data1_o(RD1),
        .read_data2_o(RD2)
    );

alu_riscv ALU(
        .a_i(RD1),
        .b_i(RD2),
        .alu_op_i(RDO[27:23]),
        .flag_o(flag),
        .result_o(alu_o)
    );
    
assign SE_MUX  = {{9{RDO[27]}}, RDO[27:5]};
assign pc_flag = (flag && RDO[30]) || RDO[31];
assign SE_PC = {{22{RDO[12]}}, RDO[12:5],2'd0};
assign SE_SW = {{16{sw_i[15]}}, sw_i[15:0]};

//логика мультиплексора у регистрового файла
always_comb begin
    case (RDO[29:28])
    2'b00: WD = SE_MUX;  
    2'b01: WD = alu_o;
    2'b10: WD = SE_SW;
    2'b11: WD = 32'd0;
    default: WD = 'b0;
endcase      
end

//логика флага
always_comb begin
    case (pc_flag)
    'b0: pc_in = 32'd4;
    'b1: pc_in = SE_PC;
endcase
end

//логика переключения инструкций
always_ff @(posedge clk_i) begin
    if (rst_i) 
       pc_out = 0;
    else 
       pc_out = pc_out+pc_in;
end

assign out_o = RD1;

endmodule