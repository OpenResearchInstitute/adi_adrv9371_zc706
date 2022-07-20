
set_property -dict {PACKAGE_PIN AJ6  IOSTANDARD LVCMOS18} [get_ports rmii_rx_ref_clk_a]            ; ## D08 FMC_HPC1_LA01_CC_P
set_property -dict {PACKAGE_PIN AJ5  IOSTANDARD LVCMOS18} [get_ports rmii_rx_er_a]                 ; ## D09 FMC_HPC1_LA01_CC_N
set_property -dict {PACKAGE_PIN AE4  IOSTANDARD LVCMOS18 PULLUP true} [get_ports rmii_rx_dv_a]     ; ## H14 FMC_HPC1_LA07_N
set_property -dict {PACKAGE_PIN AE5  IOSTANDARD LVCMOS18 PULLUP true} [get_ports mac_if_sel_0_a]   ; ## G06 FMC_HPC1_LA00_CC_P
set_property -dict {PACKAGE_PIN AD2  IOSTANDARD LVCMOS18} [get_ports {rmii_rxd_a[0]}]              ; ## H07 FMC_HPC1_LA02_P
set_property -dict {PACKAGE_PIN AD1  IOSTANDARD LVCMOS18} [get_ports {rmii_rxd_a[1]}]              ; ## H08 FMC_HPC1_LA02_N
set_property -dict {PACKAGE_PIN AD4  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports rmii_tx_en_a]       ; ## H13 FMC_HPC1_LA07_P
set_property -dict {PACKAGE_PIN AE2  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {rmii_txd_a[0]}]    ; ## D14 FMC_HPC1_LA09_P
set_property -dict {PACKAGE_PIN AE1  IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {rmii_txd_a[1]}]    ; ## D15 FMC_HPC1_LA09_N

set_property -dict {PACKAGE_PIN AE8  IOSTANDARD LVCMOS18 PULLUP true} [get_ports mdio_fmc_a]       ; ## H16 FMC_HPC1_LA11_P
set_property -dict {PACKAGE_PIN AF8  IOSTANDARD LVCMOS18} [get_ports mdc_fmc_a]                    ; ## H17 FMC_HPC1_LA11_N

set_property -dict {PACKAGE_PIN AD10 IOSTANDARD LVCMOS18} [get_ports reset_a]                      ; ## H19 FMC_HPC1_LA15_P
set_property -dict {PACKAGE_PIN AF2  IOSTANDARD LVCMOS18} [get_ports link_st_a]                    ; ## H10 FMC_HPC1_LA04_P
set_property -dict {PACKAGE_PIN AE3  IOSTANDARD LVCMOS18} [get_ports led_0_a]                      ; ## G12 FMC_HPC1_LA08_P
set_property -dict {PACKAGE_PIN AD7  IOSTANDARD LVCMOS18} [get_ports led_ar_c_c2m]                 ; ## G15 FMC_HPC1_LA12_P
set_property -dict {PACKAGE_PIN AD6  IOSTANDARD LVCMOS18} [get_ports led_ar_a_c2m]                 ; ## G16 FMC_HPC1_LA12_N
set_property -dict {PACKAGE_PIN AG8  IOSTANDARD LVCMOS18} [get_ports led_al_c_c2m]                 ; ## D17 FMC_HPC1_LA13_P
set_property -dict {PACKAGE_PIN AH8  IOSTANDARD LVCMOS18} [get_ports led_al_a_c2m]                 ; ## D18 FMC_HPC1_LA13_N

set_property -dict {PACKAGE_PIN Y5   IOSTANDARD LVCMOS18} [get_ports rmii_rx_ref_clk_b]            ; ## D20 FMC_HPC1_LA17_CC_P
set_property -dict {PACKAGE_PIN AA5  IOSTANDARD LVCMOS18} [get_ports rmii_rx_er_b]                 ; ## D21 FMC_HPC1_LA17_CC_N
set_property -dict {PACKAGE_PIN AH11 IOSTANDARD LVCMOS18 PULLUP true} [get_ports rmii_rx_dv_b]     ; ## H29 FMC_HPC1_LA24_N
set_property -dict {PACKAGE_PIN Y8   IOSTANDARD LVCMOS18 PULLUP true} [get_ports mac_if_sel_0_b]   ; ## C22 FMC_HPC1_LA18_CC_P
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS18} [get_ports {rmii_rxd_b[0]}]              ; ## H22 FMC_HPC1_LA19_P
set_property -dict {PACKAGE_PIN AA10 IOSTANDARD LVCMOS18} [get_ports {rmii_rxd_b[1]}]              ; ## H23 FMC_HPC1_LA19_N
set_property -dict {PACKAGE_PIN AH12 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports rmii_tx_en_b]       ; ## H28 FMC_HPC1_LA24_P
set_property -dict {PACKAGE_PIN AC12 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {rmii_txd_b[0]}]    ; ## H25 FMC_HPC1_LA21_P
set_property -dict {PACKAGE_PIN AC11 IOSTANDARD LVCMOS18 SLEW FAST} [get_ports {rmii_txd_b[1]}]    ; ## H26 FMC_HPC1_LA21_N

set_property -dict {PACKAGE_PIN T13  IOSTANDARD LVCMOS18 PULLUP true} [get_ports mdio_fmc_b]       ; ## H31 FMC_HPC1_LA28_P
set_property -dict {PACKAGE_PIN R13  IOSTANDARD LVCMOS18} [get_ports mdc_fmc_b]                    ; ## H32 FMC_HPC1_LA28_N

set_property -dict {PACKAGE_PIN AE9  IOSTANDARD LVCMOS18} [get_ports reset_b]                      ; ## H20 FMC_HPC1_LA15_N
set_property -dict {PACKAGE_PIN AE10 IOSTANDARD LVCMOS18} [get_ports link_st_b]                    ; ## G27 FMC_HPC1_LA25_P
set_property -dict {PACKAGE_PIN AE12 IOSTANDARD LVCMOS18} [get_ports led_0_b]                      ; ## D23 FMC_HPC1_LA23_P
set_property -dict {PACKAGE_PIN T12  IOSTANDARD LVCMOS18} [get_ports led_bl_c_c2m]                 ; ## D26 FMC_HPC1_LA26_P
set_property -dict {PACKAGE_PIN R12  IOSTANDARD LVCMOS18} [get_ports led_bl_a_c2m]                 ; ## D27 FMC_HPC1_LA26_N
set_property -dict {PACKAGE_PIN AG10 IOSTANDARD LVCMOS18} [get_ports led_br_c_c2m]                 ; ## G18 FMC_HPC1_LA16_P
set_property -dict {PACKAGE_PIN AG9  IOSTANDARD LVCMOS18} [get_ports led_br_a_c2m]                 ; ## G19 FMC_HPC1_LA16_N

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rmii_rx_ref_clk_a]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets rmii_rx_ref_clk_b]

create_clock -name rx_clk_a -period 20.0 [get_ports rmii_rx_ref_clk_a]
create_clock -name rx_clk_b -period 20.0 [get_ports rmii_rx_ref_clk_b]

create_clock -name mdio_clk_a -period 400.0 [get_pins i_system_wrapper/system_i/sys_ps8/inst/emio_enet0_mdio_mdc]
create_clock -name mdio_clk_b -period 400.0 [get_pins i_system_wrapper/system_i/sys_ps8/inst/emio_enet1_mdio_mdc]

create_clock -name mdio_0_rx_clk_a -period 40.0 [get_pins i_system_wrapper/system_i/sys_ps8/emio_enet0_gmii_rx_clk]
create_clock -name mdio_0_tx_clk_a -period 40.0 [get_pins i_system_wrapper/system_i/sys_ps8/emio_enet0_gmii_tx_clk]
create_clock -name mdio_0_rx_clk_b -period 40.0 [get_pins i_system_wrapper/system_i/sys_ps8/emio_enet1_gmii_rx_clk]
create_clock -name mdio_0_tx_clk_b -period 40.0 [get_pins i_system_wrapper/system_i/sys_ps8/emio_enet1_gmii_tx_clk]

