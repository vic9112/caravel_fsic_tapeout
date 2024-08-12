//`include "fsic_defines.v"
//`define USE_EDK32 1

module sky130_fd_sc_hd__clkbuf_8(
    input VGND,
    input VNB,
    input VPB,
    input VPWR,
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


module sky130_fd_sc_hd__buf_8(
    input VGND,
    input VNB,
    input VPB,
    input VPWR,
    input A,
    output X
    );


`ifdef USE_EDK32
    NBUFFX8_RVT my_BUF_8(
        .A(A),
        .Y(X)
    );
`endif //USE_EDK32

`ifdef USE_PDK18
    BUFX8 my_BUF_8(
         .A(A),
         .Y(X)
    );
`endif //USE_PDK18

endmodule    

module sky130_fd_sc_hd__nand2_4(
    input VGND,
    input VNB,
    input VPB,
    input VPWR,
    input A,
    input B,
    output Y
    );


`ifdef USE_EDK32
    NAND2X4_RVT my_ND2_4(
        .A1(A),
        .A2(B),
        .Y(Y)
    );
`endif //USE_EDK32

`ifdef USE_PDK18
    NAND2X4 my_ND2_4(
         .A(A),
         .B(B),
         .Y(Y)
    );
`endif //USE_PDK18

endmodule    

module sky130_fd_sc_hd__conb_1(
    input VGND,
    input VNB,
    input VPB,
    input VPWR,
    output LO,
    output HI
    );

    assign LO = 0;
    assign HI = 1;

endmodule    

module sky130_fd_sc_hd__buf_16(
    input VGND,
    input VNB,
    input VPB,
    input VPWR,
    input A,
    output X
    );


`ifdef USE_EDK32
    NBUFFX16_RVT my_BUF_16(
        .A(A),
        .Y(X)
    );
`endif //USE_EDK32

`ifdef USE_PDK18
    BUFX16 my_BUF_16(
         .A(A),
         .Y(X)
    );
`endif //USE_PDK18

endmodule    
