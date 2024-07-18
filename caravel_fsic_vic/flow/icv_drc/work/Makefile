#ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
#ICC2_EXEC = /global/apps/icc2_2022.12/bin/icc2_shell
#DC_EXEC = /global/apps/syn_2022.12/bin/dc_shell
#ICV_EXEC = /global/apps/icv_2022.12-SP5/bin/LINUX.64/icv
ICV_EXEC = icv
LOGS_DIR = ./LOG
#TECH_DIR = ../../../SAED14_EDK_LAB/tech
TECH_DIR = /home/course/ee5252/lab_snps_flow/SAED14_EDK_LAB/SAED14_EDK_LAB/tech
###############################################################
#standalone icv drc setting (NDM)
###############################################################
#TOP_CELL = i2c_master_top
#FORMATE = NDM 
#LAYOUT_FILE = i2c_master_top
#LAYER_MAPPING_FILE = $(TECH_DIR)/milkyway/saed14nm_1p9m_gdsout_mw.map
#INPUT_LIBRARY_PATH = ../../results
#RUN_DIR = ./signoff_drc_run
#RUNSET_FILE = $(TECH_DIR)/icv_drc/saed14nm_1p9m_drc_rules.rs
#NUMBER_HOST = 4

###############################################################
#standalone icv drc setting (GDS)
###############################################################
TOP_CELL = i2c_master_top
FORMATE = GDSII
LAYOUT_FILE = $(INPUT_LIBRARY_PATH)/i2c_master_top.gds
LAYER_MAPPING_FILE = $(TECH_DIR)/milkyway/saed14nm_1p9m_gdsout_mw.map
INPUT_LIBRARY_PATH = ../../results
RUN_DIR = ./signoff_drc_run
RUNSET_FILE = $(TECH_DIR)/icv_drc/saed14nm_1p9m_drc_rules.rs
#NUMBER_HOST = 4




console:
	$(ICV_EXEC)
setup:	
	test -d $(LOGS_DIR) || mkdir $(LOGS_DIR)
	test -d $(RUN_DIR) || mkdir $(RUN_DIR)
	date > setup
run_icv_DRC: setup 
	$(ICV_EXEC) -vue -c $(TOP_CELL) -f $(FORMATE) -lf $(LAYER_MAPPING_FILE) -p $(INPUT_LIBRARY_PATH) -i $(LAYOUT_FILE) -I $(RUN_DIR) $(RUNSET_FILE) | tee -i $(LOGS_DIR)/run_icv_DRC.log
	date > 	run_icv_DRC
all: setup run_icv_DRC
	date > 	all
clean:
	ls | grep -v "Makefile" | xargs rm -r

