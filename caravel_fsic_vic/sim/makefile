
#.PHONY: run_edge_rtl
#run_edge_rtl:
#	$(MAKE) rtlcom -C sim_vcs_edge
#	cp sim_vcs_edge/compile.log sim_vcs_edge/compile.log.rtl
	
#.PHONY: run_edge_post
#run_edge_post:
#	$(MAKE) postcom -C sim_vcs_edge
#	cp sim_vcs_edge/compile.log sim_vcs_edge/compile.log.post
	
#.PHONY: run_edge
#run_edge: run_edge_rtl run_edge_post

.PHONY: clean
clean:
	rm -rf sim_vcs_system_test111

	rm -rf sim_vcs_system_test112

	rm -rf sim_vcs_system_test103

	rm -rf sim_vcs_system_test104

	rm -rf sim_vcs_system_test113

	rm -rf sim_vcs_system_test114

# $(MAKE) clean -C sim_vcs_edge

TARGETS = test111 test112 test113 test114 test103 test104

# Define variables for clarity (assuming sim_vcs_system is the common path)
SIM_DIR = sim_vcs_system

.PHONY: dir_rtl

dir_rtl:
	for dir in $(TARGETS); do \
		$(MAKE) rtlcom -C $(SIM_DIR)_$$dir; \
		cp  $(SIM_DIR)_$$dir/compile.log $(SIM_DIR)_$$dir/compile.log.rtl; \
	done

.PHONY: dir_post
dir_post:
	for dir in $(TARGETS); do \
		$(MAKE) postcom -C $(SIM_DIR)_$$dir; \
		cp  $(SIM_DIR)_$$dir/compile.log $(SIM_DIR)_$$dir/compile.log.post; \
	done

pre_sim: dir_rtl dir_post #run_edge youwei comment delete edge part

SED_CMD = sed -e 's/^\/\/`define\s*SYSTEM_$$dir\s*1/`define SYSTEM_$$dir 1/' testbench/top_bench.sv 

.PHONY: setup_sed
setup_sed:

	for dir in $(TARGETS); do \
		$(SED_CMD) > $(SIM_DIR)_$$dir/top_bench.sv; \
	done

.PHONY: setup_new
setup_new:

	for dir in $(TARGETS); do \
		rm -rf $(SIM_DIR)_$$dir; \
		cp -r system $(SIM_DIR)_$$dir; \
		sed -e 's/^\/\/`define\s*SYSTEM_$$dir\s*1/`define SYSTEM_$$dir 1/' testbench/top_bench.sv > $(SIM_DIR)_$$dir/top_bench.sv; \
		cp system/hex/system_$$dir.hex $(SIM_DIR)_$$dir/riscv.hex; \
	done

.PHONY: setup
setup:
	rm -rf sim_vcs_system_test111
	cp -r system sim_vcs_system_test111
	sed -e 's/^\/\/`define\s*SYSTEM_test111\s*1/`define SYSTEM_test111 1/' testbench/top_bench.sv > sim_vcs_system_test111/top_bench.sv
	cp system/hex/system_test111.hex sim_vcs_system_test111/riscv.hex

	rm -rf sim_vcs_system_test112
	cp -r system sim_vcs_system_test112
	sed -e 's/^\/\/`define\s*SYSTEM_test112\s*1/`define SYSTEM_test112 1/' testbench/top_bench.sv > sim_vcs_system_test112/top_bench.sv
	cp system/hex/system_test112.hex sim_vcs_system_test112/riscv.hex

	rm -rf sim_vcs_system_test103
	cp -r system sim_vcs_system_test103
	sed -e 's/^\/\/`define\s*SYSTEM_test103\s*1/`define SYSTEM_test103 1/' testbench/top_bench.sv > sim_vcs_system_test103/top_bench.sv
	cp system/hex/system_test103.hex sim_vcs_system_test103/riscv.hex

	rm -rf sim_vcs_system_test104
	cp -r system sim_vcs_system_test104
	sed -e 's/^\/\/`define\s*SYSTEM_test104\s*1/`define SYSTEM_test104 1/' testbench/top_bench.sv > sim_vcs_system_test104/top_bench.sv
	cp system/hex/system_test104.hex sim_vcs_system_test104/riscv.hex

	rm -rf sim_vcs_system_test113
	cp -r system sim_vcs_system_test113
	sed -e 's/^\/\/`define\s*SYSTEM_test113\s*1/`define SYSTEM_test113 1/' testbench/top_bench.sv > sim_vcs_system_test113/top_bench.sv
	cp system/hex/system_test113.hex sim_vcs_system_test113/riscv.hex

	rm -rf sim_vcs_system_test114
	cp -r system sim_vcs_system_test114
	sed -e 's/^\/\/`define\s*SYSTEM_test114\s*1/`define SYSTEM_test114 1/' testbench/top_bench.sv > sim_vcs_system_test114/top_bench.sv
	cp system/hex/system_test114.hex sim_vcs_system_test114/riscv.hex



	
