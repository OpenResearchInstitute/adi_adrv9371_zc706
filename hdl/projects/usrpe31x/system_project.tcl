
source ../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project_create usrpe31x 0 {} "xc7z020clg484-1"

adi_project_files usrpe31x [list \
  "system_top.v" \
  "system_constr.xdc" \
  "$ad_hdl_dir/library/common/ad_iobuf.v"]

adi_project_run usrpe31x
source $ad_hdl_dir/library/axi_ad9361/axi_ad9361_delay.tcl

