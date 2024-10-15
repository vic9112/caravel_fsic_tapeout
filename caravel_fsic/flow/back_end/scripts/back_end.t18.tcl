################################################################################
# Date: 8/6/2024            
# Name: Vic Chen             
################################################################################

set_host_options -max_core 16
set_app_options  -name shell.common.report_default_significant_digits -value 3
set_app_var search_path "."

set DESIGN_NAME       "caravel_top"
set DESIGN_LIBRARY    "../../../results/${DESIGN_NAME}.dlib"

## Data setup
set TECH_FILE         "/cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/ICC/tsmc18_CIC.tf"

## tsmc18_fram: ICC core library; tpz973gv: ICC IO library; tpb973gv: ICC Bond_pad library
set MW_LIBRARY        "/cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/ICC/tsmc18_fram \
                       /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/ICC/tpz973gv \
                       /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/ICC/tpb973gv"
## RAM path
set DESIGN_REF_RAM1   "/project/dr095/pe57/pe5701/memory/ra2sh128x32m4h3v2"
set DESIGN_REF_RAM2   "/project/dr095/pe57/pe5701/memory/ra1shd80x64m4h3v2"
set DESIGN_REF_RAM3   "/project/dr095/pe57/pe5701/memory/ra1shd128x8m16h3v2"

## lef
set PHYSICAL_LIBRARY  "/cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SOCE/lef/tsmc18_6lm_cic.lef \
                       /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SOCE/lef/tpz973gv_6lm_cic.lef \
                       ${DESIGN_REF_RAM1}/ra2sh128x32m4h3v2.lef \
                       ${DESIGN_REF_RAM2}/ra1shd80x64m4h3v2.lef \
                       ${DESIGN_REF_RAM3}/ra1shd128x8m16h3v2.lef"
## db
set LINK_LIBRARY_FILE "/cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/db/typical.db \
                       /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/db/slow.db \
                       /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/db/fast.db \
                       /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/db/tpz973gvtc.db \
                       /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/db/tpz973gvwc.db \
                       /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/db/tpz973gvbc.db \
                       ${DESIGN_REF_RAM1}/ra2sh128x32m4h3v2_typical_syn.db \
                       ${DESIGN_REF_RAM2}/ra1shd80x64m4h3v2_typical_syn.db \
                       ${DESIGN_REF_RAM3}/ra1shd128x8m16h3v2_typical_syn.db" 

set LINK_LIBRARY_FILE "[glob /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SynopsysDC/db/*]"

set VERILOG_NETLIST   "../../../input/${DESIGN_NAME}.v"

########################################
# Create the design library
########################################
set_app_var link_library "$LINK_LIBRARY_FILE"

create_lib $DESIGN_LIBRARY \
           -technology $TECH_FILE \
           -ref_libs   $PHYSICAL_LIBRARY

read_parasitic_tech -name "max_min_tlu" -tlup  /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/ICC/tluplus/t18.tluplus

current_lib
report_ref_libs

########################################
# Read the design
########################################
read_verilog -top ${DESIGN_NAME} ${VERILOG_NETLIST}

########################################
# Initialize the floorplan
########################################
get_site_defs -filter is_default
get_attribute [get_site_arrays] site_name

set_ignored_layers -min_routing_layer METAL1 -max_routing_layer METAL5
set_attribute -name routing_direction -value horizontal [get_layers {METAL1 METAL3 METAL5}]
set_attribute -name routing_direction -value vertical   [get_layers {METAL2 METAL4}]
set_attribute -name track_offset -value 0.28 [get_layers METAL1]
set_attribute -name track_offset -value 0.31 [get_layers METAL2]
set_attribute -name track_offset -value 0.31 [get_layers METAL3]
set_attribute -name track_offset -value 0.31 [get_layers METAL4]
set_attribute -name track_offset -value 0.28 [get_layers METAL5]

## Set spacing rules
## Fine-tune the height for better result
set_app_options \
        -name plan.macro.spacing_rule_heights \
        -value {37um 37um}

set_app_options \
        -name plan.macro.spacing_rule_widths \
        -value {25um 25um}

## 25um^2
initialize_floorplan -control_type die -side_length {5000 5000} -core_offset {200 200}

########################################
# Create power domain
########################################
create_net VDD
create_net VSS
create_net VDDIO
create_net VSSIO

create_supply_net VDD
create_supply_net VSS

create_power_domain PD_TOP -elements {.}
set_domain_supply_net PD_TOP -primary_power_net VDD -primary_ground_net VSS

########################################
# IO & Power PAD planning
########################################
create_io_ring -name ring1
remove_signal_io_constraints

## powerpad for CORNER
create_cell {cornerLL cornerLR cornerUL cornerUR} PCORNER
## powerpad for Core
create_cell {core_vdd1 core_vdd2} PVDD1DGZ
create_cell {core_vss1 core_vss2} PVSS1DGZ
## powerpad for IO
create_cell {io_vdd1 io_vdd2} PVDD2DGZ
create_cell {io_vss1 io_vss2} PVSS2DGZ

## Manualy place the IO pads
source ../scripts/CHIP_IO.tcl
place_io

## Set the placed IO status to "fixed"
set_attribute -name physical_status -value fixed [get_cells -filter "design_type==pad"]
set_attribute -name physical_status -value fixed [get_flat_cells -filter "design_type==pad"]

## Place macro and std_cells simultaneously
create_placement -floorplan -effort high

## Set the placed macro status to "fixed"
set_attribute -name physical_status -value fixed [get_cells -filter "is_hard_macro==true"]
set_attribute -name physical_status -value fixed [get_flat_cells -filter "is_hard_macro==true"]

## Create placement blockage for SRAM to avoid placing std_cells on its power nets around
foreach cell [get_object_name [get_flat_cells -filter "is_hard_macro==true"]] {
        set bbox [get_attribute -name bbox [get_flat_cells $cell]];
        create_placement_blockage -boundary $bbox -type hard
}

## Create routing blockage around SRAM before power planning to avoid being affected by PG nets
## Notice that standard cells in those regions still need the M1 pg mesh for power supplying, 
## so we keep the M1 mesh (didn't create routing blockage on M1)
foreach cell [get_object_name [get_flat_cells -filter "is_hard_macro==true"]] {
        set bbox_llx [get_attribute -name bbox_llx [get_cells $cell]];
        set bbox_lly [get_attribute -name bbox_lly [get_cells $cell]];
        set bbox_urx [get_attribute -name bbox_urx [get_cells $cell]];
        set bbox_ury [get_attribute -name bbox_ury [get_cells $cell]];
        set P_Bkg_bbox "\{$bbox_llx $bbox_lly \} \{ $bbox_urx $bbox_ury\}"
        set ori_dir [get_attribute -name orientation [get_cells $cell]]
        if {$ori_dir == "MX"} {
                set P_Bkg_bbox "\{$bbox_llx [expr $bbox_ury - 50] \} \{$bbox_urx [expr $bbox_ury + 30]\}"
        } elseif {$ori_dir == "R0" || $ori_dir == "MY"} {
                set P_Bkg_bbox "\{$bbox_llx [expr $bbox_lly - 30] \} \{$bbox_urx [expr $bbox_lly + 50]\}"
        }
        create_routing_blockage -name sram_DRC -layers {METAL2} -boundary $P_Bkg_bbox
        create_routing_blockage -name sram_DRC -layers {METAL3} -boundary $P_Bkg_bbox
        create_routing_blockage -name sram_DRC -layers {METAL4} -boundary $P_Bkg_bbox
        create_routing_blockage -name sram_DRC -layers {METAL5} -boundary $P_Bkg_bbox
}

# Insert IO filler cells
save_block -as 01_initial_floorplan

########################################
# Power planning
########################################
set_attribute -objects [get_net VDD]   -name net_type -value power
set_attribute -objects [get_net VSS]   -name net_type -value ground
set_attribute -objects [get_net VDDIO] -name net_type -value power
set_attribute -objects [get_net VSSIO] -name net_type -value ground

connect_pg_net -net VDD [get_pins -physical_context */VDD]
connect_pg_net -net VSS [get_pins -physical_context */VSS]

connect_supply_net -ports [get_pins core_vdd1/VDD] VDD
connect_supply_net -ports [get_pins core_vdd2/VDD] VDD
connect_supply_net -ports [get_pins core_vss1/VSS] VSS
connect_supply_net -ports [get_pins core_vss1/VSS] VSS

remove_pg_via_master_rules -all
remove_pg_patterns -all
remove_pg_strategies -all
remove_pg_strategy_via_rules -all

## RING for core power pad (METAL4 METAL5)
create_pg_region rg_core -core

create_pg_ring_pattern ring_M4M5 \
        -vertical_layer METAL4 \
        -horizontal_layer METAL5 \
        -vertical_width 2.0 \
        -horizontal_width 2.0 \
        -vertical_spacing 2.0 \
        -horizontal_spacing 2.0

set_pg_strategy ring_M4M5 \
        -pg_region {rg_core} \
        -pattern { \
                {name: ring_M4M5} \
                {nets: {VDD VSS VDD VSS}} \
                {offset: {20 20}} \
                }

compile_pg -strategies ring_M4M5

## IO PG to RING (METAL1 METAL2)
set_app_options -name plan.pgroute.treat_pad_as_macro -value true

create_pg_macro_conn_pattern conn_iopg_M1M2 \
        -pin_conn_type scattered_pin \
        -nets {VDD VSS} \
        -layer {METAL1 METAL2} \
        -pin_layers {METAL1 METAL2} \
        -width {6 6}

set_pg_strategy s_iopg_M1M2 \
        -macros {core_vss1 core_vss2 core_vdd1 core_vdd2} \ \
        -pattern { \
                {name: conn_iopg_M1M2} \
                {nets: {VDD VSS}} \
                } \
        -extension {stop: outermost_ring}

## IO Pad pin will have DRC
compile_pg -strategies s_iopg_M1M2 -ignore_drc

## Remove VIA with DRC
foreach bbox [get_attribute -name bbox [get_cells {core_vss1 core_vss2 core_vdd1 core_vdd2}]] {
        set vias [get_vias -touching $bbox]
        if {$vias != ""} {
                puts [get_object_name $vias]
                remove_objects $vias
        }
}

## Create core PG and extend to RING {METAL4 METAL5}
create_pg_mesh_pattern mesh2ring_M4M5 \
        -layer { \
                  {{vertical_layer:   METAL4} {width: 0.28} {spacing: 1} {pitch: 7.28} {track_alignment: track}} \
                  {{horizontal_layer: METAL5} {width: 0.28} {spacing: 1} {pitch: 7.88} {track_alignment: track}} \
                } \
        -via_rule {{layers: METAL4} {layers: METAL5}}

set_pg_strategy s_mesh2ring_M4M5 -core \
        -pattern { \
                {name: mesh2ring_M4M5} \
                {nets: {VDD VSS}} \
                } \
        -extension { \
                {nets: {VDD VSS}} \
                {stop: outermost_ring} \
                }

set_pg_strategy_via_rule r_via_ring_M4M5 \
        -via_rule { \
                  { {{existing: ring} {layers: {METAL4 METAL5}}} \
                    {via_master: default} \
                  } \
                  { {{existing: strap} {layers: {METAL4 METAL5}}} \
                    {via_master: default} \
                  } \
                }

compile_pg -strategies s_mesh2ring_M4M5 -via_rule r_via_ring_M4M5

## Core PG (METAL2 METAL3)
create_pg_mesh_pattern pg_mesh \
        -layer { \
                  {{vertical_layer:   METAL2} {width: 0.28} {spacing: interleaving} {pitch: 95} {trim: true} {track_alignment: track}} \
                  {{horizontal_layer: METAL3} {width: 0.28} {spacing: interleaving} {pitch: 10} {trim: true} {track_alignment: track}} \                
                } \
        -via_rule {{intersection: adjacent} {via_master: default}}

set_pg_strategy s_mesh_core -core \
        -pattern { \
                {name: pg_mesh} \
                {nets: {VDD VSS}} \
                } \
        -extension { \
                {nets: {VDD VSS}} \
                {stop: core_boundary} \
                }

compile_pg -strategies s_mesh_core

## Create PG for std_cell and connect to core mesh
create_pg_std_cell_conn_pattern conn_std_pg -layers {METAL1}
set_pg_strategy std -core -pattern {{name: conn_std_pg} {nets {VDD VSS}}}

set_pg_strategy std_pwr -core -pattern {{name: conn_std_pg} {nets: VDD} {parameters: {0.76 0.76}}}
set_pg_strategy std_gnd -core -pattern {{name: conn_std_pg} {nets: VSS} {parameters: {0.76 0.76}}}

compile_pg -strategies std_pwr
compile_pg -strategies std_gnd

## Remove routing blockages {METAL2 to METAL5} adter creating PG nets
remove_routing_blockages [get_routing_blockages *sram_DRC*]

save_block -as 02_powerplan

########################################
# Before placement,
# add routing blockage on Metal5 to
# avoid nets being routed on IO Pad
########################################
source ../scripts/addRouteBlk.cmd

########################################
# MCMM & Macro placement
########################################
remove_scenarios -all
remove_modes -all
remove_corners -all

create_corner BCCOM
create_corner WCCOM
create_corner TCCOM

## RC max & min
read_parasitic_tech \
        -tlup /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/ICC/tluplus/t18.tluplus \
        -layermap /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/ICC/tluplus/t18.map \
        -name tlup_all

set_parasitics_parameters \
        -early_spec tlup_all \
        -late_spec tlup_all \
        -corners {BCCOM}

set_parasitics_parameters \
        -early_spec tlup_all \
        -late_spec tlup_all \
        -corners {WCCOM}

set_parasitics_parameters \
        -early_spec tlup_all \
        -late_spec tlup_all \
        -corners {TCCOM}

create_mode func
current_mode func

set_voltage 1.980 -min 1.980 -corner BCCOM -object_list VDD
set_voltage 1.620 -min 1.620 -corner WCCOM -object_list VDD
set_voltage 1.800 -min 1.800 -corner TCCOM -object_list VDD
set_voltage 0 -min 0 -corner BCCOM -object_list VSS
set_voltage 0 -min 0 -corner WCCOM -object_list VSS
set_voltage 0 -min 0 -corner TCCOM -object_list VSS

set_temperature -40.000 -min -40.000 -corners BCCOM
set_temperature 125.000 -min 125.000 -corners WCCOM
set_temperature  25.000 -min  25.000 -corners TCCOM

create_scenario -mode func -corner BCCOM -name func_BCCOM
create_scenario -mode func -corner WCCOM -name func_WCCOM
create_scenario -mode func -corner TCCOM -name func_TCCOM

## Setting corner constraints
current_scenario func_BCCOM
read_sdc ./../../../common/caravel_top.sdc
current_scenario func_WCCOM
read_sdc ./../../../common/caravel_top.sdc
current_scenario func_TCCOM
read_sdc ./../../../common/caravel_top.sdc

########################################
# Placement Optimization
########################################

set_app_options \
        -name place_opt.place.congestion_effort \
        -value high

set_app_options \
        -name place.legalize.enable_advanced_prerouted_net_check \
        -value true

report_ignored_layers
set_qor_strategy -stage pnr
set_stage -step placement

set_lib_cell_purpose -include all [get_lib_cells]

place_opt

report_global_timing
connect_pg_net
save_block -as 03_place_opt

########################################
# Clock Tree Synthesis Optimization
########################################

## Clock tree cell selection
set CTS_CELLS [get_lib_cells "*/CLKBUF* */BUF* */INV* */*DFF*"]
suppress_message ATTR-12
set_dont_touch $CTS_CELLS false
set_lib_cell_purpose -exclude cts [get_lib_cells]
set_lib_cell_purpose -include cts $CTS_CELLS
unsuppress_message ATTR-12

set_lib_cell_purpose -exclude hold [get_lib_cells]
set_lib_cell_purpose -include hold [get_lib_cells "*/*BUFF* */*INV*"]

set_stage -step cts
clock_opt -to route_clock

report_global_timing
connect_pg_net

save_block -as 04_clock_opt_cts

## Optimize clock tree
set_stage -step post_cts_opto
clock_opt -from final_opto

report_global_timing
connect_pg_net

save_block -as 05_clock_opt_opto

########################################
# Initial routing
########################################
set_stage -step route
route_auto

report_global_timing
connect_pg_net
save_block -as 06_route_auto

########################################
# Fix DRC violations
########################################

## This option can significantly increase runtime
## if a design has many shorts over macros that
## are difficult to repair
set_app_options \
        -name route.detail.repair_shorts_over_macros_effort_level \
        -value high

set_app_options \
        -name route.detail.optimize_partition_size_for_drc \
        -value true

route_detail -incremental true

save_block -as 07_route_fix_drc

########################################
# Route Optimization
########################################
set_stage -step post_route
route_opt

report_global_timing
connect_pg_net

save_block -as 08_route_opt

########################################
# Write out netlist & gds
########################################
write_verilog ../../../results/caravel_top_routed.v

write_gds -design 08_route_opt \
          -layer_map /cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/SOCE/streamOut.map \
          -keep_data_type \
          -output_pin all \
          -merge_files {/cad/CBDK/CBDK_TSMC018_Arm_v4.0/CIC/Phantom/tsmc18_core.gds} \
          -long_names \
          ./
