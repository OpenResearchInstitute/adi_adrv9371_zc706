
set_property ASYNC_REG TRUE \
  [get_cells -hier *sync_mode_d*]

set_false_path -to [get_pins -hier -filter {NAME =~ */sync_mode_d1_reg/D}]

