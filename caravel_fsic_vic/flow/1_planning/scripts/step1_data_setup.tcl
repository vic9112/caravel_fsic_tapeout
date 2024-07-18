source ../../../common/common.tcl

################################################################################Set_Library
set link_library          "$Std_cell_lib $Io_lib $Ram_lib"
set target_library        "$Std_cell_lib $Io_lib $Ram_lib"
################################################################################Open_Lib

#[AJ] NDM + DB + TF flow
#create_lib $ARC_TOP \
#		-technology $Tech_file  \
#		-ref_libs $REFERENCE_LIB

#[AJ] LEF + DB + TF flow
#set_app_var search_path $search_path
#set physical_lib "$Std_cell_lef $Ram_lef"
#create_lib $ARC_TOP -technology $Tech_file -ref_libs $physical_lib

#[Vic] Stdcell NDM + Sram LEF + DB + TF
set_app_var search_path $search_path
set physical_lib "$Ram_lef $Io_lef"
create_lib $ARC_TOP \
		-technology $Tech_file  \
		-ref_libs "$REFERENCE_LIB $physical_lib"

################################################################################Set_Tluplus_Files
read_parasitic_tech -tlup "$Tlup_max_file $Tlup_min_file" \
                    -layermap $Map_file 

################################################################################Import_Design
read_verilog "$Core_compile"
current_design ${DESIGN_NAME}
source $Constraints_file

################################################################################Save_Block
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