#ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
#ICC2_EXEC = /global/apps/icc2_2022.12/bin/icc2_shell
#DC_EXEC = /global/apps/syn_2022.12/bin/dc_shell
#ICV_EXEC = /global/apps/icv_2022.12-SP5/bin/LINUX.64/icv
#FM_EXEC = /global/apps/fm_2022.12-SP6/bin/fm_shell
FM_EXEC = /usr/cad/synopsys/formality/2021.06/bin/fm_shell
LOGS_DIR = ./LOG
TECH_DIR = ../../../SAED14_EDK_LAB/tech/


console:
	$(FM_EXEC)
setup:	
	test -d $(LOGS_DIR) || mkdir $(LOGS_DIR)
	date > setup
gen_formality_cmd: setup 
	tclsh ./../script/gen_formality_cmd.tcl
	date > gen_formality_cmd
run_formality_cmd: gen_formality_cmd setup 
	$(FM_EXEC) -file ../script/run_formality_cmd.tcl | tee -i $(LOGS_DIR)/run_formality.log
	date > run_formality_cmd
all: setup run_formality_cmd
	date > 	all
clean:
	ls | grep -v "Makefile" | xargs rm -r

