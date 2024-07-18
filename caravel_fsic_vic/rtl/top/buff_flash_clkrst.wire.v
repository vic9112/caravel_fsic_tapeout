`default_nettype wire

module buff_flash_clkrst (
	`ifdef USE_POWER_PINS
		inout wire VPWR,
		inout wire VGND,
	`endif
	input  [11:0] in_n,
	input  [2:0]  in_s,
	output [11:0] out_s,
	output [2:0]  out_n);

	clkrst_buff BUF[14:0] (
		`ifdef USE_POWER_PINS
			.VGND(VGND),
			.VNB(VGND),
			.VPB(VPWR),
			.VPWR(VPWR),
		`endif
		.A({in_n, in_s}), 
		.X({out_s, out_n})
	);   

    //assign out_s = in_n;
    //assign out_n = in_s;     

endmodule

// Vic: place the buffer
module clkrst_buff(
    `ifdef USE_POWER_PINS
    	input VGND,
    	input VNB,
    	input VPB,
    	input VPWR,
    `endif //USE_POWER_PINS
    input A,
    output X
    );

`ifdef USE_EDK32
    NBUFFX8_RVT my_CLKSPLT_8(
        .A(A),
        .Y(X)
    );
`endif //USE_EDK32

`ifdef USE_PDK18
    wire no_connect;
    CLKBUFX8 my_CLKSPLT_8(
         .A(A),
         .Y(X)
    );
`endif //USE_PDK18

endmodule    