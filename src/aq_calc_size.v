/*
 * Copyright (C)2006-2019 AQUAXIS TECHNOLOGY.
 *  Don't remove this header. 
 * When you use this source, there is a need to inherit this header.
 *
 * License: MIT License
 *
 * For further information please contact.
 *  URI:    http://www.aquaxis.com/
 *  E-Mail: info(at)aquaxis.com
 */
module aq_calc_size(
  input         RST_N,
  input         CLK,

  input         START,

  input         ENA,
  input [15:0]  ORG,
  input [15:0]  CNV,

  output        VALID,
  output [15:0] MA,
  output [15:0] MB
);

wire [15:0] next_ma, next_mb;
reg [15:0]  reg_ma, reg_mb;

assign next_ma[15:0] = (START || (reg_mb == 16'd0))?16'd0:(ORG-reg_mb>CNV)?CNV:ORG-reg_mb;
assign next_mb[15:0] = (START || (reg_mb == 16'd0))?CNV:(ORG-reg_mb>CNV)?next_ma+reg_mb:CNV-next_ma;

always @(posedge CLK or negedge RST_N) begin
  if(!RST_N) begin
    reg_ma  <= 16'd0;
    reg_mb  <= 16'd0;
  end else begin
    if( ENA ) begin
      reg_ma  <= next_ma;
      reg_mb  <= next_mb;
    end;
  end
end

assign MA     = reg_ma;
assign MB     = reg_mb;
assign VALID  = ((reg_ma > 16'd0) && (reg_mb <= CNV))?1'b1:1'b0;

endmodule
