//===========================================================
// Modified by Vic Chen
// July 26, 2024
//===========================================================

`define INPUT_PAD(vddio,vssio,vccd,vssd,X,Y,CONB_ONE,CONB_ZERO) \
	padframe X``_pad ( \
	`ifndef	TOP_ROUTING \
		.PAD(X), \
	`endif	\
		.VDDIO(vddio), \
		.VSSIO(vssio), \
		.VCCD(vccd), \
		.VSSD(vssd), \
		.OUT(CONB_ZERO), \
		.DM({CONB_ZERO, CONB_ZERO, CONB_ONE}), \
		.IN(Y))

`define OUTPUT_NO_INP_DIS_PAD(vddio,vssio,vccd,vssd,X,Y,CONB_ONE,CONB_ZERO) \
	padframe X``_pad ( \
	`ifndef	TOP_ROUTING \
		.PAD(X), \
	`endif \
		.VDDIO(vddio), \
		.VSSIO(vssio), \
		.VCCD(vccd), \
		.VSSD(vssd), \
		.OUT(Y), \
		.DM({CONB_ONE, CONB_ONE, CONB_ZERO}), \
		.IN()) 

`define INOUT_PAD(vddio,vssio,vccd,vssd,X,Y,Y_OUT,MODE) \
	padframe X``_pad ( \
	`ifndef	TOP_ROUTING \
		.PAD(X), \
	`endif	\
		.VDDIO(vddio), \
		.VSSIO(vssio), \
		.VCCD(vccd), \
		.VSSD(vssd), \
		.OUT(Y_OUT),	\
		.DM(MODE), \
		.IN(Y) )

// `default_nettype wire
