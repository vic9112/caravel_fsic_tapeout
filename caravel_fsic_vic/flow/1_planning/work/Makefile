#ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
#ICC2_EXEC = /global/apps/icc2_2022.12-SP5/bin/icc2_shell
ICC2_EXEC = icc2_shell
LOGS_DIR = ./LOG

console:
	$(ICC2_EXEC)
setup: #[Vic] Using generated ndm libraries
	cp -r ../../ndm_libs ./
	mv ndm_libs CLIBs
	test -d $(LOGS_DIR) || mkdir $(LOGS_DIR)	
	date > setup
step1_data_setup: setup
	test -e $(LOGS_DIR)/../../../results/caravel_top || rm -rf ../../../results/caravel_top
	$(ICC2_EXEC) -f ./../scripts/step1_data_setup.tcl | tee -i $(LOGS_DIR)/step1_data_setup.log
	date > 	step1_data_setup
step2_floorplan: setup step1_data_setup
	$(ICC2_EXEC) -f ./../scripts/step2_floorplan.tcl | tee -i $(LOGS_DIR)/step2_floorplan.log
	date > step2_floorplan
step3_powerplan: setup step2_floorplan
	$(ICC2_EXEC) -f ./../scripts/step3_powerplan.tcl | tee -i $(LOGS_DIR)/step3_powerplan.log
	date >  step3_powerplan
all: setup step3_powerplan
	date > all 
clean:
	ls | grep -v "Makefile" | xargs rm -rf
	rm -rf ../../../results/caravel_top
