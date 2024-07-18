source ../../../common/common.tcl
################################################################################Set_Library
set link_library          "$Std_cell_lib $Ram_lib"
set target_library        "$Std_cell_lib $Ram_lib"
################################################################################
#script_for_lab_8
open_lib $ARC_TOP
copy_block -from_block  ${DESIGN_NAME}_3_powerplan_ends -to temp_powerplan_ends
open_block  temp_powerplan_ends
################################################################################General Optimization
set_app_options -name time.disable_recovery_removal_checks -value false
set_app_options -name time.disable_case_analysis -value false
set_app_options -name place.coarse.continue_on_missing_scandef -value true
################################################################################Place_Optimization
set_app_options -name opt.common.user_instance_name_prefix -value place
#set_app_options -name place.legalize.enable_variant_aware -value true
#set_app_options -name pin_check.route.effort -value high
set_app_options -name  place.coarse.congestion_driven_max_util -value 0.6
set_app_options -name  place.coarse.max_density -value 0.2

source ./../scripts/mcmm.tcl
source ./../scripts/set_dont_use.tcl

place_opt
legalize_placement
################################################################################Reports
set_app_option -name time.snapshot_storage_location -value "./"
create_qor_snapshot -name place_qor_snp -significant_digits 4

report_qor_snapshot -name place_qor_snp > ../../../reports/place.qor_snapshot.rpt
report_qor > ../../../reports/place.qor
report_constraints -all_violators > ../../../reports/place.con
report_timing -capacitance -transition_time -input_pins -nets -delay_type max > ../../../reports/place.max.tim
report_timing -capacitance -transition_time -input_pins -nets -delay_type min > ../../../reports/place.min.tim
################################################################################Save_Block
save_block -as ${DESIGN_NAME}_4_place_ends
save_lib
################################################################################

close_block
close_lib

exit
