//`timescale 1ns / 1ps


module uart_rx_sb_ctrl(
  //system bus
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic [31:0] addr_i,
  input  logic        req_i,
  input  logic [31:0] write_data_i,
  input  logic        write_enable_i,
  output logic [31:0] read_data_o,
  
  //interruptions
  output logic        interrupt_request_o,
  input  logic        interrupt_return_i,
  
  //uart_rx
  input logic         rx_i
    );
     // main
    logic        busy;
    logic [16:0] baudrate;
    logic        parity_en;
    logic        stopbit;
    logic [ 7:0] data;
    logic        valid;
    // supporting
    logic        rst_valid;
    logic        rst;
    logic        busy_o;
    logic        write_req;
    logic        read_req;
    logic        is_rst_addr;
    logic        busy_read;
    logic        rx_valid;
    logic [ 7:0] rx_data;

    uart_rx rx_inst(
        .clk_i(clk_i),
        .rst_i(rst),
        .rx_i(rx_i),
        .busy_o(busy_o),
        .baudrate_i(baudrate),
        .parity_en_i(parity_en),
        .stopbit_i(stopbit),
        .rx_data_o(rx_data),
        .rx_valid_o(rx_valid)
    );

    assign write_req = req_i & write_enable_i;
    assign read_req = ~write_enable_i & req_i;
    assign rst = rst_i | (write_req & addr_i == 32'h24 & rst_valid);
    //write logic
    always_ff @(posedge clk_i) begin
    if (rst) begin
            baudrate <= 32'h9600;
            parity_en <= 1'h1;
            stopbit <= 1'h1;
        //    data <= 8'b0;
        end
    
    else begin
        if (~busy & write_req) begin
        case (addr_i) 
       //   32'h00: data <= write_data_i[7:0];
          32'h0c: baudrate <= write_data_i[16:0];
          32'h10: parity_en <= write_data_i[0];
          32'h14: stopbit <= write_data_i[0]; 
        //   default: begin
        //            baudrate <= 32'h9600;
        //            parity_en <= 1'h1;
        //            stopbit <= 1'h1;
        //            data <= 8'b0;
        //   end
        endcase
        end
    end      

    end
       
    // if (addr_i == 32'h0c  & busy_o == 0) baudrate = write_data_i[16:0];
        // else if (addr_i == 32'h24 & write_req) baudrate = 32'h9600;
        // if (addr_i == 32'h10  & busy_o == 0) parity_en = write_data_i[0];
        // else if (addr_i == 32'h24 & write_req) parity_en = 1'h1;
        // if (addr_i == 32'h14  & busy_o == 0) stopbit = write_data_i[0];     
        // else if (addr_i == 32'h24 & write_req) stopbit = 1'h1;

   //read logic
   always_ff @(posedge clk_i) begin
      if (read_req) begin
      case (addr_i)
          32'h00: read_data_o <= data;
          32'h04: read_data_o <= valid;
          32'h08: read_data_o <= busy;
          32'h0C: read_data_o <= baudrate;
          32'h10: read_data_o <= parity_en;
          32'h14: read_data_o <= stopbit;
         default: read_data_o <= read_data_o;
      endcase
      end
      else read_data_o <= 0;
    end
   
    //rst logic
    always_comb begin
     if (write_data_i == 32'd1 & write_req) rst_valid = 1;
     else rst_valid = 0;
    end
    //busy logic
   always_ff @(posedge clk_i)
    begin
      if (rst)
        begin
            busy <= 1'b0;
        end
      else begin
        busy <= busy_o;
      end
    end
    //data logic
    always_ff @(posedge clk_i)
    begin
      if (rx_valid) data <= rx_data;
      else if (~rst & ~busy & write_req & addr_i == 32'h00 )
         data <= write_data_i[7:0];
      else if (rst)
         data <= 0;
    end
    //valid logic
    always_ff @(posedge clk_i) begin
      if (interrupt_return_i | (addr_i == 32'h00 & read_req) | rst) begin
          valid <= 0;
      end
       else if (rx_valid) begin
          valid <= 1;
       end
    end

    assign interrupt_request_o = valid;

    // always_comb begin
    //   if (addr_i == 32'h24 & write_req) begin
    //     baudrate = 32'h9600;
    //     parity_en = 1'h1;
    //     stopbit = 1'h1;
    //     data = 8'h0;
    //     valid = '0;
    //     busy = '0;
    //   end
    // end

endmodule





