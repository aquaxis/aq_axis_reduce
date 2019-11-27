module task_axilm(
  // AXI4 Lite Interface
  input         ARESETN,
  input         ACLK,

  // Write Address Channel
  output reg [31:0] AXI_AWADDR,
  output reg [3:0]  AXI_AWCACHE,
  output reg [2:0]  AXI_AWPROT,
  output        AXI_AWVALID,
  input         AXI_AWREADY,

  // Write Data Channel
  output reg [31:0] AXI_WDATA,
  output reg [3:0]  AXI_WSTRB,
  output        AXI_WVALID,
  input         AXI_WREADY,

  // Write Response Channel
  input         AXI_BVALID,
  output reg        AXI_BREADY,
  input [1:0]   AXI_BRESP,

  // Read Address Channel
  output reg [31:0] AXI_ARADDR,
  output reg [3:0]  AXI_ARCACHE,
  output reg [2:0]  AXI_ARPROT,
  output        AXI_ARVALID,
  input         AXI_ARREADY,

  // Read Data Channel
  input [31:0]  AXI_RDATA,
  input [1:0]   AXI_RRESP,
  input         AXI_RVALID,
  output        AXI_RREADY
);

task write;
input [31:0] ADDR;
input [31:0] WDATA;
begin
  @(posedge ACLK);
  wait(AXI_AWREADY);
  AXI_AWADDR  <= ADDR;
  AXI_AWCACHE <= 4'b0011;
  AXI_AWPROT  <= 3'b000;
  AXI_AWVALID <= 1'b1;
  @(posedge ACLK);
  wait(AXI_AWREADY);
  AXI_AWADDR  <= 32'd0;
  AXI_AWCACHE <= 4'b0000;
  AXI_AWPROT  <= 3'b000;
  AXI_AWVALID <= 1'b0;
  @(posedge ACLK);
  wait(AXI_WREADY);
  AXI_WDATA   <= WDATA;
  AXI_WSTRB   <= 4'b1111;
  AXI_WVALID  <= 1'b1;
  AXI_BREADY  <= 1'b1;
  @(posedge ACLK);
  wait(AXI_WREADY);
  AXI_WDATA   <= 32'd0;
  AXI_WSTRB   <= 4'b0000;
  AXI_WVALID  <= 1'b1;
  @(posedge ACLK);
  wait(AXI_BVALID);
  AXI_WVALID  <= 1'b0;
  @(posedge ACLK);

end
endtask

endmodule
