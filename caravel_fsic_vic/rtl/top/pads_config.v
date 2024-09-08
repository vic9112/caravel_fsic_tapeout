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
