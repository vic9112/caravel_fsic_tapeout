.PHONY:rtlcom postcom rtlgui postgui sim cov clean

OUTPUT = simv_dff_exp

#SIM is for caravel_top.v to set default_nettype
VERILOG_DEFINE = +define+SIM
#USER_PROJECT_SIDEBAND_SUPPORT should be enable in default
VERILOG_DEFINE += +define+USER_PROJECT_SIDEBAND_SUPPORT
#USE_EDGEDETECT_IP should be enable in default
VERILOG_DEFINE += +define+USE_EDGEDETECT_IP

#FUNCTIONAL is for skywater ring_osc module simulation no used in saed32 and t18
#VERILOG_DEFINE += +define+FUNCTIONAL

#USER_PROJ_IRQ0_EN is used in top_bench
TOP_BENTCH_DEFINE = +define+USER_PROJ_IRQ0_EN
# only edge_detect need to use TOP_BENCH_USE_EDGEDETECT_IP
#TOP_BENTCH_DEFINE = +define+TOP_BENCH_USE_EDGEDETECT_IP

#for SAED32 EDK
SAED32_TARGET_DEFINE = +define+USE_EDK32
SAED32_TARGET_DEFINE += +define+USE_EDK_IO
SAED32_TARGET_DEFINE += +define+USE_EDK_SRAM

#for T18 PDK
T18_TARGET_DEFINE = +define+USE_PDK18
T18_TARGET_DEFINE += +define+USE_PDK18_IO
T18_TARGET_DEFINE += +define+USE_PDK_SRAM

export TARGET_PROCESS ?= SAED32

ifeq ($(TARGET_PROCESS), SAED32)
	TARGET_DEFINE = $(SAED32_TARGET_DEFINE)
endif

ifeq ($(TARGET_PROCESS), T18)
	TARGET_DEFINE = $(T18_TARGET_DEFINE)
endif

RTL_DEFINE = $(VERILOG_DEFINE)
RTL_DEFINE += $(TOP_BENTCH_DEFINE)
RTL_DEFINE += $(TARGET_DEFINE)
#CPU_TRACE is only used in rtl simulation, for post simulation no interface to get the cpu internal signal.
RTL_DEFINE += +define+CPU_TRACE

# for post simulation, the 
POST_DEFINE = $(TOP_BENTCH_DEFINE)
#USER_PROJECT_SIDEBAND_SUPPORT used by behavior model when post simulation
POST_DEFINE += +define+USER_PROJECT_SIDEBAND_SUPPORT
# use synthesis_defines.v to add VERILOG_DEFINE except 'SIM' and TARGET_DEFINE for synthesis



#code coverage command
CM = -cm line+cond+fsm+branch+tgl
CM_NAME = -cm_name $(OUTPUT)
CM_DIR = -cm_dir ./$(OUTPUT).vdb

# vpd file name
VPD_NAME = +vpdfiles+$(OUTPUT).vpd

#compile command 
ifeq ($(HOST_NAME),iclab)
    VCS_EXE = vcs
		DVE_EXE = /usr/cadtool/cad/synopsys/vcs/2020.12-sp2/gui/dve/bin/dve
else
    VCS_EXE = Rvcs
		DVE_EXE = Rdve
endif

vcs_encrypt = $(VCS_EXE) -sverilog +v2k -timescale=1ns/1ns              \
	+autoprotect.vp \
	+nospecify                                           \
 	+vcs+flush+all                                       \
	-full64												\
	-R													\
	-debug_access+all									\
 	+nontimingcheck                                      \
	+incdir+../../rtl/top                                \
	+incdir+../../rtl/caravel                            \
	+incdir+../../rtl/fsic                               \
	+incdir+../../rtl/user_project                       \
	+incdir+../system/env	\
	+lint=TFIPC-L	\
 	$(CM)                                                \
 	$(CM_NAME)                                           \
 	$(CM_DIR)                                            \
 	$(RTL_DEFINE)                                        \
 	$(VPD_NAME)                                          \
 	-o $(OUTPUT)                                         \
 	-l compile.log

vcs_RTL = $(VCS_EXE) -sverilog +v2k -timescale=1ns/1ns              \
	+nospecify                                           \
 	+vcs+flush+all                                       \
	-full64												\
	-R													\
	-debug_access+all									\
 	+nontimingcheck                                      \
	+incdir+../../rtl/top                                \
	+incdir+../../rtl/caravel                            \
	+incdir+../../rtl/fsic                               \
	+incdir+../../rtl/user_project                       \
	+incdir+../system/env	\
	+lint=TFIPC-L	\
 	$(CM)                                                \
 	$(CM_NAME)                                           \
 	$(CM_DIR)                                            \
 	$(RTL_DEFINE)                                        \
 	$(VPD_NAME)                                          \
 	-o $(OUTPUT)                                         \
 	-l compile.log

vcs_POST = $(VCS_EXE) -sverilog +v2k -timescale=1ns/1ns              \
	+nospecify                                           \
 	+vcs+flush+all                                       \
	-full64												\
	-R													\
	-debug_access+all									\
 	+nontimingcheck                                      \
	+incdir+../../rtl/top                                \
	+incdir+../../rtl/caravel                            \
	+incdir+../../rtl/fsic                               \
	+incdir+../../rtl/user_project                       \
	+incdir+../system/env	\
	+lint=TFIPC-L	\
 	$(CM)                                                \
 	$(CM_NAME)                                           \
 	$(CM_DIR)                                            \
 	$(POST_DEFINE)                                        \
 	$(VPD_NAME)                                          \
 	-o $(OUTPUT)                                         \
 	-l compile.log

vcs_RTL_gui = $(VCS_EXE) -sverilog +v2k -timescale=1ns/1ns              \
	+nospecify                                           \
 	+vcs+flush+all                                       \
	-full64												\
	-R													\
	-gui -kdb	\
	-debug_access+all									\
 	+nontimingcheck                                      \
	+incdir+../../rtl/top                                \
	+incdir+../../rtl/caravel                            \
	+incdir+../../rtl/fsic                               \
	+incdir+../../rtl/user_project                       \
	+incdir+../system/env	\
	+lint=TFIPC-L	\
 	$(CM)                                                \
 	$(CM_NAME)                                           \
 	$(CM_DIR)                                            \
 	$(RTL_DEFINE)                                        \
 	$(VPD_NAME)                                          \
 	-o $(OUTPUT)                                         \
 	-l compile.log

vcs_POST_gui = $(VCS_EXE) -sverilog +v2k -timescale=1ns/1ns              \
	+nospecify                                           \
 	+vcs+flush+all                                       \
	-full64												\
	-R													\
	-gui -kdb	\
	-debug_access+all									\
 	+nontimingcheck                                      \
	+incdir+../../rtl/top                                \
	+incdir+../../rtl/caravel                            \
	+incdir+../../rtl/fsic                               \
	+incdir+../../rtl/user_project                       \
	+incdir+../system/env	\
	+lint=TFIPC-L	\
 	$(CM)                                                \
 	$(CM_NAME)                                           \
 	$(CM_DIR)                                            \
 	$(POST_DEFINE)                                        \
 	$(VPD_NAME)                                          \
 	-o $(OUTPUT)                                         \
 	-l compile.log

	#-debug_all                                           \

#simulation command
SIM = ./$(OUTPUT)                \
  $(CM) $(CM_NAME) $(CM_DIR) \
  $(VPD_NAME)                \
  -l $(OUTPUT).log

# start compile
rtlencrypt: 	
	$(vcs_encrypt) -f ../../rtl/caravel.f \
	-f ../system/env/bfm.sys.f \
	-f ../system/env/bfm.lib.f 

rtlcom: 	
	$(vcs_RTL) -f ../../rtl/caravel.f \
	-f ../system/env/bfm.sys.f \
	-f ../system/env/bfm.lib.f 

postcom: 	
	$(vcs_POST) -f ../../rtl/caravel_post.f \
	-f ../system/env/bfm.sys.f \
	-f ../system/env/bfm.lib.f 

rtlgui: 	
	$(vcs_RTL_gui) -f ../../rtl/caravel.f \
	-f ../system/env/bfm.sys.f \
	-f ../system/env/bfm.lib.f 

postgui: 	
	$(vcs_POST_gui) -f ../../rtl/caravel_post.f \
	-f ../system/env/bfm.sys.f \
	-f ../system/env/bfm.lib.f 


#start simulation
sim:
	$(SIM)

# show the coverage
cov:
	$(DVE_EXE) -covdir *.vdb &

debug:
	$(DVE_EXE) -vpd $(OUTPUT).vpd &

# start clean

clean:
	rm -rf ./csrc *.daidir ./csrc *.log *.vdb *.vdb simv* *.key *.vcd *.fsdb novas.*
