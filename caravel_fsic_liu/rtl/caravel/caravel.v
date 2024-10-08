//===========================================================
// Modified by Vic Chen
// Oct 5, 2024
//===========================================================

/* Copyright (C) 1991-2020 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <https://www.gnu.org/licenses/>.  */

/* This header is separate from features.h so that the compiler can
   include it implicitly at the start of every compilation.  It must
   not itself include <features.h> or any other header that includes
   <features.h> because the implicit include comes before any feature
   test macros that may be defined in a source file before it first
   explicitly includes a system header.  GCC knows the name of this
   header in order to preinclude it.  */

/* glibc's intent is to support the IEC 559 math functionality, real
   and complex.  If the GCC (4.9 and later) predefined macros
   specifying compiler intent are available, use them to determine
   whether the overall intent is to support these features; otherwise,
   presume an older compiler has intent to support these features and
   define these macros by default.  */
/* wchar_t uses Unicode 10.0.0.  Version 10.0 of the Unicode Standard is
   synchronized with ISO/IEC 10646:2017, fifth edition, plus
   the following additions from Amendment 1 to the fifth edition:
   - 56 emoji characters
   - 285 hentaigana
   - 3 additional Zanabazar Square characters */
 

// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

/*--------------------------------------------------------------*/
/* caravel, a project harness for the Google/SkyWater sky130	*/
/* fabrication process and open source PDK			*/
/*                                                          	*/
/* Copyright 2020 efabless, Inc.                            	*/
/* Written by Tim Edwards, December 2019                    	*/
/* and Mohamed Shalan, August 2020			    	*/
/* This file is open source hardware released under the     	*/
/* Apache 2.0 license.  See file LICENSE.                   	*/
/*								*/
/* Updated 10/15/2021:  Revised using the housekeeping module	*/
/* from housekeeping.v (refactoring a number of functions from	*/
/* the management SoC).						*/
/*                                                          	*/
/*--------------------------------------------------------------*/
module caravel_top (
    inout [`MPRJ_IO_PADS-1:0]  mprj_io,

    //Willy debug - e
    input clock, // CMOS core clock input, not a crystal
    input resetb, // Reset input (sense inverted)

    // Note that only two flash data pins are dedicated to the
    // management SoC wrapper.  The management SoC exports the
    // quad SPI mode status to make use of the top two mprj_io
    // pins for io2 and io3.

    output flash_csb,
    output flash_clk,
    output flash_io0,
    input  flash_io1, //Willy debug

    inout gpio // Used for external LDO control
);


    //------------------------------------------------------------
    // This value is uniquely defined for each user project.
    //------------------------------------------------------------
    parameter USER_PROJECT_ID = 32'h00000000;

    /*
     *--------------------------------------------------------------------
     *
     * These pins are overlaid on mprj_io space.  They have the function
     * below when the management processor is in reset, or in the default
     * configuration.  They are assigned to uses in the user space by the
     * configuration program running off of the SPI flash.  Note that even
     * when the user has taken control of these pins, they can be restored
     * to the original use by setting the resetb pin low.  The SPI pins and
     * UART pins can be connected directly to an FTDI chip as long as the
     * FTDI chip sets these lines to high impedence (input function) at
     * all times except when holding the chip in reset.
     *
     * JTAG       = mprj_io[0]		(inout)
     * SDO 	  = mprj_io[1]		(output)
     * SDI 	  = mprj_io[2]		(input)
     * CSB 	  = mprj_io[3]		(input)
     * SCK	  = mprj_io[4]		(input)
     * ser_rx     = mprj_io[5]		(input)
     * ser_tx     = mprj_io[6]		(output)
     * irq 	  = mprj_io[7]		(input)
     *
     * spi_sck    = mprj_io[32]		(output)
     * spi_csb    = mprj_io[33]		(output)
     * spi_sdi    = mprj_io[34]		(input)
     * spi_sdo    = mprj_io[35]		(output)
     * flash_io2  = mprj_io[36]		(inout) 
     * flash_io3  = mprj_io[37]		(inout) 
     *
     * These pins are reserved for any project that wants to incorporate
     * its own processor and flash controller.  While a user project can
     * technically use any available I/O pins for the purpose, these
     * four pins connect to a pass-through mode from the SPI slave (pins
     * 1-4 above) so that any SPI flash connected to these specific pins
     * can be accessed through the SPI slave even when the processor is in
     * reset.
     *
     * user_flash_csb = mprj_io[8]
     * user_flash_sck = mprj_io[9]
     * user_flash_io0 = mprj_io[10]
     * user_flash_io1 = mprj_io[11]
     *
     *--------------------------------------------------------------------
     */
    //Willy debug - s
    //wire [`MPRJ_IO_PADS-1:0] mprj_io;
    //Willy debug - e


    // One-bit GPIO dedicated to management SoC (outside of user control)
    wire gpio_out_core;
    wire gpio_in_core;
    wire gpio_mode0_core;
    wire gpio_mode1_core;
    wire gpio_outenb_core;
    wire gpio_inenb_core;

    // User Project Control (pad-facing)
    wire [`MPRJ_IO_PADS-1:0] mprj_io_inp_dis;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_oeb;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_ib_mode_sel;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_vtrip_sel;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_slow_sel;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_holdover;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_analog_en;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_analog_sel;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_analog_pol;
    wire [`MPRJ_IO_PADS*3-1:0] mprj_io_dm;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_in;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_out;
    wire [`MPRJ_IO_PADS-1:0] mprj_io_one;

    // User Project Control (user-facing)
    wire [`MPRJ_IO_PADS-1:0] user_io_oeb;
    wire [`MPRJ_IO_PADS-1:0] user_io_in;
    wire [`MPRJ_IO_PADS-1:0] user_io_out;
    wire [`MPRJ_IO_PADS-10:0] user_analog_io;

    /* Padframe control signals */
    wire [`MPRJ_IO_PADS_1-1:0] gpio_serial_link_1;
    wire [`MPRJ_IO_PADS_2-1:0] gpio_serial_link_2;
    wire mprj_io_loader_resetn;
    wire mprj_io_loader_clock;
    wire mprj_io_loader_strobe;
    wire mprj_io_loader_data_1; /* user1 side serial loader */
    wire mprj_io_loader_data_2; /* user2 side serial loader */

    // User Project Control management I/O
    // There are two types of GPIO connections:
    // (1) Full Bidirectional: Management connects to in, out, and oeb
    //     Uses:  JTAG and SDO
    // (2) Selectable bidirectional:  Management connects to in and out,
    //	   which are tied together.  oeb is grounded (oeb from the
    //	   configuration is used)

    // SDI 	 = mprj_io[2]		(input)
    // CSB 	 = mprj_io[3]		(input)
    // SCK	 = mprj_io[4]		(input)
    // ser_rx    = mprj_io[5]		(input)
    // ser_tx    = mprj_io[6]		(output)
    // irq 	 = mprj_io[7]		(input)

    wire [`MPRJ_IO_PADS-1:0] mgmt_io_in; /* two- and three-pin data in	*/
    wire [`MPRJ_IO_PADS-1:0] mgmt_io_out; /* two- and three-pin data out	*/
    wire [`MPRJ_IO_PADS-1:0] mgmt_io_oeb; /* output enable, used only by	*/
      /* the three-pin interfaces	*/
    wire [`MPRJ_PWR_PADS-1:0] pwr_ctrl_nc; /* no-connects */

    /* Buffers are placed between housekeeping and gpio_control_block		*/
    /* instances to mitigate timing issues on very long (> 1.5mm) wires.	*/
    wire [`MPRJ_IO_PADS-1:0] mgmt_io_in_hk; /* mgmt_io_in at housekeeping	*/
    wire [`MPRJ_IO_PADS-1:0] mgmt_io_out_hk; /* mgmt_io_out at housekeeping	*/
    wire [`MPRJ_IO_PADS-1:0] mgmt_io_oeb_hk; /* mgmt_io_oeb at housekeeping	*/

    wire clock_core;

    // Power-on-reset signal.  The reset pad generates the sense-inverted
    // reset at 3.3V.  The 1.8V signal and the inverted 1.8V signal are
    // derived.

    wire porb_h;
    wire porb_l;
    wire por_l;

    wire rstb_h;
    wire rstb_l;

    // Flash SPI communication (management SoC to housekeeping)
    wire flash_clk_core, flash_csb_core;
    wire flash_clk_oeb_core, flash_csb_oeb_core;
    wire flash_io0_oeb_core, flash_io1_oeb_core;
    wire flash_io2_oeb_core, flash_io3_oeb_core;
    wire flash_io0_ieb_core, flash_io1_ieb_core;
    wire flash_io2_ieb_core, flash_io3_ieb_core;
    wire flash_io0_do_core, flash_io1_do_core;
    wire flash_io2_do_core, flash_io3_do_core;
    wire flash_io0_di_core, flash_io1_di_core;
    wire flash_io2_di_core, flash_io3_di_core;

    // Flash SPI communication (
    wire flash_clk_frame;
    wire flash_csb_frame;
    wire flash_clk_oeb, flash_csb_oeb;
    wire flash_clk_ieb, flash_csb_ieb;
    wire flash_io0_oeb, flash_io1_oeb;
    wire flash_io0_ieb, flash_io1_ieb;
    wire flash_io0_do, flash_io1_do;
    wire flash_io0_di, flash_io1_di;

 // Flash buffered signals
    wire flash_clk_frame_buf;
    wire flash_csb_frame_buf;
    wire flash_clk_ieb_buf, flash_csb_ieb_buf;
    wire flash_io0_oeb_buf, flash_io1_oeb_buf;
    wire flash_io0_ieb_buf, flash_io1_ieb_buf;
    wire flash_io0_do_buf, flash_io1_do_buf;
    wire flash_io0_di_buf, flash_io1_di_buf;

   // Clock and reset buffered signals
   wire caravel_clk_buf;
   wire caravel_rstn_buf;
   wire clock_core_buf;

 // SoC pass through buffered signals
 wire mprj_io_loader_clock_buf;
 wire mprj_io_loader_strobe_buf;
 wire mprj_io_loader_resetn_buf;
 wire mprj_io_loader_data_2_buf;
 wire rstb_l_buf;
 wire por_l_buf;
 wire porb_h_buf;


    // SoC core
    wire caravel_clk;
    wire caravel_clk2;
    wire caravel_rstn;
    
//Willy debug - s
//assign mprj_o = mprj_io_out;
//assign mprj_en = mprj_io_oeb;
//assign mprj_io_in = mprj_i;

   //================ Start of Padframe ================//
   //================= IO Configure ====================//
   // Input:  OEN = 1, REN = 0 during reset operation
   //         OEN = 1, REN = 1 during normal operation
   //---------------------------------------------------//
   // Output: OEN = 1, REN = 1 during reset operation
   //         OEN = 0, REN = 1 during normal operation
   //===================================================//
   wire        REN;
   wire [37:0] mprj_oen;


    // Input Pad for MPRJ
    `define INPAD_MPRJ(n) \
        PDDWDGZ iopad_MPRJ``n(  \
            .C(mprj_io_in[n]),  \
            .PAD(mprj_io[n]),   \
            .REN(REN)           \
        );

    `define IOPAD_MPRJ(n)         \
        PDUW04DGZ iopad_MPRJ``n(  \
            .I(mprj_io_out[n]),   \
            .C(mprj_io_in[n]),    \
            .OEN(mprj_oen[n]),    \
            .PAD(mprj_io[n]),     \
            .REN(REN)             \
        );

    PDDWDGZ iopad_CLK(
        .PAD(clock), 
        .C(clock_core),
        .REN(REN)
    );
    PDISDGZ iopad_RST(
        .C(resetb_core),
        .PAD(resetb)
    );

    wire fcsb_oen, fclk_oen, fio0_oen, fio1_oen;
    assign fclk_oen = 1'b0 | (~resetb_core);
    assign fcsb_oen = 1'b0 | (~resetb_core);
    assign fio0_oen = 1'b0 | (~resetb_core);
    assign fio1_oen = 1'b1 | (~resetb_core);
    assign gpio_oen = 1'b1 | (~resetb_core);

    PDUW04DGZ iopad_FCSB(
        .PAD(flash_csb), 
        .I(flash_csb_frame_buf), 
        .C(), 
        .OEN(fcsb_oen), 
        .REN(REN)
    );
    PDUW04DGZ iopad_FCLK(
        .PAD(flash_clk), 
        .I(flash_clk_frame_buf), 
        .C(), 
        .OEN(fclk_oen), 
        .REN(REN)
    );
    PDUW04DGZ iopad_FIO0(
        .PAD(flash_io0), 
        .I(flash_io0_do_buf), 
    	  .C(flash_io0_di), 
        .OEN(fio0_oen), 
        .REN(REN)
    );
    PDUW04DGZ iopad_FIO1(
        .PAD(flash_io1), 
        .I(flash_io1_do_buf), 
    	  .C(flash_io1_di), 
        .OEN(fio1_oen), 
        .REN(REN)
    );
    // Management GPIO pad
    PDUW04DGZ iopad_GPIO(
        .PAD(gpio), 
        .I(gpio_out_core), 
        .C(gpio_in_core), 
        .OEN(gpio_oen), 
        .REN(REN)
    );
    // Instance 38 MPRJ Pads
    `IOPAD_MPRJ(0)   // JTAG
    `IOPAD_MPRJ(1)   // SDO
    `IOPAD_MPRJ(2)   // SDI
    `IOPAD_MPRJ(3)   // CSB
    `IOPAD_MPRJ(4)   // SCK
    `IOPAD_MPRJ(5)   // ser_rx
    `IOPAD_MPRJ(6)   // ser_tx
    `INPAD_MPRJ(7)   // irq
    
    `INPAD_MPRJ(8)   // RXD[0]
    `INPAD_MPRJ(9)   // RXD[1]
    `INPAD_MPRJ(10)  // RXD[2]
    `INPAD_MPRJ(11)  // RXD[3]
    `INPAD_MPRJ(12)  // RXD[4]
    `INPAD_MPRJ(13)  // RXD[5]
    `INPAD_MPRJ(14)  // RXD[6]
    `INPAD_MPRJ(15)  // RXD[7]
    `INPAD_MPRJ(16)  // RXD[8]
    `INPAD_MPRJ(17)  // RXD[9]
    `INPAD_MPRJ(18)  // RXD[10]
    `INPAD_MPRJ(19)  // RXD[11]
    `INPAD_MPRJ(20)  // RXD[12]
    `INPAD_MPRJ(21)  // RXCLK
    
    `IOPAD_MPRJ(22)  // TXD[0]
    `IOPAD_MPRJ(23)  // TXD[1]
    `IOPAD_MPRJ(24)  // TXD[2]
    `IOPAD_MPRJ(25)  // TXD[3]
    `IOPAD_MPRJ(26)  // TXD[4]
    `IOPAD_MPRJ(27)  // TXD[5]
    `IOPAD_MPRJ(28)  // TXD[6]
    `IOPAD_MPRJ(29)  // TXD[7]
    `IOPAD_MPRJ(30)  // TXD[8]
    `IOPAD_MPRJ(31)  // TXD[9]
    `IOPAD_MPRJ(32)  // TXD[10]
    `IOPAD_MPRJ(33)  // TXD[11]
    `IOPAD_MPRJ(34)  // TXD[12]
    `IOPAD_MPRJ(35)  // TXCLK
    
    `INPAD_MPRJ(36)  // IOCLK
    `IOPAD_MPRJ(37)  // NOT USE


//Willy debug - e
    
    
 // FPGA - Remove module buff_flash_clkrst - bypass the buffer
 //  .A({in_n, in_s}), 
 //	.X({out_s, out_n})); 
 assign {caravel_clk_buf,
  caravel_rstn_buf,
  flash_clk_frame_buf,
  flash_csb_frame_buf,
  flash_clk_oeb_buf,
  flash_csb_oeb_buf,
  flash_io0_oeb_buf,
  flash_io1_oeb_buf,
  flash_io0_ieb_buf,
  flash_io1_ieb_buf,
  flash_io0_do_buf,
  flash_io1_do_buf } =
  {
  caravel_clk,
  caravel_rstn,
  flash_clk_frame,
  flash_csb_frame,
  flash_clk_oeb,
  flash_csb_oeb,
  flash_io0_oeb,
  flash_io1_oeb,
  flash_io0_ieb,
  flash_io1_ieb,
  flash_io0_do,
  flash_io1_do };
 assign
 {
  clock_core_buf,
  flash_io1_di_buf,
  flash_io0_di_buf } =
 {
  clock_core,
  flash_io1_di,
  flash_io0_di };
// end of module buff_flash_clkrst 




  /* NOTE: The first 7 GPIO are unbuffered, and all
		 * OEB lines except the last three are unbuffered
		 * (most of these end up being no-connects from
		 * housekeeping).
		 */
  assign mgmt_io_in_hk[6:0] = mgmt_io_in[6:0];
  assign mgmt_io_out[6:0] = mgmt_io_out_hk[6:0];
  assign mgmt_io_oeb[34:0] = mgmt_io_oeb_hk[34:0];
// FPGA Remove module gpio_signal_buffering
  assign mgmt_io_in_hk[37:7] = mgmt_io_in[37:7];
         assign mgmt_io_out[37:7] = mgmt_io_out_hk[37:7];
  assign mgmt_io_oeb[37:35] = mgmt_io_oeb_hk[37:35];


/*
 chip_io padframe(
// FPGA: Remove vdd, vss, ports
 // Core Side Pins
 .gpio(gpio),
 .mprj_io(mprj_io),
 .clock(clock),
 .resetb(resetb),
 .flash_csb(flash_csb),
 .flash_clk(flash_clk),
 .flash_io0(flash_io0),
 .flash_io1(flash_io1),
 // SoC Core Interface
 .porb_h(porb_h),
 .por(por_l_buf),
 .resetb_core_h(rstb_h),
 .clock_core(clock_core),
 .gpio_out_core(gpio_out_core),
 .gpio_in_core(gpio_in_core),
 .gpio_mode0_core(gpio_mode0_core),
 .gpio_mode1_core(gpio_mode1_core),
 .gpio_outenb_core(gpio_outenb_core),
 .gpio_inenb_core(gpio_inenb_core),
 .flash_csb_core(flash_csb_frame_buf),
 .flash_clk_core(flash_clk_frame_buf),
 .flash_csb_oeb_core(flash_csb_oeb_buf),
 .flash_clk_oeb_core(flash_clk_oeb_buf),
 .flash_io0_oeb_core(flash_io0_oeb_buf),
 .flash_io1_oeb_core(flash_io1_oeb_buf),
 .flash_io0_ieb_core(flash_io0_ieb_buf),
 .flash_io1_ieb_core(flash_io1_ieb_buf),
 .flash_io0_do_core(flash_io0_do_buf),
 .flash_io1_do_core(flash_io1_do_buf),
 .flash_io0_di_core(flash_io0_di),
 .flash_io1_di_core(flash_io1_di),
 .mprj_io_one(mprj_io_one),
//Willy debug .mprj_io_in(mprj_io_in),
 .mprj_io_out(mprj_io_out),
 .mprj_io_oeb(mprj_io_oeb),
 .mprj_io_inp_dis(mprj_io_inp_dis),
 .mprj_io_ib_mode_sel(mprj_io_ib_mode_sel),
 .mprj_io_vtrip_sel(mprj_io_vtrip_sel),
 .mprj_io_slow_sel(mprj_io_slow_sel),
 .mprj_io_holdover(mprj_io_holdover),
 .mprj_io_analog_en(mprj_io_analog_en),
 .mprj_io_analog_sel(mprj_io_analog_sel),
 .mprj_io_analog_pol(mprj_io_analog_pol),
 .mprj_io_dm(mprj_io_dm),
 .mprj_analog_io(user_analog_io)
    );
*/

    // Logic analyzer signals
    wire [127:0] la_data_in_user; // From CPU to MPRJ
    wire [127:0] la_data_in_mprj; // From MPRJ to CPU
    wire [127:0] la_data_out_mprj; // From CPU to MPRJ
    wire [127:0] la_data_out_user; // From MPRJ to CPU
    wire [127:0] la_oenb_user; // From CPU to MPRJ
    wire [127:0] la_oenb_mprj; // From CPU to MPRJ
    wire [127:0] la_iena_mprj; // From CPU only

    wire [2:0] user_irq; // From MRPJ to CPU
    wire [2:0] user_irq_core;
    wire [2:0] user_irq_ena;
    wire [2:0] irq_spi; // From SPI and external pins

    // Exported Wishbone Bus (processor facing)
    wire mprj_iena_wb;
    wire mprj_cyc_o_core;
    wire mprj_stb_o_core;
    wire mprj_we_o_core;
    wire [3:0] mprj_sel_o_core;
    wire [31:0] mprj_adr_o_core;
    wire [31:0] mprj_dat_o_core;
    wire mprj_ack_i_core;
    wire [31:0] mprj_dat_i_core;

    wire [31:0] hk_dat_i;
    wire hk_ack_i;
    wire hk_stb_o;
    wire hk_cyc_o;

    // Exported Wishbone Bus (user area facing)
    wire mprj_cyc_o_user;
    wire mprj_stb_o_user;
    wire mprj_we_o_user;
    wire [3:0] mprj_sel_o_user;
    wire [31:0] mprj_adr_o_user;
    wire [31:0] mprj_dat_o_user;
    wire [31:0] mprj_dat_i_user;
    wire mprj_ack_i_user;

    // Mask revision
    wire [31:0] mask_rev;

    wire mprj_clock;
    wire mprj_clock2;
    wire mprj_reset;

    // Power monitoring 


    // Management processor (wrapper).  Any management core
    // implementation must match this pinout.

    // Pass thru clock and reset
    wire clk_passthru;
    wire resetn_passthru;

 // NC passthru signal porb_h 
 //wire porb_h_in_nc;
 //wire porb_h_out_nc;

    mgmt_core_wrapper soc (

	    // SoC pass through buffered signals
	    .serial_clock_in(mprj_io_loader_clock),
	    .serial_clock_out(mprj_io_loader_clock_buf),
	    .serial_load_in(mprj_io_loader_strobe),
	    .serial_load_out(mprj_io_loader_strobe_buf),
	    .serial_resetn_in(mprj_io_loader_resetn),
	    .serial_resetn_out(mprj_io_loader_resetn_buf),
	    .serial_data_2_in(mprj_io_loader_data_2),
	    .serial_data_2_out(mprj_io_loader_data_2_buf),
	    .rstb_l_in(rstb_l),
	    .rstb_l_out(rstb_l_buf),

		 // [Vic]: POR is useless here
	    //.porb_h_in(porb_h_in_nc),
	    //.porb_h_out(porb_h_out_nc),
	    //.por_l_in(por_l),
	    //.por_l_out(por_l_buf),
    
	    // Clock and reset
	    .core_clk(caravel_clk_buf),
	    .core_rstn(caravel_rstn_buf),
    
        // Pass thru Clock and reset
	    .clk_in(caravel_clk_buf),
	    .resetn_in(caravel_rstn_buf),
	    .clk_out(clk_passthru),
	    .resetn_out(resetn_passthru),
    
	    // GPIO (1 pin)
	    .gpio_out_pad(gpio_out_core),
	    .gpio_in_pad(gpio_in_core),
	    .gpio_mode0_pad(gpio_mode0_core),
	    .gpio_mode1_pad(gpio_mode1_core),
	    .gpio_outenb_pad(gpio_outenb_core),
	    .gpio_inenb_pad(gpio_inenb_core),
    
	    // Primary SPI flash controller
	    .flash_csb(flash_csb_core),
	    .flash_clk(flash_clk_core),
	    .flash_io0_oeb(flash_io0_oeb_core),
	    .flash_io0_di(flash_io0_di_core),
	    .flash_io0_do(flash_io0_do_core),
	    .flash_io1_oeb(flash_io1_oeb_core),
	    .flash_io1_di(flash_io1_di_core),
	    .flash_io1_do(flash_io1_do_core),
	    .flash_io2_oeb(flash_io2_oeb_core),
	    .flash_io2_di(flash_io2_di_core),
	    .flash_io2_do(flash_io2_do_core),
	    .flash_io3_oeb(flash_io3_oeb_core),
	    .flash_io3_di(flash_io3_di_core),
	    .flash_io3_do(flash_io3_do_core),
    
	    // Exported Wishbone Bus
	    .mprj_wb_iena(mprj_iena_wb),
	    .mprj_cyc_o(mprj_cyc_o_core),
	    .mprj_stb_o(mprj_stb_o_core),
	    .mprj_we_o(mprj_we_o_core),
	    .mprj_sel_o(mprj_sel_o_core),
	    .mprj_adr_o(mprj_adr_o_core),
	    .mprj_dat_o(mprj_dat_o_core),
	    .mprj_ack_i(mprj_ack_i_core),
	    .mprj_dat_i(mprj_dat_i_core),
    
	    .hk_stb_o(hk_stb_o),
	    .hk_cyc_o(hk_cyc_o),
	    .hk_dat_i(hk_dat_i),
	    .hk_ack_i(hk_ack_i),
    
	    // IRQ
	    .irq({irq_spi, user_irq}),
	    .user_irq_ena(user_irq_ena),
    
	    // Module status (these may or may not be implemented)
	    .qspi_enabled(qspi_enabled),
	    .uart_enabled(uart_enabled),
	    .spi_enabled(spi_enabled),
	    .debug_mode(debug_mode),
    
	    // Module I/O (these may or may not be implemented)
	    // UART
	    .ser_tx(ser_tx),
	    .ser_rx(ser_rx),
	    // SPI master
	    .spi_sdi(spi_sdi),
	    .spi_csb(spi_csb),
	    .spi_sck(spi_sck),
	    .spi_sdo(spi_sdo),
	    .spi_sdoenb(spi_sdoenb),
	    // Debug
	    .debug_in(debug_in),
	    .debug_out(debug_out),
	    .debug_oeb(debug_oeb),
	    // Logic analyzer
	    .la_input(la_data_in_mprj),
	    .la_output(la_data_out_mprj),
	    .la_oenb(la_oenb_mprj),
	    .la_iena(la_iena_mprj),
    
    	// Trap status
    	.trap(trap)
    );

    /* Clock and reset to user space are passed through a tristate	*/
    /* buffer like the above, but since they are intended to be		*/
    /* always active, connect the enable to the logic-1 output from	*/
    /* the vccd1 domain.						*/
// FPGA : Remove mgmt_protect module, passthrough


 assign la_data_in_mprj = la_data_out_user;
 assign la_data_in_user = la_data_out_mprj;
 assign la_oenb_user = la_oenb_mprj;

   assign mprj_clock = clk_passthru;
   assign mprj_clock2 = caravel_clk2;
   assign mprj_reset = ~resetn_passthru; // Note: it is inversted - mprj_reset is active high
   assign mprj_cyc_o_user = mprj_cyc_o_core;
   assign mprj_stb_o_user = mprj_stb_o_core;
   assign mprj_we_o_user = mprj_we_o_core;
   assign mprj_sel_o_user = mprj_sel_o_core;
   assign mprj_adr_o_user = mprj_adr_o_core;
   assign mprj_dat_o_user = mprj_dat_o_core;
   assign mprj_dat_i_core = mprj_dat_i_user;
   assign mprj_ack_i_core = mprj_ack_i_user;
   assign user_irq = user_irq_core;

   assign user1_vcc_powergood = 1'b1;
   assign user2_vcc_powergood = 1'b1;
   assign user1_vdd_powergood = 1'b1;
   assign user2_vdd_powergood = 1'b1;

    /*--------------------------------------------------*/
    /* Wrapper module around the user project 		*/
    /*--------------------------------------------------*/
   wire        uspj_cyc; // CYC
   wire        uspj_ack;
   wire [31:0] uspj_dat;

   user_project_wrapper mprj (

      .wb_clk_i(mprj_clock),
      .wb_rst_i(mprj_reset),

      // Management SoC Wishbone bus (exported)
      .wbs_cyc_i(uspj_cyc),
      .wbs_stb_i(mprj_stb_o_user),
      .wbs_we_i(mprj_we_o_user),
      .wbs_sel_i(mprj_sel_o_user),
      .wbs_adr_i(mprj_adr_o_user),
      .wbs_dat_i(mprj_dat_o_user),
      .wbs_ack_o(uspj_ack),
      .wbs_dat_o(uspj_dat),

      // GPIO pad 3-pin interface (plus analog)
      .io_in (user_io_in),
      .io_out(user_io_out),
      .io_oeb(user_io_oeb),
      //.analog_io(user_analog_io),

      // Logic analyzer
      .la_data_in(la_data_in_user),
      .la_data_out(la_data_out_user),
      .la_oenb(la_oenb_user),

      // Independent clock
      .user_clock2(mprj_clock2),

      // IRQ
      .user_irq(user_irq_core)
   );

   //======================================================//
   // [Vic]: PAD IOs should also be flexible
   //======================================================//
   wire        wb_mux;
   wire        io_cnfg_cyc;
   wire        io_cnfg_ack;
   wire [31:0] io_cnfg_dat;

   pads_config PAD_IO_CNFG (
  	   .clk(clock_core),
	   .resetb(resetb_core),
	   .wb_clk_i(mprj_clock),
	   .wb_rst_i(mprj_reset),
	   .wbs_cyc_i(io_cnfg_cyc),
	   .wbs_stb_i(mprj_stb_o_user),
	   .wbs_we_i(mprj_we_o_user),
	   .wbs_sel_i(mprj_sel_o_user),
	   .wbs_adr_i(mprj_adr_o_user),
	   .wbs_dat_i(mprj_dat_o_user),
	   .wbs_ack_o(io_cnfg_ack),
	   .wbs_dat_o(io_cnfg_dat),
	   .re_n(REN),
	   .oe_n(mprj_oen)
   );
   // IO configuration area: 3000_6000 ~ 3000_6025
   assign wb_mux = (mprj_adr_o_user[31:12] == 20'h3000_6)? 1'b1 : 1'b0;
   assign uspj_cyc    = (wb_mux)? 0 : mprj_cyc_o_user;
   assign io_cnfg_cyc = (wb_mux)? mprj_cyc_o_user : 0;
   assign mprj_ack_i_user = (wb_mux)? io_cnfg_ack : uspj_ack;
   assign mprj_dat_i_user = (wb_mux)? io_cnfg_dat : uspj_dat;
   //======================================================//


    wire [`MPRJ_IO_PADS_1-1:0] gpio_serial_link_1_shifted;
    wire [`MPRJ_IO_PADS_2-1:0] gpio_serial_link_2_shifted;

    assign gpio_serial_link_1_shifted = {gpio_serial_link_1[`MPRJ_IO_PADS_1-2:0],
      mprj_io_loader_data_1};
    // Note that serial_link_2 is backwards compared to serial_link_1, so it
    // shifts in the other direction.
    assign gpio_serial_link_2_shifted = {mprj_io_loader_data_2_buf,
      gpio_serial_link_2[`MPRJ_IO_PADS_2-1:1]};

    // Propagating clock and reset to mitigate timing and fanout issues
    wire [`MPRJ_IO_PADS_1-1:0] gpio_clock_1;
    wire [`MPRJ_IO_PADS_2-1:0] gpio_clock_2;
    wire [`MPRJ_IO_PADS_1-1:0] gpio_resetn_1;
    wire [`MPRJ_IO_PADS_2-1:0] gpio_resetn_2;
    wire [`MPRJ_IO_PADS_1-1:0] gpio_load_1;
    wire [`MPRJ_IO_PADS_2-1:0] gpio_load_2;
    wire [`MPRJ_IO_PADS_1-1:0] gpio_clock_1_shifted;
    wire [`MPRJ_IO_PADS_2-1:0] gpio_clock_2_shifted;
    wire [`MPRJ_IO_PADS_1-1:0] gpio_resetn_1_shifted;
    wire [`MPRJ_IO_PADS_2-1:0] gpio_resetn_2_shifted;
    wire [`MPRJ_IO_PADS_1-1:0] gpio_load_1_shifted;
    wire [`MPRJ_IO_PADS_2-1:0] gpio_load_2_shifted;

    assign gpio_clock_1_shifted = {gpio_clock_1[`MPRJ_IO_PADS_1-2:0],
      mprj_io_loader_clock};
    assign gpio_clock_2_shifted = {mprj_io_loader_clock_buf,
     gpio_clock_2[`MPRJ_IO_PADS_2-1:1]};
    assign gpio_resetn_1_shifted = {gpio_resetn_1[`MPRJ_IO_PADS_1-2:0],
      mprj_io_loader_resetn};
    assign gpio_resetn_2_shifted = {mprj_io_loader_resetn_buf,
     gpio_resetn_2[`MPRJ_IO_PADS_2-1:1]};
    assign gpio_load_1_shifted = {gpio_load_1[`MPRJ_IO_PADS_1-2:0],
      mprj_io_loader_strobe};
    assign gpio_load_2_shifted = {mprj_io_loader_strobe_buf,
     gpio_load_2[`MPRJ_IO_PADS_2-1:1]};

    wire [2:0] spi_pll_sel;
    wire [2:0] spi_pll90_sel;
    wire [4:0] spi_pll_div;
    wire [25:0] spi_pll_trim;
    wire  ext_reset;
// FPGA Remove module caravel_clocking: clock/reset directly from IO pad
    assign caravel_clk = clock_core_buf;
    assign caravel_clk2 = clock_core_buf;
    assign caravel_rstn = rstb_l_buf // original design : sync rstb_l_buf 3T 
                          & ~ext_reset;

   // DCO/Digital Locked Loop
   // FPGA: Remove digital_pll

   // Housekeeping interface

   housekeeping housekeeping (
         .wb_clk_i(caravel_clk),
         .wb_rstn_i(caravel_rstn),
 
         .wb_adr_i(mprj_adr_o_core),
         .wb_dat_i(mprj_dat_o_core),
         .wb_sel_i(mprj_sel_o_core),
         .wb_we_i(mprj_we_o_core),
         .wb_cyc_i(hk_cyc_o),
         .wb_stb_i(hk_stb_o),
         .wb_ack_o(hk_ack_i),
         .wb_dat_o(hk_dat_i),
 
         .porb(porb_l),
 
         .pll_ena(spi_pll_ena),
         .pll_dco_ena(spi_pll_dco_ena),
         .pll_div(spi_pll_div),
         .pll_sel(spi_pll_sel),
         .pll90_sel(spi_pll90_sel),
         .pll_trim(spi_pll_trim),
         .pll_bypass(ext_clk_sel),
 
  .qspi_enabled(qspi_enabled),
  .uart_enabled(uart_enabled),
  .spi_enabled(spi_enabled),
  .debug_mode(debug_mode),
 
  .ser_tx(ser_tx),
  .ser_rx(ser_rx),
 
  .spi_sdi(spi_sdi),
  .spi_csb(spi_csb),
  .spi_sck(spi_sck),
  .spi_sdo(spi_sdo),
  .spi_sdoenb(spi_sdoenb),
 
  .debug_in(debug_in),
  .debug_out(debug_out),
  .debug_oeb(debug_oeb),
 
         .irq(irq_spi),
         .reset(ext_reset),
 
         .serial_clock(mprj_io_loader_clock),
         .serial_load(mprj_io_loader_strobe),
         .serial_resetn(mprj_io_loader_resetn),
         .serial_data_1(mprj_io_loader_data_1),
         .serial_data_2(mprj_io_loader_data_2),
 
  .mgmt_gpio_in(mgmt_io_in_hk),
  .mgmt_gpio_out(mgmt_io_out_hk),
  .mgmt_gpio_oeb(mgmt_io_oeb_hk),
 
  .pwr_ctrl_out(pwr_ctrl_nc), /* Not used in this version */
 
         .trap(trap),
 
  .user_clock(caravel_clk2),
 
         .mask_rev_in(mask_rev),
 
  .spimemio_flash_csb(flash_csb_core),
  .spimemio_flash_clk(flash_clk_core),
  .spimemio_flash_io0_oeb(flash_io0_oeb_core),
  .spimemio_flash_io1_oeb(flash_io1_oeb_core),
  .spimemio_flash_io2_oeb(flash_io2_oeb_core),
  .spimemio_flash_io3_oeb(flash_io3_oeb_core),
  .spimemio_flash_io0_do(flash_io0_do_core),
  .spimemio_flash_io1_do(flash_io1_do_core),
  .spimemio_flash_io2_do(flash_io2_do_core),
  .spimemio_flash_io3_do(flash_io3_do_core),
  .spimemio_flash_io0_di(flash_io0_di_core),
  .spimemio_flash_io1_di(flash_io1_di_core),
  .spimemio_flash_io2_di(flash_io2_di_core),
  .spimemio_flash_io3_di(flash_io3_di_core),
 
  .pad_flash_csb(flash_csb_frame),
  .pad_flash_csb_oeb(flash_csb_oeb),
  .pad_flash_clk(flash_clk_frame),
  .pad_flash_clk_oeb(flash_clk_oeb),
  .pad_flash_io0_oeb(flash_io0_oeb),
  .pad_flash_io1_oeb(flash_io1_oeb),
  .pad_flash_io0_ieb(flash_io0_ieb),
  .pad_flash_io1_ieb(flash_io1_ieb),
  .pad_flash_io0_do(flash_io0_do),
  .pad_flash_io1_do(flash_io1_do),
  .pad_flash_io0_di(flash_io0_di_buf),
  .pad_flash_io1_di(flash_io1_di_buf),


   .usr1_vcc_pwrgood(user1_vcc_powergood),
   .usr2_vcc_pwrgood(user2_vcc_powergood),
   .usr1_vdd_pwrgood(user1_vdd_powergood),
   .usr2_vdd_pwrgood(user2_vdd_powergood)
    );

    // [Vic]: Remove GPIO configuration logics
    assign mprj_io_out = user_io_out;
    assign user_io_in  = mprj_io_in;
    assign mgmt_io_in  = mprj_io_in;

// FPGA: Remove module user_id_programming
    assign mask_rev = USER_PROJECT_ID;


   // Power-on-reset circuit
   // FPGA: Remove module "simple_por", "xres_buf"
   // Hack por equal to resetb
   assign porb_h = resetb_core;
   assign porb_l = resetb_core;
   assign por_l = ~porb_l;
// rstb_l is a level-shift version of rstb_h
    assign rstb_l = resetb_core;
// FPGA: remove module spare_logic_block


endmodule
// `default_nettype wire
