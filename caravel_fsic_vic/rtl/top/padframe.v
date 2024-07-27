//===========================================================
// Modified by Vic Chen
// July 26, 2024
//===========================================================
`default_nettype wire

module padframe (
    inout VDDIO, 
    inout VSSIO, 
    inout VCCD, 
    inout VSSD, 
    inout PAD, 
    input [2:0] DM,  

    input  OUT,
    output IN
    );

//only support below mode for DM[2:0]
// 3'b001 input (output disable), no pullup or pulldown
// 3'b010 input (output disable), with pullup
// 3'b011 input (output disable), with pulldown
// 3'b110 output enable
// others, set to default mode = 3'b001

  reg oe;
  reg PAD_pullup;
  reg PAD_pulldown;

  always @(*) begin
    case( DM[2:0] )
      3'b001: begin
          oe = 0;
          PAD_pullup = 0;
          PAD_pulldown = 0;
        end
      3'b010: begin
          oe = 0;
          PAD_pullup = 1;
          PAD_pulldown = 0;
        end
      3'b011: begin
          oe = 0;
          PAD_pullup = 0;
          PAD_pulldown = 1;
        end
      3'b110: begin
          oe = 1;
          PAD_pullup = 0;
          PAD_pulldown = 0;
        end
      default: begin
          oe = 0;
          PAD_pullup = 0;
          PAD_pulldown = 0;
        end
    endcase
 end   

`ifdef USE_EDK_IO
  B16I1025_EW gpiov2_pad(
	.VDDIO(VDDIO), 
	.VSSIO(VSSIO), 
	.VDD(VCCD), 
	.VSS(VSSD), 
    .DIN(OUT),
    .DOUT(IN),
    .EN(oe),
    .PADIO(PAD),
    .PULL_DOWN(PAD_pulldown),
    .PULL_UP(PAD_pullup),
    .R_EN(~oe)    
  );
`endif //USE_EDK_IO

`ifdef USE_PDK18_IO
  PDUW24DGZ gpiov2_pad(
    .I(OUT),
    .C(IN),
    .OEN(~oe),
    .PAD(PAD),
    .REN(~PAD_pullup)
    );
`endif //USE_PDK18_IO

endmodule

module rstpad (
    output rst_pad,
    input  PAD
    );

`ifdef  USE_EDK_IO
    ISH1025_EW reset_pad(
        .DOUT(rst_pad),
        .R_EN(1'b1),
        .PADIO(PAD)
    );
`endif //USE_EDK_IO

`ifdef USE_PDK18_IO
    PDDSDGZ reset_pad(    
        .C(rst_pad),
        .PAD(PAD)
    );
`endif //USE_PDK18_IO

endmodule

module clkbuffer(
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

module clkmux (
    input A,
    input B,
    input S0,
    output Y
);

    `ifdef USE_EDK32
    (* dont_touch = "true" *) MUX21X2_RVT csclk_MUX_dont_touch(
        .A1(A),
        .A2(B),
        .S0(S0),
        .Y(Y)
    );
    `endif //USE_EDK32

    `ifdef USE_PDK18
    (* dont_touch = "true" *) MX2X2 csclk_MUX_dont_touch(
        .A(A),
        .B(B),
        .S0(S0),
        .Y(Y)
    );
    `endif //USE_PDK18

endmodule

module buf_8(
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

module nand2_4(
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

module conb_1(
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

module buf_16(
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






