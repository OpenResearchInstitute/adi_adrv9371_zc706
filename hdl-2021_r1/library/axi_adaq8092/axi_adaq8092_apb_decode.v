// ***************************************************************************
// ***************************************************************************
// Copyright 2022 (c) Analog Devices, Inc. All rights reserved.
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
// ADC ALTERNATE BIT POLARITY DECODE 

`timescale 1ns/100ps

module axi_adaq8092_apb_decode (

  input      [27:0]      adc_data,
  input                  adc_clk,
  input                  adc_abp_enb,
  output     [27:0]      adc_data_decoded);

  // internal registers 
 
  reg        [27:0]      adc_data_decoded_s;

  // internal variable

  integer i; 

  assign adc_data_decoded = adc_abp_enb ? adc_data_decoded_s : adc_data ;

  always @(posedge adc_clk) begin 
    for (i = 0; i <= 13; i = i + 1) begin
      adc_data_decoded_s[2*i+1] = ~adc_data[2*i+1];
      adc_data_decoded_s[2*i] = adc_data[2*i];
    end
  end  

endmodule
