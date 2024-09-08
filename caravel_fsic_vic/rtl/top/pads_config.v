//===========================================================
// Author: Vic Chen
// Email: s179038@gmail.com
// Date: Sep 8, 2024
//===========================================================
`default_nettype wire

// IO signal
//==========================
// 0:  mprj[0] - JTAG ---- I
// 1:  mprj[1] - SDO ----- O
// 2:  mprj[2] - SDI ----- I
// 3:  mprj[3] - CSB ----- I
// 4:  mprj[4] - SCK ----- I
// 5:  mprj[5] - ser_rx -- I
// 6:  mprj[6] - ser_tx -- O
// 7:  mprj[7] - irq ----- I
//--------------------------
// 8 ~ 21:
//     mprj[20:8] - RXD -- I
//     mprj[21] - RXCLK -- I
//--------------------------
// 22 ~ 35:
//     mprj[34:22] - TXD - O
//     mprj[35] - TXCLK -- O
//--------------------------
// 36: mprj[36] - IOCLK -- I
// 37: mprj[37] - NOTUSE - I
//==========================
// 38: clock ------------- I
// 39: flash_csb --------- O
// 40: flash_clk --------- O
// 41: flash_io0 --------- O
// 42: flash_io1 --------- I
// 43: gpio -------------- I

module pads_config (
  input clk,
  input resetb, // reset, active low
  input [43:0] cnfg_io,
  input [43:0] cnfg_en,
  output [43:0] re,
  output [43:0] oe
);

  reg [43:0] r_REN;
  reg [43:0] r_OEN;

  assign oe = r_OEN;

  // Reset period, force ren=0, i.e. enable pull-up/down resistors
  generate
    genvar i;
    for (i = 0; i < 44; i = i + 1) begin : AND_RST
      assign re[i] = r_REN[i] & resetb;
    end
  endgenerate

  // Given the initial state when reset (I/O)
  always @(posedge clk or negedge resetb) begin
    if (~resetb) begin
      r_OEN[0]     <=   {{1'b1}};  // JTAG
      r_OEN[1]     <=   {{1'b0}};  // SDO
      r_OEN[5:2]   <=  {4{1'b1}};  // SDI, CSB, SCK, ser_rx
      r_OEN[6]     <=   {{1'b0}};  // ser_tx
      r_OEN[21:7]  <= {15{1'b1}};  // irq, RXD, RXCLK
      r_OEN[35:22] <= {14{1'b0}};  // TXD, TXCLK
      r_OEN[36]    <=   {{1'b1}};  // IOCLK
      r_OEN[37]    <=   {{1'b1}};  // mprj[37
      r_OEN[38]    <=   {{1'b1}};  // clock
      r_OEN[41:39] <=  {3{1'b0}};  // flash_csb, flash_clk, flash_io0
      r_OEN[43:42] <=  {2{1'b1}};  // flash_io1, gpio
    end else begin
      integer I;
      for (i = 0; i < 44; i = i + 1) begin
        if (cnfg_en[i]) r_OEN[i] <= cnfg_io[i];
      end
    end
  end

endmodule
