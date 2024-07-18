#ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
#ICC2_EXEC = /global/apps/icc2_2022.12/bin/icc2_shell
#DC_EXEC = /global/apps/syn_2022.12/bin/dc_shell
#ICV_EXEC = /global/apps/icv_2022.12-SP5/bin/LINUX.64/icv
#ICV_NETTRAN_EXEC = /global/apps/icv_2022.12-SP5/bin/LINUX.64/icv_nettran
ICV_EXEC = icv
ICV_NETTRAN_EXEC = icv_nettran
LOGS_DIR = ./LOG
TECH_DIR = ../../../SAED14_EDK_LAB/tech/



###############################################################
#standalone icv lvs setting (GDS)
###############################################################
GDSII_TOPCELL_NAME = i2c_master_top
GDSII_FILE = ../../results/$(GDSII_TOPCELL_NAME).gds
SPICE_FILE = ./netlist2spice.sp
NETLIST_TOPCELL_NAME = i2c_master_top
LVS_RUNSET_FILE = ../script/saed14nm_1p9m_lvs_runset.rs.tim

console:
	$(ICV_EXEC)
setup:	
	test -d $(LOGS_DIR) || mkdir $(LOGS_DIR)
	test -d $(RUN_DIR) || mkdir $(RUN_DIR)
	date > setup
run_icv_nettran: setup
	$(ICV_NETTRAN_EXEC) -verilog ../../results/i2c_master_top.lvs.v.gz -sp ../script/rev_saed14nm_rvt_2.cdl ../script/rev_test.sp -outType SPICE -outName netlist2spice.sp
	date > run_icv_nettran
run_icv_LVS: setup run_icv_nettran 
	$(ICV_EXEC) -vue -vueshortALL -create_lvs_short_outputALL -i $(GDSII_FILE) -c $(GDSII_TOPCELL_NAME) -s $(SPICE_FILE) -stc $(NETLIST_TOPCELL_NAME) -sf SPICE $(LVS_RUNSET_FILE) 
	date > 	run_icv_LVS
all: setup run_icv_nettran run_icv_LVS
	date > 	all
clean:
	ls | grep -v "Makefile" | xargs rm -r

