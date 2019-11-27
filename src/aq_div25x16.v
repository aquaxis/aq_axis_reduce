/*
 * Copyright (C)2006-2015 AQUAXIS TECHNOLOGY.
 *  Don't remove this header. 
 * When you use this source, there is a need to inherit this header.
 *
 * License
 *  For no commercial -
 *   License:     The Open Software License 3.0
 *   License URI: http://www.opensource.org/licenses/OSL-3.0
 *
 *  For commmercial -
 *   License:     AQUAXIS License 1.0
 *   License URI: http://www.aquaxis.com/licenses
 *
 * For further information please contact.
 *  URI:    http://www.aquaxis.com/
 *  E-Mail: info(at)aquaxis.com
 */
module aq_div25x16(
  input      RST_N,
  input      CLK,
  input [24:0]  DINA,
  input [15:0]  DINB,
  output [7:0]  DOUT
);

reg [25:0] r1r, r2r, r3r, r4r, r5r, r6r, r7r, r8r;
reg [15:0] s1r, s2r, s3r, s4r, s5r, s6r, s7r;

always @(negedge RST_N or posedge CLK) begin
  if(!RST_N) begin
    r1r <= 26'd0;
    r2r <= 26'd0;
    r3r <= 26'd0;
    r4r <= 26'd0;
    r5r <= 26'd0;
    r6r <= 26'd0;
    r7r <= 26'd0;
    r8r <= 26'd0;
    s1r <= 16'd0;
    s2r <= 16'd0;
    s3r <= 16'd0;
    s4r <= 16'd0;
    s5r <= 16'd0;
    s6r <= 16'd0;
    s7r <= 16'd0;
  end else begin
    // 1st
    r1r[25:7]  <= ({1'b 1,DINA[24:8] }) - ({2'b 00,DINB});
    r1r[7:0]  <= DINA[7:0];
    s1r     <= DINB;
    // 2nd
    if((r1r[25] == 1'b 0)) begin
      r2r[24:7]  <= ({1'b 0,r1r[23:7] }) + ({2'b 00,s1r});
    end else begin
      r2r[24:7]  <= ({1'b 1,r1r[23:7] }) - ({2'b 00,s1r});
    end
    r2r[25]    <= r1r[25];
    r2r[6:0]  <= r1r[6:0];
    s2r     <= s1r;
    // 3rd
    if((r2r[24] == 1'b 0)) begin
      r3r[23:6]  <= ({1'b 0,r2r[22:6] }) + ({2'b 00,s2r});
    end else begin
      r3r[23:6]  <= ({1'b 1,r2r[22:6] }) - ({2'b 00,s2r});
    end
    r3r[25:24]  <= r2r[25:24];
    r3r[5:0]  <= r2r[5:0];
    s3r     <= s2r;
    // 4th
    if((r3r[23] == 1'b 0)) begin
      r4r[22:5]  <= ({1'b 0,r3r[21:5] }) + ({2'b 00,s3r});
    end else begin
      r4r[22:5]  <= ({1'b 1,r3r[21:5] }) - ({2'b 00,s3r});
    end
    r4r[25:23]  <= r3r[25:23];
    r4r[4:0]  <= r3r[4:0];
    s4r     <= s3r;
    // 5th
    if((r4r[22] == 1'b 0)) begin
      r5r[21:4]  <= ({1'b 0,r4r[20:4] }) + ({2'b 00,s4r});
    end else begin
      r5r[21:4]  <= ({1'b 1,r4r[20:4] }) - ({2'b 00,s4r});
    end
    r5r[25:22]  <= r4r[25:22];
    r5r[3:0]  <= r4r[3:0];
    s5r     <= s4r;
    // 6th
    if((r5r[21] == 1'b 0)) begin
      r6r[20:3]  <= ({1'b 0,r5r[19:3] }) + ({2'b 00,s5r});
    end else begin
      r6r[20:3]  <= ({1'b 1,r5r[19:3] }) - ({2'b 00,s5r});
    end
    r6r[25:21]  <= r5r[25:21];
    r6r[2:0]  <= r5r[2:0];
    s6r     <= s5r;
    // 7th
    if((r6r[20] == 1'b 0)) begin
      r7r[19:2]  <= ({1'b 0,r6r[18:2] }) + ({2'b 00,s6r});
    end else begin
      r7r[19:2]  <= ({1'b 1,r6r[18:2] }) - ({2'b 00,s6r});
    end
    r7r[25:20]  <= r6r[25:20];
    r7r[1:0]  <= r6r[1:0];
    s7r     <= s6r;
    // 8th
    if((r7r[19] == 1'b 0)) begin
      r8r[18:1]  <= ({1'b 0,r7r[17:1] }) + ({2'b 00,s7r});
    end else begin
      r8r[18:1]  <= ({1'b 1,r7r[17:1] }) - ({2'b 00,s7r});
    end
    r8r[25:19]  <= r7r[25:19];
    end
end

assign DOUT = r8r[25:18];

endmodule
