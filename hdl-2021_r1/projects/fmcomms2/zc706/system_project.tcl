
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project fmcomms2_zc706
adi_project_files fmcomms2_zc706 [list \
  "system_top.v" \
  "system_constr.xdc"\
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/zc706/zc706_system_constr.xdc" ]

adi_project_run fmcomms2_zc706
source $ad_hdl_dir/library/axi_ad9361/axi_ad9361_delay.tcl

