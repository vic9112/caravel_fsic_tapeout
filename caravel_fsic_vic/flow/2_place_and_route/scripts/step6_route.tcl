source ../../../common/common.tcl
################################################################################Set_Library
set link_library          "$Std_cell_lib $Ram_lib"
set target_library        "$Std_cell_lib $Ram_lib"
################################################################################

################################################################################Open_Lib
open_lib $ARC_TOP
copy_block -from_block  ${DESIGN_NAME}_5_clock_ends -to temp_clock_ends
open_block temp_clock_ends
################################################################################Checking

set_ignored_layers -min_routing_layer  ${route_min_layer} -max_routing_layer ${route_max_layer}
report_ignored_layers

################################################################################Route_Optimization
source ./../scripts/mcmm.tcl

set_app_option -name route.detail.ignore_drc -value { }

#track assignment & initial route optimize 
route_auto

#route optimize
route_opt

################################################################################Connecting_power/Ground_Nets_And_Pins
connect_pg_net -net VDD [get_pins -physical_context */VDD]
connect_pg_net -net VSS [get_pins -physical_context */VSS]

optimize_routes -max_detail_route_iterations 5

check_lvs -max_errors 2000


################################################################################Reports
set_app_option -name time.snapshot_storage_location -value "./"
create_qor_snapshot -name route -significant_digits 4
report_congestion
write_verilog -include {pg_netlist} "$Top_design_pt"

report_qor_snapshot > ../../../reports/route.qor_snapshot.rpt
report_qor > ../../../reports/route.qor
report_constraints -all_violators > ../../../reports/route.con
report_timing -capacitance -transition_time -input_pins -nets -delay_type max > ../../../reports/route.max.tim
report_timing -capacitance -transition_time -input_pins -nets -delay_type min > ../../../reports/route.min.tim

################################################################################Save_Cell
save_block -as ${DESIGN_NAME}_6_complete
save_lib

################################################################################GDS_OUT (for PT pre-check)
write_verilog -exclude {physical_only_cells} ../../../results/${DESIGN_NAME}.out.wo_filler.v

write_sdc -output ../../../results/${DESIGN_NAME}.out.wo_filler.sdc

write_def ../../../results/${DESIGN_NAME}.out.wo_filler.def

write_parasitics -format SPEF -output ../../../results/${DESIGN_NAME}.out.wo_filler.spef


write_gds -design ${DESIGN_NAME}_6_complete \
	  -layer_map $Gds_map_file \
	  -keep_data_type \
	  -fill include \
	  -output_pin all \
	  -merge_files $Std_cell_gds \
	  -long_names \
	  ../../results/${DESIGN_NAME}.out.wo_filler.gds

close_block
close_lib
exit
