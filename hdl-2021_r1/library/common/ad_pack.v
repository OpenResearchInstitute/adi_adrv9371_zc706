// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2020 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

// Packer:
//   - pack I_W number of data units into O_W number of data units
//   - data unit defined in bits by UNIT_W e.g 8 is a byte
//
// Constraints:
//   - O_W >= I_W
//   - no backpressure
//
// Data format:
//  idata  [U(I_W-1) .... U(0)]
//  odata [U(O_W-1) .... U(0)] 
//
// e.g 
//  I_W = 4
//  O_W = 6
//  UNIT_W = 8
//
//  idata : [B3,B2,B1,B0],[B7,B6,B5,B4],[B11,B10,B9,B8]
//  odata:                             [B5,B4,B3,B2,B1,B0],[B11,B10,B9,B8,B7,B6]
//

module ad_pack #(
  parameter I_W = 4,
  parameter O_W = 6,
  parameter UNIT_W = 8,
  parameter I_REG = 0,
  parameter O_REG = 1
) (
  input                   clk,
  input                   reset,
  input [I_W*UNIT_W-1:0]  idata,
  input                   ivalid,

  output reg [O_W*UNIT_W-1:0] odata = 'h0,
  output reg                  ovalid = 'b0
);

// Width of shift reg is integer multiple of input data width
localparam SH_W = ((O_W/I_W)+|(O_W % I_W))*I_W;
localparam STEP = O_W % I_W;

reg [O_W*UNIT_W-1:0] idata_packed;
reg [SH_W*UNIT_W-1:0] idata_d = 'h0;
reg ivalid_d  = 'h0;
reg [SH_W*UNIT_W-1:0] idata_dd = 'h0;
reg [SH_W-1:0] in_use = 'b0;
reg [SH_W-1:0] out_mask;

wire [SH_W*UNIT_W-1:0] idata_dd_nx;
wire [SH_W-1:0] in_use_nx;
wire pack_wr;

generate
  if (I_REG) begin : i_reg

    always @(posedge clk) begin
      ivalid_d <= ivalid;
      idata_d <= idata;
    end

  end else begin

    always @(*) begin
      ivalid_d = ivalid;
      idata_d = idata;
    end

  end
endgenerate

assign idata_dd_nx = {idata_d,idata_dd[SH_W*UNIT_W-1:I_W*UNIT_W]};
assign in_use_nx = {{I_W{ivalid_d}},in_use[SH_W-1:I_W]};

always @(posedge clk) begin
  if (reset) begin
    in_use <= 'h0;
  end else if (ivalid_d) begin
    in_use <= in_use_nx &(~out_mask);
  end
end

always @(posedge clk) begin
  if (ivalid_d) begin
    idata_dd <= idata_dd_nx;
  end
end

integer i;
always @(*) begin
  out_mask = 'b0;
  idata_packed = 'bx;
  if (STEP>0) begin
    for (i = SH_W-O_W; i >= 0; i=i-STEP) begin
      if (in_use_nx[i]) begin
        out_mask = {O_W{1'b1}} << i;
        idata_packed = idata_dd_nx >> i*UNIT_W;
      end
    end
  end else begin
    if (in_use_nx[0]) begin
      out_mask = {O_W{1'b1}};
      idata_packed = idata_dd_nx;
    end
  end
end

assign pack_wr = ivalid_d & |in_use_nx[SH_W-O_W:0];

generate
  if (O_REG) begin : o_reg

    always @(posedge clk) begin
      if (reset) begin
        ovalid <= 1'b0;
      end else begin
        ovalid <= pack_wr;
      end
    end

    always @(posedge clk) begin
      odata <= idata_packed;
    end

  end else begin

    always @(*) begin
      ovalid = pack_wr;
      odata = idata_packed;
    end

  end
endgenerate

endmodule

