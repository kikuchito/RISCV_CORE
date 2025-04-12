//`timescale 1ns / 1ps


module irq_controller(
   input  logic        clk_i,
   input  logic        rst_i,
   input  logic        exception_i,
   input  logic        irq_req_i,
   input  logic        mie_i,
   input  logic        mret_i,

   output logic        irq_ret_o,
   output logic [31:0] irq_cause_o,
   output logic        irq_o
    );
    
    logic exc_h;
    logic irq_h;
    logic set_exc;
    logic set_irq;
    logic sel_ex;
    logic sel_irq;
    
    assign sel_ex = exc_h | exception_i;
    assign sel_irq = irq_o | irq_h;
    assign irq_cause_o = 32'h10000010;
    assign irq_ret_o = mret_i & ~sel_ex;
    assign irq_o = (irq_req_i & mie_i) & ~(irq_h | sel_ex);
    assign set_exc = ~mret_i & sel_ex;
    assign set_irq = sel_irq & ~(mret_i & ~sel_ex);

    always_ff @(posedge clk_i) begin
        if (rst_i) 
            exc_h <= 0;
        else
            exc_h <= set_exc;
    end
    
    always_ff @(posedge clk_i) begin
        if (rst_i)
           irq_h <= 0;
        else
           irq_h <= set_irq;
    end
    
    
    
    

endmodule