source ../../common/common.tcl


set DESIGN_NAME i2c_master_top


read_db "$Std_cell_lib $Ram_lib"


set hdlin_interface_only "" ; # set block_box


#refence design (the golden design)
read_verilog -r <absolute path>/lab_formal_release/lab_formal/work/../../input/i2c_master_top.v -work_library WORK
set_top -auto


#implement design (the target design)
read_verilog -i <absolute path>/University_LAB_0220/lab_formal_release/lab_formal/work/../../results/i2c_master_top.pt.v.gz
set_top i:WORK/i2c_master_top


set verification_set_undriven_signals BINARY
set verification_check_gate_reserve_gating true
verify
quit
