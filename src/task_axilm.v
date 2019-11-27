module task_axilm(
  // AXI4 Lite Interface
  input         ARESETN,
  input         ACLK,

  // Write Address Channel
  output reg [31:0] S_AXI_AWADDR,
  output reg [3:0]  S_AXI_AWCACHE,
  output reg [2:0]  S_AXI_AWPROT,
  output        S_AXI_AWVALID,
  input         S_AXI_AWREADY,

  // Write Data Channel
  output reg [31:0] S_AXI_WDATA,
  output reg [3:0]  S_AXI_WSTRB,
  output        S_AXI_WVALID,
  input         S_AXI_WREADY,

  // Write Response Channel
  input         S_AXI_BVALID,
  output reg        S_AXI_BREADY,
  input [1:0]   S_AXI_BRESP,

  // Read Address Channel
  output reg [31:0] S_AXI_ARADDR,
  output reg [3:0]  S_AXI_ARCACHE,
  output reg [2:0]  S_AXI_ARPROT,
  output        S_AXI_ARVALID,
  input         S_AXI_ARREADY,

  // Read Data Channel
  input [31:0]  S_AXI_RDATA,
  input [1:0]   S_AXI_RRESP,
  input         S_AXI_RVALID,
  output        S_AXI_RREADY
);

task write;
input [31:0] ADDR;
input [31:0] WDATA;
begin
  @(posedge ACLK);
  wait(S_AXI_AWREADY);
  S_AXI_AWADDR  <= ADDR;
  S_AXI_AWCACHE <= 4'b0011;
  S_AXI_AWPROT  <= 3'b000;
  S_AXI_AWVALID <= 1'b1;
  @(posedge ACLK);
  wait(S_AXI_AWREADY);
  S_AXI_AWADDR  <= 32'd0;
  S_AXI_AWCACHE <= 4'b0000;
  S_AXI_AWPROT  <= 3'b000;
  S_AXI_AWVALID <= 1'b0;
  @(posedge ACLK);
  wait(S_AXI_WREADY);
  S_AXI_WDATA   <= WDATA;
  S_AXI_WSTRB   <= 4'b1111;
  S_AXI_WVALID  <= 1'b1;
  S_AXI_BREADY  <= 1'b1;
  @(posedge ACLK);
  wait(S_AXI_WREADY);
  S_AXI_WDATA   <= 32'd0;
  S_AXI_WSTRB   <= 4'b0000;
  S_AXI_WVALID  <= 1'b1;
  @(posedge ACLK);
  wait(S_AXI_BVALID);
  S_AXI_WVALID  <= 1'b0;
  @(posedge ACLK);

end
endtask

endmodule
