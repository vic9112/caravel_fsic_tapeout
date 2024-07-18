#ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
#ICC2_EXEC = /global/apps/icc2_2022.12/bin/icc2_shell
#DC_EXEC = /global/apps/syn_2022.12/bin/dc_shell
#PT_EXEC = /global/apps/pt_2022.12-SP5/bin/pt_shell
PT_EXEC = pt_shell
LOGS_DIR = ./LOG
TECH_DIR = ../../../SAED14_EDK_LAB/tech/

PT_SELECTED_SCENARIO = fast slow

console:
	$(PT_EXEC)
setup:
	test -d pt_workspace | mkdir pt_workspace
	for SCENARIO in $(PT_SELECTED_SCENARIO); do test -d ./pt_workspace/$$SCENARIO || mkdir ./pt_workspace/$$SCENARIO ; done
	date > setup		
gen_pt_cmd: setup 
	tclsh ./../script/gen_pt_cmd.tcl
	date > gen_pt_cmd
set_pt_cmd: setup gen_pt_cmd
	for SCENARIO in $(PT_SELECTED_SCENARIO); do chmod 777 -R ./pt_workspace/$$SCENARIO ; done
	date > set_pt_cmd
run_pt: setup gen_pt_cmd set_pt_cmd
	for SCENARIO in $(PT_SELECTED_SCENARIO); do $(PT_EXEC) -file ./pt_workspace/$$SCENARIO/run_pt_cmd.$$SCENARIO.tcl -output_log_file ./pt_workspace/$$SCENARIO/run_pt.log.$$SCENARIO  ; done
	date > 	run_pt
all: setup run_pt
	date > 	all
clean:
	ls | grep -v "Makefile" | xargs rm -r

