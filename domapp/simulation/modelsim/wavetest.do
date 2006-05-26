onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/clk40
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/rst
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/enable_daq
add wave -noupdate -format Literal /dom_vhd_tst/tb/inst_daq/inst_trigger/enable_ab
add wave -noupdate -format Literal /dom_vhd_tst/tb/inst_daq/inst_trigger/trigger_enable
add wave -noupdate -format Literal /dom_vhd_tst/tb/inst_daq/inst_trigger/cs_trigger
add wave -noupdate -format Literal /dom_vhd_tst/tb/inst_daq/inst_trigger/lc_trigger
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/busy_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/busy_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/rst_trg_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/rst_trg_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/atwdtrigger_sig_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/atwdtrigger_sig_b
add wave -noupdate -format Literal /dom_vhd_tst/tb/inst_daq/inst_trigger/trigger_word
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/multispe
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/onespe
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/multispe_nl
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/onespe_nl
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/atwdtrigger_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/atwdtrigger_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/discspepulse
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/discmpepulse
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/last_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/launch_enable_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/launch_enable_b
add wave -noupdate -format Literal /dom_vhd_tst/tb/inst_daq/inst_trigger/launch_mode_a
add wave -noupdate -format Literal /dom_vhd_tst/tb/inst_daq/inst_trigger/launch_mode_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/trig_lut_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/trig_lut_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/discspe
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/discmpe
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/rst_trigger_spe
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/rst_trigger_mpe
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/discspe_latch
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/discspe_pulse
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/discmpe_latch
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/discmpe_pulse
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/enable_spe_sig_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/enable_mpe_sig_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/enable_spe_sig_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/enable_mpe_sig_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/set_sig_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/rst_sig_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/set_sig_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/rst_sig_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/force_sig
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/atwdtrigger_a_sig
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/atwdtrigger_b_sig
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/triggered_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/triggered_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/spe_enable
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/mpe_enable
add wave -noupdate -format Literal /dom_vhd_tst/tb/inst_daq/inst_trigger/atwdtrigger_a_shift
add wave -noupdate -format Literal /dom_vhd_tst/tb/inst_daq/inst_trigger/atwdtrigger_b_shift
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/trig_veto_short_a
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/trig_veto_short_b
add wave -noupdate -format Logic /dom_vhd_tst/tb/inst_daq/inst_trigger/veto_trig
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
WaveRestoreZoom {0 ns} {256 us}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
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
