module task_axism(
  input             RST_N,
  input             CLK,

  output            AXIS_TCLK,
  output reg [31:0] AXIS_TDATA,
  output reg        AXIS_TKEEP,
  output reg        AXIS_TLAST,
  input             AXIS_TREADY,
  output reg [3:0]  AXIS_TSTRB,
  output reg        AXIS_TVALID
);

initial begin
  #0;
  AXIS_TDATA  = 0;
  AXIS_TKEEP  = 0;
  AXIS_TLAST  = 0;
  AXIS_TSTRB  = 0;
  AXIS_TVALID = 0;
end

reg [31:0]  ram[0:1023];

task save;
  input [9:0] ADDR;
  input [31:0] WDATA;
  begin
    ram[ADDR] <= WDATA;
  end
endtask

task stream;
  input [9:0] WORD;
  integer i;
  begin
    wait(AXIS_TREADY);
    @(posedge CLK);

    for( i = 0; i < WORD; i = i + 1)
    begin
      AXIS_TKEEP <= 0;
      AXIS_TVALID <= 1;
      AXIS_TSTRB <= 4'b1111;
      AXIS_TDATA <= ram[i];
      if(i == WORD -1) begin
        AXIS_TLAST <= 1;
      end
      @(posedge CLK);
    end
    AXIS_TDATA  <= 0;
    AXIS_TKEEP  <= 0;
    AXIS_TLAST  <= 0;
    AXIS_TSTRB  <= 0;
    AXIS_TVALID <= 0;
  end
endtask

assign AXIS_TCLK = CLK;

endmodule
