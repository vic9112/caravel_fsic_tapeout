# 2024.7.11 Modified by Vic

################# Main Path On EDA Cloud ##################
set starrc_bin_path       "/cad/synopsys/star-rcxt/2020.09/linux64_starrc/bin"
set primetime_bin_path    "/cad/synopsys/primetime/2022.12/bin"
set REDHAWK_PGA_ICV_DIR   "/cad/synopsys/icvalidator/2022.12-sp4/bin"

###########################################################
set ROOT_DIR              "[pwd]/../../.."
set DESIGN_REF_PATH       "/cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC"
set VERILOG_DIR           "${ROOT_DIR}/rtl"
###########################################################
set DESIGN_NAME "caravel_top"

set Constraints_file      "${ROOT_DIR}/common/${DESIGN_NAME}.sdc"
set analyze_script        "${ROOT_DIR}/common/${DESIGN_NAME}_analyze.tcl"
set Warning_file          "${ROOT_DIR}/common/warnings_to_ignore.tcl"
############### outputs 
set Svf_file              "${ROOT_DIR}/input/${DESIGN_NAME}.svf"
set ARC_TOP               "${ROOT_DIR}/results/${DESIGN_NAME}"
set Core_compile          "${ROOT_DIR}/input/${DESIGN_NAME}.v"  
set Top_design_pt         "${ROOT_DIR}/input/${DESIGN_NAME}_pt.v"
###########################################################

##### ?????????????????
set pns_vlayer M6
set pns_hlayer M7
##### ?????????????????

set route_min_layer M1
set route_max_layer M5

########################################################### REF_PATH
set DESIGN_REF_LIB_PATH  "${DESIGN_REF_PATH}/SynopsysDC/lib"
set DESIGN_REF_DB_PATH   "${DESIGN_REF_PATH}/SynopsysDC/db"
########################################################### LIB_PATH
set DESIGN_REF_MW_PATH   "${DESIGN_REF_PATH}/ICC/tsmc18_fram"
set DESIGN_REF_RC_PATH   "${DESIGN_REF_PATH}/ICC/tlupus"
set DESIGN_REF_ICC_PATH  "${DESIGN_REF_PATH}/ICC"
###########################################################

########################################################### T18
set DESIGN_REF_RAM_PATH  "/project/dr095/pe57/pe5701/memory/ra2sh128x32m4h3v2"
set DESIGN_REF_RAM_PATH2 "/project/dr095/pe57/pe5701/memory/ra1shd80x64m4h3v2"
set DESIGN_REF_RAM_PATH3 "/project/dr095/pe57/pe5701/memory/ra1shd128x8m16h3v2"

set Std_cell_lib         "typical.db slow.db fast.db"
set Io_lib               "tpz973gvtc.db tpz973gvwc.db tpz973gvbc.db"
set Ram_lib              "${DESIGN_REF_RAM_PATH}/ra2sh128x32m4h3v2_typical_syn.db \
                          ${DESIGN_REF_RAM_PATH2}/ra1shd80x64m4h3v2_typical_syn.db \
                          ${DESIGN_REF_RAM_PATH3}/ra1shd128x8m16h3v2_typical_syn.db" 

set Std_cell_lef         "${DESIGN_REF_PATH}/SOCE/lef/tsmc18_6lm_cic.lef"
set Io_lef               "${DESIGN_REF_PATH}/SOCE/lef/tpz973gv_6lm_cic.lef"
set Ram_lef              "${DESIGN_REF_RAM_PATH}/ra2sh128x32m4h3v2_ant.lef \
                          ${DESIGN_REF_RAM_PATH2}/ra1shd80x64m4h3v2_ant.lef \
                          ${DESIGN_REF_RAM_PATH3}/ra1shd128x8m16h3v2_ant.lef"
###########################################################
set REFERENCE_LIB        ""

set Std_cell_gds         "${DESIGN_REF_PATH}/Phantom/tsmc18_core.gds"
set search_path          "$DESIGN_REF_RC_PATH $DESIGN_REF_NLDM_PATH $DESIGN_REF_RAM_PATH"

set Tech_file            "${DESIGN_REF_MW_PATH}/../tsmc18_CIC.tf"
set Map_file             "${DESIGN_REF_RC_PATH}/t18.map"
set Tluplus_file         "${DESIGN_REF_RC_PATH}/t18.tluplus"

# ??? set Antenna_file         "${DESIGN_REF_MW_PATH}/saed32nm_ant_1p9m.tcl"
# ??? set Alf_file             "${DESIGN_REF_MW_PATH}/saed32nm_em_1p9m.alf"
# ??? set Gds_map_file         "${DESIGN_REF_MW_PATH}/saed32nm_1p9m_gdsout_mw.map"
set Nxtgrd_file          "${DESIGN_REF_PATH}/StarRC/t018s6mm_rf.nxtgrd"

# ??? set icv_drc_runset       "${DESIGN_REF_TECH_PATH}/icv_drc/saed32nm_1p9m_drc_rules.rs"
# ??? set icv_mfill_runset     "${DESIGN_REF_TECH_PATH}/icv_drc/saed32nm_1p9m_mfill_rules.rs"
###########################################################
# ??? set STARRC_CORNER_GRD_FILE "${ROOT_DIR}/lab_starRC/script/StarRC.smc"
set STARRC_SELECTED_CORNERS "fast slow"
set METAL_FILL_SELECT_LAYER "M2 M6"

###########################################################
#PT setting for single mode (Note : not for multi mode)
###########################################################
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

###########################################################
#FM setting 
###########################################################
#set FM_IMPLEMENTED_DESIGN "${ROOT_DIR}/results/${DESIGN_NAME}.fm.v.gz"
set FM_IMPLEMENTED_DESIGN "${ROOT_DIR}/results/${DESIGN_NAME}.pt.v.gz"

set GRD_TLU_FILE "${DESIGN_REF_PATH}/tech/star_rc/max/"
set CORNER_GRD_FILE ""
