//===========================================================
// Modified by Vic Chen
// July 26, 2024
//===========================================================

`default_nettype none
/* 
 *---------------------------------------------------------------------
 * A simple module that generates buffered high and low outputs
 * in the 1.8V domain.
 *---------------------------------------------------------------------
 */

module constant_block (
    inout wire vccd,
    inout wire vssd,
    output wire one,
    output wire zero
);

    wire	one_unbuf;
    wire	zero_unbuf;

    conb_1 const_source (
        .VPWR(vccd),
        .VGND(vssd),
        .VPB(vccd),
        .VNB(vssd),
        .HI(one_unbuf),
        .LO(zero_unbuf)
    );

    /* Buffer the constant outputs (could be synthesized) */
    /* NOTE:  Constant cell HI, LO outputs are connected to power	*/
    /* rails through an approximately 120 ohm resistor, which is not	*/
    /* enough to drive inputs in the I/O cells while ensuring ESD	*/
    /* requirements, without buffering.					*/

    buf_16 const_one_buf (
        .VPWR(vccd),
        .VGND(vssd),
        .VPB(vccd),
        .VNB(vssd),
        .A(one_unbuf),
        .X(one)
    );

    buf_16 const_zero_buf (
        .VPWR(vccd),
        .VGND(vssd),
        .VPB(vccd),
        .VNB(vssd),
        .A(zero_unbuf),
        .X(zero)
    );

endmodule
`default_nettype wire
