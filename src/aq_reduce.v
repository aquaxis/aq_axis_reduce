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
module aq_reduce(
  input         RST_N,
  input         CLK,

  input [15:0]  ORG_X,
  input [15:0]  ORG_Y,
  input [15:0]  CNV_X,
  input [15:0]  CNV_Y,

  input         DIN_WE,
  input         DIN_FSYNC,
  input [31:0]  DIN,

  output        DOUT_OE,
  output        DOUT_FSYNC,
  output        DOUT_LAST,
  output [31:0] DOUT
);

// Pre Buffer
reg [15:0]  pre_org_x, pre_org_y, pre_cnv_x, pre_cnv_y;
reg         pre_din_we, pre_din_fsync, pre_din_start_x, pre_din_start_y;
reg [31:0]  pre_din;
always @( posedge CLK or negedge RST_N ) begin
  if( !RST_N ) begin
    pre_org_x[15:0] <= 16'd0;
    pre_org_y[15:0] <= 16'd0;
    pre_cnv_x[15:0] <= 16'd0;
    pre_cnv_y[15:0] <= 16'd0;
    pre_din_we      <= 1'b0;
    pre_din_fsync   <= 1'b0;
    pre_din[31:0]   <= 32'd0;
  end else begin
    pre_org_x[15:0] <= ORG_X;
    pre_org_y[15:0] <= ORG_Y;
    pre_cnv_x[15:0] <= CNV_X;
    pre_cnv_y[15:0] <= CNV_Y;
    pre_din_we      <= DIN_WE;
    pre_din_fsync   <= DIN_FSYNC;
    pre_din[31:0]   <= DIN;
  end
end

// 1st Buffer
// バッファリング
reg [15:0]  buf_org_x, buf_org_y, buf_cnv_x, buf_cnv_y;
reg         buf_din_we, buf_din_fsync;
reg [31:0]  buf_din;
reg [15:0]  buf_cnt_x, buf_cnt_y;
always @( posedge CLK or negedge RST_N ) begin
  if( !RST_N ) begin
    buf_org_x[15:0] <= 16'd0;
    buf_org_y[15:0] <= 16'd0;
    buf_cnv_x[15:0] <= 16'd0;
    buf_cnv_y[15:0] <= 16'd0;
    buf_din_we      <= 1'b0;
    buf_din_fsync   <= 1'b0;
    buf_din[31:0]   <= 32'd0;
    buf_cnt_x[15:0] <= 16'd0;
    buf_cnt_y[15:0] <= 16'd0;
  end else begin
    buf_org_x[15:0] <= pre_org_x;
    buf_org_y[15:0] <= pre_org_y;
    buf_cnv_x[15:0] <= pre_cnv_x;
    buf_cnv_y[15:0] <= pre_cnv_y;
    buf_din_we      <= pre_din_we;
    buf_din_fsync   <= pre_din_fsync;
    buf_din[31:0]   <= pre_din;
    if(pre_din_fsync) begin
      buf_cnt_x[15:0] <= 16'd0;
      buf_cnt_y[15:0] <= 16'd0;
    end else if(buf_din_we) begin
      if(buf_cnt_x == (buf_org_x - 16'd1)) begin
        buf_cnt_x[15:0] <= 16'd0;
        if(buf_cnt_y == (buf_org_y - 16'd1)) begin
          buf_cnt_y[15:0] <= 16'd0;
        end else begin
          buf_cnt_y       <= buf_cnt_y + 16'd1;
        end
      end else begin
        buf_cnt_x       <= buf_cnt_x + 16'd1;
      end
    end
  end
end

// Stage 1
// 縮小割合の計算
// X
wire          x_valid, y_valid;
wire [15:0]   x_ma, x_mb, y_ma, y_mb;
reg [2:0]     st1_st;
reg [7:0]     st1_da, st1_dr, st1_dg, st1_db;
reg [1:0]     st1_fs;

wire          x_start, y_start;
assign x_start = ((buf_cnt_x == 16'd0) && buf_din_we)?1'b1:1'b0;
assign y_start = ((buf_cnt_x == 16'd0) && (buf_cnt_y == 16'd0) && buf_din_we)?1'b1:1'b0;

wire          w_last;
assign w_last = ((buf_cnt_x == (buf_cnv_x - 16'd1)) && (buf_cnt_y == (buf_cnv_y - 16'd1)) && buf_din_we)?1'b1:1'b0;

aq_calc_size u_aq_calc_size_x(
  .RST_N  ( RST_N       ),
  .CLK    ( CLK         ),
  .ENA    ( buf_din_we  ),
  .START  ( x_start     ),
  .ORG    ( buf_org_x   ),
  .CNV    ( buf_cnv_x   ),
  .VALID  ( x_valid     ),
  .MA     ( x_ma        ),
  .MB     ( x_mb        )
);
// Y
aq_calc_size u_aq_calc_size_y(
  .RST_N  ( RST_N       ),
  .CLK    ( CLK         ),
  .ENA    ( x_start     ),
  .START  ( y_start     ),
  .ORG    ( buf_org_y   ),
  .CNV    ( buf_cnv_y   ),
  .VALID  ( y_valid     ),
  .MA     ( y_ma        ),
  .MB     ( y_mb        )
);
always @( posedge CLK or negedge RST_N ) begin
  if( !RST_N ) begin
    st1_st  <= 3'd0;
    st1_fs  <= 2'd0;
    st1_da  <= 8'd0;
    st1_dr  <= 8'd0;
    st1_dg  <= 8'd0;
    st1_db  <= 8'd0;
  end else begin
    st1_st  <= { y_start, x_start, buf_din_we };
    st1_fs  <= { w_last, buf_din_fsync };
    st1_da  <= buf_din[31:24];
    st1_dr  <= buf_din[23:16];
    st1_dg  <= buf_din[15: 8];
    st1_db  <= buf_din[ 7: 0];
  end
end

// Stage 2
// X方向の拡大
reg [23:0]  st2_da, st2_dr, st2_dg, st2_db, st2_da_b, st2_dr_b, st2_dg_b, st2_db_b;
reg [4:0]   st2_st;
reg [1:0]   st2_fs;
reg [15:0]  st2_y_ma, st2_y_mb;
always @( posedge CLK or negedge RST_N ) begin
  if( !RST_N ) begin
    st2_st    <= 5'd0;
    st2_fs    <= 2'd0;
    st2_y_ma  <= 16'd0;
    st2_y_mb  <= 16'd0;
    st2_da    <= 24'd0;
    st2_dr    <= 24'd0;
    st2_dg    <= 24'd0;
    st2_db    <= 24'd0;
    st2_da_b  <= 24'd0;
    st2_dr_b  <= 24'd0;
    st2_dg_b  <= 24'd0;
    st2_db_b  <= 24'd0;
  end else begin
    st2_st    <= { y_valid, x_valid, st1_st };
    st2_fs    <= st1_fs;
    st2_y_ma  <= y_ma;
    st2_y_mb  <= y_mb;
    st2_da    <= st1_da * x_ma;
    st2_dr    <= st1_dr * x_ma;
    st2_dg    <= st1_dg * x_ma;
    st2_db    <= st1_db * x_ma;
    st2_da_b  <= st1_da * x_mb;
    st2_dr_b  <= st1_dr * x_mb;
    st2_dg_b  <= st1_dg * x_mb;
    st2_db_b  <= st1_db * x_mb;
  end
end

// Stage 3
reg [4:0]   st3_st;
reg [1:0]   st3_fs;
reg [15:0]  st3_y_ma, st3_y_mb;
reg [24:0]  st3_da, st3_dr, st3_dg, st3_db;
reg [24:0]  st3_da_b, st3_dr_b, st3_dg_b, st3_db_b;
always @( posedge CLK or negedge RST_N ) begin
  if( !RST_N ) begin
    st3_st    <= 5'd0;
    st3_fs    <= 2'd0;
    st3_y_ma  <= 16'd0;
    st3_y_mb  <= 16'd0;
    st3_da    <= 25'd0;
    st3_dr    <= 25'd0;
    st3_dg    <= 25'd0;
    st3_db    <= 25'd0;
    st3_da_b  <= 25'd0;
    st3_dr_b  <= 25'd0;
    st3_dg_b  <= 25'd0;
    st3_db_b  <= 25'd0;
  end else begin
    st3_st    <= st2_st;
    st3_fs    <= st2_fs;
    st3_y_ma  <= st2_y_ma;
    st3_y_mb  <= st2_y_mb;
    if( st2_st[0] ) begin
      if( st2_st[1] ) begin
        st3_da    <= {1'b0, st2_da};
        st3_da_b  <= {1'b0, st2_da_b};
        st3_dr    <= {1'b0, st2_dr};
        st3_dr_b  <= {1'b0, st2_dr_b};
        st3_dg    <= {1'b0, st2_dg};
        st3_dg_b  <= {1'b0, st2_dg_b};
        st3_db    <= {1'b0, st2_db};
        st3_db_b  <= {1'b0, st2_db_b};
      end else if( st2_st[3] ) begin
        // VALが立っている時は出力データが揃っていることを示す
        st3_da    <= st2_da + st3_da_b;
        st3_da_b  <= {1'b0, st2_da_b};
        st3_dr    <= st2_dr + st3_dr_b;
        st3_dr_b  <= {1'b0, st2_dr_b};
        st3_dg    <= st2_dg + st3_dg_b;
        st3_dg_b  <= {1'b0, st2_dg_b};
        st3_db    <= st2_db + st3_db_b;
        st3_db_b  <= {1'b0, st2_db_b};
      end else begin
        // VALが立っていない時は計算したデータを保持するタイミングである
        st3_da_b  <= st2_da_b + st3_da_b;
        st3_dr_b  <= st2_dr_b + st3_dr_b;
        st3_dg_b  <= st2_dg_b + st3_dg_b;
        st3_db_b  <= st2_db_b + st3_db_b;
      end
    end
  end
end

// Stage 4-11
wire [7:0]  st11_da, st11_dr, st11_dg, st11_db;
reg [4:0]  st4_st, st5_st, st6_st, st7_st, st8_st, st9_st, st10_st, st11_st; 
reg [1:0]   st4_fs, st5_fs, st6_fs, st7_fs, st8_fs, st9_fs, st10_fs, st11_fs;
reg [15:0]  st4_y_ma, st5_y_ma, st6_y_ma, st7_y_ma, st8_y_ma, st9_y_ma, st10_y_ma, st11_y_ma;
reg [15:0]  st4_y_mb, st5_y_mb, st6_y_mb, st7_y_mb, st8_y_mb, st9_y_mb, st10_y_mb, st11_y_mb;
aq_div25x16 u_aq_div25x16_xa (
  .RST_N  ( RST_N    ),
  .CLK  ( CLK    ),
  .DINA  ( st3_da  ),
  .DINB  ( buf_org_x  ),
  .DOUT  ( st11_da  )
);
aq_div25x16 u_aq_div25x16_xr (
  .RST_N  ( RST_N    ),
  .CLK  ( CLK    ),
  .DINA  ( st3_dr  ),
  .DINB  ( buf_org_x  ),
  .DOUT  ( st11_dr  )
);
aq_div25x16 u_aq_div25x16_xg (
  .RST_N  ( RST_N    ),
  .CLK  ( CLK    ),
  .DINA  ( st3_dg  ),
  .DINB  ( buf_org_x  ),
  .DOUT  ( st11_dg  )
);
aq_div25x16 u_aq_div25x16_xb (
  .RST_N  ( RST_N    ),
  .CLK  ( CLK    ),
  .DINA  ( st3_db  ),
  .DINB  ( buf_org_x  ),
  .DOUT  ( st11_db  )
);
always @( posedge CLK or negedge RST_N ) begin
  if ( !RST_N ) begin
    st4_st  <= 5'd0;
    st5_st  <= 5'd0;
    st6_st  <= 5'd0;
    st7_st  <= 5'd0;
    st8_st  <= 5'd0;
    st9_st  <= 5'd0;
    st10_st  <= 5'd0;
    st11_st  <= 5'd0;
    st4_fs  <= 2'd0;
    st5_fs  <= 2'd0;
    st6_fs  <= 2'd0;
    st7_fs  <= 2'd0;
    st8_fs  <= 2'd0;
    st9_fs  <= 2'd0;
    st10_fs  <= 2'd0;
    st11_fs  <= 2'd0;
    st4_y_ma  <= 16'd0;
    st5_y_ma  <= 16'd0;
    st6_y_ma  <= 16'd0;
    st7_y_ma  <= 16'd0;
    st8_y_ma  <= 16'd0;
    st9_y_ma  <= 16'd0;
    st10_y_ma  <= 16'd0;
    st11_y_ma  <= 16'd0;
    st4_y_mb  <= 16'd0;
    st5_y_mb  <= 16'd0;
    st6_y_mb  <= 16'd0;
    st7_y_mb  <= 16'd0;
    st8_y_mb  <= 16'd0;
    st9_y_mb  <= 16'd0;
    st10_y_mb  <= 16'd0;
    st11_y_mb  <= 16'd0;
  end else begin
    st4_st <=  st3_st;
    st5_st <=  st4_st;
    st6_st <=  st5_st;
    st7_st <=  st6_st;
    st8_st <=  st7_st;
    st9_st <=  st8_st;
    st10_st <=  st9_st;
    st11_st <=  st10_st;
    st4_fs <=  st3_fs;
    st5_fs <=  st4_fs;
    st6_fs <=  st5_fs;
    st7_fs <=  st6_fs;
    st8_fs <=  st7_fs;
    st9_fs <=  st8_fs;
    st10_fs <=  st9_fs;
    st11_fs <=  st10_fs;
    st4_y_ma <= st3_y_ma;
    st5_y_ma <= st4_y_ma;
    st6_y_ma <= st5_y_ma;
    st7_y_ma <= st6_y_ma;
    st8_y_ma <= st7_y_ma;
    st9_y_ma <= st8_y_ma;
    st10_y_ma <= st9_y_ma;
    st11_y_ma <= st10_y_ma;
    st4_y_mb <= st3_y_mb;
    st5_y_mb <= st4_y_mb;
    st6_y_mb <= st5_y_mb;
    st7_y_mb <= st6_y_mb;
    st8_y_mb <= st7_y_mb;
    st9_y_mb <= st8_y_mb;
    st10_y_mb <= st9_y_mb;
    st11_y_mb <= st10_y_mb;
  end
end

// Stage 12
reg [24:0]  st12_da, st12_dr, st12_dg, st12_db;
reg [24:0]  st12_da_b, st12_dr_b, st12_dg_b, st12_db_b;
reg [4:0]   st12_st;
reg [1:0]   st12_fs;
always @( posedge CLK or negedge RST_N ) begin
  if( !RST_N ) begin
    st12_st  <= 5'd0;
    st12_fs  <= 2'd0;
    st12_da   <= 25'd0;
    st12_dr   <= 25'd0;
    st12_dg   <= 25'd0;
    st12_db   <= 25'd0;
    st12_da_b <= 25'd0;
    st12_dr_b <= 25'd0;
    st12_dg_b <= 25'd0;
    st12_db_b <= 25'd0;
  end else begin
    st12_st <=  st11_st;
    st12_fs <=  st11_fs;
    st12_da   <= st11_da * st11_y_ma;
    st12_dr   <= st11_dr * st11_y_ma;
    st12_dg   <= st11_dg * st11_y_ma;
    st12_db   <= st11_db * st11_y_ma;
    st12_da_b <= st11_da * st11_y_mb;
    st12_dr_b <= st11_dr * st11_y_mb;
    st12_dg_b <= st11_dg * st11_y_mb;
    st12_db_b <= st11_db * st11_y_mb;
  end
end

// Stage 13
reg [15:0]  addra, addrb;
reg [4:0]   st13_st;
reg [1:0]   st13_fs;
reg [24:0]  st13_da, st13_dr, st13_dg, st13_db;
reg [24:0]  st13_da_bi, st13_dr_bi, st13_dg_bi, st13_db_bi;
wire [24:0] st13_da_b, st13_dr_b, st13_dg_b, st13_db_b;
wire    st13_we;
assign st13_we = st13_st[3] & st13_st[0];
aq_ram25x16 u_aq_ram25x16_ya(
  .CLKA   ( CLK         ),
  .WEA    ( st13_we     ),
  .ADDRA  ( addra       ),
  .DINA   ( st13_da_bi  ),
  
  .CLKB   ( CLK         ),
  .ADDRB  ( addrb       ),
  .DOUTB  ( st13_da_b   )
);
aq_ram25x16 u_aq_ram25x16_yr(
  .CLKA   ( CLK         ),
  .WEA    ( st13_we     ),
  .ADDRA  ( addra       ),
  .DINA   ( st13_dr_bi  ),
  
  .CLKB   ( CLK         ),
  .ADDRB  ( addrb       ),
  .DOUTB  ( st13_dr_b   )
);
aq_ram25x16 u_aq_ram25x16_yg(
  .CLKA   ( CLK         ),
  .WEA    ( st13_we     ),
  .ADDRA  ( addra       ),
  .DINA   ( st13_dg_bi  ),
  
  .CLKB   ( CLK         ),
  .ADDRB  ( addrb       ),
  .DOUTB  ( st13_dg_b   )
);
aq_ram25x16 u_aq_ram25x16_yb(
  .CLKA   ( CLK         ),
  .WEA    ( st13_we     ),
  .ADDRA  ( addra       ),
  .DINA   ( st13_db_bi  ),
  
  .CLKB   ( CLK         ),
  .ADDRB  ( addrb       ),
  .DOUTB  ( st13_db_b   )
);
always @( posedge CLK or negedge RST_N ) begin
  if( !RST_N ) begin
    addrb  <= 16'd0;
  end else begin
    if( st12_st[1] ) begin
      addrb  <= 16'd0;
    end else if( st12_st[3] ) begin
      addrb <= addrb + 16'd1;
    end
  end
end
always @( posedge CLK or negedge RST_N ) begin
  if( !RST_N ) begin
    st13_st  <= 5'd0;
    st13_fs  <= 2'd0;
    st13_da    <= 25'd0;
    st13_dr    <= 25'd0;
    st13_dg    <= 25'd0;
    st13_db    <= 25'd0;
    st13_da_bi    <= 25'd0;
    st13_dr_bi    <= 25'd0;
    st13_dg_bi    <= 25'd0;
    st13_db_bi    <= 25'd0;
    addra  <= 16'd0;
  end else begin
    st13_st    <= st12_st;
    st13_fs    <= st12_fs;
    if( st12_st[3] ) begin
      if( st12_st[2] ) begin
        st13_da     <= st12_da;
        st13_da_bi  <= st12_da_b;
        st13_dr     <= st12_dr;
        st13_dr_bi  <= st12_dr_b;
        st13_dg     <= st12_dg;
        st13_dg_bi  <= st12_dg_b;
        st13_db     <= st12_db;
        st13_db_bi  <= st12_db_b;
      end else if( st12_st[4] ) begin
        // VALが立っている時は出力データが揃っていることを示す
        st13_da     <= st12_da + st13_da_b;
        st13_da_bi  <= st12_da_b;
        st13_dr     <= st12_dr + st13_dr_b;
        st13_dr_bi  <= st12_dr_b;
        st13_dg     <= st12_dg + st13_dg_b;
        st13_dg_bi  <= st12_dg_b;
        st13_db     <= st12_db + st13_db_b;
        st13_db_bi  <= st12_db_b;
      end else begin
        // VALが立っていない時は計算したデータを保持するタイミングである
        st13_da_bi  <= st12_da_b + st13_da_b;
        st13_dr_bi  <= st12_dr_b + st13_dr_b;
        st13_dg_bi  <= st12_dg_b + st13_dg_b;
        st13_db_bi  <= st12_db_b + st13_db_b;
      end
    end
    if( st12_st[1] ) begin
      addra  <= 16'd0;
    end else if( st12_st[3] ) begin
      addra <= addra + 16'd1;
    end
  end
end

// Stage 14-21
wire [7:0]  st21_da, st21_dr, st21_dg, st21_db;
reg [4:0]  st14_st, st15_st, st16_st, st17_st, st18_st, st19_st, st20_st, st21_st;
reg [1:0]  st14_fs, st15_fs, st16_fs, st17_fs, st18_fs, st19_fs, st20_fs, st21_fs;
aq_div25x16 u_aq_div25x16_ya (
  .RST_N  ( RST_N     ),
  .CLK    ( CLK       ),
  .DINA   ( st13_da   ),
  .DINB   ( buf_org_y ),
  .DOUT   ( st21_da   )
);
aq_div25x16 u_aq_div25x16_yr (
  .RST_N  ( RST_N     ),
  .CLK    ( CLK       ),
  .DINA   ( st13_dr   ),
  .DINB   ( buf_org_y ),
  .DOUT   ( st21_dr   )
);
aq_div25x16 u_aq_div25x16_yg (
  .RST_N  ( RST_N     ),
  .CLK    ( CLK       ),
  .DINA   ( st13_dg   ),
  .DINB   ( buf_org_y ),
  .DOUT   ( st21_dg   )
);
aq_div25x16 u_aq_div25x16_yb (
  .RST_N  ( RST_N     ),
  .CLK    ( CLK       ),
  .DINA   ( st13_db   ),
  .DINB   ( buf_org_y ),
  .DOUT   ( st21_db   )
);
always @( posedge CLK or negedge RST_N ) begin
  if ( !RST_N ) begin
    st14_st <= 5'd0;
    st15_st <= 5'd0;
    st16_st <= 5'd0;
    st17_st <= 5'd0;
    st18_st <= 5'd0;
    st19_st <= 5'd0;
    st20_st <= 5'd0;
    st21_st <= 5'd0;
    st14_fs <= 2'd0;
    st15_fs <= 2'd0;
    st16_fs <= 2'd0;
    st17_fs <= 2'd0;
    st18_fs <= 2'd0;
    st19_fs <= 2'd0;
    st20_fs <= 2'd0;
    st21_fs <= 2'd0;
  end else begin
    st14_st <=  st13_st;
    st15_st <=  st14_st;
    st16_st <=  st15_st;
    st17_st <=  st16_st;
    st18_st <=  st17_st;
    st19_st <=  st18_st;
    st20_st <=  st19_st;
    st21_st <=  st20_st;
    st14_fs <=  st13_fs;
    st15_fs <=  st14_fs;
    st16_fs <=  st15_fs;
    st17_fs <=  st16_fs;
    st18_fs <=  st17_fs;
    st19_fs <=  st18_fs;
    st20_fs <=  st19_fs;
    st21_fs <=  st20_fs;
  end
end

// Stage 22
reg [4:0]  st22_st;
reg [1:0]  st22_fs;
reg [7:0]  st22_da, st22_dr, st22_dg, st22_db;
always @( posedge CLK or negedge RST_N ) begin
  if ( !RST_N ) begin
    st22_st <= 5'd0;
    st22_fs <= 2'd0;
    st22_da <= 8'd0;
    st22_dr <= 8'd0;
    st22_dg <= 8'd0;
    st22_db <= 8'd0;
  end else begin
    st22_st <= st21_st;
    st22_fs <= st21_fs;
    st22_da <= st21_da;
    st22_dr <= st21_dr;
    st22_dg <= st21_dg;
    st22_db <= st21_db;
  end
end

// Output signals
assign DOUT_OE      = ( st22_st[0] )?( st22_st[3] & st22_st[4] ):1'b0;
assign DOUT_FSYNC   = st22_fs[0];
assign DOUT_LAST    = st22_fs[1];
assign DOUT         = {st22_da, st22_dr, st22_dg, st22_db};

endmodule
