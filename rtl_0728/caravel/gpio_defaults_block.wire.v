//===========================================================
// Modified by Vic Chen
// July 26, 2024
//===========================================================

`default_nettype none

// This module represents an unprogrammed set of GPIO pad default
// values that is configured with via programming on the chip top
// level.  This value is passed as a set of parameters (formerly
// part of gpio_control_block.v).

/// sta-blackbox
module gpio_defaults_block #(
    // Parameterized initial startup state of the pad.  The default
    // parameters if unspecified is for the pad to be a user input
    // with no pull-up or pull-down, so that it is disconnected
    // from the outside world.  See defs.h for configuration word
    // definitions.
    parameter GPIO_CONFIG_INIT = 13'h0402
) (
    inout wire VPWR,
    inout wire VGND,
    output wire [12:0] gpio_defaults
);
    wire [12:0] gpio_defaults_high;
    wire [12:0] gpio_defaults_low;

    // For the mask revision input, use an array of digital constant logic cells

    conb_1 gpio_default_value [12:0] (
        .VPWR(VPWR),
        .VPB(VPWR),
        .VNB(VGND),
        .VGND(VGND),
        .HI(gpio_defaults_high),
        .LO(gpio_defaults_low)
    );

    genvar i;
    generate
        for (i = 0; i < 13; i = i+1) begin
    	    assign gpio_defaults[i] = (GPIO_CONFIG_INIT & (13'h0001 << i)) ?
			gpio_defaults_high[i] : gpio_defaults_low[i];
	end
    endgenerate

endmodule
`default_nettype wire
