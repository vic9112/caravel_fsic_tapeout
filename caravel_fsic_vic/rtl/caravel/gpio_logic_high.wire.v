//===========================================================
// Modified by Vic Chen
// July 26, 2024
//===========================================================


module gpio_logic_high(
    inout wire vccd,
    inout wire vssd,
     output wire gpio_logic1
);

    conb_1 gpio_logic_high (
        .VPWR(vccd),
        .VGND(vssd),
        .VPB(vccd),
        .VNB(vssd),
        .HI(gpio_logic1),
        .LO()
    );

endmodule
