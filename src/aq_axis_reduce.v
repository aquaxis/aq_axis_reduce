/*
 * AXI4 Lite Slave
 *
 * Copyright (C)2014-2019 AQUAXIS TECHNOLOGY.
 *  Don't remove this header.
 * When you use this source, there is a need to inherit this header.
 *
 * License: MIT License
 *
 * For further information please contact.
 *	URI:    http://www.aquaxis.com/
 *	E-Mail: info(at)aquaxis.com
 */
module aq_axis_reduce
(
  // AXI4 Lite Interface
  input         ARESETN,
  input         ACLK,

  // Write Address Channel
  input [31:0]  S_AXI_AWADDR,
  input [3:0]   S_AXI_AWCACHE,
  input [2:0]   S_AXI_AWPROT,
  input         S_AXI_AWVALID,
  output        S_AXI_AWREADY,

  // Write Data Channel
  input [31:0]  S_AXI_WDATA,
  input [3:0]   S_AXI_WSTRB,
  input         S_AXI_WVALID,
  output        S_AXI_WREADY,

  // Write Response Channel
  output        S_AXI_BVALID,
  input         S_AXI_BREADY,
  output [1:0]  S_AXI_BRESP,

  // Read Address Channel
  input [31:0]  S_AXI_ARADDR,
  input [3:0]   S_AXI_ARCACHE,
  input [2:0]   S_AXI_ARPROT,
  input         S_AXI_ARVALID,
  output        S_AXI_ARREADY,

  // Read Data Channel
  output [31:0] S_AXI_RDATA,
  output [1:0]  S_AXI_RRESP,
  output        S_AXI_RVALID,
  input         S_AXI_RREADY,

  // AXI Stream input
  input         S_AXIS_TCLK,
  input [31:0]  S_AXIS_TDATA,
  input         S_AXIS_TKEEP,
  input         S_AXIS_TLAST,
  output        S_AXIS_TREADY,
  input [3:0]   S_AXIS_TSTRB,
  input         S_AXIS_TVALID,

  // AXI Stream output
  output        M_AXIS_TCLK,
  output [31:0] M_AXIS_TDATA,
  output        M_AXIS_TKEEP,
  output        M_AXIS_TLAST,
  input         M_AXIS_TREADY,
  output [3:0]  M_AXIS_TSTRB,
  output        M_AXIS_TVALID,

  input         FSYNC_IN,
  output        FSYNC_OUT
);

wire [15:0] org_x, org_y, cnv_x, cnv_y;

aq_axils_reduce u_aq_axils_reduce
(
  // AXI4 Lite Interface
  .ARESETN        ( ARESETN       ),
  .ACLK           ( ACLK          ),

  // Write Address Channel
  .S_AXI_AWADDR   ( S_AXI_AWADDR  ),
  .S_AXI_AWCACHE  ( S_AXI_AWCACHE ),
  .S_AXI_AWPROT   ( S_AXI_AWPROT  ),
  .S_AXI_AWVALID  ( S_AXI_AWVALID ),
  .S_AXI_AWREADY  ( S_AXI_AWREADY ),

  // Write Data Channel
  .S_AXI_WDATA    ( S_AXI_WDATA   ),
  .S_AXI_WSTRB    ( S_AXI_WSTRB   ),
  .S_AXI_WVALID   ( S_AXI_WVALID  ),
  .S_AXI_WREADY   ( S_AXI_WREADY  ),

  // Write Response Channel
  .S_AXI_BVALID   ( S_AXI_BVALID  ),
  .S_AXI_BREADY   ( S_AXI_BREADY  ),
  .S_AXI_BRESP    ( S_AXI_BRESP   ),

  // Read Address Channel
  .S_AXI_ARADDR   ( S_AXI_ARADDR  ),
  .S_AXI_ARCACHE  ( S_AXI_ARCACHE ),
  .S_AXI_ARPROT   ( S_AXI_ARPROT  ),
  .S_AXI_ARVALID  ( S_AXI_ARVALID ),
  .S_AXI_ARREADY  ( S_AXI_ARREADY ),

  // Read Data Channel
  .S_AXI_RDATA    ( S_AXI_RDATA   ),
  .S_AXI_RRESP    ( S_AXI_RRESP   ),
  .S_AXI_RVALID   ( S_AXI_RVALID  ),
  .S_AXI_RREADY   ( S_AXI_RREADY  ),

  // Local Interface
  .ORG_X          ( org_x         ), 
  .ORG_Y          ( org_y         ), 
  .CNV_X          ( cnv_x         ), 
  .CNV_Y          ( cnv_y         )
);

wire din_we, dout_oe;
assign din_we = (S_AXIS_TVALID & |(S_AXIS_TSTRB))?1'b1:1'b0;

aq_reduce u_aq_reduce
(
  .RST_N      ( ARESETN       ),
  .CLK        ( S_AXIS_TCLK   ),

  .ORG_X      ( org_x         ),
  .ORG_Y      ( org_y         ),
  .CNV_X      ( cnv_x         ),
  .CNV_Y      ( cnv_y         ),

  .DIN_WE     ( din_we        ),
  .DIN_FSYNC  ( FSYNC_IN      ),
  .DIN        ( S_AXIS_TDATA  ),

  .DOUT_OE    ( dout_oe       ),
  .DOUT_FSYNC ( FSYNC_OUT     ),
  .DOUT_LAST  ( M_AXIS_TLAST  ),
  .DOUT       ( M_AXIS_TDATA  )
);

assign S_AXIS_TREADY  = 1'b1;

assign M_AXIS_TCLK    = S_AXIS_TCLK;
assign M_AXIS_TKEEP   = 1'b0;
assign M_AXIS_TSTRB   = {dout_oe, dout_oe, dout_oe, dout_oe};
assign M_AXIS_TVALID  = (M_AXIS_TREADY & dout_oe)?1'b1:1'b0;

endmodule
