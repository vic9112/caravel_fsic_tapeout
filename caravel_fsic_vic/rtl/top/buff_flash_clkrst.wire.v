//===========================================================
// Modified by Vic Chen
// Sep 23, 2024
//===========================================================

`default_nettype wire

module buff_flash_clkrst (
	input  [5:0] in_n,
	input  [2:0]  in_s,
	output [5:0] out_s,
	output [2:0]  out_n);

	clkbuffer BUF[8:0] (
		.A({in_n, in_s}), 
		.X({out_s, out_n})
	);   

    //assign out_s = in_n;
    //assign out_n = in_s;     

endmodule
