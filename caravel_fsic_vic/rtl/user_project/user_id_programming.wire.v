//===========================================================
// Modified by Vic Chen
// July 26, 2024
//===========================================================

`default_nettype none
// This module represents an unprogrammed mask revision
// block that is configured with via programming on the
// chip top level.  This value is passed to the block as
// a parameter

/// sta-blackbox
module user_id_programming #(
    parameter USER_PROJECT_ID = 32'h0
) (
    inout wire VPWR,
    inout wire VGND,
    output wire [31:0] mask_rev
);
    wire [31:0] user_proj_id_high;
    wire [31:0] user_proj_id_low;

    // For the mask revision input, use an array of digital constant logic cells

    conb_1 mask_rev_value [31:0] (
        .HI(user_proj_id_high),
        .LO(user_proj_id_low)
    );

    genvar i;
    generate
	for (i = 0; i < 32; i = i+1) begin
	    assign mask_rev[i] = (USER_PROJECT_ID & (32'h01 << i)) ?
			user_proj_id_high[i] : user_proj_id_low[i];
	end
    endgenerate

endmodule
`default_nettype wire
