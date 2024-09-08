//===========================================================
// Author: Vic Chen
// Email: s179038@gmail.com
// Date: Sep 8, 2024
//===========================================================
`default_nettype wire

// Input Pad for MPRJ
`define INPAD_MPRJ(n)                                             \
    module iopad_mprj``n (                                        \
        inout PAD,                                                \
        input REN                                                 \
        input OEN                                                 \
        input OUT,                                                \
        output IN                                                 \
        );                                                        \
        PDDWDGZ iopad_MPRJ``n(                                    \
          .C(IN),                                                 \
          .PAD(PAD),                                              \
          .REN(REN)                                               \
          );                                                      \
    endmodule

// Output Pad for MPRJ
`define OUTPAD_MPRJ(n)                                            \
    module iopad_mprj``n (                                        \
        inout PAD,                                                \
        input [2:0] DM,                                           \
        input  OUT,                                               \
        output IN                                                 \
        );                                                        \
        PDO04CDG iopad_MPRJ``n(                                   \
          .I(OUT),                                                \
          .PAD(PAD)                                               \
          );                                                      \
    endmodule

//===================== IO Configurate ====================//
// Input:  OEN = 1, REN = 0 during reset operation
//         OEN = 1, REN = 1 during normal operation
//---------------------------------------------------------//
// Output: OEN = 1, REN = 0 during reset operation
//         OEN = 0, REN = 1 during normal operation
//=========================================================//
`define IOPAD_MPRJ(n)                                             \
    module iopad_mprj``n (                                        \
        inout PAD,                                                \
        input REN                                                 \
        input OEN                                                 \
        input OUT,                                                \
        output IN                                                 \
        );                                                        \
        PDUW04DGZ iopad_MPRJ``n(                                  \
          .I(OUT),                                                \
          .C(IN),                                                 \
          .OEN(OEN),                                              \
          .PAD(PAD),                                              \
          .REN(REN)                                               \
          );                                                      \
    endmodule

`IOPAD_MPRJ(0);    // JTAG
`IOPAD_MPRJ(1);   // SDO
`IOPAD_MPRJ(2);    // SDI
`IOPAD_MPRJ(3);    // CSB
`IOPAD_MPRJ(4);    // SCK
`IOPAD_MPRJ(5);    // ser_rx
`IOPAD_MPRJ(6);   // set_tx
`INPAD_MPRJ(7);    // irq

`INPAD_MPRJ(8);    // RXD[0]
`INPAD_MPRJ(9);    // RXD[1]
`INPAD_MPRJ(10);   // RXD[2]
`INPAD_MPRJ(11);   // RXD[3]
`INPAD_MPRJ(12);   // RXD[4]
`INPAD_MPRJ(13);   // RXD[5]
`INPAD_MPRJ(14);   // RXD[6]
`INPAD_MPRJ(15);   // RXD[7]
`INPAD_MPRJ(16);   // RXD[8]
`INPAD_MPRJ(17);   // RXD[9]
`INPAD_MPRJ(18);   // RXD[10]
`INPAD_MPRJ(19);   // RXD[11]
`INPAD_MPRJ(20);   // RXD[12]
`INPAD_MPRJ(21);   // RXCLK 

`IOPAD_MPRJ(22);  // TXD[0]
`IOPAD_MPRJ(23);  // TXD[1]
`IOPAD_MPRJ(24);  // TXD[2]
`IOPAD_MPRJ(25);  // TXD[3]
`IOPAD_MPRJ(26);  // TXD[4]
`IOPAD_MPRJ(27);  // TXD[5]
`IOPAD_MPRJ(28);  // TXD[6]
`IOPAD_MPRJ(29);  // TXD[7]
`IOPAD_MPRJ(30);  // TXD[8]
`IOPAD_MPRJ(31);  // TXD[9]
`IOPAD_MPRJ(32);  // TXD[10]
`IOPAD_MPRJ(33);  // TXD[11]
`IOPAD_MPRJ(34);  // TXD[12]
`IOPAD_MPRJ(35);  // TXCLK

`INPAD_MPRJ(36);   // IOCLK
`IOPAD_MPRJ(37);


module iopad_clk (
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
    PDDWDGZ iopad_CLK(
      .C(IN),
      .PAD(PAD),
      .REN(REN)
      );
endmodule

module iopad_gpio (
    inout PAD, 
    input REN,
    input OEN,
    input OUT,
    output IN
    );
    PDUW04DGZ iopad_GPIO(
      .I(OUT),
      .C(IN),
      .OEN(OEN),
      .PAD(PAD),
      .REN(REN)
      );
endmodule

module iopad_flash_io0 (
    inout PAD, 
    input REN,
    input OEN,
    input OUT,
    output IN
    );
    PDUW04DGZ iopad_FIO0(
      .I(OUT),
      .C(IN),
      .OEN(OEN),
      .PAD(PAD),
      .REN(REN)
      );
endmodule

module iopad_flash_io1 (
    inout PAD, 
    input REN,
    input OEN,
    input OUT,
    output IN
    );
    PDUW04DGZ iopad_FIO1(
      .I(OUT),
      .C(IN),
      .OEN(OEN),
      .PAD(PAD),
      .REN(REN)
      );
endmodule

module iopad_flash_csb (
    inout PAD, 
    input REN,
    input OEN,
    input OUT,
    output IN
    );
    PDUW04DGZ iopad_FCSB(
      .I(OUT),
      .C(IN),
      .OEN(OEN),
      .PAD(PAD),
      .REN(REN)
      );
endmodule

module iopad_flash_clk (
    inout PAD, 
    input REN,
    input OEN,
    input OUT,
    output IN
    );
    PDUW04DGZ iopad_FCLK(
      .I(OUT),
      .C(IN),
      .OEN(OEN),
      .PAD(PAD),
      .REN(REN)
      );
endmodule

module rstpad (
    output rst_pad,
    input  PAD
    );
    PDISDGZ iopad_RST(    
        .C(rst_pad),
        .PAD(PAD)
    );
endmodule

module clkbuffer(
    input A,
    output X
    );
    CLKBUFX8 my_CLKSPLT_8(
         .A(A),
         .Y(X)
    );
endmodule    

module clkmux (
    input A,
    input B,
    input S0,
    output Y
);
    (* dont_touch = "true" *) MX2X2 csclk_MUX_dont_touch(
        .A(A),
        .B(B),
        .S0(S0),
        .Y(Y)
    );
  
endmodule

module buf_8(
    input A,
    output X
    );
    BUFX8 my_BUF_8(
         .A(A),
         .Y(X)
    );
endmodule    

module nand2_4(
    input A,
    input B,
    output Y
    );
    NAND2X4 my_ND2_4(
         .A(A),
         .B(B),
         .Y(Y)
    );
endmodule    

module conb_1(
    output LO,
    output HI
    );
    assign LO = 0;
    assign HI = 1;
endmodule    

module buf_16(
    input A,
    output X
    );
    BUFX16 my_BUF_16(
         .A(A),
         .Y(X)
    );
endmodule    






