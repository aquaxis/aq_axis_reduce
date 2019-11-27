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
module tb_aq_axis_reduce;

  // Reset&Clock
  reg RST_N;
  reg CLK;

  // Write Address Channel
  wire [31:0] S_AXI_AWADDR;
  wire [3:0]  S_AXI_AWCACHE;
  wire [2:0]  S_AXI_AWPROT;
  wire        S_AXI_AWVALID;
  wire        S_AXI_AWREADY;

  // Write Data Channel
  wire [31:0] S_AXI_WDATA;
  wire [3:0]  S_AXI_WSTRB;
  wire        S_AXI_WVALID;
  wire        S_AXI_WREADY;

  // Write Response Channel
  wire        S_AXI_BVALID;
  wire        S_AXI_BREADY;
  wire [1:0]  S_AXI_BRESP;

  // Read Address Channel
  wire [31:0] S_AXI_ARADDR;
  wire [3:0]  S_AXI_ARCACHE;
  wire [2:0]  S_AXI_ARPROT;
  wire        S_AXI_ARVALID;
  wire        S_AXI_ARREADY;

  // Read Data Channel
  wire [31:0] S_AXI_RDATA;
  wire [1:0]  S_AXI_RRESP;
  wire        S_AXI_RVALID;
  wire        S_AXI_RREADY;

  // AXI Stream wire
  wire        S_AXIS_TCLK;
  wire [31:0] S_AXIS_TDATA;
  wire        S_AXIS_TKEEP;
  wire        S_AXIS_TLAST;
  wire        S_AXIS_TREADY;
  wire [3:0]  S_AXIS_TSTRB;
  wire        S_AXIS_TVALID;

  // AXI Stream wire
  wire        M_AXIS_TCLK;
  wire [31:0] M_AXIS_TDATA;
  wire        M_AXIS_TKEEP;
  wire        M_AXIS_TLAST;
  wire        M_AXIS_TREADY;
  wire [3:0]  M_AXIS_TSTRB;
  wire        M_AXIS_TVALID;

  wire        FSYNC_IN;
  wire        FSYNC_OUT;

  parameter TIME10N = 10;

  always begin
    #(TIME10N/2) CLK = ~CLK;
  end

  initial begin
    // Initialize Inputs
    RST_N = 0;
    CLK = 0;
    #100;
  end


  aq_axis_reduce u_aq_axis_reduce
  (
    // AXI4 Lite Interface
    .ARESETN(RST_N),
    .ACLK(CLK),

    // Write Address Channel
    .S_AXI_AWADDR(S_AXI_AWADDR),
    .S_AXI_AWCACHE(S_AXI_AWCACHE),
    .S_AXI_AWPROT(S_AXI_AWPROT),
    .S_AXI_AWVALID(S_AXI_AWVALID),
    .S_AXI_AWREADY(S_AXI_AWREADY),

    // Write Data Channel
    .S_AXI_WDATA(S_AXI_WDATA),
    .S_AXI_WSTRB(S_AXI_WSTRB),
    .S_AXI_WVALID(S_AXI_WVALID),
    .S_AXI_WREADY(S_AXI_WREADY),

    // Write Response Channel
    .S_AXI_BVALID(S_AXI_BVALID),
    .S_AXI_BREADY(S_AXI_BREADY),
    .S_AXI_BRESP(S_AXI_BRESP),

    // Read Address Channel
    .S_AXI_ARADDR(S_AXI_ARADDR),
    .S_AXI_ARCACHE(S_AXI_ARCACHE),
    .S_AXI_ARPROT(S_AXI_ARPROT),
    .S_AXI_ARVALID(S_AXI_ARVALID),
    .S_AXI_ARREADY(S_AXI_ARREADY),

    // Read Data Channel
    .S_AXI_RDATA(S_AXI_RDATA),
    .S_AXI_RRESP(S_AXI_RRESP),
    .S_AXI_RVALID(S_AXI_RVALID),
    .S_AXI_RREADY(S_AXI_RREADY),

    // AXI Stream input
    .S_AXIS_TCLK(S_AXIS_TCLK),
    .S_AXIS_TDATA(S_AXIS_TDATA),
    .S_AXIS_TKEEP(S_AXIS_TKEEP),
    .S_AXIS_TLAST(S_AXIS_TLAST),
    .S_AXIS_TREADY(S_AXIS_TREADY),
    .S_AXIS_TSTRB(S_AXIS_TSTRB),
    .S_AXIS_TVALID(S_AXIS_TVALID),

    // AXI Stream output
    .M_AXIS_TCLK(M_AXIS_TCLK),
    .M_AXIS_TDATA(M_AXIS_TDATA),
    .M_AXIS_TKEEP(M_AXIS_TKEEP),
    .M_AXIS_TLAST(M_AXIS_TLAST),
    .M_AXIS_TREADY(M_AXIS_TREADY),
    .M_AXIS_TSTRB(M_AXIS_TSTRB),
    .M_AXIS_TVALID(M_AXIS_TVALID),

    .FSYNC_IN(FSYNC_IN),
    .FSYNC_OUT(FSYNC_OUT)
  );

  task_axilm u_task_axilm(
    // AXI4 Lite Interface
    .ARESETN(RST_N),
    .ACLK(CLK),

    // Write Address Channel
    .AXI_AWADDR(S_AXI_AWADDR),
    .AXI_AWCACHE(S_AXI_AWCACHE),
    .AXI_AWPROT(S_AXI_AWPROT),
    .AXI_AWVALID(S_AXI_AWVALID),
    .AXI_AWREADY(S_AXI_AWREADY),

    // Write Data Channel
    .AXI_WDATA(S_AXI_WDATA),
    .AXI_WSTRB(S_AXI_WSTRB),
    .AXI_WVALID(S_AXI_WVALID),
    .AXI_WREADY(S_AXI_WREADY),

    // Write Response Channel
    .AXI_BVALID(S_AXI_BVALID),
    .AXI_BREADY(S_AXI_BREADY),
    .AXI_BRESP(S_AXI_BRESP),

    // Read Address Channel
    .AXI_ARADDR(S_AXI_ARADDR),
    .AXI_ARCACHE(S_AXI_ARCACHE),
    .AXI_ARPROT(S_AXI_ARPROT),
    .AXI_ARVALID(S_AXI_ARVALID),
    .AXI_ARREADY(S_AXI_ARREADY),

    // Read Data Channel
    .AXI_RDATA(S_AXI_RDATA),
    .AXI_RRESP(S_AXI_RRESP),
    .AXI_RVALID(S_AXI_RVALID),
    .AXI_RREADY(S_AXI_RREADY)
  );

/*
  initial begin
    // Initialize Inputs
    RST_N = 0;
    CLK = 0;
    ORG_X = 0;
    ORG_Y = 0;
    CNV_X = 0;
    CNV_Y = 0;
    DIN_WE = 0;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 0;
    DIN_R = 0;
    DIN_G = 0;
    DIN_B = 0;

    // Wait 100 ns for global reset to finish
    #100;
        
    RST_N = 1;
    // Add stimulus here

    @(posedge CLK);

    ORG_X = 4;
    ORG_Y = 4;
    CNV_X = 3;
    CNV_Y = 3;

    // 0,0
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 1;
    DIN_START_Y = 1;
    DIN_A = 'hF0;
    DIN_R = 'hE0;
    DIN_G = 'hD0;
    DIN_B = 'hC0;

    // 1,0
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 1;
    DIN_A = 'hE0;
    DIN_R = 'hD0;
    DIN_G = 'hC0;
    DIN_B = 'hB0;

    // 2,0
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 1;
    DIN_A = 'hD0;
    DIN_R = 'hC0;
    DIN_G = 'hB0;
    DIN_B = 'hA0;

    // 3,0
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 1;
    DIN_A = 'hC0;
    DIN_R = 'hB0;
    DIN_G = 'hA0;
    DIN_B = 'h90;

    // 0,1
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 1;
    DIN_START_Y = 0;
    DIN_A = 'hB0;
    DIN_R = 'hA0;
    DIN_G = 'h90;
    DIN_B = 'h80;

    // 1,1
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 'hA0;
    DIN_R = 'h90;
    DIN_G = 'h80;
    DIN_B = 'h70;

    // 2,1
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 'h90;
    DIN_R = 'h80;
    DIN_G = 'h70;
    DIN_B = 'h60;

    // 3,1
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 'h80;
    DIN_R = 'h70;
    DIN_G = 'h60;
    DIN_B = 'h50;

    // 0,0
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 1;
    DIN_START_Y = 0;
    DIN_A = 'hF0;
    DIN_R = 'hE0;
    DIN_G = 'hD0;
    DIN_B = 'hC0;

    // 1,0
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 'hE0;
    DIN_R = 'hD0;
    DIN_G = 'hC0;
    DIN_B = 'hB0;

    // 2,0
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 'hD0;
    DIN_R = 'hC0;
    DIN_G = 'hB0;
    DIN_B = 'hA0;

    // 3,0
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 'hC0;
    DIN_R = 'hB0;
    DIN_G = 'hA0;
    DIN_B = 'h90;

    // 0,1
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 1;
    DIN_START_Y = 0;
    DIN_A = 'hB0;
    DIN_R = 'hA0;
    DIN_G = 'h90;
    DIN_B = 'h80;

    // 1,1
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 'hA0;
    DIN_R = 'h90;
    DIN_G = 'h80;
    DIN_B = 'h70;

    // 2,1
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 'h90;
    DIN_R = 'h80;
    DIN_G = 'h70;
    DIN_B = 'h60;

    // 3,1
    @(posedge CLK);
    DIN_WE = 1;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 'h80;
    DIN_R = 'h70;
    DIN_G = 'h60;
    DIN_B = 'h50;

    // fin
    @(posedge CLK);
    DIN_WE = 0;
    DIN_START_X = 0;
    DIN_START_Y = 0;
    DIN_A = 0;
    DIN_R = 0;
    DIN_G = 0;
    DIN_B = 0;

    @(posedge CLK);

    repeat (40) @(posedge CLK);
    
    $finish();
  end
*/
endmodule

