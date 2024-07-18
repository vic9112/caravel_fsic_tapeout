#!/bin/tcsh -f

#LAYOUT
#write_gds -design ${DESIGN_NAME}_7_finished -layer_map $Gds_map_file -keep_data_type -fill include -output_pin all -merge_files $Std_cell_gds -long_names  i2c_master_top.gds
set GDSII_FILE = "../../results/i2c_master_top_wostd.gds"
#set GDSII_FILE =  "/remote/testcases/TC102/042022/4196128/LIB_AJ/ICC2/FlowTraining_BE/TEST_AJ/University_LAB/lab_formal_release/results/i2c_master_top.out.wo_filler.gds"
set GDSII_TOPCELL_NAME = "i2c_master_top"

#Schematic (SPICE/VERILOG)
# icv_nettran -verilog i2c_master_top.v.pg -outType SPICE -outName verilog2spice.sp
set SPICE_FILE = "./netlist2spice.sp"
set NETLIST_TOPCELL_NAME = "i2c_master_top"

\rm -rf run_details *.vue *.net *LAYOUT_ERROR *LVS_ERRORS *.RESULTS icv.log

icv -vue -vueshortALL -create_lvs_short_outputALL \
-i $GDSII_FILE \
-c $GDSII_TOPCELL_NAME \
-s $SPICE_FILE \
-stc $NETLIST_TOPCELL_NAME \
-sf SPICE \
../script/saed14nm_1p9m_lvs_runset.rs.tim


