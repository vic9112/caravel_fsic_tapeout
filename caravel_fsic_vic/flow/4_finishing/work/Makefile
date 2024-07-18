#ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
#ICC2_EXEC = /global/apps/icc2_2022.12/bin/icc2_shell
ICC2_EXEC = icc2_shell
LOGS_DIR = ./LOG

console:
	$(ICC2_EXEC)
setup:	
	test -d $(LOGS_DIR) || mkdir $(LOGS_DIR)	
	date > setup
step7_finishing: setup
	$(ICC2_EXEC) -f ./../scripts/step7_finishing.tcl | tee -i $(LOGS_DIR)/step7_finishing.log
	date > 	step7_finishing
all: setup step7_finishing
	date > all
clean:
	ls | grep -v "Makefile" | xargs rm -r
