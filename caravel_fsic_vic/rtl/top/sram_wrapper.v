// for LA
//
`ifdef USE_PDK_SRAM

    module PDK_SRAM2RW128x32 (
      input CLKA,
      input CENA,
      input WENA,
      input [6:0] AA,
      input [31:0] DA,
      input OENA,
      output [31:0] QA,
      input CLKB,
      input CENB,
      input WENB,
      input [6:0] AB,
      input [31:0] DB,
      input OENB,
      output [31:0] QB
      );

      ra2sh128x32m4h3v2 PDK_SRAM
      (
        .CLKA(CLKA),
        .CENA(CENA),
        .WENA(WENA),
        .AA(AA),
        .DA(DA),
        .OENA(QENA),
        .QA(QA),
        .CLKB(CLKB),
        .CENB(CENB),
        .WENB(WENB), //slways read
        .AB(AB),      
        .DB(DB),       //data in always 0
        .OENB(OENB),
        .QB(QB)
      );
  

    endmodule 
`endif //USE_PDK_SRAM
   
`ifdef USE_EDK_SRAM

    module EDK_SRAM2RW128x32(
      input CE1,
      input CSB1,
      input WEB1,
      input OEB1,
      input [6:0] A1,
      input [31:0] I1,
      output [31:0] O1,
      input CE2,
      input CSB2,
      input WEB2,
      input OEB2,
      input [6:0] A2,
      input [31:0] I2,
      output [31:0] O2
      );

      SRAM2RW128x32 EDK_SRAM(
        .CE1(CE1),
        .CSB1(CSB1),
        .WEB1(WEB1),
        .OEB1(OEB1),
        .A1(A1),
        .I1(I1),
        .O1(O1),
        .CE2(CE2),
        .CSB2(CSB2),
        .WEB2(WEB2), 
        .OEB2(OEB2),
        .A2(A2),      
        .I2(I2),
        .O2(O2)
        );

    endmodule        

`endif //USE_EDK_SRAM

//for Edge detect
//
`ifdef USE_PDK_SRAM
  module PDK_SRAM1RW80x64(
    input [6:0] A,
    input [63:0] D,
    input CEN,
    input WEN,
    input OEN,
    input CLK,
    output [63:0] Q
    );

    ra1shd80x64m4h3v2 PDK_SRAM(
      .A   (A), 
      .D   (D), 
      .CEN (CEN), 
      .WEN (WEN), 
      .OEN (OEN), 
      .CLK (CLK),
      .Q   (Q)
    );

  endmodule
`endif //USE_PDK_SRAM

`ifdef USE_EDK_SRAM
  module EDK_SRAM1RW128x64(
    input [6:0] A,
    input [63:0] I,
    input CSB,
    input WEB,
    input OEB,
    input CE,
    output [63:0] O
    );

  `ifdef USE_SAED14
  //for SAED14
    SRAM1RW128x32 SRAM_0(
      .A   (A), 
      .I   (I[31:0]), 
      .CSB (CSB), 
      .WEB (WEB), 
      .OEB (OEB), 
      .CE  (CE), 
      .O   (O[31:0])
      );

    SRAM1RW128x32 SRAM_1(
      .A   (A), 
      .I   (I[63:32]), 
      .CSB (CSB), 
      .WEB (WEB), 
      .OEB (OEB), 
      .CE  (CE), 
      .O   (O[63:32])
      );

  `else //USE_SAED14

  //for SAED32
    SRAM1RW256x32 SRAM_0(
      .A   ({1'b0,A}), 
      .I   (I[31:0]), 
      .CSB (CSB), 
      .WEB (WEB), 
      .OEB (OEB), 
      .CE  (CE), 
      .O   (O[31:0])
      );

    SRAM1RW256x32 SRAM_1(
      .A   ({1'b0,A}), 
      .I   (I[63:32]), 
      .CSB (CSB), 
      .WEB (WEB), 
      .OEB (OEB), 
      .CE  (CE), 
      .O   (O[63:32])
      );
  `endif //USE_SAED14

  endmodule
`endif //USE_EDK_SRAM
