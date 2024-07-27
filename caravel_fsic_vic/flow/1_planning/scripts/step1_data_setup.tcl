################################################################################
# Date: 7/26/2024            
# Name: Vic Chen             
################################################################################

source ../../../common/common.tcl

################################################################################
set link_library          "$Std_cell_lib $Io_lib $Ram_lib"
set target_library        "$Std_cell_lib $Io_lib $Ram_lib"
################################################################################

#[Vic] LEF + DB + TF to create libraries
set_app_var search_path $search_path
set physical_lib "$Std_cell_lef $Ram_lef $Io_lef"
create_lib $ARC_TOP -technology $Tech_file -ref_libs $physical_lib

################################################################################
read_parasitic_tech -tlup "$Tlup_max_file $Tlup_min_file" \
                    -layermap $Map_file 

################################################################################
read_verilog  "$Core_compile"
current_design ${DESIGN_NAME}
source $Constraints_file

################################################################################
save_block -as ${DESIGN_NAME}_1_data_setup
save_lib
close_block
close_lib

exit


#################################################################################
#set_app_var  link_library $Io_lib
#set $search_path ../../../../SAED32_EDK/lib/io_std/db_nldm/
#create_lib aaa -technology $Tech_file -ref_libs $Io_lef
#################################################################################