
##########  VARIABLES TO MODIFY ############################################################################# Main_PATH
set starrc_bin_path        	"/usr/cad/synopsys/star-rcxt/2022.12/linux64_starrc/bin"
set primetime_bin_path    	"/usr/cad/synopsys/primetime/2022.03/bin"
set REDHAWK_PGA_ICV_DIR		"/usr/cad/synopsys/icvalidator/2022.12-sp4/bin"
###########################################################
set ROOT_DIR        "[pwd]/../../.."
set DESIGN_REF_PATH "${ROOT_DIR}/../SAED32_EDK"
set VERILOG_DIR     "${ROOT_DIR}/rtl"
###########################################################

set DESIGN_NAME     "caravel_top"

set Constraints_file     "${ROOT_DIR}/common/${DESIGN_NAME}.sdc"
set analyze_script       "${ROOT_DIR}/common/${DESIGN_NAME}_analyze.tcl"
set Warning_file         "${ROOT_DIR}/common/warnings_to_ignore.tcl"
############### outputs 
set Svf_file             "${ROOT_DIR}/input/${DESIGN_NAME}.svf"
set ARC_TOP              "${ROOT_DIR}/results/${DESIGN_NAME}"
set Core_compile         "${ROOT_DIR}/input/${DESIGN_NAME}.v"  
set Top_design_pt        "${ROOT_DIR}/input/${DESIGN_NAME}_pt.v"
###########################################################

set pns_vlayer M6
set pns_hlayer M7
set route_min_layer M1
set route_max_layer M5

#################################################################################REF_PATH
set DESIGN_REF_LIB_PATH  "${DESIGN_REF_PATH}/lib"
set DESIGN_REF_TECH_PATH "${DESIGN_REF_PATH}/tech"
#################################################################################LIB_PATH
set DESIGN_REF_MW_PATH   "${DESIGN_REF_TECH_PATH}/milkyway"
#set DESIGN_REF_RC_PATH   "${DESIGN_REF_TECH_PATH}/star_rcxt"
set DESIGN_REF_RC_PATH   "${DESIGN_REF_TECH_PATH}/starrc"
set DESIGN_REF_TF_PATH   "${DESIGN_REF_TECH_PATH}/tf"
#################################################################################TECH_PATH
set DESIGN_REF_NLDM_PATH "${DESIGN_REF_LIB_PATH}/stdcell_rvt/db_nldm \ 
                          ${DESIGN_REF_LIB_PATH}/io_std/db_nldm \
                          ${DESIGN_REF_LIB_PATH}/sram/db_nldm"
#######################################################################################Liberty

#######################################################################################SAED32
set DESIGN_REF_RAM_PATH  "${DESIGN_REF_LIB_PATH}/sram/db_nldm"
set Std_cell_lib         "${DESIGN_REF_LIB_PATH}/stdcell_rvt/db_nldm/saed32rvt_tt1p05v25c.db"
#set Std_cell_lib         "${DESIGN_REF_LIB_PATH}/stdcell_hvt/db_nldm/saed32hvt_ss0p95v125c.db \
#                          ${DESIGN_REF_LIB_PATH}/stdcell_hvt/db_nldm/saed32hvt_dlvl_ss0p75v125c_i0p75v.db \
#                          ${DESIGN_REF_LIB_PATH}/stdcell_hvt/db_nldm/saed32hvt_ulvl_ff1p16vn40c_i1p16v.db \
#                          ${DESIGN_REF_LIB_PATH}/stdcell_hvt/db_nldm/saed32hvt_ff0p85v25c.db"
set Io_lib               "${DESIGN_REF_LIB_PATH}/io_std/db_nldm/saed32io_wb_tt1p05v25c_2p5v.db"
set Ram_lib              "${DESIGN_REF_RAM_PATH}/saed32sram_tt1p05v25c.db"

#set Std_cell_lef "${DESIGN_REF_LIB_PATH}/stdcell_hvt/lef/saed32nm_hvt_1p9m.lef"
set Std_cell_lef         "${DESIGN_REF_LIB_PATH}/stdcell_rvt/lef/saed32nm_rvt_1p9m.lef"
set Ram_lef              "${DESIGN_REF_RAM_PATH}/../lef/saed32sram.lef"
set Io_lef               "${DESIGN_REF_LIB_PATH}/io_std/lef/saed32_io_wb_all.lef"

#######################################################################################T18
#set DESIGN_REF_RAM_PATH "/project/dr095/pe57/pe5701/memory/ra2sh128x32m4h3v2"
#set DESIGN_REF_RAM_PATH2 "/project/dr095/pe57/pe5701/memory/ra1shd80x64m4h3v2"
#set DESIGN_REF_RAM_PATH3 "/project/dr095/pe57/pe5701/memory/ra1shd128x8m16h3v2"
#set Std_cell_lib        "typical.db slow.db fast.db"
#set Io_lib              "tpz973gvtc.db"
#set Ram_lib             "${DESIGN_REF_RAM_PATH}/ra2sh128x32m4h3v2_typical_syn.db ${DESIGN_REF_RAM_PATH2}/ra1shd80x64m4h3v2_typical_syn.db ${DESIGN_REF_RAM_PATH3}/ra1shd128x8m16h3v2_typical_syn.db" 
#set Ram_lef  "${DESIGN_REF_LIB_PATH}/sram/"

#######################################################################################
set REFERENCE_LIB         "${DESIGN_REF_LIB_PATH}/stdcell_rvt/ndm/saed32rvt_frame_only.ndm"

set Std_cell_gds          "${DESIGN_REF_LIB_PATH}/stdcell_rvt/gds/saed32nm_rvt_oa.gds"
set search_path           "$DESIGN_REF_RC_PATH $DESIGN_REF_NLDM_PATH $DESIGN_REF_RAM_PATH"

# For those who use old SAED32
#set Tech_file             "${DESIGN_REF_MW_PATH}/saed32nm_1p9m_mw.tf"
#set Map_file              "${DESIGN_REF_RC_PATH}/saed32nm_tf_itf_tluplus.map"
#set Antenna_file          "${DESIGN_REF_MW_PATH}/saed32nm_ant_1p9m.tcl"
#set Alf_file              "${DESIGN_REF_MW_PATH}/saed32nm_em_1p9m.alf"
#set Gds_map_file          "${DESIGN_REF_MW_PATH}/saed32nm_1p9m_gdsout_mw.map"
#set Tlup_max_file         "${DESIGN_REF_RC_PATH}/saed32nm_1p9m_Cmax.tluplus"
#set Tlup_min_file         "${DESIGN_REF_RC_PATH}/saed32nm_1p9m_Cmin.tluplus"
#set Nxtgrd_max_file       "${DESIGN_REF_RC_PATH}/saed32nm_1p9m_Cmax.nxtgrd"
#set Nxtgrd_min_file       "${DESIGN_REF_RC_PATH}/saed32nm_1p9m_Cmin.nxtgrd"

# For SAED32 2024
set Tech_file             "${DESIGN_REF_TF_PATH}/saed32nm_1p9m.tf"
set Map_file              "${DESIGN_REF_RC_PATH}/saed32nm_tf_itf_tluplus.map"
set Antenna_file          "${DESIGN_REF_TF_PATH}/../ant/saed32nm_ant_1p9m.tcl"
set Alf_file              "${DESIGN_REF_TF_PATH}/../em/saed32nm_em_1p9m.alf"
set Gds_map_file          "${DESIGN_REF_TF_PATH}/../map/saed32nm_1p9m_gdsout_mw.map"
set Tlup_max_file         "${DESIGN_REF_RC_PATH}/max/saed32nm_1p9m_Cmax.tluplus"
set Tlup_min_file         "${DESIGN_REF_RC_PATH}/min/saed32nm_1p9m_Cmin.tluplus"
set Nxtgrd_max_file       "${DESIGN_REF_RC_PATH}/max/saed32nm_1p9m_Cmax.nxtgrd"
set Nxtgrd_min_file       "${DESIGN_REF_RC_PATH}/min/saed32nm_1p9m_Cmin.nxtgrd"

set icv_drc_runset	      "${DESIGN_REF_TECH_PATH}/icv_drc/saed32nm_1p9m_drc_rules.rs"
#set icv_drc_runset "${DESIGN_REF_MW_PATH}/saed14nm_1p9m_mw.tf"
set icv_mfill_runset      "${DESIGN_REF_TECH_PATH}/icv_drc/saed32nm_1p9m_mfill_rules.rs"
###########################################################
set STARRC_CORNER_GRD_FILE "${ROOT_DIR}/lab_starRC/script/StarRC.smc"
set STARRC_SELECTED_CORNERS "fast slow"
set METAL_FILL_SELECT_LAYER "M2 M6"

##########################################################
#PT setting for single mode (Note : not for multi mode)
##########################################################
set PT_SELECTED_SCENARIO "fast slow"
set PT_REPORTS_DIR "reports"
set PT_RESULTS_DIR "results"
set PT_SESSION_DIR "pt_session"
set PT_link_path "* $Std_cell_lib $Ram_lib"
set PT_NETLIST_FILES "${ROOT_DIR}/results/${DESIGN_NAME}.out.wo_filler.v"
set PT_PARASITIC_FILES	 "${ROOT_DIR}/results/${DESIGN_NAME}.star.wo_filler.spef.fast" 
set PT_PARASITIC_PATHS	 "caravel_top"
#use gloden sdc (FROM FE)
set PT_CONSTRAINT_FILES "${ROOT_DIR}/input/${DESIGN_NAME}.sdc" 

##########################################################
#FM setting 
##########################################################
#set FM_IMPLEMENTED_DESIGN "${ROOT_DIR}/results/${DESIGN_NAME}.fm.v.gz"
set FM_IMPLEMENTED_DESIGN "${ROOT_DIR}/results/${DESIGN_NAME}.pt.v.gz"

set GRD_TLU_FILE "${DESIGN_REF_PATH}/tech/star_rc/max/"
set CORNER_GRD_FILE ""
