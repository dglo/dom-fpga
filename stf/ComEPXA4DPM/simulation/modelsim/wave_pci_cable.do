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
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/pci_ad
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/pci_req
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/pci_gnt
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/pci_idsel
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/bus_command
add wave -noupdate -divider cable
add wave -noupdate -format Analog-Step -height 50 -radix hexadecimal -scale 0.050000000000000003 /simpletest_vhd_tst/cable_inst/dor_dac
add wave -noupdate -format Analog-Step -height 50 -offset -1500.0 -radix hexadecimal -scale 0.050000000000000003 /simpletest_vhd_tst/cable_inst/dor_adc
add wave -noupdate -format Analog-Step -height 50 -radix hexadecimal -scale 0.050000000000000003 /simpletest_vhd_tst/cable_inst/dom_dac
add wave -noupdate -format Analog-Step -height 50 -radix hexadecimal -scale 0.050000000000000003 /simpletest_vhd_tst/cable_inst/dom_adc
add wave -noupdate -format Literal /simpletest_vhd_tst/cable_inst/doradc
add wave -noupdate -format Literal /simpletest_vhd_tst/cable_inst/dordac
add wave -noupdate -format Literal /simpletest_vhd_tst/cable_inst/domadc
add wave -noupdate -format Literal /simpletest_vhd_tst/cable_inst/domdac
add wave -noupdate -divider {DOM com}
add wave -noupdate -format Literal /simpletest_vhd_tst/dor_tb_inst/dor_inst/ww_adc0_d
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/rxd0
add wave -noupdate -format Logic /simpletest_vhd_tst/dor_tb_inst/dor_inst/rxd1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {278050 ns} 0}
WaveRestoreZoom {0 ns} {195968 ns}
configure wave -namecolwidth 220
configure wave -valuecolwidth 87
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
