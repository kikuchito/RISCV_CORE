//`timescale 1ns / 1ps


module uart_tx_sb_ctrl(
  //system bus
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic [31:0] addr_i,
  input  logic        req_i,
  input  logic [31:0] write_data_i,
  input  logic        write_enable_i,
  output logic [31:0] read_data_o,
  
  //uart_tx
  output logic         tx_o
    );
    // main
    logic busy;
    logic [16:0] baudrate;
    logic parity_en;
    logic stopbit;
    logic [7:0] data;
    // supporting
    logic valid_tx;
    logic rst_valid;
    logic rst;
    logic  busy_o;
    logic write_req;
    logic read_req;
    logic is_rst_addr;
    logic busy_read;
    logic [7:0] data_reg;
    
    uart_tx tx_inst(
      .clk_i(clk_i),
      .rst_i(rst),
      .tx_o(tx_o),
      .busy_o(busy_o),
      .baudrate_i(baudrate),
      .parity_en_i(parity_en),
      .stopbit_i(stopbit),
      .tx_data_i(data_reg),
      .tx_valid_i(valid_tx)
    );
    
    assign write_req = req_i & write_enable_i;
    assign read_req = ~write_enable_i & req_i;
    assign rst = rst_i | (write_req & addr_i == 32'h24 & rst_valid);
//write logic
  always_ff @(posedge clk_i) begin
    if (rst) begin
            baudrate = 32'h9600;
            parity_en = 1'h1;
            stopbit = 1'h1;
            data <= 8'b0;
        end
    
    else if (~busy & write_req) begin 
        case (addr_i) 
          32'h00: data <= write_data_i[7:0];
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
    //read logic
    always_ff @(posedge clk_i) begin
      if (read_req) begin
      case (addr_i)
          32'h00: read_data_o <= data;
          32'h04: read_data_o <= valid_tx;
          32'h08: read_data_o <= busy;
          32'h0c: read_data_o <= baudrate;
          32'h10: read_data_o <= parity_en;
          32'h14: read_data_o <= stopbit;
         default: read_data_o <= read_data_o;
      endcase
      end
      else read_data_o <= 0;
    end
   //busy reg
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
    //rst
    always_comb begin
     if (write_data_i == 32'd1 & write_req) rst_valid = 1;
     else rst_valid = 0;
    end
    //data
    always_ff @(posedge clk_i)
    begin
       if (~busy & addr_i == 32'h0)
          data_reg <= data;
       else
          data_reg <= 0;
    end
    
    //valid
    always_comb begin
      if (rst) valid_tx <= 1'b0;
      else if (addr_i == 32'h00 & write_req & ~busy)
         valid_tx <= '1;
      else
         valid_tx <= '0;
    end


endmodule

