################################################################################
# Date: 7/26/2024            
# Name: Vic Chen             
################################################################################

source ../../../common/common.tcl
################################################################################
set link_library          "$Std_cell_lib $Io_lib $Ram_lib"
set target_library        "$Std_cell_lib $Io_lib $Ram_lib"
################################################################################

################################################################################
open_lib $ARC_TOP
copy_block -from_block  ${DESIGN_NAME}_4_place_ends -to temp_place_ends
open_block temp_place_ends
################################################################################
check_legality  -verbose > ../../../reports/place_report.rpt

set_ignored_layers -min_routing_layer ${route_min_layer} -max_routing_layer ${route_max_layer}

set_app_options -name cts.compile.enable_cell_relocation -value all
set_app_options -name cts.compile.size_pre_existing_cell_to_cts_references -value true

# [Vic]: Exclude generated_clocks
set_clock_tree_options -clocks {clk ioclk_in rxclk hk_serial_clk hk_serial_load hkspi_clk} \
                       -target_skew 0.1 
################################################################################
# Set clock tree reference
set_clock_uncertainty 0.1 [all_clocks]

create_routing_rule CLK_SPACING -spacings {M2 0.3 M3 0.5 M4 0.7}
set_clock_routing_rules -rules CLK_SPACING -min_routing_layer M2 -max_routing_layer M4

report_clock_settings

set_app_options -name opt.common.user_instance_name_prefix -value clock
source ./../scripts/mcmm.tcl

clock_opt -from build_clock -to build_clock

################################################################################
set_app_option -name time.snapshot_storage_location -value "./"
create_qor_snapshot -name clock_pre_route -significant_digits 4
set_app_option -name cts.compile.enable_global_route -value true
################################################################################
report_qor_snapshot -name clock_pre_route > ../../../reports/clock_pre_route.qor_snapshot.rpt
report_qor > ../../../reports/clock_pre_route.qor
report_constraints -all_violators > ../../../reports/clock_pre_route.con
report_timing -capacitance -transition_time -input_pins -nets -delay_type max > ../../../reports/clock_pre_route.max.tim
report_timing -capacitance -transition_time -input_pins -nets -delay_type min > ../../../reports/clock_pre_route.min.tim
################################################################################
set_app_options -name opt.common.user_instance_name_prefix -value clock
clock_opt -from route_clock -to final_opto
################################################################################
report_clock_qor > ../../../reports/clock_tree.rpt
report_clock_timing -type skew > ../../../reports/clock_timing.rpt

create_qor_snapshot -name clock -significant_digits 4

report_qor_snapshot -name clock > ../../../reports/clock.qor_snapshot.rpt
report_qor > ../../../reports/clock.qor
report_constraints -all_violators > ../../../reports/clock_route.con
report_timing -capacitance -transition_time -input_pins -nets -delay_type max > ../../../reports/clock.max.tim
report_timing -capacitance -transition_time -input_pins -nets -delay_type min > ../../../reports/clock.min.tim

################################################################################
connect_pg_net -net vccd [get_pins -physical_context */VDD]
connect_pg_net -net vssd [get_pins -physical_context */VSS]
################################################################################
save_block -as ${DESIGN_NAME}_5_clock_ends
save_lib

close_block
close_lib
exit
