
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project cn0501_coraz7s

adi_project_files cn0501_coraz7s [list \
    "$ad_hdl_dir/projects/ad7768evb/common/ad7768_if.v" \
    "$ad_hdl_dir/projects/common/coraz7s/coraz7s_system_constr.xdc" \
    "system_top.v" \
    "system_constr.xdc" \
    ]
	
adi_project_run cn0501_coraz7s
