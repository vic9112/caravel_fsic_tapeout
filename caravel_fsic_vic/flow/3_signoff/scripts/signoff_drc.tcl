source ../../../common/common.tcl

################################################################################Set_Library
set link_library          "$Std_cell_lib $Ram_lib"
set target_library        "$Std_cell_lib $Ram_lib"
################################################################################Open_Lib

################################################################################Open_Lib
open_lib ${ARC_TOP}
open_block ${DESIGN_NAME}_6_complete

read_parasitic_tech -tlup "$Tlup_max_file $Tlup_min_file" \
                    -layermap $Map_file

################################################################################setting in design icv 
if {[which $REDHAWK_PGA_ICV_DIR/bin/LINUX.64/icv] == "" } {
	puts "RM-error: Unable to find icv at \"$REDHAWK_PGA_ICV_DIR/bin/LINUX.64\". Exiting...."

	exit

} else {
	puts "RM-info: Setting ICV binary path"
	setenv ICV_HOME_DIR $REDHAWK_PGA_ICV_DIR
        setenv ICV_INCLUDES [getenv ICV_HOME_DIR]/include/
	setenv PATH [getenv ICV_HOME_DIR]/bin/LINUX.64:[getenv PATH]

}

################################################################################Checking
set_app_options -name signoff.check_drc.runset -value ${icv_drc_runset}
set_app_options -name signoff.check_drc.max_errors_per_rule -value 1000
set_app_options -name signoff.check_drc.run_dir -value "./signoff_drc_run/"
set_app_options -name signoff.physical.layer_map_file -value ${Gds_map_file}

################################################################################Use_Latest_ICV_Version
signoff_check_drc

save_block
save_lib

close_block
close_lib
exit
