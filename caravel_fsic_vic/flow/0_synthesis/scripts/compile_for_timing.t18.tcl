# 2024.7.11 Modified by Vic

source ../../../common/common.tcl

echo $search_path
set search_path " \
   /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/lib \
   /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/db \
   $search_path "
echo $search_path

set target_library    "typical.db slow.db fast.db $Io_lib $Ram_lib"
set link_library      "$target_library dw_foundation.sldb"
set symbol_library    "tsmc18.sdb generic.sdb"
set synthetic_library "dw_foundation.sldb"

echo $enable_keep_signal
set enable_keep_signal true
echo $enable_keep_signal

echo $hdlin_keep_signal_name 
set hdlin_keep_signal_name all
echo $hdlin_keep_signal_name 

set dc_allow_rtl_pg	  true

source $analyze_script
elaborate ${DESIGN_NAME} -architecture verilog -library WORK

current_design ${DESIGN_NAME}

link

source $Constraints_file

#get_pins [all_connected housekeeping/csclk -leaf] -filter "@direction == out"
all_connected housekeeping/csclk
#echo $csclk_mux_out_pin 


report_port -verbose > ../../../reports/timing_${DESIGN_NAME}_report_port.log
report_clock > ../../../reports/timing_${DESIGN_NAME}_report_clock.log
report_clock -skew >> ../../../reports/timing_${DESIGN_NAME}_report_clock.log
check_timing > ../../../reports/timing_${DESIGN_NAME}_check_timing.log
report_timing_requirements -ignored > ../../../reports/timing_${DESIGN_NAME}_report_timing_requirements.log
# quit

#set_dont_use [get_lib_cells */*FDN*]

set_fix_multiple_port_nets -outputs -feedthroughs 
source $Warning_file

#get_pins [all_connected housekeeping/csclk -leaf] -filter "@direction == out"
all_connected housekeeping/csclk
#echo $csclk_mux_out_pin 

check_design

#get_pins [all_connected housekeeping/csclk -leaf] -filter "@direction == out"
all_connected housekeeping/csclk
#echo $csclk_mux_out_pin 
report_timing -to housekeeping/csclk > ../../../reports/timing_${DESIGN_NAME}_report_timing_csclk_stage1.log

# quit
 
link
 
#get_pins [all_connected housekeeping/csclk -leaf] -filter "@direction == out"
all_connected housekeeping/csclk
#echo $csclk_mux_out_pin 

report_clock

#set_dont_touch mprj/u_fsic/U_IO_SERDES0/tx_shift_phase_cnt_reg[*]

# set_app_var compile_seqmap_enable_output_inversion true

compile -exact_map -map_effort high -area_effort medium -power_effort none
#compile_ultra -exact_map 
#compile -map_effort high -area_effort medium -power_effort none

#change_names -rules verilog
#write_file -format verilog -hierarchy -pg -output ../../input/${DESIGN_NAME}_stage1.v
#
#report_clock
#
#set wbbd_sck_pin [get_pins -of_objects housekeeping/wbbd_sck -filter lib_pin_name==Q]
#create_generated_clock -name wbbd_sck -source [get_ports {housekeeping/wb_clk_i} ] -divide_by 2 $wbbd_sck_pin
#set csclk_mux_out_pin [get_pins [all_connected housekeeping/csclk -leaf] -filter "@direction == out"]
#create_generated_clock -name wbbd_sck_to_csclk_mux -source  [get_ports clock] -divide_by 2 $csclk_mux_out_pin 
#
##set csclk_mux_out_pin [get_pins -of_objects housekeeping/pll_ena_reg -filter "lib_pin_name==CK"]
##create_generated_clock -name wbbd_sck_to_csclk_mux -source  $wbbd_sck_pin -divide_by 1 $csclk_mux_out_pin
#create_generated_clock -name hkspi_clk_to_csclk_mux -source [get_ports {mprj_io[4]}] -add -divide_by 1 $csclk_mux_out_pin
#
#set_clock_groups \
#-name clock_group \
#-logically_exclusive \
#-group [get_clocks {clk wbbd_sck_to_csclk_mux}]\
#-group [get_clocks {ioclk_in rxclk}]\
#-group [get_clocks {hk_serial_clk}]\
#-group [get_clocks {hk_serial_load}]\
#-group [get_clocks {hkspi_clk hkspi_clk_to_csclk_mux}]


report_clock

report_timing -to [get_pins -of_objects housekeeping/pll_sel_reg[0] -filter "lib_pin_name==D"]
report_timing -to [get_pins -of_objects housekeeping/pll_sel_reg[0] -filter "lib_pin_name==D"] -group wbbd_sck_to_csclk_mux
report_timing -to [get_pins -of_objects housekeeping/pll_sel_reg[0] -filter "lib_pin_name==D"] -group hkspi_clk_to_csclk_mux

#create_generated_clock -name wbbd_sck_to_csclk_mux -source  [get_ports clock] -divide_by 2 [get_pins housekeeping/U4718/X]
#create_generated_clock -name hkspi_clk_to_csclk_mux -source [get_ports {mprj_io[4]}] -add -divide_by 1 [get_pins housekeeping/U4718/X]
#set_clock_groups -logically_exclusive -name csclk_mux -group wbbd_sck_to_csclk_mux -group hkspi_clk_to_csclk_mux 
#get_pins [all_connected housekeeping/csclk -leaf] -filter "@direction == out"
#all_connected housekeeping/csclk

#compile -exact_map -map_effort high -area_effort medium -power_effort none
#compile -map_effort high -area_effort medium -power_effort none

#get_pins [all_connected housekeeping/csclk -leaf] -filter "@direction == out"
all_connected housekeeping/csclk
#echo $csclk_mux_out_pin 

report_timing -to housekeeping/csclk > ../../../reports/timing_${DESIGN_NAME}_report_timing_csclk_stage_end.log

report_clock > ../../../reports/timing_${DESIGN_NAME}_report_clock_end.log
report_clock -skew >> ../../../reports/timing_${DESIGN_NAME}_report_clock_end.log

## reporting and output
#report_port -verbose > ../../reports/timing_${DESIGN_NAME}_report_port.log
#report_clock > ../../reports/timing_${DESIGN_NAME}_report_clock.log
#report_clock -skew >> ../../reports/timing_${DESIGN_NAME}_report_clock.log
check_timing > ../../../reports/timing_${DESIGN_NAME}_check_timing_end.log

report_timing > ../../../reports/timing_${DESIGN_NAME}_timing_reports.log
report_qor > ../../../reports/timing_${DESIGN_NAME}_qor_reports.log
report_area -hierarchy  > ../../../reports/timing_${DESIGN_NAME}_area_reports.log
report_power -hierarchy > ../../../reports/timing_${DESIGN_NAME}_power_reports.log
report_timing -to [get_pins -of_objects housekeeping/pll_sel_reg[0] -filter "lib_pin_name==D"]
report_timing -to [get_pins -of_objects housekeeping/pll_sel_reg[0] -filter "lib_pin_name==D"] -group wbbd_sck_to_csclk_mux
report_timing -to [get_pins -of_objects housekeeping/pll_sel_reg[0] -filter "lib_pin_name==D"] -group hkspi_clk_to_csclk_mux

change_names -rules verilog
write_file -format verilog -hierarchy -pg -output ../../input/${DESIGN_NAME}.v

quit
