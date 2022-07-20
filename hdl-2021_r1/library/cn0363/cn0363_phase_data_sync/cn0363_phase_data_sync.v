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

module cn0363_phase_data_sync (
  input clk,
  input resetn,

  input processing_resetn,

  output s_axis_sample_ready,
  input s_axis_sample_valid,
  input [7:0] s_axis_sample_data,

  input sample_has_stat,

  input conv_done,
  input [31:0] phase,

  output reg m_axis_sample_valid,
  input m_axis_sample_ready,
  output [23:0] m_axis_sample_data,

  output reg m_axis_phase_valid,
  input m_axis_phase_ready,
  output [31:0] m_axis_phase_data,

  output reg overflow
);

reg [1:0] data_counter = 'h00;

reg [31:0] phase_hold = 'h00;
reg [23:0] sample_hold = 'h00;
reg sample_hold_valid = 1'b0;
reg conv_done_d1 = 1'b0;

reg synced = 1'b0;
wire sync;

/* The ADC will do conversions regardless of whether the pipeline is ready or
   not. So we'll always accept new samples and assert overflow if necessary if
   the pipeline is not ready. */
assign s_axis_sample_ready = 1'b1;

// Conversion from offset binary to signed on data
assign m_axis_sample_data = {~sample_hold[23],sample_hold[22:0]};
assign m_axis_phase_data = phase_hold;

always @(posedge clk) begin
  if (conv_done_d1 == 1'b0 && conv_done == 1'b1) begin
    // Is the processing pipeline ready to accept data?
    if (m_axis_sample_valid | m_axis_phase_valid | ~processing_resetn) begin
      overflow <= 1'b1;
    end else begin
      phase_hold <= phase;
      overflow <= 1'b0;
    end
  end else begin
    overflow <= 1'b0;
  end
  conv_done_d1 <= conv_done;
end

always @(posedge clk) begin
  if (processing_resetn == 1'b0) begin
    m_axis_phase_valid <= 1'b0;
    m_axis_sample_valid <= 1'b0;
  end else begin
    /* Data and phase become valid once we have both */
    if (sample_hold_valid == 1'b1) begin
      m_axis_phase_valid <= 1'b1;
      m_axis_sample_valid <= 1'b1;
    end else begin
      if (m_axis_phase_ready == 1'b1) begin
        m_axis_phase_valid <= 1'b0;
      end
      if (m_axis_sample_ready == 1'b1) begin
        m_axis_sample_valid <= 1'b0;
      end
    end
  end
end

/* If the STAT register is included in the sample we get 4 bytes per sample and
 * are able to detect channel swaps and synchronize the first output sample to
 * the first channel. If the STAT register is not included we only get 3 bytes
 * per sample and rely on that the first sample will always be from the first
 * channel */

always @(posedge clk) begin
  sample_hold_valid <= 1'b0;
  if (sample_has_stat == 1'b0) begin
    if (s_axis_sample_valid == 1'b1 && data_counter == 2'h2) begin
      sample_hold_valid <= 1'b1;
    end
  end else begin
    if (s_axis_sample_valid == 1'b1 && data_counter == 2'h3 &&
      (sync == 1'b1 || synced == 1'b1)) begin
      sample_hold_valid <= 1'b1;
    end
  end
end

always @(posedge clk) begin
  if (s_axis_sample_valid == 1'b1 && data_counter != 2'h3) begin
    sample_hold <= {sample_hold[15:0],s_axis_sample_data};
  end
end

always @(posedge clk) begin
  if (s_axis_sample_valid == 1'b1) begin
    if (data_counter == 2'h2 && sample_has_stat == 1'b0) begin
      data_counter <= 2'h0;
    end else begin
      data_counter <= data_counter + 1'b1;
    end
  end
end

assign sync = s_axis_sample_data[3:0] == 'h00 && data_counter == 'h3;

always @(posedge clk) begin
  if (processing_resetn == 1'b0) begin
    synced <= ~sample_has_stat;
  end else begin
    if (s_axis_sample_valid == 1'b1 && sync == 1'b1) begin
      synced <= 1'b1;
    end
  end
end

endmodule
