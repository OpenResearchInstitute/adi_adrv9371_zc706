#
# The ADI JESD204 Core is released under the following license, which is
# different than all other HDL cores in this repository.
#
# Please read this, and understand the freedoms and responsibilities you have
# by using this source code/core.
#
# The JESD204 HDL, is copyright © 2016-2017 Analog Devices Inc.
#
# This core is free software, you can use run, copy, study, change, ask
# questions about and improve this core. Distribution of source, or resulting
# binaries (including those inside an FPGA or ASIC) require you to release the
# source of the entire project (excluding the system libraries provide by the
# tools/compiler/FPGA vendor). These are the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
#
# This core  is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License version 2
# along with this source code, and binary.  If not, see
# <http://www.gnu.org/licenses/>.
#
# Commercial licenses (with commercial support) of this JESD204 core are also
# available under terms different than the General Public License. (e.g. they
# do not require you to accompany any image (FPGA or ASIC) using the JESD204
# core with any corresponding source code.) For these alternate terms you must
# purchase a license from Analog Devices Technology Licensing Office. Users
# interested in such a license should contact jesd204-licensing@analog.com for
# more information. This commercial license is sub-licensable (if you purchase
# chips from Analog Devices, incorporate them into your PCB level product, and
# purchase a JESD204 license, end users of your product will also have a
# license to use this core in a commercial setting without releasing their
# source code).
#
# In addition, we kindly ask you to acknowledge ADI in any program, application
# or publication in which you use this JESD204 HDL core. (You are not required
# to do so; it is up to your common sense to decide whether you want to comply
# with this request or not.) For general publications, we suggest referencing :
# “The design and implementation of the JESD204 HDL Core used in this project
# is copyright © 2016-2017, Analog Devices, Inc.”
#

source ../../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

global VIVADO_IP_LIBRARY

adi_ip_create jesd204_tx
adi_ip_files jesd204_tx [list \
  "jesd204_tx_lane.v" \
  "jesd204_tx_lane_64b.v" \
  "jesd204_tx_header.v" \
  "jesd204_tx_gearbox.v" \
  "jesd204_tx_ctrl.v" \
  "jesd204_tx_constr.ttcl" \
  "jesd204_tx_ooc.ttcl" \
  "../../common/ad_upack.v" \
  "jesd204_tx.v" \
  "bd/bd.tcl"
]

adi_ip_properties_lite jesd204_tx
adi_ip_ttcl jesd204_tx "jesd204_tx_constr.ttcl"
adi_ip_ttcl jesd204_tx "jesd204_tx_ooc.ttcl"
adi_ip_bd jesd204_tx "bd/bd.tcl"

adi_ip_add_core_dependencies [list \
  analog.com:$VIVADO_IP_LIBRARY:jesd204_common:1.0 \
  analog.com:$VIVADO_IP_LIBRARY:util_cdc:1.0 \
]

set_property display_name "ADI JESD204 Transmit" [ipx::current_core]
set_property description "ADI JESD204 Transmit" [ipx::current_core]

adi_add_bus "tx_data" "slave" \
  "xilinx.com:interface:axis_rtl:1.0" \
  "xilinx.com:interface:axis:1.0" \
  { \
    { "tx_valid" "TVALID" } \
    { "tx_ready" "TREADY" } \
    { "tx_data" "TDATA" } \
  }

adi_add_multi_bus 16 "tx_phy" "master" \
  "xilinx.com:display_jesd204:jesd204_tx_bus_rtl:1.0" \
  "xilinx.com:display_jesd204:jesd204_tx_bus:1.0" \
  [list \
    { "phy_data" "txdata" 32 "(spirit:decode(id('MODELPARAM_VALUE.DATA_PATH_WIDTH')) * 8)"} \
    { "phy_charisk" "txcharisk" 4 "(spirit:decode(id('MODELPARAM_VALUE.DATA_PATH_WIDTH')))"} \
    { "phy_header" "txheader" 2} \
  ] \
  "(spirit:decode(id('MODELPARAM_VALUE.NUM_LANES')) > {i})"

adi_add_bus "tx_cfg" "slave" \
  "analog.com:interface:jesd204_tx_cfg_rtl:1.0" \
  "analog.com:interface:jesd204_tx_cfg:1.0" \
  { \
    { "cfg_lanes_disable" "lanes_disable" } \
    { "cfg_links_disable" "links_disable" } \
    { "cfg_octets_per_multiframe" "octets_per_multiframe" } \
    { "cfg_octets_per_frame" "octets_per_frame" } \
    { "cfg_continuous_cgs" "continuous_cgs" } \
    { "cfg_continuous_ilas" "continuous_ilas" } \
    { "cfg_skip_ilas" "skip_ilas" } \
    { "cfg_mframes_per_ilas" "mframes_per_ilas" } \
    { "cfg_disable_char_replacement" "disable_char_replacement" } \
    { "cfg_disable_scrambler" "disable_scrambler" } \
    { "device_cfg_octets_per_multiframe" "device_octets_per_multiframe" } \
    { "device_cfg_octets_per_frame" "device_octets_per_frame" } \
    { "device_cfg_beats_per_multiframe" "device_beats_per_multiframe" } \
    { "device_cfg_lmfc_offset" "device_lmfc_offset" } \
    { "device_cfg_sysref_oneshot" "device_sysref_oneshot" } \
    { "device_cfg_sysref_disable" "device_sysref_disable" } \
  }

adi_add_bus "tx_ilas_config" "master" \
  "analog.com:interface:jesd204_tx_ilas_config_rtl:1.0" \
  "analog.com:interface:jesd204_tx_ilas_config:1.0" \
  { \
    { "ilas_config_rd" "rd" } \
    { "ilas_config_addr" "addr" } \
    { "ilas_config_data" "data" } \
  }

adi_add_bus "tx_event" "master" \
  "analog.com:interface:jesd204_tx_event_rtl:1.0" \
  "analog.com:interface:jesd204_tx_event:1.0" \
  { \
    { "device_event_sysref_alignment_error" "sysref_alignment_error" } \
    { "device_event_sysref_edge" "sysref_edge" } \
  }

adi_add_bus "tx_status" "master" \
  "analog.com:interface:jesd204_tx_status_rtl:1.0" \
  "analog.com:interface:jesd204_tx_status:1.0" \
  { \
    { "status_state" "state" } \
    { "status_sync" "sync" } \
    { "status_synth_params0" "synth_params0" } \
    { "status_synth_params1" "synth_params1" } \
    { "status_synth_params2" "synth_params2" } \
  }

adi_add_bus "tx_ctrl" "slave" \
  "analog.com:interface:jesd204_tx_ctrl_rtl:1.0" \
  "analog.com:interface:jesd204_tx_ctrl:1.0" \
  { \
    { "ctrl_manual_sync_request" "manual_sync_request" } \
  }

adi_add_bus_clock "clk" "tx_cfg:tx_ilas_config:tx_event:tx_status:tx_ctrl" "reset"

adi_add_bus_clock "device_clk" "tx_data" "device_reset"

adi_set_bus_dependency "tx_ilas_config" "tx_ilas_config" \
	"(spirit:decode(id('MODELPARAM_VALUE.LINK_MODE')) = 1)"

adi_set_bus_dependency "tx_ctrl" "tx_ctrl" \
	"(spirit:decode(id('MODELPARAM_VALUE.LINK_MODE')) = 1)"

adi_set_ports_dependency "sync" \
	"(spirit:decode(id('MODELPARAM_VALUE.LINK_MODE')) = 1)"


set cc [ipx::current_core]
set page0 [ipgui::get_pagespec -name "Page 0" -component $cc]

# Link layer mode
set p [ipgui::get_guiparamspec -name "LINK_MODE" -component $cc]
ipgui::move_param -component $cc -order 0 $p -parent $page0
set_property -dict [list \
 "display_name" "Link Layer mode" \
 "tooltip" "Link Layer mode" \
 "widget" "comboBox" \
] $p

set_property -dict [list \
  value_validation_type pairs \
  value_validation_pairs {64B66B 2 8B10B 1} \
] [ipx::get_user_parameters $p -of_objects $cc]


# Data width selection
set param [ipx::get_user_parameters DATA_PATH_WIDTH -of_objects $cc]
set_property -dict [list \
  enablement_tcl_expr {$LINK_MODE==1} \
  value_tcl_expr {expr $LINK_MODE*4} \
] $param


# SYSREF IOB placement
set param [ipx::add_user_parameter SYSREF_IOB $cc]
set_property -dict {value_resolve_type user value_format bool value true} $param

set param [ipgui::add_param -name {SYSREF_IOB} -component $cc -parent $page0]
set_property -dict [list \
  display_name {Place SYSREF in IOB} \
  widget {checkBox} \
  show_label true \
] $param


set clk_group [ipgui::add_group -name {Clock Domain Configuration} -component $cc \
    -parent $page0 -display_name {Clock Domain Configuration}]

set p [ipgui::get_guiparamspec -name "ASYNC_CLK" -component $cc]
ipgui::move_param -component $cc -order 0 $p -parent $clk_group
set_property -dict [list \
  "display_name" "Link and Device Clock Asynchronous" \
  "widget" "checkBox" \
] $p

ipx::create_xgui_files [ipx::current_core]
ipx::save_core [ipx::current_core]
