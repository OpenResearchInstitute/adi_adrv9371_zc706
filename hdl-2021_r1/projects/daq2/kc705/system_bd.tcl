## Offload attributes
set adc_offload_type 0
set adc_offload_size [expr 512 * 1024]

set dac_offload_type 0
set dac_offload_size [expr 512 * 1024]

set plddr_offload_axi_data_width 0

## NOTE: With this configuration the #36Kb BRAM utilization is at ~70%

source $ad_hdl_dir/projects/common/kc705/kc705_system_bd.tcl
source ../common/daq2_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

set sys_cstring "ADC_OFFLOAD_TYPE=$adc_offload_type\nDAC_OFFLOAD_TYPE=$dac_offload_type"
sysid_gen_sys_init_file $sys_cstring
