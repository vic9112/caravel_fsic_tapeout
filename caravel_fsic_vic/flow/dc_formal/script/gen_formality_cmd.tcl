#!/usr/bin/tclsh
source ../../common/common.tcl

set fp [open "../script/run_formality_cmd.tcl" w+]
puts $fp "source ../../common/common.tcl"
puts $fp "\n"
puts $fp "set DESIGN_NAME ${DESIGN_NAME}"
puts $fp "\n"
puts $fp "read_db \"\$Std_cell_lib \$Ram_lib\""
puts $fp "\n"
puts $fp "set hdlin_interface_only \"\" \; \# set block_box"
puts $fp "\n"
puts $fp "\#refence design (the golden design)"
puts $fp "read_verilog -r ${Core_compile} -work_library WORK"
puts $fp "set_top -auto"
puts $fp "\n"
puts $fp "\#implement design (the target design)"
puts $fp "read_verilog -i ${FM_IMPLEMENTED_DESIGN}"
puts $fp "set_top i:WORK/${DESIGN_NAME}"
puts $fp "\n"
puts $fp "set verification_set_undriven_signals BINARY"
puts $fp "set verification_check_gate_reserve_gating true"
puts $fp "verify"
puts $fp "quit"

close $fp



