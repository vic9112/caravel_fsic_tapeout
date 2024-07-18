#ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
#ICC2_EXEC = /global/apps/icc2_2022.12/bin/icc2_shell
#DC_EXEC = /global/apps/syn_2022.12/bin/dc_shell
#ICV_EXEC = /global/apps/icv_2022.12-SP5/bin/LINUX.64/icv
LOGS_DIR = ./LOG
TECH_DIR = ../../../SAED14_EDK_LAB/tech/
#STARXTRACT_EXEC = /global/apps/starrc_2022.12-SP5/bin/StarXtract
STARXTRACT_EXEC = StarXtract

###############################################################
#standalone StarRC EXTRACTIN setting
###############################################################

console:
	$(ICV_EXEC)
setup:	
	test -d $(LOGS_DIR) || mkdir $(LOGS_DIR)
	test -d $(RUN_DIR) || mkdir $(RUN_DIR)
	date > setup
gen_StarRC_smc: setup
	rm -rf ./../script/StarRC.smc
	./../script/gen_StarRC_smc.tcl
	date > 	gen_StarRC_smc
gen_StarRC_cmd: setup
	rm -rf ./../script/star_cmd_gate 
	./../script/gen_star_cmd_gate_DEFLEF.tcl
	date > 	gen_StarRC_cmd
run_StarRC_cmd: setup 
	$(STARXTRACT_EXEC) ./../script/star_cmd_gate
	date > 	run_StarRC_cmd
all: setup gen_StarRC_smc gen_StarRC_cmd run_StarRC_cmd
	date > 	all
clean:
	ls | grep -v "Makefile" | xargs rm -r

