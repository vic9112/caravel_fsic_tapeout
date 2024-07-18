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

// `default_nettype none
module chip_io(
`ifndef REMOVE_POWER_PAD //tony_debug
	// Package Pins
inout wire vddio_pad,
inout wire vddio_pad2,
inout wire vssio_pad,
inout wire vssio_pad2,
inout wire vccd_pad,
inout wire vssd_pad,
inout wire vdda_pad,
inout wire vssa_pad,
inout wire vdda1_pad,
inout wire vdda1_pad2,
inout wire vdda2_pad,
inout wire vssa1_pad,
inout wire vssa1_pad2,
inout wire vssa2_pad,
inout wire vccd1_pad,
inout wire vccd2_pad,
inout wire vssd1_pad,
inout wire vssd2_pad,

	// Core Side
inout wire vddio,
inout wire vssio,
inout wire vccd,
inout wire vssd,
inout wire vdda,
inout wire vssa,
inout wire vdda1,
inout wire vdda2,
inout wire vssa1,
inout wire vssa2,
inout wire vccd1,
inout wire vccd2,
inout wire vssd1,
inout wire vssd2,
`endif //REMOVE_POWER_PAD //tony_debug

inout wire gpio,
input wire clock,
`ifndef NO_POR_PAD //tony_debug
input wire resetb,
`endif //NO_POR_PAD //tony_debug
output wire flash_csb,
output wire flash_clk,
inout wire flash_io0,
inout wire flash_io1,
	// Chip Core Interface
input wire porb_h,
input wire por,
`ifndef NO_POR_PAD //tony_debug
output wire resetb_core_h,
`endif //NO_POR_PAD //tony_debug
output wire clock_core,
input wire gpio_out_core,
output wire gpio_in_core,
input wire gpio_mode0_core,
input wire gpio_mode1_core,
input wire gpio_outenb_core,
input wire gpio_inenb_core,
input wire flash_csb_core,
input wire flash_clk_core,
input wire flash_csb_oeb_core,
input wire flash_clk_oeb_core,
input wire flash_io0_oeb_core,
input wire flash_io1_oeb_core,
input wire flash_io0_ieb_core,
input wire flash_io1_ieb_core,
input wire flash_io0_do_core,
input wire flash_io1_do_core,
output wire flash_io0_di_core,
output wire flash_io1_di_core,
	// User project IOs
inout wire [`MPRJ_IO_PADS-1:0] mprj_io,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_out,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_oeb,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_inp_dis,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_ib_mode_sel,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_vtrip_sel,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_slow_sel,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_holdover,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_analog_en,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_analog_sel,
input wire [`MPRJ_IO_PADS-1:0] mprj_io_analog_pol,
input wire [`MPRJ_IO_PADS*3-1:0] mprj_io_dm,
output wire [`MPRJ_IO_PADS-1:0] mprj_io_in,
	// Loopbacks to constant value 1 in the 1.8V domain
input wire [`MPRJ_IO_PADS-1:0] mprj_io_one
	// User project direct access to gpio pad connections for analog
	// (all but the lowest-numbered 7 pads)
//inout wire [`MPRJ_IO_PADS-10:0] mprj_analog_io
);

    // To be considered:  Master hold signal on all user pads (?)
    // For now, set holdh_n to 1 internally (NOTE:  This is in the
    // VDDIO 3.3V domain)
    // and setting enh to porb_h.

    wire [`MPRJ_IO_PADS-1:0] mprj_io_enh;

    assign mprj_io_enh = {`MPRJ_IO_PADS{porb_h}};
	
//	wire analog_a, analog_b;
`ifndef REMOVE_sky130_ef_io__corner_pad //tony_debug
	wire vddio_q, vssio_q;
`endif //REMOVE_sky130_ef_io__corner_pad //tony_debug


`ifndef REMOVE_POWER_PAD //tony_debug
	// Instantiate power and ground pads for management domain
	// 12 pads:  vddio, vssio, vdda, vssa, vccd, vssd
	// One each HV and LV clamp.

	// HV clamps connect between one HV power rail and one ground
	// LV clamps have two clamps connecting between any two LV power
	// rails and grounds, and one back-to-back diode which connects
	// between the first LV clamp ground and any other ground.

    	sky130_ef_io__vddio_hvc_clamped_pad \mgmt_vddio_hvclamp_pad[0]  (
		`MGMT_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VDDIO_PAD(vddio_pad)
`endif
    	);

	// lies in user area 2
    	sky130_ef_io__vddio_hvc_clamped_pad \mgmt_vddio_hvclamp_pad[1]  (
		`USER2_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VDDIO_PAD(vddio_pad2)
`endif
    	);

    	sky130_ef_io__vdda_hvc_clamped_pad mgmt_vdda_hvclamp_pad (
		`MGMT_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VDDA_PAD(vdda_pad)
`endif
    	);

    	sky130_ef_io__vccd_lvc_clamped_pad mgmt_vccd_lvclamp_pad (
		`MGMT_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VCCD_PAD(vccd_pad)
`endif
    	);

    	sky130_ef_io__vssio_hvc_clamped_pad \mgmt_vssio_hvclamp_pad[0]  (
		`MGMT_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VSSIO_PAD(vssio_pad)
`endif
    	);

    	sky130_ef_io__vssio_hvc_clamped_pad \mgmt_vssio_hvclamp_pad[1]  (
		`USER2_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VSSIO_PAD(vssio_pad2)
`endif
    	);

    	sky130_ef_io__vssa_hvc_clamped_pad mgmt_vssa_hvclamp_pad (
		`MGMT_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VSSA_PAD(vssa_pad)
`endif
    	);

    	sky130_ef_io__vssd_lvc_clamped_pad mgmt_vssd_lvclamp_pad (
		`MGMT_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VSSD_PAD(vssd_pad)
`endif
    	);

	// Instantiate power and ground pads for user 1 domain
	// 8 pads:  vdda, vssa, vccd, vssd;  One each HV and LV clamp.

    	sky130_ef_io__vdda_hvc_clamped_pad \user1_vdda_hvclamp_pad[0] (
		`USER1_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VDDA_PAD(vdda1_pad)
`endif
    	);

		sky130_ef_io__vdda_hvc_clamped_pad \user1_vdda_hvclamp_pad[1] (
		`USER1_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VDDA_PAD(vdda1_pad2)
`endif
    	);

    	sky130_ef_io__vccd_lvc_clamped3_pad user1_vccd_lvclamp_pad (
		`USER1_ABUTMENT_PINS
		.VCCD1(vccd1),
		.VSSD1(vssd1),
`ifndef TOP_ROUTING
		.VCCD_PAD(vccd1_pad)
`endif
    	);

    	sky130_ef_io__vssa_hvc_clamped_pad \user1_vssa_hvclamp_pad[0] (
		`USER1_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VSSA_PAD(vssa1_pad)
`endif
    	);


    	sky130_ef_io__vssa_hvc_clamped_pad \user1_vssa_hvclamp_pad[1] (
		`USER1_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VSSA_PAD(vssa1_pad2)
`endif
    	);

    	sky130_ef_io__vssd_lvc_clamped3_pad user1_vssd_lvclamp_pad (
		`USER1_ABUTMENT_PINS
		.VCCD1(vccd1),
		.VSSD1(vssd1),
`ifndef TOP_ROUTING
		.VSSD_PAD(vssd1_pad)
`endif
    	);

	// Instantiate power and ground pads for user 2 domain
	// 8 pads:  vdda, vssa, vccd, vssd;  One each HV and LV clamp.

    	sky130_ef_io__vdda_hvc_clamped_pad user2_vdda_hvclamp_pad (
		`USER2_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VDDA_PAD(vdda2_pad)
`endif
    	);

    	sky130_ef_io__vccd_lvc_clamped3_pad user2_vccd_lvclamp_pad (
		`USER2_ABUTMENT_PINS
		.VCCD1(vccd2),
		.VSSD1(vssd2),
`ifndef TOP_ROUTING
		.VCCD_PAD(vccd2_pad)
`endif
    	);

    	sky130_ef_io__vssa_hvc_clamped_pad user2_vssa_hvclamp_pad (
		`USER2_ABUTMENT_PINS
`ifndef TOP_ROUTING
		.VSSA_PAD(vssa2_pad)
`endif
    	);

    	sky130_ef_io__vssd_lvc_clamped3_pad user2_vssd_lvclamp_pad (
		`USER2_ABUTMENT_PINS
		.VCCD1(vccd2),
		.VSSD1(vssd2),
`ifndef TOP_ROUTING
		.VSSD_PAD(vssd2_pad)
`endif
    	);

`endif //ifdef REMOVE_POWER_PAD //tony_debug

	wire [2:0] dm_all =
    		{gpio_mode1_core, gpio_mode1_core, gpio_mode0_core};
	wire[2:0] flash_io0_mode =
		{flash_io0_ieb_core, flash_io0_ieb_core, flash_io0_oeb_core};
	wire[2:0] flash_io1_mode =
		{flash_io1_ieb_core, flash_io1_ieb_core, flash_io1_oeb_core};

    wire [6:0] vccd_const_one;	// Constant value for management pins
    wire [6:0] vssd_const_zero;	// Constant value for management pins

    constant_block constant_value_inst [6:0] (
    `ifdef USE_POWER_PINS
	.vccd(vccd),
	.vssd(vssd),
    `endif
	.one(vccd_const_one),
	.zero(vssd_const_zero)
    );

	// Management clock input pad
	`INPUT_PAD(clock, clock_core, vccd_const_one[0], vssd_const_zero[0]);

    // Management GPIO pad
	`INOUT_PAD(gpio, gpio_in_core, vccd_const_one[1], vssd_const_zero[1], gpio_out_core, gpio_inenb_core, gpio_outenb_core, dm_all);

	// Management Flash SPI pads
	`INOUT_PAD(flash_io0, flash_io0_di_core, vccd_const_one[2], vssd_const_zero[2], flash_io0_do_core, flash_io0_ieb_core, flash_io0_oeb_core, flash_io0_mode);
	
	`INOUT_PAD(flash_io1, flash_io1_di_core, vccd_const_one[3], vssd_const_zero[3], flash_io1_do_core, flash_io1_ieb_core, flash_io1_oeb_core, flash_io1_mode);

	`OUTPUT_NO_INP_DIS_PAD(flash_csb, flash_csb_core, vccd_const_one[4], vssd_const_zero[4], flash_csb_oeb_core);
	`OUTPUT_NO_INP_DIS_PAD(flash_clk, flash_clk_core, vccd_const_one[5], vssd_const_zero[5], flash_clk_oeb_core);

    `ifndef NO_POR_PAD //tony_debug
	// NOTE:  The analog_out pad from the raven chip has been replaced by
    	// the digital reset input resetb on caravel due to the lack of an on-board
    	// power-on-reset circuit.  The XRES pad is used for providing a glitch-
    	// free reset.

	wire xresloop;
	wire xres_vss_loop;
	sky130_fd_io__top_xres4v2 resetb_pad (
		`MGMT_ABUTMENT_PINS
		`ifndef	TOP_ROUTING
		    .PAD(resetb),
		`endif
		.TIE_WEAK_HI_H(xresloop),   // Loop-back connection to pad through pad_a_esd_h
		.TIE_HI_ESD(),
		.TIE_LO_ESD(xres_vss_loop),
		.PAD_A_ESD_H(xresloop),
		.XRES_H_N(resetb_core_h),
		.DISABLE_PULLUP_H(xres_vss_loop), // 0 = enable pull-up on reset pad
		.ENABLE_H(porb_h),	 	  // Power-on-reset
   		.EN_VDDIO_SIG_H(xres_vss_loop),	  // No idea.
   		.INP_SEL_H(xres_vss_loop),	  // 1 = use filt_in_h else filter the pad input
   		.FILT_IN_H(xres_vss_loop),	  // Alternate input for glitch filter
   		.PULLUP_H(xres_vss_loop),	  // Pullup connection for alternate filter input
		.ENABLE_VDDIO(vccd_const_one[6])
    	);
    `endif //NO_POR_PAD //tony_debug

`ifndef REMOVE_sky130_ef_io__corner_pad //tony_debug
	// Corner cells (These are overlay cells;  it is not clear what is normally
    	// supposed to go under them.)

	    sky130_ef_io__corner_pad mgmt_corner [1:0] (
`ifndef TOP_ROUTING
		.VSSIO(vssio),
		.VDDIO(vddio),
		.VDDIO_Q(vddio_q),
		.VSSIO_Q(vssio_q),
//		.AMUXBUS_A(analog_a),
//		.AMUXBUS_B(analog_b),
		.VSSD(vssd),
		.VSSA(vssa),
		.VSWITCH(vddio),
		.VDDA(vdda),
		.VCCD(vccd),
		.VCCHIB(vccd)
`endif
    	    );
	    sky130_ef_io__corner_pad user1_corner (
`ifndef TOP_ROUTING
		.VSSIO(vssio),
		.VDDIO(vddio),
		.VDDIO_Q(vddio_q),
		.VSSIO_Q(vssio_q),
//		.AMUXBUS_A(analog_a),
//		.AMUXBUS_B(analog_b),
		.VSSD(vssd),
		.VSSA(vssa1),
		.VSWITCH(vddio),
		.VDDA(vdda1),
		.VCCD(vccd),
		.VCCHIB(vccd)
`endif
    	    );
	    sky130_ef_io__corner_pad user2_corner (
`ifndef TOP_ROUTING
		.VSSIO(vssio),
		.VDDIO(vddio),
		.VDDIO_Q(vddio_q),
		.VSSIO_Q(vssio_q),
//		.AMUXBUS_A(analog_a),
//		.AMUXBUS_B(analog_b),
		.VSSD(vssd),
		.VSSA(vssa2),
		.VSWITCH(vddio),
		.VDDA(vdda2),
		.VCCD(vccd),
		.VCCHIB(vccd)
`endif
    	    );
`endif //REMOVE_sky130_ef_io__corner_pad //tony_debug

	mprj_io mprj_pads(
		.vddio(vddio),
		.vssio(vssio),
		.vccd(vccd),
		.vssd(vssd),
		.vdda1(vdda1),
		.vdda2(vdda2),
		.vssa1(vssa1),
		.vssa2(vssa2),
`ifndef REMOVE_sky130_ef_io__corner_pad //tony_debug
		.vddio_q(vddio_q),
		.vssio_q(vssio_q),
`endif //REMOVE_sky130_ef_io__corner_pad //tony_debug
//		.analog_a(analog_a),
//		.analog_b(analog_b),
		.porb_h(porb_h),
		.vccd_conb(mprj_io_one),
		.io(mprj_io),
		.io_out(mprj_io_out),
		.oeb(mprj_io_oeb),
		.enh(mprj_io_enh),
		.inp_dis(mprj_io_inp_dis),
		.ib_mode_sel(mprj_io_ib_mode_sel),
		.vtrip_sel(mprj_io_vtrip_sel),
		.holdover(mprj_io_holdover),
		.slow_sel(mprj_io_slow_sel),
		.analog_en(mprj_io_analog_en),
		.analog_sel(mprj_io_analog_sel),
		.analog_pol(mprj_io_analog_pol),
		.dm(mprj_io_dm),
		.io_in(mprj_io_in)
//		.analog_io(mprj_analog_io)
	);

endmodule
// `default_nettype wire
