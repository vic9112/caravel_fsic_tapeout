#!/usr/bin/tclsh
source ../../common/common.tcl

set fp [open "../script/StarRC.smc" w+]

set cur_path_split [split [pwd] "/"]
  
set abs_dir ""
for {set index 0} {$index < [expr [llength $cur_path_split] - 1]} {incr index 1} {
  set abs_dir "${abs_dir}/[lindex $cur_path_split $index]"
}
set abs_dir_slow "$abs_dir/script/saed14nm_1p9m_Cmax.nxtgrd"
set abs_dir_fast "$abs_dir/script/saed14nm_1p9m_Cmin.nxtgrd"

foreach corner ${STARRC_SELECTED_CORNERS} {
  if { $corner == "slow" } {
    puts $fp "CORNER_NAME: slow"
    puts $fp "OPERATING_TEMPERATURE: 25"
    puts $fp "TCAD_GRD_FILE: $abs_dir_slow"
    puts $fp ""
  }
  if { $corner == "fast" } {
    puts $fp "CORNER_NAME: fast"
    puts $fp "OPERATING_TEMPERATURE: 25"
    puts $fp "TCAD_GRD_FILE: $abs_dir_fast"
    puts $fp ""
  } 
}

close $fp



