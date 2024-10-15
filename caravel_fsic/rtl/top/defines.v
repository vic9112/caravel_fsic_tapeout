//===========================================================
// Modified by Vic Chen
// Oct 15, 2024
//===========================================================

//`ifndef __GLOBAL_DEFINE_H
// Global parameters
`define __GLOBAL_DEFINE_H

`define MPRJ_IO_PADS_1 19	/* number of user GPIO pads on user1 side */
`define MPRJ_IO_PADS_2 19	/* number of user GPIO pads on user2 side */
`define MPRJ_IO_PADS (`MPRJ_IO_PADS_1 + `MPRJ_IO_PADS_2)

`define MPRJ_PWR_PADS_1 2	/* vdda1, vccd1 enable/disable control */
`define MPRJ_PWR_PADS_2 2	/* vdda2, vccd2 enable/disable control */
`define MPRJ_PWR_PADS (`MPRJ_PWR_PADS_1 + `MPRJ_PWR_PADS_2)

// Analog pads are only used by the "caravan" module and associated
// modules such as user_analog_project_wrapper and chip_io_alt.

`define ANALOG_PADS_1 5
`define ANALOG_PADS_2 6

`define ANALOG_PADS (`ANALOG_PADS_1 + `ANALOG_PADS_2)

// Number of GPIO pads defined in the caravel openframe layout
`define OPENFRAME_IO_PADS 44

// Size of soc_mem_synth

// Type and size of soc_mem
// `define USE_OPENRAM
`define USE_CUSTOM_DFFRAM
// don't change the following without double checking addr widths
`define MEM_WORDS 256

// Number of columns in the custom memory; takes one of three values:
// 1 column : 1 KB, 2 column: 2 KB, 4 column: 4KB
`define DFFRAM_WSIZE 4
`define DFFRAM_USE_LATCH 0

// not really parameterized but just to easily keep track of the number
// of ram_block across different modules
`define RAM_BLOCKS 1

// Clock divisor default value
`define CLK_DIV 3'b010

// GPIO control default mode and enable for most I/Os
// Most I/Os set to be user input pins on startup.
// NOTE:  To be modified, with GPIOs 5 to 35 being set from a build-time-
// programmable block.
`define MGMT_INIT 1'b0
`define OENB_INIT 1'b0
`define DM_INIT 3'b001

//`define TOP_ROUTING 1
`define REMOVE_LEVEL_SHIFT   1 //tony_debug
`define NO_POR_PAD 1 //tony_debug
`define REMOVE_sky130_ef_sc_hd__decap_12 1 //tony_debug
`define REMOVE_sky130_ef_io__corner_pad 1 //tony_debug
`define REMOVE_spare_logic_block 1 //tony_debug
`define REMOVE_sky130_fd_sc_hd__macro_sparecell 1 //tony_debug
`define SINGLE_POWER_DOMAIN 1 //tony_debug
`define REMOVE_PLL 1 //tony_debug
`define REMOVE_POWER_PAD //tony_debug
//`endif // __GLOBAL_DEFINE_H
