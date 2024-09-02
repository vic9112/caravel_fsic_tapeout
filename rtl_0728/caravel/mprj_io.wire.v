//===========================================================
// Modified by Vic Chen
// July 26, 2024
//===========================================================

// `default_nettype none

/* Define the array of GPIO pads.  Note that the analog project support
 * version of caravel (caravan) defines fewer GPIO and replaces them
 * with analog in the chip_io_alt module.  Because the pad signalling
 * remains the same, `MPRJ_IO_PADS does not change, so a local parameter
 * is made that can be made smaller than `MPRJ_IO_PADS to accommodate
 * the analog pads.
 */

`define inst_pad(n)            \
    iopad_mprj``n pad``n (     \
	`ifndef	TOP_ROUTING        \
	    .PAD(io[n]),           \
	`endif                     \
		.VDDIO(vddio),         \
		.VSSIO(vssio),         \
		.VCCD (vccd),          \
		.VSSD (vssd),          \
	    .OUT  (io_out[n]),     \
	    .DM   (dm[n*3+2:n*3]), \
	    .IN   (io_in[n]) );

module mprj_io #(
    parameter AREA1PADS = `MPRJ_IO_PADS_1,
    parameter TOTAL_PADS = `MPRJ_IO_PADS
    ) (
    inout wire vddio,
    inout wire vssio,
    inout wire vccd,
    inout wire vssd,
    
    input wire porb_h,
    input wire [TOTAL_PADS-1:0] vccd_conb,
    inout wire [TOTAL_PADS-1:0] io,
    input wire [TOTAL_PADS-1:0] io_out,
    input wire [TOTAL_PADS-1:0] oeb,
    input wire [TOTAL_PADS-1:0] enh,
    input wire [TOTAL_PADS-1:0] inp_dis,
    input wire [TOTAL_PADS-1:0] ib_mode_sel,
    input wire [TOTAL_PADS-1:0] vtrip_sel,
    input wire [TOTAL_PADS-1:0] slow_sel,
    input wire [TOTAL_PADS-1:0] holdover,
    input wire [TOTAL_PADS-1:0] analog_en,
    input wire [TOTAL_PADS-1:0] analog_sel,
    input wire [TOTAL_PADS-1:0] analog_pol,
    input wire [TOTAL_PADS*3-1:0] dm,
    output wire [TOTAL_PADS-1:0] io_in
    );

    `inst_pad(0);
    `inst_pad(1);
    `inst_pad(2);
    `inst_pad(3);
    `inst_pad(4);
    `inst_pad(5);
    `inst_pad(6);
    `inst_pad(7);
    `inst_pad(8);
    `inst_pad(9);
    `inst_pad(10);
    `inst_pad(11);
    `inst_pad(12);
    `inst_pad(13);
    `inst_pad(14);
    `inst_pad(15);
    `inst_pad(16);
    `inst_pad(17);
    `inst_pad(18);
    `inst_pad(19);
    `inst_pad(20);
    `inst_pad(21);
    `inst_pad(22);
    `inst_pad(23);
    `inst_pad(24);
    `inst_pad(25);
    `inst_pad(26);
    `inst_pad(27);
    `inst_pad(28);
    `inst_pad(29);
    `inst_pad(30);
    `inst_pad(31);
    `inst_pad(32);
    `inst_pad(33);
    `inst_pad(34);
    `inst_pad(35);
    `inst_pad(36);
    `inst_pad(37);

/*
    padframe area1_io_pad [AREA1PADS - 1:0] (
	`ifndef	TOP_ROUTING
	    .PAD(io[AREA1PADS - 1:0]),
	`endif
		.VDDIO(vddio), 
		.VSSIO(vssio), 
		.VCCD(vccd), 
		.VSSD(vssd), 
	    .OUT(io_out[AREA1PADS - 1:0]),
	    .DM(dm[AREA1PADS*3 - 1:0]),
	    .IN(io_in[AREA1PADS - 1:0])
    );

    padframe area2_io_pad [TOTAL_PADS - AREA1PADS - 1:0] (
	`ifndef	TOP_ROUTING
	    .PAD(io[TOTAL_PADS - 1:AREA1PADS]),
	`endif
		.VDDIO(vddio), 
		.VSSIO(vssio), 
		.VCCD(vccd), 
		.VSSD(vssd), 
	    .OUT(io_out[TOTAL_PADS - 1:AREA1PADS]),
	    .DM(dm[TOTAL_PADS*3 - 1:AREA1PADS*3]),
	    .IN(io_in[TOTAL_PADS - 1:AREA1PADS])
    );
*/

endmodule
// `default_nettype wire
