# Vic: restructure folder

.PHONY: setup_caravel
setup_caravel:
	cp common/common.saed32.tcl common/common.tcl
	cp ./flow/0_synthesis/scripts/compile_for_timing.tcl.caravel ./flow/0_synthesis/scripts/compile_for_timing.tcl
	#cp lab_formal/script/gen_formality_cmd.tcl.caravel lab_formal/script/gen_formality_cmd.tcl   youwei comment it seems not to use for saed32

.PHONY: setup_t18
setup_t18: setup_caravel
	cp ./sim/sim_vcs/env/bfm.lib.f.t18 ./sim/sim_vcs/env/bfm.lib.f
	cp ./sim/system/env/bfm.lib.f.t18  ./sim/system/env/bfm.lib.f
	cp ./rtl/top/synthesis_defines.v.t18 ./rtl/top/synthesis_defines.v
	cp ./common/common.t18.tcl ./common/common.tcl


.PHONY: setup_saed32
setup_saed32: setup_caravel
	cp ./sim/sim_vcs/env/bfm.lib.f.saed32 ./sim/sim_vcs/env/bfm.lib.f
	cp ./sim/system/env/bfm.lib.f.saed32  ./sim/system/env/bfm.lib.f
	cp ./rtl/top/synthesis_defines.v.saed32 ./rtl/top/synthesis_defines.v
	cp ./common/common.saed32.tcl ./common/common.tcl

.PHONY: t18_cleanall
t18_cleanall: setup_t18
	$(MAKE) clean -C    ./sim
	$(MAKE) setup -C    ./sim
	$(MAKE) cleanall -C ./flow/0_synthesis/work
	$(MAKE) all -C  ./sim TARGET_PROCESS=T18 | tee make_t18_all.log

.PHONY: saed32_cleanall
saed32_cleanall: setup_saed32
	$(MAKE) clean -C    ./sim
	$(MAKE) setup -C    ./sim
	$(MAKE) cleanall -C ./flow/0_synthesis/work
	$(MAKE) all -C  ./sim TARGET_PROCESS=SAED32 | tee make_saed32_all.log


.PHONY: t18
t18: t18_cleanall

.PHONY: saed32
saed32: saed32_cleanall

############################## Logic Synthesis #################################
# Vic: separate synthesis (Design Compiler) and simulation (VCS)
.PHONY: saed32_syn
saed32_syn: setup_saed32
	$(MAKE) cleanall -C ./flow/0_synthesis/work | tee saed32_syn.log

.PHONY: saed32_sim
saed32_sim:
	$(MAKE) clean -C   ./sim
	$(MAKE) setup -C   ./sim
	$(MAKE) pre_sim -C ./sim TARGET_PROCESS=SAED32 | tee saed32_presim.log

.PHONY: t18_syn
t18_syn:
	$(MAKE) cleanall -C ./flow/0_synthesis/work

.PHONY: t18_sim
t18_sim:
	$(MAKE) clean -C   ./sim
	$(MAKE) setup -C   ./sim
	$(MAKE) pre_sim -C ./sim TARGET_PROCESS=T18 | tee t18_presim.log

# for debug and test in sim_vcs folder
.PHONY: t18_vcs
t18_vcs: 
	cp ./sim/sim_vcs/env/bfm.lib.f.t18 ./sim/sim_vcs/env/bfm.lib.f
	cp ./rtl/synthesis_defines.v.t18 ./rtl/synthesis_defines.v
	cp ./common/common.t18.tcl ./common/common.tcl

	$(MAKE) clean -C  ./sim/sim_vcs
	$(MAKE) rtlcom -C ./sim/sim_vcs TARGET_PROCESS=T18 
	cp ./sim/sim_vcs/compile.log ./sim/sim_vcs/compile.log.rtl

	$(MAKE) clean -C ./flow/0_synthesis/work
	$(MAKE) all -C   ./flow/0_synthesis/work

	$(MAKE) clean -C   ./sim/sim_vcs
	$(MAKE) postcom -C ./sim/sim_vcs TARGET_PROCESS=T18 
	cp ./sim/sim_vcs/compile.log ./sim/sim_vcs/compile.log.post

# for debug and test in sim_vcs folder
.PHONY:saed32_vcs
saed32_vcs: 
	cp ./sim/sim_vcs/env/bfm.lib.f.saed32 ./sim/sim_vcs/env/bfm.lib.f
	cp ./rtl/synthesis_defines.v.saed32 ./rtl/synthesis_defines.v
	cp ./common/common.saed32.tcl ./common/common.tcl

	$(MAKE) clean -C  ./sim/sim_vcs
	$(MAKE) rtlcom -C ./sim/sim_vcs TARGET_PROCESS=SAED32 
	cp ./sim/sim_vcs/compile.log ./sim/sim_vcs/compile.log.rtl

	$(MAKE) clean -C ./flow/0_synthesis/work
	$(MAKE) all -C   ./flow/0_synthesis/work

	$(MAKE) clean -C   ./sim/sim_vcs
	$(MAKE) postcom -C ./sim/sim_vcs TARGET_PROCESS=SAED32 
	cp ./sim/sim_vcs/compile.log ./sim/sim_vcs/compile.log.post


.PHONY:clean 
clean:
	$(MAKE) clean -C ./sim
	$(MAKE) clean -C ./sim/sim_vcs
	$(MAKE) clean -C ./flow/0_synthesis/work
	- rm *.log
	- rm ./upload/* 


