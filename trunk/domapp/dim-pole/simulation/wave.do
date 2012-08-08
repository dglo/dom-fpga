onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /dim_pole_flag_tb/clk40
add wave -noupdate -format Logic /dim_pole_flag_tb/rst
add wave -noupdate -format Literal /dim_pole_flag_tb/systime
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/clk40
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/rst
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/systime
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/discspepulse
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/discmpepulse
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/busy_a
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/busy_b
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/disc
add wave -noupdate -format Literal /dim_pole_flag_tb/dim_pole_flag_inst/state_wr
add wave -noupdate -format Literal /dim_pole_flag_tb/dim_pole_flag_inst/state_rd
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/wren
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/wr_addr
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/rd_addr
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/wr_ptr
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/rd_ptr0
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/rd_ptr1
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/wr_data
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/rd_data
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/dim_pole_cnt0
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/dim_pole_cnt1
add wave -noupdate -format Literal -radix unsigned /dim_pole_flag_tb/dim_pole_flag_inst/delta_t
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/drop0_last
add wave -noupdate -format Logic /dim_pole_flag_tb/dim_pole_flag_inst/drop1_last
add wave -noupdate -format Analog-Step -radix unsigned -scale 0.13385826771653545 /dim_pole_flag_tb/dim_pole_flag_inst/dim_pole_cnt0
add wave -noupdate -format Analog-Step -radix unsigned -scale 0.13385826771653545 /dim_pole_flag_tb/dim_pole_flag_inst/dim_pole_cnt1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {9995042019 ps} 0}
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
update
WaveRestoreZoom {9852691597 ps} {9907909590 ps}
