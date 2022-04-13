
source $ad_hdl_dir/projects/common/zed/zed_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9

sysid_gen_sys_init_file

# specify ADC resolution -- the design supports 16/14/12 bit resolutions

set adc_resolution 16

# specify the number of active channel -- 1 or 2 or 4

set adc_num_of_channels 2

# specify ADC sampling rate in sample/seconds -- default is 3 MSPS

set adc_sampling_rate 3000000

source ../common/ad738x_bd.tcl

