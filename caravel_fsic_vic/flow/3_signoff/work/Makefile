# ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
# ICC2_EXEC = /global/apps/icc2_2022.12-SP5/bin/icc2_shell
ICC2_EXEC = icc2_shell

LOGS_DIR = ./LOG

console:
	$(ICC2_EXEC)
setup:
	
	test -d $(LOGS_DIR) || mkdir $(LOGS_DIR)	
	date > setup
step8_signoff: setup
	$(ICC2_EXEC) -f ./../scripts/signoff_drc.tcl | tee -i $(LOGS_DIR)/step8_signoff.log
	date > 	step8_signoff
all: step8_signoff
	date > all
clean:
	- ls | grep -v "Makefile" | xargs rm -r
