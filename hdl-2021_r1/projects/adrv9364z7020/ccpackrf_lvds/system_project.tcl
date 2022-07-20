
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project_create adrv9364z7020_ccpackrf_lvds 0 {} "xc7z020clg400-1"
adi_project_files adrv9364z7020_ccpackrf_lvds [list \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/library/common/ad_adl5904_rst.v" \
  "../common/adrv9364z7020_constr.xdc" \
  "../common/adrv9364z7020_constr_lvds.xdc" \
  "../common/ccpackrf_constr.xdc" \
  "system_top.v" ]

adi_project_run adrv9364z7020_ccpackrf_lvds
source $ad_hdl_dir/library/axi_ad9361/axi_ad9361_delay.tcl

