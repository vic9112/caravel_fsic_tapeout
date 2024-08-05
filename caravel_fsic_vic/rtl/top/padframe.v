//===========================================================
// Modified by Vic Chen
// July 28, 2024
//===========================================================
`default_nettype wire

//========== only support below mode for DM[2:0] ==========//
// 3'b001 input (output disable), no pullup or pulldown
// 3'b010 input (output disable), with pullup
// 3'b011 input (output disable), with pulldown
// 3'b110 output enable
// others, set to default mode = 3'b001
//=========================================================//
`define IOPAD_MPRJ(n)                                             \
    module iopad_mprj``n (                                        \
        inout VDDIO,                                              \
        inout VSSIO,                                              \
        inout VCCD,                                               \
        inout VSSD,                                               \
        inout PAD,                                                \
        input [2:0] DM,                                           \
        input  OUT,                                               \
        output IN                                                 \
        );                                                        \
        reg oe;                                                   \
        reg PAD_pullup;                                           \
        reg PAD_pulldown;                                         \
        always @(*) begin                                         \
            case( DM[2:0] )                                       \
                3'b001: begin                                     \
                    oe = 0;                                       \
                    PAD_pullup = 0;                               \
                    PAD_pulldown = 0;                             \
                end                                               \
                3'b010: begin                                     \
                    oe = 0;                                       \
                    PAD_pullup = 1;                               \
                    PAD_pulldown = 0;                             \
                end                                               \
                3'b011: begin                                     \
                    oe = 0;                                       \
                    PAD_pullup = 0;                               \
                    PAD_pulldown = 1;                             \
                end                                               \
                3'b110: begin                                     \
                    oe = 1;                                       \
                    PAD_pullup = 0;                               \
                    PAD_pulldown = 0;                             \
                end                                               \
                default: begin                                    \
                    oe = 0;                                       \
                    PAD_pullup = 0;                               \
                    PAD_pulldown = 0;                             \
                end                                               \
            endcase                                               \
        end                                                       \
        `ifdef USE_EDK_IO                                         \
          B16I1025_EW iopad_MPRJ``n(                              \
        	.VDDIO(VDDIO),                                        \
        	.VSSIO(VSSIO),                                        \
        	.VDD(VCCD),                                           \
        	.VSS(VSSD),                                           \
            .DIN(OUT),                                            \
            .DOUT(IN),                                            \
            .EN(oe),                                              \
            .PADIO(PAD),                                          \
            .PULL_DOWN(PAD_pulldown),                             \
            .PULL_UP(PAD_pullup),                                 \
            .R_EN(~oe)                                            \
          );                                                      \
        `endif                                                    \
        `ifdef USE_PDK18_IO                                       \
          PDUW24DGZ iopad_MPRJ``n(                                \
            .I(OUT),                                              \
            .C(IN),                                               \
            .OEN(~oe),                                            \
            .PAD(PAD),                                            \
            .REN(~PAD_pullup)                                     \
            );                                                    \
        `endif                                                    \
    endmodule

`IOPAD_MPRJ(0);`IOPAD_MPRJ(10);`IOPAD_MPRJ(20);`IOPAD_MPRJ(30);
`IOPAD_MPRJ(1);`IOPAD_MPRJ(11);`IOPAD_MPRJ(21);`IOPAD_MPRJ(31);
`IOPAD_MPRJ(2);`IOPAD_MPRJ(12);`IOPAD_MPRJ(22);`IOPAD_MPRJ(32);
`IOPAD_MPRJ(3);`IOPAD_MPRJ(13);`IOPAD_MPRJ(23);`IOPAD_MPRJ(33);
`IOPAD_MPRJ(4);`IOPAD_MPRJ(14);`IOPAD_MPRJ(24);`IOPAD_MPRJ(34);
`IOPAD_MPRJ(5);`IOPAD_MPRJ(15);`IOPAD_MPRJ(25);`IOPAD_MPRJ(35);
`IOPAD_MPRJ(6);`IOPAD_MPRJ(16);`IOPAD_MPRJ(26);`IOPAD_MPRJ(36);
`IOPAD_MPRJ(7);`IOPAD_MPRJ(17);`IOPAD_MPRJ(27);`IOPAD_MPRJ(37);
`IOPAD_MPRJ(8);`IOPAD_MPRJ(18);`IOPAD_MPRJ(28);
`IOPAD_MPRJ(9);`IOPAD_MPRJ(19);`IOPAD_MPRJ(29);

module iopad_clk (
    inout VDDIO, 
    inout VSSIO, 
    inout VCCD, 
    inout VSSD, 
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
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
      B16I1025_EW iopad_CLK(
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
      PDUW24DGZ iopad_CLK(
        .I(OUT),
        .C(IN),
        .OEN(~oe),
        .PAD(PAD),
        .REN(~PAD_pullup)
        );
    `endif //USE_PDK18_IO
endmodule

module iopad_gpio (
    inout VDDIO, 
    inout VSSIO, 
    inout VCCD, 
    inout VSSD, 
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
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
      B16I1025_EW iopad_GPIO(
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
      PDUW24DGZ iopad_GPIO(
        .I(OUT),
        .C(IN),
        .OEN(~oe),
        .PAD(PAD),
        .REN(~PAD_pullup)
        );
    `endif //USE_PDK18_IO
endmodule

module iopad_flash_io0 (
    inout VDDIO, 
    inout VSSIO, 
    inout VCCD, 
    inout VSSD, 
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
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
      B16I1025_EW iopad_FIO0(
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
      PDUW24DGZ iopad_FIO0(
        .I(OUT),
        .C(IN),
        .OEN(~oe),
        .PAD(PAD),
        .REN(~PAD_pullup)
        );
    `endif //USE_PDK18_IO
endmodule

module iopad_flash_io1 (
    inout VDDIO, 
    inout VSSIO, 
    inout VCCD, 
    inout VSSD, 
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
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
      B16I1025_EW iopad_FIO1(
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
      PDUW24DGZ iopad_FIO1(
        .I(OUT),
        .C(IN),
        .OEN(~oe),
        .PAD(PAD),
        .REN(~PAD_pullup)
        );
    `endif //USE_PDK18_IO
endmodule

module iopad_flash_csb (
    inout VDDIO, 
    inout VSSIO, 
    inout VCCD, 
    inout VSSD, 
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
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
      B16I1025_EW iopad_FCSB(
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
      PDUW24DGZ iopad_FCSB(
        .I(OUT),
        .C(IN),
        .OEN(~oe),
        .PAD(PAD),
        .REN(~PAD_pullup)
        );
    `endif //USE_PDK18_IO
endmodule

module iopad_flash_clk (
    inout VDDIO, 
    inout VSSIO, 
    inout VCCD, 
    inout VSSD, 
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
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
      B16I1025_EW iopad_FCLK(
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
      PDUW24DGZ iopad_FCLK(
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
    ISH1025_EW iopad_RST(
        .DOUT(rst_pad),
        .R_EN(1'b1),
        .PADIO(PAD)
    );
`endif //USE_EDK_IO

`ifdef USE_PDK18_IO
    PDDSDGZ iopad_RST(    
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






