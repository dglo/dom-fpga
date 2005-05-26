onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_clk
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_rst
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_par
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_par64
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_m66en
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_inta
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_perr
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_serr
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_pme
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_clkrun
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_frame
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_devsel
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_trdy
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_irdy
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_stop
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_ack64
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_req64
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/pci_lock
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/pci_cbe
add wave -noupdate -format Literal -radix hexadecimal /simpletest_vhd_tst/dor_tb_inst/pci_ad
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/pci_req
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/pci_gnt
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/pci_idsel
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/bus_command
add wave -noupdate -divider cable
add wave -noupdate -format Analog-Step -height 50 -radix hexadecimal -scale 0.050000000000000003 /simpletest_vhd_tst/cable_inst/dor_dac
add wave -noupdate -format Analog-Step -height 50 -offset -1500.0 -radix hexadecimal -scale 0.050000000000000003 /simpletest_vhd_tst/cable_inst/dor_adc
add wave -noupdate -format Analog-Step -height 50 -radix hexadecimal -scale 0.050000000000000003 /simpletest_vhd_tst/cable_inst/dom_dac
add wave -noupdate -format Analog-Step -height 50 -radix hexadecimal -scale 0.050000000000000003 /simpletest_vhd_tst/cable_inst/dom_adc
add wave -noupdate -format Literal -height 50 -radix binary /simpletest_vhd_tst/cable_inst/dom_adc
add wave -noupdate -format Literal /simpletest_vhd_tst/cable_inst/doradc
add wave -noupdate -format Literal -radix hexadecimal /simpletest_vhd_tst/cable_inst/dordac
add wave -noupdate -format Literal -radix hexadecimal /simpletest_vhd_tst/cable_inst/domadc
add wave -noupdate -format Literal -radix decimal /simpletest_vhd_tst/cable_inst/domdac
add wave -noupdate -divider {DOR com}
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/dor_inst/ww_adc0_d
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/rxd0
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/rxd1
add wave -noupdate -divider mean_val
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst21/ww_reset
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst21/ww_sreg1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst21/ww_stf
add wave -noupdate -divider adc_to_ser
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ctclr
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ctclr1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/data_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/devclrn
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/devoe
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/devpor
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/dudt_a5_a
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/dudt_a7_a
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/eof_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/get_dudt_stm_act_aclr_a382
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/get_dudt_stm_adudt_ena_a61
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/get_dudt_stm_amin_ena_a70
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/get_dudt_stm_asreg_a33
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/gnd
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/hl_edge
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/inst2
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/inst24
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/max_level
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/min_level
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/rxd
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/signal_lev
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/sreg
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/sreg1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/stf
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/stf_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/vcc
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_a_a
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_clk
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_ctclr
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_ctclr1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_data_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_devclrn
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_devoe
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_devpor
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_eof_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_hl_edge
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_inst2
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_inst24
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_rxd
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_signal_lev
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_sreg
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_sreg1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_stf
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/ww_stf_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/wysi_counter_asload_path_a2_a
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/wysi_counter_asload_path_a4_a
add wave -noupdate -divider {RX uart}
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/a_1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/a_a
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/clk
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ctclr
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ctclr1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/data_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/devclrn
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/devoe
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/devpor
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/dffs_0
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/dffs_1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/dffs_2
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/dffs_3
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/dffs_4
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/dffs_5
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/dffs_6
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/dffs_7
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/eof_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/gnd
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/inst2
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/inst_ashd_areg
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/inst_ashen_areg
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/rxd
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/sreg
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/stf_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_a_1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_a_a
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_ctclr
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_ctclr1
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_data_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_eof_stb
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_inst2
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_rxd
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_sreg
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ww_stf_stb
add wave -noupdate -divider timer
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/wp_timer_ap_a1/after_64ms
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/wp_ctrap_a1/after_64ms
add wave -noupdate -divider {DOR rx level}
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/get_dudt_stm/max_level
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst26/get_dudt_stm/min_level
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/dor_regs_swp_ap_a1/wp_a0_a/rx_chan_ap_a1/inst12/ctclr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {248648 ns} 0}
WaveRestoreZoom {0 ns} {1074176 ns}
configure wave -namecolwidth 220
configure wave -valuecolwidth 105
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
