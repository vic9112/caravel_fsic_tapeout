################################################################################
# Date: 7/26/2024            
# Name: Vic Chen             
################################################################################

source ../../../common/common.tcl

open_lib $ARC_TOP
copy_block -from_block ${DESIGN_NAME}_2_floorplan_ends -to temp_floorplan_ends
open_block temp_floorplan_ends
################################################################################
set_attribute -objects [get_nets vccd]  -name net_type -value power
set_attribute -objects [get_nets vssd]  -name net_type -value ground
set_attribute -objects [get_nets vddio] -name net_type -value power
set_attribute -objects [get_nets vssio] -name net_type -value ground

connect_pg_net -net vddio [get_pins */vddio]
connect_pg_net -net vssio [get_pins */vssio]
connect_pg_net -net vccd  [get_pins */vccd]
connect_pg_net -net vssd  [get_pins */vssd]

# Connect PG for stdcell and iopad
connect_pg_net -net vddio [get_pins -physical_context */VDDIO]
connect_pg_net -net vssio [get_pins -physical_context */VSSIO]
connect_pg_net -net vccd  [get_pins -physical_context */VDD]
connect_pg_net -net vssd  [get_pins -physical_context */VSS]

# Check whether all PG pins are connected
check_mv_design
################################################################################
remove_pg_via_master_rules -all
remove_pg_patterns -all
remove_pg_strategies -all
remove_pg_strategy_via_rules -all

################################################################################
# Creates a standard cell rail connection pattern. 
# This pattern can be instantiated in a design by set_pg_strategy command to create standard cell rails.
create_pg_std_cell_conn_pattern M1_rail -layers {M1} -rail_width {@wtop @wbottom} -parameters {wtop wbottom}

set_pg_strategy M1_rail_strategy_vccd -core -pattern {{name: M1_rail} {nets: vccd} {parameters: {0.094 0.094}}}
set_pg_strategy M1_rail_strategy_vssd -core -pattern {{name: M1_rail} {nets: vssd} {parameters: {0.094 0.094}}}

compile_pg -strategies M1_rail_strategy_vccd -ignore_drc
compile_pg -strategies M1_rail_strategy_vssd -ignore_drc

################################################################################
create_pg_mesh_pattern TOP_MESH_VERTICAL \
	-layers " \
		{ {vertical_layer: M7} {width: 0.3} {spacing: interleaving} {pitch: 4} {offset: 0.5}  {trim : true} } \
		" 

set_pg_strategy VDDVSS_TOP_MESH_VERTICAL \
	-core \
	-pattern   { {name: TOP_MESH_VERTICAL} {nets:{vssd vccd}} } \
	-extension { {{stop:design_boundary_and_generate_pin}} }

compile_pg -strategies {VDDVSS_TOP_MESH_VERTICAL}

################################################################################
create_pg_mesh_pattern TOP_MESH_HORIZONTAL \
	-layers " \
		{ {horizontal_layer: M8}   {width: 0.3} {spacing: interleaving} {pitch: 4} {offset: 0.5}  {trim : true} } \
		" 

set_pg_strategy VDDVSS_TOP_MESH_HORIZONTAL \
	-core \
	-pattern   { {name: TOP_MESH_HORIZONTAL} {nets:{vssd vccd}} } \
	-extension { {{stop:design_boundary_and_generate_pin}} }

compile_pg -strategies {VDDVSS_TOP_MESH_HORIZONTAL}

################################################################################
create_pg_ring_pattern \
                 ring_pattern \
                 -horizontal_layer M8  -vertical_layer M7 \
                 -horizontal_width 1 -vertical_width 1 \
                 -horizontal_spacing 3 -vertical_spacing 3

set_pg_strategy RING -core -pattern {{ name: ring_pattern} { nets: "vccd vssd vddio vssio" }}

compile_pg -strategies RING

# Check the connectivity of PG pins
check_pg_connectivity -nets "vccd vssd vddio vssio"

################################################################################
save_block -as ${DESIGN_NAME}_3_powerplan_ends
save_lib
close_block
close_lib
exit

