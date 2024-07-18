#!/usr/bin/tclsh
source ../../common/common.tcl

set fp [open "../script/star_cmd_gate" w+]
puts $fp "***********	SETUP	  **********"
puts $fp "* Specify block name for parasitic extraction"
puts $fp "BLOCK: ${DESIGN_NAME}"
puts $fp "TOP_DEF_FILE: ../../results/${DESIGN_NAME}.out.wo_filler.def"
puts $fp "* Provide the mapping file in which design layers mapped to process layers "
puts $fp "MAPPING_FILE:  ${Map_file}"
foreach lef [list ${Std_cell_lef} ${Ram_lef}] {
  if {$lef != "" && $lef != " "} {
    puts $fp "LEF_FILE: $lef"
  }
}
#puts $fp "LEF_FILE: ${Std_cell_lef} ${Ram_lef}"
puts $fp "* Reduction setting fro STA Analysis"
puts $fp "REDUCTION: NO_EXTRA_LOOPS"
puts $fp "NETS: *"
puts $fp "EXTRACTION: RC"
puts $fp "DPT: YES "
puts $fp "***********     FLOW SELECTION       **********"
puts $fp "NUM_CORES: 4"
puts $fp "STARRC_DP_STRING:"
puts $fp "CORNERS_FILE: ../script/StarRC.smc"
puts $fp "DENSITY_BASED_THICKNESS: YES"
puts $fp "SELECTED_CORNERS: $STARRC_SELECTED_CORNERS"
puts $fp "SIMULTANEOUS_MULTI_CORNER: YES"
puts $fp "***********     SKIPPING ALL CELLS **********"
puts $fp "SKIP_CELLS: !*"
puts $fp "***********     PARASITIC OUTPUT (SPEF)       **********"
puts $fp "COUPLE_TO_GROUND: NO "
puts $fp "COUPLING_ABS_THRESHOLD: 3e-15"
puts $fp "COUPLING_REL_THRESHOLD: 0.03"
puts $fp "REDUCTION_MAX_DELAY_ERROR: 1e-14"
puts $fp "NETLIST_FORMAT: SPEF"
puts $fp "* Provide the name of a file to which output parasitic netlist is written"
puts $fp "NETLIST_FILE: ./../../results/${DESIGN_NAME}.star.wo_filler.spef"
puts $fp "* Provide the name of a summary file to which runtime and memory usage is written"
puts $fp "SUMMARY_FILE: ./../../results/${DESIGN_NAME}.star_sum"
puts $fp "* Provide the working directory name to which StarRC internal information is written in binary"
puts $fp "STAR_DIRECTORY: ./star_directory"
puts $fp "***********     PARASITIC OUTPUT (SPF)       **********"
close $fp



