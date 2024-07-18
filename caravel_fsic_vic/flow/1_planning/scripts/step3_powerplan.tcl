source ../../../common/common.tcl

open_lib $ARC_TOP
copy_block -from_block ${DESIGN_NAME}_2_floorplan_ends -to temp_floorplan_ends
open_block temp_floorplan_ends
################################################################################Power_Planing

set_attribute -objects [get_nets VDD] -name net_type -value power
set_attribute -objects [get_nets VSS] -name net_type -value ground

connect_pg_net -net VDD [get_pins -physical_context */VDD]
connect_pg_net -net VSS [get_pins -physical_context */VSS]

################################################################################Create_Power_Plan
remove_pg_via_master_rules -all
remove_pg_patterns -all
remove_pg_strategies -all
remove_pg_strategy_via_rules -all

################################################################################Create_STD_Cells_Rail
create_pg_std_cell_conn_pattern M1_rail -layers {M1} -rail_width {@wtop @wbottom} -parameters {wtop wbottom}

set_pg_strategy M1_rail_strategy_pwr -core -pattern {{name: M1_rail} {nets: VDD} {parameters: {0.094 0.094}}}
set_pg_strategy M1_rail_strategy_gnd -core -pattern {{name: M1_rail} {nets: VSS} {parameters: {0.094 0.094}}}

compile_pg -strategies M1_rail_strategy_pwr -ignore_drc
compile_pg -strategies M1_rail_strategy_gnd -ignore_drc

################################################################################Create_Top_Vertical_Mesh
create_pg_mesh_pattern TOP_MESH_VERTICAL \
	-layers " \
		{ {vertical_layer: M6}   {width: 0.3} {spacing: interleaving} {pitch: 4} {offset: 0.5}  {trim : true} } \
		" 

set_pg_strategy VDDVSS_TOP_MESH_VERTICAL \
	-core \
	-pattern   { {name: TOP_MESH_VERTICAL} {nets:{VSS VDD}} } \
	-extension { {{stop:design_boundary_and_generate_pin}} }

compile_pg -strategies {VDDVSS_TOP_MESH_VERTICAL}

################################################################################Create_Top_Horizontal_Mesh
create_pg_mesh_pattern TOP_MESH_HORIZONTAL \
	-layers " \
		{ {horizontal_layer: M7}   {width: 0.3} {spacing: interleaving} {pitch: 4} {offset: 0.5}  {trim : true} } \
		" 

set_pg_strategy VDDVSS_TOP_MESH_HORIZONTAL \
	-core \
	-pattern   { {name: TOP_MESH_HORIZONTAL} {nets:{VSS VDD}} } \
	-extension { {{stop:design_boundary_and_generate_pin}} }

compile_pg -strategies {VDDVSS_TOP_MESH_HORIZONTAL}

################################################################################Create_Rectangular_Rings
create_pg_ring_pattern \
                 ring_pattern \
                 -horizontal_layer M7  -vertical_layer M6 \
                 -horizontal_width 1 -vertical_width 1 \
                 -horizontal_spacing 3 -vertical_spacing 3

set_pg_strategy RING -core -pattern {{ name: ring_pattern} { nets: "VDD VSS" }}

compile_pg -strategies RING

check_pg_connectivity -nets "VDD VSS"

################################################################################Save_Block
save_block -as ${DESIGN_NAME}_3_powerplan_ends
save_lib
close_block
close_lib
exit

