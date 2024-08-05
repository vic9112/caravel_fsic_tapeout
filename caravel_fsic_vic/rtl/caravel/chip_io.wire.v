//===========================================================
// Modified by Vic Chen
// July 28, 2024
//===========================================================

// `default_nettype none
module chip_io(
	// Core side (power pad defined at back_end)
    inout wire vddio,
    inout wire vssio,
    inout wire vccd,
    inout wire vssd,
    
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

    //=========================================================//
    // [Vic]: Using Power PADs for ESD protection and clamping //
    //=========================================================//
/*
    powerpad POWERPAD(
        .VDDIO     (vddio),
        .VSSIO     (vssio),
        .VCCD      (vccd),
        .VSSD      (vssd),
        .VDDIO_PAD (vddio_core),
        .VSSIO_PAD (vssio_core),
        .VCCD_PAD  (vccd_core),
        .VSSD_PAD  (vssd_core)
    );
*/
    // To be considered:  Master hold signal on all user pads (?)
    // For now, set holdh_n to 1 internally (NOTE:  This is in the
    // VDDIO 3.3V domain)
    // and setting enh to porb_h.

    wire [`MPRJ_IO_PADS-1:0] mprj_io_enh;

    assign mprj_io_enh = {`MPRJ_IO_PADS{porb_h}};
	

	wire [2:0] dm_all = {gpio_mode1_core, gpio_mode1_core, gpio_mode0_core};
	wire[2:0] flash_io0_mode = {flash_io0_ieb_core, flash_io0_ieb_core, flash_io0_oeb_core};
	wire[2:0] flash_io1_mode = {flash_io1_ieb_core, flash_io1_ieb_core, flash_io1_oeb_core};

    wire [6:0] vccd_const_one;	// Constant value for management pins
    wire [6:0] vssd_const_zero;	// Constant value for management pins

    constant_block constant_value_inst [6:0] (
	    .vccd(vccd),
	    .vssd(vssd),
	    .one (vccd_const_one),
	    .zero(vssd_const_zero)
    );

	// Management clock input pad
    iopad_clk pad_clock (
        `ifndef	TOP_ROUTING
		    .PAD(clock),
	    `endif
		.VDDIO(vddio),
		.VSSIO(vssio),
		.VCCD (vccd),
		.VSSD (vssd),
		.OUT  (vssd_const_zero[0]),
		.DM   ({vssd_const_zero[0], vssd_const_zero[0], vccd_const_one[0]}),
		.IN   (clock_core));

    // Management GPIO pad
    iopad_gpio pad_gpio (
        `ifndef	TOP_ROUTING
		    .PAD(gpio),
	    `endif
		.VDDIO(vddio),
		.VSSIO(vssio),
		.VCCD (vccd),
		.VSSD (vssd),
		.OUT  (gpio_out_core),
		.DM   (dm_all),
		.IN   (gpio_in_core));
    
	// Management Flash SPI pads
    iopad_flash_io0 pad_flash_io0 (
        `ifndef	TOP_ROUTING
		    .PAD(flash_io0),
	    `endif
		.VDDIO(vddio),
		.VSSIO(vssio),
		.VCCD (vccd),
		.VSSD (vssd),
		.OUT  (flash_io0_do_core),
		.DM   (flash_io0_mode),
		.IN   (flash_io0_di_core));
	
    iopad_flash_io1 pad_flash_io1 (
        `ifndef	TOP_ROUTING
		    .PAD(flash_io1),
	    `endif
		.VDDIO(vddio),
		.VSSIO(vssio),
		.VCCD (vccd),
		.VSSD (vssd),
		.OUT  (flash_io1_do_core),
		.DM   (flash_io1_mode),
		.IN   (flash_io1_di_core));

    iopad_flash_csb pad_flash_csb (
        `ifndef	TOP_ROUTING
		    .PAD(flash_csb),
	    `endif
		.VDDIO(vddio),
		.VSSIO(vssio),
		.VCCD (vccd),
		.VSSD (vssd),
		.OUT  (flash_csb_core),
		.DM   ({vccd_const_one[4], vccd_const_one[4], vssd_const_zero[4]}),
		.IN   ());

    iopad_flash_clk pad_flash_clk (
        `ifndef	TOP_ROUTING
		    .PAD(flash_clk),
	    `endif
		.VDDIO(vddio),
		.VSSIO(vssio),
		.VCCD (vccd),
		.VSSD (vssd),
		.OUT  (flash_clk_core),
		.DM   ({vccd_const_one[5], vccd_const_one[5], vssd_const_zero[5]}),
		.IN   ());

	mprj_io mprj_pads(
		.vddio(vddio),
		.vssio(vssio),
		.vccd(vccd),
		.vssd(vssd),
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
	);

endmodule
// `default_nettype wire
