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

endmodule
// `default_nettype wire
