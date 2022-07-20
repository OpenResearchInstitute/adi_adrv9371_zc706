
create_clock -period "10.000 ns"  -name sys_clk_100mhz      [get_ports {sys_clk}]
create_clock -period  "4.069 ns"  -name ref_clk0            [get_ports {ref_clk0}]
create_clock -period  "4.069 ns"  -name ref_clk1            [get_ports {ref_clk1}]

derive_pll_clocks
derive_clock_uncertainty

set_false_path -from [get_registers *altera_reset_synchronizer:alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out*]
