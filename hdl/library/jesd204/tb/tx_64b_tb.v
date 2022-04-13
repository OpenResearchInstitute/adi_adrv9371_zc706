//
// The ADI JESD204 Core is released under the following license, which is
// different than all other HDL cores in this repository.
//
// Please read this, and understand the freedoms and responsibilities you have
// by using this source code/core.
//
// The JESD204 HDL, is copyright © 2016-2017 Analog Devices Inc.
//
// This core is free software, you can use run, copy, study, change, ask
// questions about and improve this core. Distribution of source, or resulting
// binaries (including those inside an FPGA or ASIC) require you to release the
// source of the entire project (excluding the system libraries provide by the
// tools/compiler/FPGA vendor). These are the terms of the GNU General Public
// License version 2 as published by the Free Software Foundation.
//
// This core  is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License version 2
// along with this source code, and binary.  If not, see
// <http://www.gnu.org/licenses/>.
//
// Commercial licenses (with commercial support) of this JESD204 core are also
// available under terms different than the General Public License. (e.g. they
// do not require you to accompany any image (FPGA or ASIC) using the JESD204
// core with any corresponding source code.) For these alternate terms you must
// purchase a license from Analog Devices Technology Licensing Office. Users
// interested in such a license should contact jesd204-licensing@analog.com for
// more information. This commercial license is sub-licensable (if you purchase
// chips from Analog Devices, incorporate them into your PCB level product, and
// purchase a JESD204 license, end users of your product will also have a
// license to use this core in a commercial setting without releasing their
// source code).
//
// In addition, we kindly ask you to acknowledge ADI in any program, application
// or publication in which you use this JESD204 HDL core. (You are not required
// to do so; it is up to your common sense to decide whether you want to comply
// with this request or not.) For general publications, we suggest referencing :
// “The design and implementation of the JESD204 HDL Core used in this project
// is copyright © 2016-2017, Analog Devices, Inc.”
//

`timescale 1ns/100ps

module tx_64b_tb;
  parameter VCD_FILE = "tx_tb.vcd";
  parameter NUM_LANES = 1;
  parameter NUM_LINKS = 1;
  parameter OCTETS_PER_FRAME = 4;
  parameter FRAMES_PER_MULTIFRAME = 32;

  localparam SYSREF_HALF_COUNT = OCTETS_PER_FRAME * FRAMES_PER_MULTIFRAME;

  `include "tb_base.v"

  reg [31:0] counter = 'h00;
  reg [63:0] tx_data = 'h00000000;

  wire tx_ready;
  wire [NUM_LANES-1:0] cfg_lanes_disable;
  wire [NUM_LINKS-1:0] cfg_links_disable;
  wire [9:0] cfg_octets_per_multiframe;
  wire [7:0] cfg_octets_per_frame;
  wire [7:0] device_cfg_lmfc_offset;
  wire [9:0] device_cfg_octets_per_multiframe;
  wire [7:0] device_cfg_octets_per_frame;
  wire [7:0] device_cfg_beats_per_multiframe;
  wire device_cfg_sysref_disable;
  wire device_cfg_sysref_oneshot;
  wire cfg_continuous_cgs;
  wire cfg_continuous_ilas;
  wire cfg_skip_ilas;
  wire [7:0] cfg_mframes_per_ilas;
  wire cfg_disable_char_replacement;
  wire cfg_disable_scrambler;
  wire tx_ilas_config_rd;
  wire [1:0] tx_ilas_config_addr;
  wire [64*NUM_LANES-1:0] tx_ilas_config_data;

  always @(posedge clk) begin
    if (reset == 1'b1) begin
      tx_data <= 'h00000000;
    end else if (tx_ready == 1'b1) begin
      tx_data <= tx_data + 1'b1;
    end
  end

  // DUT with static configuration

  jesd204_tx_static_config #(
    .NUM_LANES(NUM_LANES),
    .NUM_LINKS(NUM_LINKS),
    .OCTETS_PER_FRAME(OCTETS_PER_FRAME),
    .FRAMES_PER_MULTIFRAME(FRAMES_PER_MULTIFRAME),
    .LINK_MODE(2)
  ) i_cfg (
    .clk(clk),

    .cfg_lanes_disable(cfg_lanes_disable),
    .cfg_links_disable(cfg_links_disable),
    .cfg_octets_per_multiframe(cfg_octets_per_multiframe),
    .cfg_octets_per_frame(cfg_octets_per_frame),
    .cfg_continuous_cgs(cfg_continuous_cgs),
    .cfg_continuous_ilas(cfg_continuous_ilas),
    .cfg_skip_ilas(cfg_skip_ilas),
    .cfg_mframes_per_ilas(cfg_mframes_per_ilas),
    .cfg_disable_char_replacement(cfg_disable_char_replacement),
    .cfg_disable_scrambler(cfg_disable_scrambler),

    .device_cfg_octets_per_multiframe(device_cfg_octets_per_multiframe),
    .device_cfg_octets_per_frame(device_cfg_octets_per_frame),
    .device_cfg_beats_per_multiframe(device_cfg_beats_per_multiframe),
    .device_cfg_lmfc_offset(device_cfg_lmfc_offset),
    .device_cfg_sysref_disable(device_cfg_sysref_disable),
    .device_cfg_sysref_oneshot(device_cfg_sysref_oneshot),

    .ilas_config_rd(tx_ilas_config_rd),
    .ilas_config_addr(tx_ilas_config_addr),
    .ilas_config_data(tx_ilas_config_data)
  );

  jesd204_tx #(
    .NUM_LANES(NUM_LANES),
    .NUM_LINKS(NUM_LINKS),
    .LINK_MODE(2),
    .ASYNC_CLK(0)
  ) i_tx (
    .clk(clk),
    .reset(reset),

    .device_clk(clk),
    .device_reset(reset),

    .phy_data(),
    .phy_charisk(),
    .phy_header(),

    .sysref(sysref),
    .lmfc_edge(),
    .lmfc_clk(),

    .sync(),

    .tx_data({NUM_LANES{tx_data}}),
    .tx_ready(tx_ready),
    .tx_eof(),
    .tx_sof(),
    .tx_somf(),
    .tx_eomf(),
    .tx_valid(1'b1),

    .cfg_lanes_disable(cfg_lanes_disable),
    .cfg_links_disable(cfg_links_disable),
    .cfg_octets_per_multiframe(cfg_octets_per_multiframe),
    .cfg_octets_per_frame(cfg_octets_per_frame),
    .cfg_continuous_cgs(cfg_continuous_cgs),
    .cfg_continuous_ilas(cfg_continuous_ilas),
    .cfg_skip_ilas(cfg_skip_ilas),
    .cfg_mframes_per_ilas(cfg_mframes_per_ilas),
    .cfg_disable_char_replacement(cfg_disable_char_replacement),
    .cfg_disable_scrambler(cfg_disable_scrambler),

    .device_cfg_octets_per_multiframe(device_cfg_octets_per_multiframe),
    .device_cfg_octets_per_frame(device_cfg_octets_per_frame),
    .device_cfg_beats_per_multiframe(device_cfg_beats_per_multiframe),
    .device_cfg_lmfc_offset(device_cfg_lmfc_offset),
    .device_cfg_sysref_disable(device_cfg_sysref_disable),
    .device_cfg_sysref_oneshot(device_cfg_sysref_oneshot),

    .ilas_config_rd(tx_ilas_config_rd),
    .ilas_config_addr(tx_ilas_config_addr),
    .ilas_config_data(tx_ilas_config_data),

    .ctrl_manual_sync_request (1'b0),

    .device_event_sysref_edge (),
    .device_event_sysref_alignment_error (),

    .status_sync (),
    .status_state (),

    .status_synth_params0(),
    .status_synth_params1(),
    .status_synth_params2()

  );


endmodule
