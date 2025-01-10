test001:
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test001 1|`define SYSTEM_test001 1|' tb.sv
	make run_sim
test002:
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test002 1|`define SYSTEM_test002 1|' tb.sv
	make run_sim
test003:          
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test003 1|`define SYSTEM_test003 1|' tb.sv
	make run_sim
test004:          
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test004 1|`define SYSTEM_test004 1|' tb.sv
	make run_sim
test005:
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test005 1|`define SYSTEM_test005 1|' tb.sv
	make run_sim
test006:
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test006 1|`define SYSTEM_test006 1|' tb.sv
	make run_sim
test007:
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test007 1|`define SYSTEM_test007 1|' tb.sv
	make run_sim
test008:
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test008 1|`define SYSTEM_test008 1|' tb.sv
	make run_sim
test009:
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test009 1|`define SYSTEM_test009 1|' tb.sv
	make run_sim
test010:
	cp ./top_bench.sv tb.sv
	@sed -i 's|// *`define SYSTEM_test010 1|`define SYSTEM_test010 1|' tb.sv
	make run_sim
	
run_sim:
	xvlog -f ./file_list tb.sv
	xelab -top tb_fsic -debug all -snapshot tb_fsic_elab
	xsim tb_fsic_elab -R | tee sim.log

clean:
	## -rf: remove recursively and forcefully
	rm -rf xsim.dir/ *.log *.pb *.jou *.wdb *.vcd tb.v
