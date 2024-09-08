//===========================================================
// Modified by Vic Chen
// Sep 8, 2024
//===========================================================
// Update:
// 9/8: Add module `pads_config`
//      Add port REN, OEN on module `mprj_io.wire`
//===========================================================


// `default_nettype none
module chip_io(
    inout wire gpio,
    input wire clock,
    input wire resetb,
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
	// [Vic]: PAD IOs should also be flexible              //
    //=========================================================//
    wire [43:0] REN;
    wire [43:0] OEN;
    reg  [43:0] cnfg_io;
    reg  [43:0] cnfg_en;
	pads_config PAD_IO_CNFG(
		.clk(clock_core),
		.resetb(resetb),
		.cnfg_io(cnfg_io),
		.cnfg_en(cnfg_en),
		.re(REN),
		.oe(OEN)
	);

	// TMP: set cnfg signals to 0
	always @(posedge clock_core or negedge resetb) begin
		if (~resetb) begin
			cnfg_io <= 44'd0;
			cnfg_en <= 44'd0;
		end else begin
			cnfg_io <= 44'd0;
			cnfg_en <= 44'd0;
		end
	end
    //=========================================================//

    wire [`MPRJ_IO_PADS-1:0] mprj_io_enh;

    assign mprj_io_enh = {`MPRJ_IO_PADS{porb_h}};
	

	wire [2:0] dm_all = {gpio_mode1_core, gpio_mode1_core, gpio_mode0_core};
	wire[2:0] flash_io0_mode = {flash_io0_ieb_core, flash_io0_ieb_core, flash_io0_oeb_core};
	wire[2:0] flash_io1_mode = {flash_io1_ieb_core, flash_io1_ieb_core, flash_io1_oeb_core};

    wire [6:0] vccd_const_one;	// Constant value for management pins
    wire [6:0] vssd_const_zero;	// Constant value for management pins

    constant_block constant_value_inst [6:0] (
	    .one (vccd_const_one),
	    .zero(vssd_const_zero)
    );

	// Management clock input pad
    iopad_clk pad_clock (
		.PAD  (clock),
	        .REN  (REN[38]),
		.IN   (clock_core));

    iopad_flash_csb pad_flash_csb (
		.PAD  (flash_csb),
		.OUT  (flash_csb_core),
	        .REN  (REN[39]),
	        .OEN  (OEN[39]),
		.IN   ());

    iopad_flash_clk pad_flash_clk (
		.PAD  (flash_clk),
		.OUT  (flash_clk_core),
	        .REN  (REN[40]),
	        .OEN  (OEN[40]),
		.IN   ());
    
	// Management Flash SPI pads
    iopad_flash_io0 pad_flash_io0 (
		.PAD  (flash_io0),
		.OUT  (flash_io0_do_core),
	        .REN  (REN[41]),
	        .OEN  (OEN[41]),
		.IN   (flash_io0_di_core));
	
    iopad_flash_io1 pad_flash_io1 (
		.PAD  (flash_io1),
		.OUT  (flash_io1_do_core),
	        .REN  (REN[42]),
	        .OEN  (OEN[42]),
		.IN   (flash_io1_di_core));

    // Management GPIO pad
    iopad_gpio pad_gpio (
		.PAD  (gpio),
	        .OUT  (gpio_out_core),
	        .REN  (REN[43]),
	        .OEN  (OEN[43]),
		.IN   (gpio_in_core));
	
	mprj_io mprj_pads(
		.REN(REN),
		.OEN(OEN),
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
