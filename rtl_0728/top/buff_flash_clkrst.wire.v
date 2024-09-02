//===========================================================
// Modified by Vic Chen
// July 26, 2024
//===========================================================

`default_nettype wire

module buff_flash_clkrst (
	inout wire VPWR,
	inout wire VGND,
	input  [11:0] in_n,
	input  [2:0]  in_s,
	output [11:0] out_s,
	output [2:0]  out_n);

	clkbuffer BUF[14:0] (
		.VGND(VGND),
		.VNB(VGND),
		.VPB(VPWR),
		.VPWR(VPWR),
		.A({in_n, in_s}), 
		.X({out_s, out_n})
	);   

    //assign out_s = in_n;
    //assign out_n = in_s;     

endmodule