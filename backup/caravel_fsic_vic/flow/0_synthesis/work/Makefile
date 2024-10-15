#ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
#ICC2_EXEC = /global/apps/icc2_2022.12/bin/icc2_shell
#DC_EXEC = /global/apps/syn_2022.12/bin/dc_shell

ifeq ($(HOST_NAME),iclab)
	DC_EXEC = dc_shell
else
	DC_EXEC = Rdc_shell
endif	
#DC_EXEC = /cad/CIC/bin/Rdc_shell
LOGS_DIR = ./LOG

console:
	$(DC_EXEC)
setup:	
	echo 'HOST_NAME = $(HOST_NAME)'
	test -d $(LOGS_DIR) || mkdir $(LOGS_DIR)	
	date > setup
compile_for_timing: setup 
	$(DC_EXEC) -f ./../scripts/compile_for_timing.tcl | tee -i $(LOGS_DIR)/compile_for_timing.log
	date > 	compile_for_timing
all: setup compile_for_timing
	date > 	all
clean:
	- ls | grep -v "Makefile" | xargs rm -r
	- rm ../../../reports/*
cleanall: clean all
	date > 	cleanall

