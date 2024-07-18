#ICC2_EXEC = /global/apps/icc2_2019.12/bin/icc2_shell
#ICC2_EXEC = /global/apps/icc2_2022.12-SP5/bin/icc2_shell
ICC2_EXEC = icc2_shell
LOGS_DIR = ./LOG

console:
	$(ICC2_EXEC)
setup:	
	test -d $(LOGS_DIR) || mkdir $(LOGS_DIR)	
	date > setup
step4_place: setup
	$(ICC2_EXEC) -f ./../scripts/step4_place.tcl | tee -i $(LOGS_DIR)/step4_place.log
	date > step4_place
step5_clock_tree_syntesis: step4_place
	$(ICC2_EXEC) -f ./../scripts/step5_clock_tree_syntesis.tcl | tee -i $(LOGS_DIR)/step5_clock_tree_syntesis.log
	date > step5_clock_tree_syntesis
step6_route: step5_clock_tree_syntesis
	$(ICC2_EXEC) -f ./../scripts/step6_route.tcl | tee -i $(LOGS_DIR)/step6_route.log
	date > step6_route
all: step6_route
	date > all	

clean:
	ls | grep -v "Makefile" | xargs rm -r

