
create_clock -period  "40.000 ns"  -name mii_rx_clk_a          [get_ports {mii_rx_clk_a}]
create_clock -period  "40.000 ns"  -name mii_rx_clk_b          [get_ports {mii_rx_clk_b}]
create_clock -period  "40.000 ns"  -name mii_tx_clk_a          [get_ports {mii_tx_clk_a}]
create_clock -period  "40.000 ns"  -name mii_tx_clk_b          [get_ports {mii_tx_clk_b}]

