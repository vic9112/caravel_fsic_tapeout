source ../../../common/common.tcl
################################################################################Set_Library
set link_library          "$Std_cell_lib $Io_lib $Ram_lib"
set target_library        "$Std_cell_lib $Io_lib $Ram_lib"
################################################################################Open_Lib

open_lib $ARC_TOP
copy_block -from_block ${DESIGN_NAME}_1_data_setup -to temp_data_setup
open_block temp_data_setup

################################################################################Reports
report_clocks -skew -attributes
report_exceptions
report_disable_timing

################################################################################Set_Power/Ground_Nets_And_Pins 
set power                           "VDD"
set ground                          "VSS"
set powerPort                       "VDD"
set groundPort                      "VSS"
set ndm_logic0_net                  "VSS"
set ndm_logic1_net                  "VDD"
################################################################################Set_Options
set_app_option -name time.disable_recovery_removal_checks -value false
set_app_option -name time.disable_case_analysis -value false
group_path -name INPUT  -from [all_inputs]
group_path -name OUTPUT -to   [all_outputs]
group_path -name COMBO -from [all_inputs] -to [all_outputs]
################################################################################Save_Block
save_block -as temp_floorplan_init

################################################################################Defining_Prefered_Routing_Directions
set_ignored_layers -min_routing_layer ${route_min_layer} -max_routing_layer ${pns_hlayer}

set_attribute [get_layers M1] routing_direction vertical
set_attribute [get_layers M2] routing_direction horizontal
set_attribute [get_layers M3] routing_direction vertical
set_attribute [get_layers M4] routing_direction horizontal
set_attribute [get_layers M5] routing_direction vertical
set_attribute [get_layers M6] routing_direction horizontal
set_attribute [get_layers M7] routing_direction vertical

#only for SAED14nm lib porpose 
set_attribute [get_layers {M1}] track_offset 0.037

################################################################################Create_Floorplan
initialize_floorplan -core_utilization 0.2 \
			-core_offset {10 10 10 10}

################################################################################Ports_Placement
place_pins -ports [get_ports *]

################################################################################Defining_Power/Ground_Nets_And_Pins
set_attribute -objects [get_nets VDD] -name net_type -value power
set_attribute -objects [get_nets VSS] -name net_type -value ground
check_mv_design
################################################################################Save_Block
save_block -as temp_floorplane
################################################################################Create_Floorplane_Placement

create_placement -floorplan -effort high -timing_driven
legalize_placement 
route_global -congestion_map_only true -effort high  

report_placement
################################################################################Save_Block
save_block -as temp_floorplane_placed
################################################################################Save_Block

save_block -as ${DESIGN_NAME}_2_floorplan_ends
save_lib
################################################################################
close_block
close_lib
exit
