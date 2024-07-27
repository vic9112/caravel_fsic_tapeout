################################################################################
# Date: 7/26/2024            
# Name: Vic Chen             
################################################################################

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
#report_disable_timing
################################################################################Set_Options
set_app_option -name place.legalize.enable_advanced_prerouted_net_check -value true

# [Vic]: To prevent the warning message [ZRT-113]:
set_app_option -name route.common.connect_floating_shapes -value true

group_path -name INPUT  -from [all_inputs]
group_path -name OUTPUT -to   [all_outputs]
group_path -name COMBO  -from [all_inputs] -to [all_outputs]
################################################################################Save_Block
save_block -as temp_floorplan_init
################################################################################Defining_Prefered_Routing_Directions
set_ignored_layers -min_routing_layer ${route_min_layer} -max_routing_layer ${pns_hlayer}

# [Vic]: T18 process only have 6 metal layers
set_attribute [get_layers {M1 M3 M5 M7}] routing_direction horizontal
set_attribute [get_layers {M2 M4 M6 M8}] routing_direction vertical

# [Vic]: Tech files doesn't contain information on the symmetry requirements for 
#        cell placement and defaulte site for floorplan initialization
set_attribute [get_site_defs unit] symmetry {Y}
set_attribute [get_site_defs unit] is_default true

set_attribute -objects [get_nets vccd]  -name net_type -value power
set_attribute -objects [get_nets vssd]  -name net_type -value ground
set_attribute -objects [get_nets vddio] -name net_type -value power
set_attribute -objects [get_nets vssio] -name net_type -value ground

################################################################################Create_Floorplan
initialize_floorplan -core_utilization 0.8 \
			         -core_offset {10 10 10 10}
################################################################################Ports_Placement
place_pins -ports [get_ports *]
save_block -as temp_floorplane
################################################################################Create_Floorplane_Placement
create_placement -floorplan -effort high -timing_driven
legalize_placement 

# Analyze global route congestion
route_global -congestion_map_only true -effort high  

# Fix the placement of all macros before writing out the floorplan
set_fixed_objects [get_flat_cells -filter "is_hard_macro"]

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
