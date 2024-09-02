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

`default_nettype wire
/*
 *-------------------------------------------------------------
 *
 * user_project_wrapper
 *
 * This wrapper enumerates all of the pins available to the
 * user for the user project.
 *
 * An example user project is provided in this wrapper.  The
 * example should be removed and replaced with the actual
 * user project.
 *
 *-------------------------------------------------------------
 */

module user_project_wrapper #(parameter BITS = 32)
(
    inout vccd,	// 1.8v supply
    inout vssd,	// digital ground

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // Analog (direct connection to GPIO pad---use with caution)
    // Note that analog I/O is not available on the 7 lowest-numbered
    // GPIO pads, and so the analog_io indexing is offset from the
    // GPIO indexing by 7 (also upper 2 GPIOs do not have analog_io).
    `ifdef USE_skywater_LIB
      inout [`MPRJ_IO_PADS-10:0] analog_io,
    `endif //USE_skywater_LIB

    // Independent clock (on independent integer divider)
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

/*
assign wbs_ack_o   = 1'b0;
assign wbs_dat_o   = 32'd0;
assign la_data_out = 128'd0;
assign io_out      = 38'd0;
assign io_oeb      = 38'd0;
assign user_irq    = 3'd0;
*/
FSIC #(.BITS( BITS )) u_fsic  (
                      // [Vic]: Use power pin
 	                    .vccd(vccd),
	                    .vssd(vssd),

                      // MGMT SoC Wishbone Slave
                      .wb_rst      (wb_rst_i),                // I
                      .wb_clk      (wb_clk_i),                // I

                      .wbs_adr     (wbs_adr_i),               // I  32
                      .wbs_wdata   (wbs_dat_i),               // I  32
                      .wbs_sel     (wbs_sel_i),               // I  4
                      .wbs_cyc     (wbs_cyc_i),               // I
                      .wbs_stb     (wbs_stb_i),               // I
                      .wbs_we      (wbs_we_i),                // I

                      .wbs_ack     (wbs_ack_o),               // O
                      .wbs_rdata   (wbs_dat_o),               // O  32

                      // Logic Analyzer
		      // Removed. fsic has no below la interfaces.
                      //.la_data_in  (la_data_in),              // I  128
                      //.la_oenb     (la_oenb),                 // I  128
                      //.la_data_out (la_data_out),             // O  128

                      // IO Pads
                      .io_in       (io_in),                   // I  38
                      .io_out      (io_out),                  // O  38
                      .io_oeb      (io_oeb),                  // O  38

                      // IRQ
                      .user_irq    (user_irq),                // O  3

                      // MISC (Independent clock, on independent integer divider)
                      .user_clock2 (user_clock2)              // I
                     );


endmodule	// user_project_wrapper

`default_nettype wire
