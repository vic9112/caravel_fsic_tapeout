//===========================================================
// Modified by Vic Chen
// August 10, 2024
//===========================================================
`default_nettype wire

// Input Pad for MPRJ
`define INPAD_MPRJ(n)                                             \
    module iopad_mprj``n (                                        \
        inout PAD,                                                \
        input [2:0] DM,                                           \
        input  OUT,                                               \
        output IN                                                 \
        );                                                        \
        PDDDGZ iopad_MPRJ``n(                                     \
          .C(IN),                                                 \
          .PAD(PAD)                                               \
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
        PDUW04DGZ iopad_MPRJ``n(                                  \
          .I(OUT),                                                \
          .C(IN),                                                 \
          .OEN(~oe),                                              \
          .PAD(PAD),                                              \
          .REN(~PAD_pullup)                                       \
          );                                                      \
    endmodule

`IOPAD_MPRJ(0);    // JTAG
`OUTPAD_MPRJ(1);   // SDO
`INPAD_MPRJ(2);    // SDI
`INPAD_MPRJ(3);    // CSB
`INPAD_MPRJ(4);    // SCK
`INPAD_MPRJ(5);    // ser_rx
`OUTPAD_MPRJ(6);   // set_tx
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

`OUTPAD_MPRJ(22);  // TXD[0]
`OUTPAD_MPRJ(23);  // TXD[1]
`OUTPAD_MPRJ(24);  // TXD[2]
`OUTPAD_MPRJ(25);  // TXD[3]
`OUTPAD_MPRJ(26);  // TXD[4]
`OUTPAD_MPRJ(27);  // TXD[5]
`OUTPAD_MPRJ(28);  // TXD[6]
`OUTPAD_MPRJ(29);  // TXD[7]
`OUTPAD_MPRJ(30);  // TXD[8]
`OUTPAD_MPRJ(31);  // TXD[9]
`OUTPAD_MPRJ(32);  // TXD[10]
`OUTPAD_MPRJ(33);  // TXD[11]
`OUTPAD_MPRJ(34);  // TXD[12]
`OUTPAD_MPRJ(35);  // TXCLK

`INPAD_MPRJ(36);   // IOCLK
`IOPAD_MPRJ(37);


module iopad_clk (
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
    PDDDGZ iopad_CLK(
      .C(IN),
      .PAD(PAD)
      );
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
    PDUW04DGZ iopad_GPIO(
      .I(OUT),
      .C(IN),
      .OEN(~oe),
      .PAD(PAD),
      .REN(~PAD_pullup)
      );
endmodule

module iopad_flash_io0 (
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
    /*
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
    PDUW04DGZ iopad_FIO0(
      .I(OUT),
      .C(IN),
      .OEN(~oe),
      .PAD(PAD),
      .REN(~PAD_pullup)
      );
    */
    PDO04CDG iopad_FIO0(
        .I(OUT),
        .PAD(PAD)
    );
endmodule

module iopad_flash_io1 (
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
    /*
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
    PDUW04DGZ iopad_FIO1(
      .I(OUT),
      .C(IN),
      .OEN(~oe),
      .PAD(PAD),
      .REN(~PAD_pullup)
      );
    */
    PDDDGZ iopad_FIO1(
        .C(IN),
        .PAD(PAD)
    );
endmodule

module iopad_flash_csb (
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
    PDO04CDG iopad_FCSB(
      .I(OUT),
      .PAD(PAD)
      );
endmodule

module iopad_flash_clk (
    inout PAD, 
    input [2:0] DM,  
    input  OUT,
    output IN
    );
    PDO04CDG iopad_FCLK(
      .I(OUT),
      .PAD(PAD)
      );
endmodule

module rstpad (
    output rst_pad,
    input  PAD
    );
    PDDSDGZ iopad_RST(    
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






