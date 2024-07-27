
source ../../../common/common.tcl
################################################################################Set_Library
set link_library          "$Std_cell_lib $Ram_lib"
set target_library        "$Std_cell_lib $Ram_lib"

################################################################################Open_Lib
open_lib $ARC_TOP
copy_block -from_block  ${DESIGN_NAME}_6_complete -to temp_route_ends
open_block temp_route_ends


################################################################################Insert_Redundant_Vias
add_redundant_vias

################################################################################Insert_Filler
set pnr_std_fillers "SAEDRVT32_FILL*"
set std_fillers ""
foreach filler $pnr_std_fillers { lappend std_fillers "*/${filler}" }
create_stdcell_fillers \
	-lib_cells $std_fillers

################################################################################Use correct ICV version
set_app_options -name signoff.create_metal_fill.runset -value "${icv_mfill_runset}"

set create_metal_fill_cmd "signoff_create_metal_fill"

if {$METAL_FILL_SELECT_LAYER != ""} {
  lappend create_metal_fill_cmd -select_layers $METAL_FILL_SELECT_LAYER
}

eval $create_metal_fill_cmd

################################################################################Preroute_Standard_Cells
set_attribute -objects [get_nets VDD] -name net_type -value power
set_attribute -objects [get_nets VSS] -name net_type -value ground

connect_pg_net -net VDD [get_pins -physical_context */VDD]
connect_pg_net -net VSS [get_pins -physical_context */VSS]

check_mv_design

################################################################################Verify_DRC/LVS
check_lvs > ../../../reports/${DESIGN_NAME}.lvs.rpt
################################################################################Reports
report_design -all > ../../../reports/${DESIGN_NAME}.PR_summary.rpt

report_timing -capacitance -transition_time -input_pins -nets -delay_type max > ../../../reports/timing.max.tim
report_timing -capacitance -transition_time -input_pins -nets -delay_type min > ../../../reports/timing.min.tim
################################################################################Write Verilogs
write_verilog \
	-include {pg_netlist unconnected_ports} \
	../../../results/${DESIGN_NAME}.pg.v

write_verilog -exclude {physical_only_cells} ../../../results/${DESIGN_NAME}.v

## write_verilog for comparison with a DC netlist (no pg, no physical only cells, and no diodes)
set write_verilog_dc_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells diode_cells} -hierarchy all"
set write_verilog_dc_cmd "$write_verilog_dc_cmd_root ../../../results/${DESIGN_NAME}.dc.v"
eval ${write_verilog_dc_cmd}

## write_verilog for PrimeTime (no pg, no physical only cells but with diodes and DCAP for leakage power analysis)
set write_verilog_pt_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells flip_chip_pad_cells} -hierarchy all"
set write_verilog_pt_cmd "$write_verilog_pt_cmd_root ../../../results/${DESIGN_NAME}.pt.v"
eval ${write_verilog_pt_cmd}

## write_verilog for Formality (with pg, no physical only cells, and no supply statements)
set write_verilog_fm_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells supply_statements} -hierarchy all" 
set write_verilog_fm_cmd "$write_verilog_fm_cmd_root ../../../results/${DESIGN_NAME}.fm.v" 
eval ${write_verilog_fm_cmd}

## write_verilog for LVS (with pg, without filler cells)
## The filler cells do not contain any devices - just M1 power rails and NWELL. So, nothing to compare during LVS.
#LVS: implemented schematic netlsit (without filler/ with pg) vs layout (with filler/with pg) 
set write_verilog_lvs_cmd_root "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations empty_modules filler_cells} -hierarchy all"
set write_verilog_lvs_cmd "$write_verilog_lvs_cmd_root  ../../../results/${DESIGN_NAME}.lvs.v"
eval ${write_verilog_lvs_cmd}
 
################################################################################SDC_OUT
write_sdc -output ../../../results/${DESIGN_NAME}.out.sdc
################################################################################SPEF_OUT
report_timing -crosstalk_delta
write_parasitics -format SPEF -output ../../../results/${DESIGN_NAME}.out.spef
################################################################################DEF_OUT
write_def ../../../results/${DESIGN_NAME}.out.def
################################################################################GDS_OUT
save_block -as ${DESIGN_NAME}_7_finished

write_gds -design ${DESIGN_NAME}_7_finished \
	  -layer_map $Gds_map_file \
	  -keep_data_type \
	  -fill include \
	  -output_pin all \
	  -merge_files $Std_cell_gds \
	  -long_names \
	  ../../results/${DESIGN_NAME}.gds

################################################################################Save_Block
save_block
save_lib

close_block
close_lib

exit
