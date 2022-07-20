// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
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

module axi_adcfifo_wr #(

  parameter   AXI_DATA_WIDTH = 512,
  parameter   AXI_SIZE = 2,
  parameter   AXI_LENGTH = 16,
  parameter   AXI_ADDRESS = 32'h00000000,
  parameter   AXI_ADDRESS_LIMIT = 32'h00000000) (

  // request and synchronization

  input                   dma_xfer_req,

  // read interface

  output  reg             axi_rd_req,
  output  reg [ 31:0]     axi_rd_addr,

  // fifo interface

  input                   adc_rst,
  input                   adc_clk,
  input                   adc_wr,
  input       [AXI_DATA_WIDTH-1:0]  adc_wdata,

  // axi interface

  input                   axi_clk,
  input                   axi_resetn,
  output  reg             axi_awvalid,
  output      [ 3:0]      axi_awid,
  output      [ 1:0]      axi_awburst,
  output                  axi_awlock,
  output      [ 3:0]      axi_awcache,
  output      [ 2:0]      axi_awprot,
  output      [ 3:0]      axi_awqos,
  output      [ 3:0]      axi_awuser,
  output      [ 7:0]      axi_awlen,
  output      [ 2:0]      axi_awsize,
  output  reg [ 31:0]     axi_awaddr,
  input                   axi_awready,
  output                  axi_wvalid,
  output      [AXI_DATA_WIDTH-1:0]  axi_wdata,
  output      [AXI_BYTE_WIDTH-1:0]  axi_wstrb,
  output                  axi_wlast,
  output      [ 3:0]      axi_wuser,
  input                   axi_wready,
  input                   axi_bvalid,
  input       [ 3:0]      axi_bid,
  input       [ 1:0]      axi_bresp,
  input       [ 3:0]      axi_buser,
  output                  axi_bready,

  // axi status

  output  reg             axi_dwovf,
  output  reg             axi_dwunf,
  output  reg             axi_werror);

  localparam  AXI_BYTE_WIDTH = AXI_DATA_WIDTH/8;
  localparam  AXI_AWINCR = AXI_LENGTH * AXI_BYTE_WIDTH;
  localparam  BUF_THRESHOLD_LO = 8'd6;
  localparam  BUF_THRESHOLD_HI = 8'd250;

  // internal registers

  reg     [  2:0]                 adc_xfer_req_m = 'd0;
  reg                             adc_xfer_init = 'd0;
  reg                             adc_xfer_limit = 'd0;
  reg                             adc_xfer_enable = 'd0;
  reg     [ 31:0]                 adc_xfer_addr = 'd0;
  reg     [  7:0]                 adc_waddr = 'd0;
  reg     [  7:0]                 adc_waddr_g = 'd0;
  reg                             adc_rel_enable = 'd0;
  reg                             adc_rel_toggle = 'd0;
  reg     [  7:0]                 adc_rel_waddr = 'd0;
  reg     [  2:0]                 axi_rel_toggle_m = 'd0;
  reg     [  7:0]                 axi_rel_waddr = 'd0;
  reg     [  7:0]                 axi_waddr_m1 = 'd0;
  reg     [  7:0]                 axi_waddr_m2 = 'd0;
  reg     [  7:0]                 axi_waddr = 'd0;
  reg     [  7:0]                 axi_addr_diff = 'd0;
  reg                             axi_almost_full = 'd0;
  reg                             axi_almost_empty = 'd0;
  reg     [  2:0]                 axi_xfer_req_m = 'd0;
  reg                             axi_xfer_init = 'd0;
  reg     [  7:0]                 axi_raddr = 'd0;
  reg                             axi_rd = 'd0;
  reg                             axi_rlast = 'd0;
  reg                             axi_rd_d = 'd0;
  reg                             axi_rlast_d = 'd0;
  reg     [AXI_DATA_WIDTH-1:0]    axi_rdata_d = 'd0;
  reg                             axi_reset = 'd0;

  // internal signals

  wire                            axi_rel_toggle_s;
  wire    [  8:0]                 axi_addr_diff_s;
  wire                            axi_wready_s;
  wire                            axi_rd_s;
  wire                            axi_req_s;
  wire                            axi_rlast_s;
  wire    [AXI_DATA_WIDTH-1:0]    axi_rdata_s;

  // binary to grey conversion

  function [7:0] b2g;
    input [7:0] b;
    reg   [7:0] g;
    begin
      g[7] = b[7];
      g[6] = b[7] ^ b[6];
      g[5] = b[6] ^ b[5];
      g[4] = b[5] ^ b[4];
      g[3] = b[4] ^ b[3];
      g[2] = b[3] ^ b[2];
      g[1] = b[2] ^ b[1];
      g[0] = b[1] ^ b[0];
      b2g = g;
    end
  endfunction

  // grey to binary conversion

  function [7:0] g2b;
    input [7:0] g;
    reg   [7:0] b;
    begin
      b[7] = g[7];
      b[6] = b[7] ^ g[6];
      b[5] = b[6] ^ g[5];
      b[4] = b[5] ^ g[4];
      b[3] = b[4] ^ g[3];
      b[2] = b[3] ^ g[2];
      b[1] = b[2] ^ g[1];
      b[0] = b[1] ^ g[0];
      g2b = b;
    end
  endfunction

  // fifo interface

  always @(posedge adc_clk) begin
    if (adc_rst == 1'b1) begin
      adc_waddr <= 'd0;
      adc_waddr_g <= 'd0;
      adc_xfer_req_m <= 'd0;
      adc_xfer_init <= 'd0;
      adc_xfer_limit <= 'd0;
      adc_xfer_enable <= 'd0;
      adc_xfer_addr <= 'd0;
      adc_rel_enable <= 'd0;
      adc_rel_toggle <= 'd0;
      adc_rel_waddr <= 'd0;
    end else begin
      if ((adc_wr == 1'b1) && (adc_xfer_enable == 1'b1)) begin
        adc_waddr <= adc_waddr + 1'b1;
      end
      adc_waddr_g <= b2g(adc_waddr);
      adc_xfer_req_m <= {adc_xfer_req_m[1:0], dma_xfer_req};
      adc_xfer_init <= adc_xfer_req_m[1] & ~adc_xfer_req_m[2];
      if (adc_xfer_init == 1'b1) begin
        adc_xfer_limit <= 1'd1;
      end else if ((adc_xfer_addr >= AXI_ADDRESS_LIMIT) || (adc_xfer_enable == 1'b0)) begin
        adc_xfer_limit <= 1'd0;
      end
      if (adc_xfer_init == 1'b1) begin
        adc_xfer_enable <= 1'b1;
        adc_xfer_addr <= AXI_ADDRESS;
      end else if ((adc_waddr[1:0] == 2'h3) && (adc_wr == 1'b1)) begin
        adc_xfer_enable <= adc_xfer_req_m[2] & adc_xfer_limit;
        adc_xfer_addr <= adc_xfer_addr + AXI_AWINCR;
      end
      if (adc_waddr[1:0] == 2'h3) begin
        adc_rel_enable <= adc_wr;
      end else begin
        adc_rel_enable <= 1'd0;
      end
      if (adc_rel_enable == 1'b1) begin
        adc_rel_toggle <= ~adc_rel_toggle;
        adc_rel_waddr <= adc_waddr;
      end
    end
  end

  // fifo signals on axi side

  assign axi_rel_toggle_s = axi_rel_toggle_m[2] ^ axi_rel_toggle_m[1];

  always @(posedge axi_clk or negedge axi_resetn) begin
    if (axi_resetn == 1'b0) begin
      axi_rel_toggle_m <= 'd0;
      axi_rel_waddr <= 'd0;
      axi_waddr_m1 <= 'd0;
      axi_waddr_m2 <= 'd0;
      axi_waddr <= 'd0;
    end else begin
      axi_rel_toggle_m <= {axi_rel_toggle_m[1:0], adc_rel_toggle};
      if (axi_rel_toggle_s == 1'b1) begin
        axi_rel_waddr <= adc_rel_waddr;
      end
      axi_waddr_m1 <= adc_waddr_g;
      axi_waddr_m2 <= axi_waddr_m1;
      axi_waddr <= g2b(axi_waddr_m2);
    end
  end

  // overflow (no underflow possible)

  assign axi_addr_diff_s = {1'b1, axi_waddr} - axi_raddr;

  always @(posedge axi_clk or negedge axi_resetn) begin
    if (axi_resetn == 1'b0) begin
      axi_addr_diff <= 'd0;
      axi_almost_full <= 'd0;
      axi_dwunf <= 'd0;
      axi_almost_empty <= 'd0;
      axi_dwovf <= 'd0;
    end else begin
      axi_addr_diff <= axi_addr_diff_s[7:0];
      if (axi_addr_diff > BUF_THRESHOLD_HI) begin
        axi_almost_full <= 1'b1;
        axi_dwunf <= axi_almost_empty;
      end else begin
        axi_almost_full <= 1'b0;
        axi_dwunf <= 1'b0;
      end
      if (axi_addr_diff < BUF_THRESHOLD_LO) begin
        axi_almost_empty <= 1'b1;
        axi_dwovf <= axi_almost_full;
      end else begin
        axi_almost_empty <= 1'b0;
        axi_dwovf <= 1'b0;
      end
    end
  end

  // transfer request is required to keep things in sync

  always @(posedge axi_clk or negedge axi_resetn) begin
    if (axi_resetn == 1'b0) begin
      axi_xfer_req_m <= 'd0;
      axi_xfer_init <= 'd0;
    end else begin
      axi_xfer_req_m <= {axi_xfer_req_m[1:0], dma_xfer_req};
      axi_xfer_init <= axi_xfer_req_m[1] & ~axi_xfer_req_m[2];
    end
  end

  // read is initiated if xfer enabled

  assign axi_wready_s = ~axi_wvalid | axi_wready;
  assign axi_rd_s = (axi_rel_waddr == axi_raddr) ? 1'b0 : axi_wready_s;
  assign axi_req_s = (axi_raddr[1:0] == 2'h0) ? axi_rd_s : 1'b0;
  assign axi_rlast_s = (axi_raddr[1:0] == 2'h3) ? axi_rd_s : 1'b0;

  always @(posedge axi_clk or negedge axi_resetn) begin
    if (axi_resetn == 1'b0) begin
      axi_raddr <= 'd0;
      axi_rd <= 'd0;
      axi_rlast <= 'd0;
      axi_rd_d <= 'd0;
      axi_rlast_d <= 'd0;
      axi_rdata_d <= 'd0;
    end else begin
      if (axi_rd_s == 1'b1) begin
        axi_raddr <= axi_raddr + 1'b1;
      end
      axi_rd <= axi_rd_s;
      axi_rlast <= axi_rlast_s;
      axi_rd_d <= axi_rd;
      axi_rlast_d <= axi_rlast;
      axi_rdata_d <= axi_rdata_s;
    end
  end

  // send read request for every burst about to be completed

  always @(posedge axi_clk or negedge axi_resetn) begin
    if (axi_resetn == 1'b0) begin
      axi_rd_req <= 'd0;
      axi_rd_addr <= 'd0;
    end else begin
      axi_rd_req <= axi_rlast_s;
      if (axi_xfer_init == 1'b1) begin
        axi_rd_addr <= AXI_ADDRESS;
      end else if (axi_rd_req == 1'b1) begin
        axi_rd_addr <= axi_rd_addr + AXI_AWINCR;
      end
    end
  end

  // address channel

  assign axi_awid = 4'b0000;
  assign axi_awburst = 2'b01;
  assign axi_awlock = 1'b0;
  assign axi_awcache = 4'b0010;
  assign axi_awprot = 3'b000;
  assign axi_awqos = 4'b0000;
  assign axi_awuser = 4'b0001;
  assign axi_awlen = AXI_LENGTH - 1;
  assign axi_awsize = AXI_SIZE;

  always @(posedge axi_clk or negedge axi_resetn) begin
    if (axi_resetn == 1'b0) begin
      axi_awvalid <= 'd0;
      axi_awaddr <= 'd0;
    end else begin
      if (axi_awvalid == 1'b1) begin
        if (axi_awready == 1'b1) begin
          axi_awvalid <= 1'b0;
        end
      end else begin
        if (axi_req_s == 1'b1) begin
          axi_awvalid <= 1'b1;
        end
      end
      if (axi_xfer_init == 1'b1) begin
        axi_awaddr <= AXI_ADDRESS;
      end else if ((axi_awvalid == 1'b1) && (axi_awready == 1'b1)) begin
        axi_awaddr <= axi_awaddr + AXI_AWINCR;
      end
    end
  end

  // write channel

  assign axi_wstrb = {AXI_BYTE_WIDTH{1'b1}};
  assign axi_wuser = 4'b0000;

  // response channel

  assign axi_bready = 1'b1;

  always @(posedge axi_clk or negedge axi_resetn) begin
    if (axi_resetn == 1'b0) begin
      axi_werror <= 'd0;
    end else begin
      axi_werror <= axi_bvalid & axi_bready & axi_bresp[1];
    end
  end

  // fifo needs a reset

  always @(posedge axi_clk or negedge axi_resetn) begin
    if (axi_resetn == 1'b0) begin
      axi_reset <= 1'b1;
    end else begin
      axi_reset <= 1'b0;
    end
  end

  // interface handler

  ad_axis_inf_rx #(.DATA_WIDTH(AXI_DATA_WIDTH)) i_axis_inf (
    .clk (axi_clk),
    .rst (axi_reset),
    .valid (axi_rd_d),
    .last (axi_rlast_d),
    .data (axi_rdata_d),
    .inf_valid (axi_wvalid),
    .inf_last (axi_wlast),
    .inf_data (axi_wdata),
    .inf_ready (axi_wready));

  // buffer

  ad_mem #(.DATA_WIDTH(AXI_DATA_WIDTH), .ADDRESS_WIDTH(8)) i_mem (
    .clka (adc_clk),
    .wea (adc_wr),
    .addra (adc_waddr),
    .dina (adc_wdata),
    .clkb (axi_clk),
    .reb (1'b1),
    .addrb (axi_raddr),
    .doutb (axi_rdata_s));

endmodule

// ***************************************************************************
// ***************************************************************************
