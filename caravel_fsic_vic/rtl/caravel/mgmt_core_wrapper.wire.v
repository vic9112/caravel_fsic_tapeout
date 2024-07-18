/*
 *  SPDX-FileCopyrightText: 2015 Clifford Wolf
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 *  Revision 1,  July 2019:  Added signals to drive flash_clk and flash_csb
 *  output enable (inverted), tied to reset so that the flash is completely
 *  isolated from the processor when the processor is in reset.
 *
 *  Also: Made ram_wenb a 4-bit bus so that the memory access can be made
 *  byte-wide for byte-wide instructions.
 *
 *  SPDX-License-Identifier: ISC
 */


`default_nettype none

`ifndef _MGMT_CORE_WRAPPER_
`define _MGMT_CORE_WRAPPER_

/* Wrapper module around management SoC core for pin compatibility  */
/* with the Caravel harness chip. */    

module mgmt_core_wrapper (
`ifdef USE_POWER_PINS
inout wire VPWR,
inout wire VGND,
`endif
    // Clock and reset
input wire core_clk,
input wire core_rstn,

    // Pass-thru signals
input wire clk_in,
input wire resetn_in,
output wire clk_out,
output wire resetn_out,

input wire serial_load_in,
input wire serial_data_2_in,
input wire serial_resetn_in,
input wire serial_clock_in,
input wire rstb_l_in,
input wire por_l_in,
//input wire porb_h_in,

output wire serial_load_out,
output wire serial_data_2_out,
output wire serial_resetn_out,
output wire serial_clock_out,
output wire rstb_l_out,
output wire por_l_out,
//output wire porb_h_out,

    // GPIO (one pin)
output wire gpio_out_pad,
input wire gpio_in_pad,
output wire gpio_mode0_pad,
output wire gpio_mode1_pad,
output wire gpio_outenb_pad,
output wire gpio_inenb_pad,

    // Logic analyzer signals
input wire [127:0] la_input,
output wire [127:0] la_output,
output wire [127:0] la_oenb,
output wire [127:0] la_iena,

    // Flash memory control (SPI master)
output wire flash_csb,
output wire flash_clk,

output wire flash_io0_oeb,
output wire flash_io1_oeb,
output wire flash_io2_oeb,
output wire flash_io3_oeb,

output wire flash_io0_do,
output wire flash_io1_do,
output wire flash_io2_do,
output wire flash_io3_do,

input wire flash_io0_di,
input wire flash_io1_di,
input wire flash_io2_di,
input wire flash_io3_di,

    // Exported Wishboned bus
output wire mprj_wb_iena,
output wire mprj_cyc_o,
output wire mprj_stb_o,
output wire mprj_we_o,
output wire [3:0] mprj_sel_o,
output wire [31:0] mprj_adr_o,
output wire [31:0] mprj_dat_o,
input wire mprj_ack_i,
input wire [31:0] mprj_dat_i,

output wire hk_cyc_o,
output wire hk_stb_o,
input wire [31:0] hk_dat_i,
input wire hk_ack_i,

    // IRQ
input wire [5:0] irq,
output wire [2:0] user_irq_ena,

    // Module status
output wire qspi_enabled,
output wire uart_enabled,
output wire spi_enabled,
output wire debug_mode,

    // Module I/O
output wire ser_tx,
input wire ser_rx,
output wire spi_csb,
output wire spi_sck,
output wire spi_sdo,
output wire spi_sdoenb,
input wire spi_sdi,
input wire debug_in,
output wire debug_out,
output wire debug_oeb,

    // Trap state from CPU
output wire trap
);


// Signals below are sram_ro ports that left no_connect
// as they are tied down inside mgmt_core

    /* Implement the PicoSoC core */

    mgmt_core core (
    `ifdef USE_POWER_PINS
        .VPWR(VPWR),        /* 1.8V domain */
        .VGND(VGND),
    `endif
        .core_clk(core_clk),
        .core_rstn(core_rstn),

        // Pass-thru signals
        .clk_in(clk_in),
        .clk_out(clk_out),
        .resetn_in(resetn_in),
        .resetn_out(resetn_out),

        .serial_load_in(serial_load_in),
        .serial_load_out(serial_load_out),
        .serial_data_2_in(serial_data_2_in),
        .serial_data_2_out(serial_data_2_out),
        .serial_resetn_in(serial_resetn_in),
        .serial_resetn_out(serial_resetn_out),
        .serial_clock_in(serial_clock_in),
        .serial_clock_out(serial_clock_out),

        .rstb_l_in(rstb_l_in),
        .rstb_l_out(rstb_l_out),
        .por_l_in(por_l_in),
        .por_l_out(por_l_out),
//        .porb_h_in(porb_h_in),
//        .porb_h_out(porb_h_out),

        // Trap state from CPU
        .trap(trap),

        // GPIO (one pin)
        .gpio_out_pad(gpio_out_pad),        // Connect to out on gpio pad
        .gpio_in_pad(gpio_in_pad),      // Connect to in on gpio pad
        .gpio_mode0_pad(gpio_mode0_pad),    // Connect to dm[0] on gpio pad
        .gpio_mode1_pad(gpio_mode1_pad),    // Connect to dm[2] on gpio pad
        .gpio_outenb_pad(gpio_outenb_pad),  // Connect to oe_n on gpio pad
        .gpio_inenb_pad(gpio_inenb_pad),    // Connect to inp_dis on gpio pad

        .la_input(la_input),            // From user project to CPU
        .la_output(la_output),          // From CPU to user project
        .la_oenb(la_oenb),          // Logic analyzer output enable
        .la_iena(la_iena),          // Logic analyzer input enable

        // IRQ
        .user_irq(irq),     // IRQ from SPI and user project
        .user_irq_ena(user_irq_ena),

        // Flash memory control (SPI master)
        .flash_cs_n(flash_csb),
        .flash_clk(flash_clk),

        .flash_io0_oeb(flash_io0_oeb),
        .flash_io1_oeb(flash_io1_oeb),
        .flash_io2_oeb(flash_io2_oeb),
        .flash_io3_oeb(flash_io3_oeb),

        .flash_io0_do(flash_io0_do),
        .flash_io1_do(flash_io1_do),
        .flash_io2_do(flash_io2_do),
        .flash_io3_do(flash_io3_do),

        .flash_io0_di(flash_io0_di),
        .flash_io1_di(flash_io1_di),
        .flash_io2_di(flash_io2_di),
        .flash_io3_di(flash_io3_di),

        // Exported wishbone bus (User project)
        .mprj_wb_iena(mprj_wb_iena),
        .mprj_ack_i(mprj_ack_i),
        .mprj_dat_i(mprj_dat_i),
        .mprj_cyc_o(mprj_cyc_o),
        .mprj_stb_o(mprj_stb_o),
        .mprj_we_o(mprj_we_o),
        .mprj_sel_o(mprj_sel_o),
        .mprj_adr_o(mprj_adr_o),
        .mprj_dat_o(mprj_dat_o),

        .hk_cyc_o(hk_cyc_o),
        .hk_stb_o(hk_stb_o),
        .hk_dat_i(hk_dat_i),
        .hk_ack_i(hk_ack_i),

        // Module status
        .qspi_enabled(qspi_enabled),
        .uart_enabled(uart_enabled),
        .spi_enabled(spi_enabled),
        .debug_mode(debug_mode),

        // Module I/O
//      .ser_tx(ser_tx),
//      .ser_rx(ser_rx),
        .serial_tx(ser_tx),
        .serial_rx(ser_rx),
        .spi_cs_n(spi_csb),
        .spi_clk(spi_sck),
        .spi_miso(spi_sdi),
        .spi_sdoenb(spi_sdoenb),
        .spi_mosi(spi_sdo),
        .debug_in(debug_in),
        .debug_out(debug_out),
        .debug_oeb(debug_oeb)

    );


endmodule
`default_nettype wire

`endif
