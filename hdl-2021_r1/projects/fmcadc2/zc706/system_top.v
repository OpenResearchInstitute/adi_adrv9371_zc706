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

module system_top #(
    parameter RX_JESD_L = 8
  ) (

  inout       [14:0]      ddr_addr,
  inout       [ 2:0]      ddr_ba,
  inout                   ddr_cas_n,
  inout                   ddr_ck_n,
  inout                   ddr_ck_p,
  inout                   ddr_cke,
  inout                   ddr_cs_n,
  inout       [ 3:0]      ddr_dm,
  inout       [31:0]      ddr_dq,
  inout       [ 3:0]      ddr_dqs_n,
  inout       [ 3:0]      ddr_dqs_p,
  inout                   ddr_odt,
  inout                   ddr_ras_n,
  inout                   ddr_reset_n,
  inout                   ddr_we_n,

  inout                   fixed_io_ddr_vrn,
  inout                   fixed_io_ddr_vrp,
  inout       [53:0]      fixed_io_mio,
  inout                   fixed_io_ps_clk,
  inout                   fixed_io_ps_porb,
  inout                   fixed_io_ps_srstb,

  inout       [14:0]      gpio_bd,

  output                  hdmi_out_clk,
  output                  hdmi_vsync,
  output                  hdmi_hsync,
  output                  hdmi_data_e,
  output      [23:0]      hdmi_data,

  output                  spdif,

  input                   sys_rst,
  input                   sys_clk_p,
  input                   sys_clk_n,

  output      [13:0]      ddr3_addr,
  output      [ 2:0]      ddr3_ba,
  output                  ddr3_cas_n,
  output      [ 0:0]      ddr3_ck_n,
  output      [ 0:0]      ddr3_ck_p,
  output      [ 0:0]      ddr3_cke,
  output      [ 0:0]      ddr3_cs_n,
  output      [ 7:0]      ddr3_dm,
  inout       [63:0]      ddr3_dq,
  inout       [ 7:0]      ddr3_dqs_n,
  inout       [ 7:0]      ddr3_dqs_p,
  output      [ 0:0]      ddr3_odt,
  output                  ddr3_ras_n,
  output                  ddr3_reset_n,
  output                  ddr3_we_n,

  inout                   iic_scl,
  inout                   iic_sda,

  input                   rx_ref_clk_p,
  input                   rx_ref_clk_n,
  output                  rx_sysref_p,
  output                  rx_sysref_n,
  output                  rx_sync_p,
  output                  rx_sync_n,
  input  [RX_JESD_L-1:0]  rx_data_p,
  input  [RX_JESD_L-1:0]  rx_data_n,

  inout                   adc_irq,
  inout                   adc_fd,

  output                  spi_adc_csn,
  output                  spi_adc_clk,
  inout                   spi_adc_sdio,

  output                  spi_adf4355_data_or_csn_0,
  output                  spi_adf4355_clk_or_csn_1,
  output                  spi_adf4355_le_or_clk,
  inout                   spi_adf4355_ce_or_sdio);

  // internal signals

  wire    [63:0]  gpio_i;
  wire    [63:0]  gpio_o;
  wire    [63:0]  gpio_t;
  wire    [ 2:0]  spi0_csn;
  wire            spi0_clk;
  wire            spi0_mosi;
  wire            spi0_miso;
  wire    [ 2:0]  spi1_csn;
  wire            spi1_clk;
  wire            spi1_mosi;
  wire            spi1_miso;
  wire            rx_ref_clk;
  wire            rx_sync;
  wire            rx_clk;
  wire            rx_sysref;
  wire    [7:0]   rx_data_p_loc;
  wire    [7:0]   rx_data_n_loc;

  // instantiations

  IBUFDS_GTE2 i_ibufds_rx_ref_clk (
    .CEB (1'd0),
    .I (rx_ref_clk_p),
    .IB (rx_ref_clk_n),
    .O (rx_ref_clk),
    .ODIV2 ());

  OBUFDS i_obufds_rx_sysref (
    .I (rx_sysref),
    .O (rx_sysref_p),
    .OB (rx_sysref_n));

  OBUFDS i_obufds_rx_sync (
    .I (rx_sync),
    .O (rx_sync_p),
    .OB (rx_sync_n));

  // spi

  fmcadc2_spi i_fmcadc2_spi (
    .spi_adf4355 (gpio_o[36]),
    .spi_adf4355_ce (gpio_o[37]),
    .spi_clk (spi0_clk),
    .spi_csn (spi0_csn),
    .spi_mosi (spi0_mosi),
    .spi_miso (spi0_miso),
    .spi_adc_csn (spi_adc_csn),
    .spi_adc_clk (spi_adc_clk),
    .spi_adc_sdio (spi_adc_sdio),
    .spi_adf4355_data_or_csn_0 (spi_adf4355_data_or_csn_0),
    .spi_adf4355_clk_or_csn_1 (spi_adf4355_clk_or_csn_1),
    .spi_adf4355_le_or_clk (spi_adf4355_le_or_clk),
    .spi_adf4355_ce_or_sdio (spi_adf4355_ce_or_sdio));

  ad_iobuf #(.DATA_WIDTH(2)) i_iobuf (
    .dio_t (gpio_t[33:32]),
    .dio_i (gpio_o[33:32]),
    .dio_o (gpio_i[33:32]),
    .dio_p ({adc_irq, adc_fd}));

  ad_iobuf #(.DATA_WIDTH(15)) i_iobuf_bd (
    .dio_t (gpio_t[14:0]),
    .dio_i (gpio_o[14:0]),
    .dio_o (gpio_i[14:0]),
    .dio_p (gpio_bd));

  assign gpio_i[63:34] = gpio_o[63:34];
  assign gpio_i[31:15] = gpio_o[31:15];

  ad_sysref_gen i_sysref (
    .core_clk (rx_clk),
    .sysref_en (gpio_o[34]),
    .sysref_out (rx_sysref));

  system_wrapper i_system_wrapper (
    .ddr3_addr (ddr3_addr),
    .ddr3_ba (ddr3_ba),
    .ddr3_cas_n (ddr3_cas_n),
    .ddr3_ck_n (ddr3_ck_n),
    .ddr3_ck_p (ddr3_ck_p),
    .ddr3_cke (ddr3_cke),
    .ddr3_cs_n (ddr3_cs_n),
    .ddr3_dm (ddr3_dm),
    .ddr3_dq (ddr3_dq),
    .ddr3_dqs_n (ddr3_dqs_n),
    .ddr3_dqs_p (ddr3_dqs_p),
    .ddr3_odt (ddr3_odt),
    .ddr3_ras_n (ddr3_ras_n),
    .ddr3_reset_n (ddr3_reset_n),
    .ddr3_we_n (ddr3_we_n),
    .ddr_addr (ddr_addr),
    .ddr_ba (ddr_ba),
    .ddr_cas_n (ddr_cas_n),
    .ddr_ck_n (ddr_ck_n),
    .ddr_ck_p (ddr_ck_p),
    .ddr_cke (ddr_cke),
    .ddr_cs_n (ddr_cs_n),
    .ddr_dm (ddr_dm),
    .ddr_dq (ddr_dq),
    .ddr_dqs_n (ddr_dqs_n),
    .ddr_dqs_p (ddr_dqs_p),
    .ddr_odt (ddr_odt),
    .ddr_ras_n (ddr_ras_n),
    .ddr_reset_n (ddr_reset_n),
    .ddr_we_n (ddr_we_n),
    .fixed_io_ddr_vrn (fixed_io_ddr_vrn),
    .fixed_io_ddr_vrp (fixed_io_ddr_vrp),
    .fixed_io_mio (fixed_io_mio),
    .fixed_io_ps_clk (fixed_io_ps_clk),
    .fixed_io_ps_porb (fixed_io_ps_porb),
    .fixed_io_ps_srstb (fixed_io_ps_srstb),
    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_t (gpio_t),
    .hdmi_data (hdmi_data),
    .hdmi_data_e (hdmi_data_e),
    .hdmi_hsync (hdmi_hsync),
    .hdmi_out_clk (hdmi_out_clk),
    .hdmi_vsync (hdmi_vsync),
    .iic_main_scl_io (iic_scl),
    .iic_main_sda_io (iic_sda),
    .rx_data_0_n (rx_data_n_loc[0]),
    .rx_data_0_p (rx_data_p_loc[0]),
    .rx_data_1_n (rx_data_n_loc[1]),
    .rx_data_1_p (rx_data_p_loc[1]),
    .rx_data_2_n (rx_data_n_loc[2]),
    .rx_data_2_p (rx_data_p_loc[2]),
    .rx_data_3_n (rx_data_n_loc[3]),
    .rx_data_3_p (rx_data_p_loc[3]),
    .rx_data_4_n (rx_data_n_loc[4]),
    .rx_data_4_p (rx_data_p_loc[4]),
    .rx_data_5_n (rx_data_n_loc[5]),
    .rx_data_5_p (rx_data_p_loc[5]),
    .rx_data_6_n (rx_data_n_loc[6]),
    .rx_data_6_p (rx_data_p_loc[6]),
    .rx_data_7_n (rx_data_n_loc[7]),
    .rx_data_7_p (rx_data_p_loc[7]),
    .rx_ref_clk_0 (rx_ref_clk),
    .rx_sync_0 (rx_sync),
    .rx_sysref_0 (rx_sysref),
    .rx_core_clk (rx_clk),
    .spdif (spdif),
    .spi0_clk_i (spi0_clk),
    .spi0_clk_o (spi0_clk),
    .spi0_csn_0_o (spi0_csn[0]),
    .spi0_csn_1_o (spi0_csn[1]),
    .spi0_csn_2_o (spi0_csn[2]),
    .spi0_csn_i (1'b1),
    .spi0_sdi_i (spi0_miso),
    .spi0_sdo_i (spi0_mosi),
    .spi0_sdo_o (spi0_mosi),
    .spi1_clk_i (spi1_clk),
    .spi1_clk_o (spi1_clk),
    .spi1_csn_0_o (spi1_csn[0]),
    .spi1_csn_1_o (spi1_csn[1]),
    .spi1_csn_2_o (spi1_csn[2]),
    .spi1_csn_i (1'b1),
    .spi1_sdi_i (1'b1),
    .spi1_sdo_i (spi1_mosi),
    .spi1_sdo_o (spi1_mosi),
    .sys_clk_clk_n (sys_clk_n),
    .sys_clk_clk_p (sys_clk_p),
    .sys_rst (sys_rst));

  assign rx_data_p_loc[RX_JESD_L-1:0] = rx_data_p[RX_JESD_L-1:0];
  assign rx_data_n_loc[RX_JESD_L-1:0] = rx_data_n[RX_JESD_L-1:0];

endmodule

// ***************************************************************************
// ***************************************************************************
