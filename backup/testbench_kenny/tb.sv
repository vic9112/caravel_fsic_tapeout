`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2023 11:55:15 AM
// Design Name: 
// Module Name: tb_fsic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//20230804 1. use #0 for create event to avoid potencial race condition. I didn't found issue right now, just update the code to improve it.
//	reference https://blog.csdn.net/seabeam/article/details/41078023, the source is come from http://www.deepchip.com/items/0466-07.html
//	 Not using #0 is a good guideline, except for event data types.  In Verilog, there is no way to defer the event triggering to the nonblocking event queue.


//`define USER_PROJECT_SIDEBAND_SUPPORT 1
//`define USE_EDGEDETECT_IP 1

//`define SYSTEM_test001 1
//`define SYSTEM_test002 1
//`define SYSTEM_test003 1
//`define SYSTEM_test004 1
//`define SYSTEM_test005 1
//`define SYSTEM_test006 1
//`define SYSTEM_test007 1
//`define SYSTEM_test008 1
//`define SYSTEM_test009 1
`define SYSTEM_test010 1



module tb_fsic #( parameter BITS=32,
		`ifdef USER_PROJECT_SIDEBAND_SUPPORT
			parameter pUSER_PROJECT_SIDEBAND_WIDTH   = 5,
			parameter pSERIALIO_WIDTH   = 13,
		`else
			parameter pUSER_PROJECT_SIDEBAND_WIDTH   = 0,
			parameter pSERIALIO_WIDTH   = 12,
		`endif
		parameter pADDR_WIDTH   = 15,
		parameter pDATA_WIDTH   = 32,
		parameter IOCLK_Period	= 10,
		// parameter DLYCLK_Period	= 1,
		parameter SHIFT_DEPTH = 5,
		parameter pRxFIFO_DEPTH = 5,
		parameter pCLK_RATIO = 4
	)
(
);
`ifdef USE_EDGEDETECT_IP
		localparam CoreClkPhaseLoop    = 1;
                localparam TST_TOTAL_FRAME_NUM = 2;
                localparam TST_FRAME_WIDTH     = 640;
                localparam TST_FRAME_HEIGHT    = 360;
                localparam TST_TOTAL_PIXEL_NUM = TST_FRAME_WIDTH * TST_FRAME_HEIGHT;
                localparam TST_SW              = 1;
`else
		localparam CoreClkPhaseLoop	= 4;
`endif
		localparam UP_BASE=32'h3000_0000;
		localparam AA_BASE=32'h3000_2000;
		localparam IS_BASE=32'h3000_3000;

		localparam SOC_to_FPGA_MailBox_Base=28'h000_2000;
		localparam FPGA_to_SOC_UP_BASE=28'h000_0000;
		localparam FPGA_to_SOC_AA_BASE=28'h000_2000;
		localparam FPGA_to_SOC_IS_BASE=28'h000_3000;
		
		localparam AA_MailBox_Reg_Offset=12'h000;
		localparam AA_Internal_Reg_Offset=12'h100;
		
		localparam TUSER_AXIS = 2'b00;
		localparam TUSER_AXILITE_WRITE = 2'b01;
		localparam TUSER_AXILITE_READ_REQ = 2'b10;
		localparam TUSER_AXILITE_READ_CPL = 2'b11;

		localparam TID_DN_UP = 2'b00;
		localparam TID_DN_AA = 2'b01;
		localparam TID_UP_UP = 2'b00;
		localparam TID_UP_AA = 2'b01;
		localparam TID_UP_LA = 2'b10;
`ifdef USE_EDGEDETECT_IP
		localparam fpga_axis_test_length = TST_TOTAL_PIXEL_NUM / 4; //each pixel is 8 bits //each transaction 
`else
		localparam fpga_axis_test_length = 16;
`endif		
		localparam BASE_OFFSET = 8;
		localparam RXD_OFFSET = BASE_OFFSET;
		localparam RXCLK_OFFSET = RXD_OFFSET + pSERIALIO_WIDTH;
		localparam TXD_OFFSET = RXCLK_OFFSET + 1;
		localparam TXCLK_OFFSET = TXD_OFFSET + pSERIALIO_WIDTH;
		localparam IOCLK_OFFSET = TXCLK_OFFSET + 1;
		localparam TXRX_WIDTH = IOCLK_OFFSET - BASE_OFFSET + 1;
		
    real ioclk_pd = IOCLK_Period;

  wire           wb_rst;
  wire           wb_clk;
  reg   [31: 0] wbs_adr;
  reg   [31: 0] wbs_wdata;
  reg    [3: 0] wbs_sel;
  reg           wbs_cyc;
  reg           wbs_stb;
  reg           wbs_we;
  reg  [127: 0] la_data_in;
  reg  [127: 0] la_oenb;
  wire   [37: 0] io_in;
  `ifdef USE_POWER_PINS
  reg           vccd1;
  reg           vccd2;
  reg           vssd1;
  reg           vssd2;
  `endif //USE_POWER_PINS
  reg           user_clock2;
	
	wire  [37: 0] io_oeb;	
	wire  [37: 0] io_out;	
	
	wire soc_coreclk;
	wire fpga_coreclk;
	
	wire [37:0] mprj_io;
	wire  [127: 0] la_data_out;
	wire    [2: 0] user_irq;
	
//-------------------------------------------------------------------------------------

	reg[31:0] i;
	
	reg[31:0] cfg_read_data_expect_value;
	reg[31:0] cfg_read_data_captured;
	event soc_cfg_read_event;
	
	reg[27:0] soc_to_fpga_mailbox_write_addr_expect_value;
	reg[3:0] soc_to_fpga_mailbox_write_addr_BE_expect_value;
	reg[31:0] soc_to_fpga_mailbox_write_data_expect_value;
	reg [31:0] soc_to_fpga_mailbox_write_addr_captured;
	reg [31:0] soc_to_fpga_mailbox_write_data_captured;
	event soc_to_fpga_mailbox_write_event;

    reg stream_data_addr_or_data; //0: address, 1: data, use to identify the write transaction from AA.

	reg [31:0] soc_to_fpga_axilite_read_cpl_expect_value;
	reg [31:0] soc_to_fpga_axilite_read_cpl_captured;
	event soc_to_fpga_axilite_read_cpl_event;

	event aa_axis_event;
	event la_axis_event;
	event soc_to_fpga_axis_event;

	reg [31:0] soc_to_fpga_axis_captured_count;
	reg [31:0] soc_to_fpga_axis_expect_count;

	`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		reg [(pUSER_PROJECT_SIDEBAND_WIDTH+4+4+1+32-1):0] soc_to_fpga_axis_expect_value[fpga_axis_test_length-1:0];
	`else
		reg [(4+4+1+32-1):0] soc_to_fpga_axis_expect_value[fpga_axis_test_length-1:0];
	`endif
        
	`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		reg [(pUSER_PROJECT_SIDEBAND_WIDTH+4+4+1+32-1):0] soc_to_fpga_axis_captured[fpga_axis_test_length-1:0];
	`else
		reg [(4+4+1+32-1):0] soc_to_fpga_axis_captured[fpga_axis_test_length:0];
	`endif

	reg [31:0] error_cnt;
	reg [31:0] check_cnt;

	reg [31:0] start_test;
	reg seed;
//-------------------------------------------------------------------------------------	
	//reg soc_rst;
	reg fpga_rst;
	reg soc_resetb;		//POR reset
	reg fpga_resetb;	//POR reset	
	
	//reg ioclk;
	//reg dlyclk;


	//write addr channel
	reg fpga_axi_awvalid;
	reg [pADDR_WIDTH-1:0] fpga_axi_awaddr;
	wire fpga_axi_awready;
	
	//write data channel
	reg 	fpga_axi_wvalid;
	reg 	[pDATA_WIDTH-1:0] fpga_axi_wdata;
	reg 	[3:0] fpga_axi_wstrb;
	wire	fpga_axi_wready;
	
	//read addr channel
	reg 	fpga_axi_arvalid;
	reg 	[pADDR_WIDTH-1:0] fpga_axi_araddr;
	wire 	fpga_axi_arready;
	
	//read data channel
	wire 	fpga_axi_rvalid;
	wire 	[pDATA_WIDTH-1:0] fpga_axi_rdata;
	reg 	fpga_axi_rready;
	
	reg 	fpga_cc_is_enable;		//axi_lite enable

	wire [pSERIALIO_WIDTH-1:0] soc_serial_txd;
	wire soc_txclk;
	wire fpga_txclk;
	
	reg [pDATA_WIDTH-1:0] fpga_as_is_tdata;
	`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		reg 	[pUSER_PROJECT_SIDEBAND_WIDTH-1:0] fpga_as_is_tupsb;
	`endif
	reg [3:0] fpga_as_is_tstrb;
	reg [3:0] fpga_as_is_tkeep;
	reg fpga_as_is_tlast;
	reg [1:0] fpga_as_is_tid;
	reg fpga_as_is_tvalid;
	reg [1:0] fpga_as_is_tuser;
	reg fpga_as_is_tready;		//when local side axis switch Rxfifo size <= threshold then as_is_tready=0; this flow control mechanism is for notify remote side do not provide data with is_as_tvalid=1

	wire [pSERIALIO_WIDTH-1:0] fpga_serial_txd;
//	wire [7:0] fpga_Serial_Data_Out_tdata;
//	wire fpga_Serial_Data_Out_tstrb;
//	wire fpga_Serial_Data_Out_tkeep;
//	wire fpga_Serial_Data_Out_tid_tuser;	// tid and tuser	
//	wire fpga_Serial_Data_Out_tlast_tvalid_tready;		//flowcontrol

	wire [pDATA_WIDTH-1:0] fpga_is_as_tdata;
	`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		wire 	[pUSER_PROJECT_SIDEBAND_WIDTH-1:0] fpga_is_as_tupsb;
	`endif
	wire [3:0] fpga_is_as_tstrb;
	wire [3:0] fpga_is_as_tkeep;
	wire fpga_is_as_tlast;
	wire [1:0] fpga_is_as_tid;
	wire fpga_is_as_tvalid;
	wire [1:0] fpga_is_as_tuser;
	wire fpga_is_as_tready;		//when remote side axis switch Rxfifo size <= threshold then is_as_tready=0, this flow control mechanism is for notify local side do not provide data with as_is_tvalid=1

	wire	wbs_ack;
	wire	[pDATA_WIDTH-1: 0] wbs_rdata;

	//wire [7:0] Serial_Data_Out_ad_delay1;
	//wire txclk_delay1;

	//wire [7:0] Serial_Data_Out_ad_delay;
	//wire txclk_delay;

	//assign #4 Serial_Data_Out_ad_delay1 = Serial_Data_Out_ad;
	//assign #4 txclk_delay1 = txclk;
	//assign #4 Serial_Data_Out_ad_delay = Serial_Data_Out_ad_delay1;
	//assign #4 txclk_delay = txclk_delay1;

//-------------------------------------------------------------------------------------	
//remove fpga_clock_div, it is for control clock phase of fpga_coreclk relative to ioclk.                          
//to avoid post simulation report error when fpga_coreclk and soc_coreclk with phase different in ioclk.
//set fpga_coreclk = clock = soc_coreclk	
	
	// fsic_clock_div soc_clock_div (
	// .resetb(soc_resetb),
	// .in clock),
	// .out(soc_coreclk)
	// );

	// fsic_clock_div fpga_clock_div (
	// .resetb(fpga_resetb),
	// .in clock),
	// .out(fpga_coreclk)
	// );
  reg clock;
  reg io_clk;   // generated from FPGA in real system

  localparam pSOC_FREQ = 10.0;                 // 10 MHz
  localparam pIOS_FREQ = (pSOC_FREQ * 4.0);    // 40 MHz

  // Timing Order
  // POWER ==> CLOCK ==> RESET

  initial begin
    clock  = 1;
    //wait(power2);
    //#100;
    forever begin
      #(500.0 / pSOC_FREQ);
      clock = ~clock;
    end
  end

    initial begin
    io_clk  = 1;
    //wait(power2);
    //#100;
    forever begin
      #(500.0 / pIOS_FREQ);
      io_clk = ~io_clk;
    end
  end

assign fpga_coreclk = clock;
assign soc_coreclk = clock;

wire ioclk;
assign ioclk = io_clk;


	FSIC #(
		.BITS(BITS),
		.pUSER_PROJECT_SIDEBAND_WIDTH(pUSER_PROJECT_SIDEBAND_WIDTH),
		`ifdef USER_PROJECT_SIDEBAND_SUPPORT
			.pSERIALIO_WIDTH(13),
		`else
			.pSERIALIO_WIDTH(12),
		`endif
		.pADDR_WIDTH(pADDR_WIDTH),
		.pDATA_WIDTH(pDATA_WIDTH),
		.pRxFIFO_DEPTH(pRxFIFO_DEPTH),
		.pCLK_RATIO(pCLK_RATIO)
	)
	dut (
		.wb_rst(wb_rst),
		.wb_clk(wb_clk),
		.wbs_adr(wbs_adr),
		.wbs_wdata(wbs_wdata),
		.wbs_sel(wbs_sel),
		.wbs_cyc(wbs_cyc),
		.wbs_stb(wbs_stb),
		.wbs_we(wbs_we),
		.io_in(io_in),
        `ifdef USE_POWER_PINS        
		    .vccd1(vccd1),
		    .vccd2(vccd2),
		    .vssd1(vssd1),
		    .vssd2(vssd2),
        `endif //USE_POWER_PINS        
		.wbs_ack(wbs_ack),
		.wbs_rdata(wbs_rdata),		
		.user_irq(user_irq),
		.io_out(io_out),
		.io_oeb(io_oeb),
		.user_clock2(user_clock2)
	);

	fpga  #(
		.pUSER_PROJECT_SIDEBAND_WIDTH(pUSER_PROJECT_SIDEBAND_WIDTH),
		.pSERIALIO_WIDTH(pSERIALIO_WIDTH),
		.pADDR_WIDTH(pADDR_WIDTH),
		.pDATA_WIDTH(pDATA_WIDTH),
		.pRxFIFO_DEPTH(pRxFIFO_DEPTH),
		.pCLK_RATIO(pCLK_RATIO)
	)
	fpga_fsic(
		.axis_rst_n(~fpga_rst),
		.axi_reset_n(~fpga_rst),
		.serial_tclk(fpga_txclk),
		.serial_rclk(soc_txclk),
		.ioclk (ioclk),
		.axis_clk(fpga_coreclk),
		.axi_clk(fpga_coreclk),
		
		//write addr channel
		.axi_awvalid_s_awvalid(fpga_axi_awvalid),
		.axi_awaddr_s_awaddr(fpga_axi_awaddr),
		.axi_awready_axi_awready3(fpga_axi_awready),

		//write data channel
		.axi_wvalid_s_wvalid(fpga_axi_wvalid),
		.axi_wdata_s_wdata(fpga_axi_wdata),
		.axi_wstrb_s_wstrb(fpga_axi_wstrb),
		.axi_wready_axi_wready3(fpga_axi_wready),

		//read addr channel
		.axi_arvalid_s_arvalid(fpga_axi_arvalid),
		.axi_araddr_s_araddr(fpga_axi_araddr),
		.axi_arready_axi_arready3(fpga_axi_arready),
		
		//read data channel
		.axi_rvalid_axi_rvalid3(fpga_axi_rvalid),
		.axi_rdata_axi_rdata3(fpga_axi_rdata),
		.axi_rready_s_rready(fpga_axi_rready),
		
		.cc_is_enable(fpga_cc_is_enable),


		.as_is_tdata(fpga_as_is_tdata),
		`ifdef USER_PROJECT_SIDEBAND_SUPPORT
			.as_is_tupsb(fpga_as_is_tupsb),
		`endif
		.as_is_tstrb(fpga_as_is_tstrb),
		.as_is_tkeep(fpga_as_is_tkeep),
		.as_is_tlast(fpga_as_is_tlast),
		.as_is_tid(fpga_as_is_tid),
		.as_is_tvalid(fpga_as_is_tvalid),
		.as_is_tuser(fpga_as_is_tuser),
		.as_is_tready(fpga_as_is_tready),
		.serial_txd(fpga_serial_txd),
		.serial_rxd(soc_serial_txd),
		.is_as_tdata(fpga_is_as_tdata),
		`ifdef USER_PROJECT_SIDEBAND_SUPPORT
			.is_as_tupsb(fpga_is_as_tupsb),
		`endif
		.is_as_tstrb(fpga_is_as_tstrb),
		.is_as_tkeep(fpga_is_as_tkeep),
		.is_as_tlast(fpga_is_as_tlast),
		.is_as_tid(fpga_is_as_tid),
		.is_as_tvalid(fpga_is_as_tvalid),
		.is_as_tuser(fpga_is_as_tuser),
		.is_as_tready(fpga_is_as_tready)
	);

	assign wb_clk = soc_coreclk;
	assign wb_rst = ~soc_resetb;		//wb_rst is high active
	//assign ioclk = clock;
	
    assign mprj_io[IOCLK_OFFSET] = io_clk;
    assign mprj_io[RXCLK_OFFSET] = fpga_txclk;
    assign mprj_io[RXD_OFFSET +: pSERIALIO_WIDTH] = fpga_serial_txd;

    assign soc_txclk = mprj_io[TXCLK_OFFSET];
    assign soc_serial_txd = mprj_io[TXD_OFFSET +: pSERIALIO_WIDTH];

	//connect input part : mprj_io to io_in
	assign io_in[IOCLK_OFFSET] = mprj_io[IOCLK_OFFSET];
	assign io_in[RXCLK_OFFSET] = mprj_io[RXCLK_OFFSET];
	assign io_in[RXD_OFFSET +: pSERIALIO_WIDTH] = mprj_io[RXD_OFFSET +: pSERIALIO_WIDTH];

	//connect output part : io_out to mprj_io
	assign mprj_io[TXCLK_OFFSET] = io_out[TXCLK_OFFSET];
	assign mprj_io[TXD_OFFSET +: pSERIALIO_WIDTH] = io_out[TXD_OFFSET +: pSERIALIO_WIDTH];
    // generate vcd
    initial begin
        $dumpfile("caravel_fsic.vcd");
        $dumpvars(0,tb_fsic);
    end
    
    initial begin
	 	clock=0;
        soc_resetb = 0;
		wbs_adr = 0;
		wbs_wdata = 0;
		wbs_sel = 0;
		wbs_cyc = 0;
		wbs_stb = 0;
		wbs_we = 0;
		la_data_in = 0;
		la_oenb = 0;
        `ifdef USE_POWER_PINS
    		vccd1 = 1;
	    	vccd2 = 1;
    		vssd1 = 1;
	    	vssd2 = 1;
        `endif //USE_POWER_PINS    
		user_clock2 = 0;
		error_cnt = 0;
		check_cnt = 0;
		start_test = 0;
		seed = 1;
		
        fsic_system_initial();// initial whole system            
                
        `ifdef SYSTEM_test001
		test001();
        `endif

        `ifdef SYSTEM_test002
		test002();
        `endif

        `ifdef SYSTEM_test003
		test003();
        `endif

        `ifdef SYSTEM_test004
		test004();
        `endif

        `ifdef SYSTEM_test005
		test005();
        `endif

        `ifdef SYSTEM_test006
		test006();
		`endif

        `ifdef SYSTEM_test007
        test007();
        `endif

        `ifdef SYSTEM_test008
        test008();
        `endif

		`ifdef SYSTEM_test009
        test008();
        `endif

		`ifdef SYSTEM_test010
        test010();
        `endif

		#400;
		$display("=============================================================================================");

		if (error_cnt != 0 )  begin 
			$display($time, "=> Final result [FAILED], error_cnt = %04d, please search [ERROR] in the log", error_cnt);
		end
		else
			$display($time, "=> Final result [PASS], error_cnt = %04d", error_cnt);
		$display("=============================================================================================");
		$finish;
        
    end
    
    
    
	//WB Master wb_ack_o handling
	always @( posedge wb_clk or posedge wb_rst) begin
		if ( wb_rst ) begin
			wbs_adr <= 32'h0;
			wbs_wdata <= 32'h0;
			wbs_sel <= 4'b0;
			wbs_cyc <= 1'b0;
			wbs_stb <= 1'b0;
			wbs_we <= 1'b0;			
		end else begin 
			if ( wbs_ack ) begin
				wbs_adr <= 32'h0;
				wbs_wdata <= 32'h0;
				wbs_sel <= 4'b0;
				wbs_cyc <= 1'b0;
				wbs_stb <= 1'b0;
				wbs_we <= 1'b0;
			end
		end
	end    
	
        task fsic_system_initial;
           begin
            fork 
                soc_apply_reset(40, 40);			//change coreclk phase in soc
                fpga_apply_reset(40, 40);		//fix coreclk phase in fpga
            join
            #40;
            fpga_as_to_is_init();
    
            fpga_cc_is_enable=1;
            fork 
                soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
                fpga_cfg_write(0,1,1,0);
            join
            $display($time, "=> soc rxen_ctl=1");
            $display($time, "=> fpga rxen_ctl=1");

            #400;
            fork 
                soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
                fpga_cfg_write(0,3,1,0);
            join
           end   
        endtask
        
        
        task soc_cfg_write;
		input [31:0] adr;		//4K range
		input [3:0] sel;
		input [31:0] data;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= adr;				
			wbs_wdata <= data;
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b1;	

			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end

			$display($time, "=> soc_cfg_write : wbs_adr=%x, wbs_sel=%b, wbs_wdata=%x", wbs_adr, wbs_sel, wbs_wdata); 
		end
	endtask
	
	
	
	task fpga_to_soc_cfg_write;
	   input [27:0]addr;
	   input [31:0]data;
	   begin
	   @ (posedge fpga_coreclk);
			fpga_axilite_write_req(addr, 4'b0001, data);
				//write address = h0000_2100 ~ h0000_2FFF for AA internal register
			//step 3. fpga wait for write to soc
			repeat(100) @ (posedge soc_coreclk);    //TODO fpga wait for write to soc	   
	   end
	endtask
     
	task test001;
		begin
			$display("test001: soc cfg write/read test");

			test001_is_soc_cfg();
			test001_aa_internal_soc_cfg();
			test001_up_soc_cfg();
		end
	endtask

	task test001_is_soc_cfg;
		begin
			//Test offset 0x00 only for io serdes
			$display("test001_is_soc_cfg: IS cfg read/write test");

			cfg_read_data_expect_value = 32'h01;	
			soc_is_cfg_write(0, 4'b0001, cfg_read_data_expect_value);				//ioserdes rxen
			soc_is_cfg_read(0, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test001_is_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
			end	
			else
				$display($time, "=> test001_is_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");

			cfg_read_data_expect_value = 32'h03;	
			soc_is_cfg_write(0, 4'b0001, cfg_read_data_expect_value);				//ioserdes rxen
			soc_is_cfg_read(0, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test001_is_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
			end	
			else
				$display($time, "=> test001_is_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");
			$display("test001_is_soc_cfg: IS cfg read/write test - end");
			$display("--------------------------------------------------------------------");

			#100;
		end
	endtask

	task test001_aa_internal_soc_cfg;
		begin

			//Test offset 0x100~0xfff for AA internal register 
			$display("test001_aa_internal_soc_cfg: AA internal register read/write test - start");

			cfg_read_data_expect_value = 	32'h1;	
			soc_aa_cfg_write(AA_Internal_Reg_Offset, 4'b1111, cfg_read_data_expect_value);				
			soc_aa_cfg_read(AA_Internal_Reg_Offset, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test001_aa_internal_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
				end	
			else
				$display($time, "=> test001_aa_internal_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");

			cfg_read_data_expect_value = 	32'h0;	
			soc_aa_cfg_write(AA_Internal_Reg_Offset + 4, 4'b1111, cfg_read_data_expect_value);				
			soc_aa_cfg_read(AA_Internal_Reg_Offset + 4, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test001_aa_internal_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
				end	
			else
				$display($time, "=> test001_aa_internal_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");


			$display("test001_aa_internal_soc_cfg: AA internal reg read/write test - end");
			$display("--------------------------------------------------------------------");

			#100;
		end
	endtask

	task test001_up_soc_cfg;
		begin
			$display("test001_up_soc_cfg: UP cfg read/write test - start");

			cfg_read_data_expect_value = 	32'h0000_005a;	
			soc_up_cfg_write(0, 4'b1111, cfg_read_data_expect_value);				
			soc_up_cfg_read(0, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test001_up_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
				end	
			else
				$display($time, "=> test001_up_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");

			$display("test001_up_soc_cfg: UP cfg read/write test - end");
			$display("--------------------------------------------------------------------");

			#100;

		end
	endtask 

	task test002;
		//input [7:0] compare_data;

		begin
			$display("test002: fpga_cfg_read test");

			test002_fpga_to_soc_cfg_read();
		end
	endtask

	reg[31:0]idx2;

	task test002_fpga_to_soc_cfg_read;		
		//input [7:0] compare_data;

		//FPGA to SOC Axilite test
		begin

		// to io serdes

			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;

			fpga_axilite_write(FPGA_to_SOC_IS_BASE, 4'b1111, 32'h0000_0002);
			// IS module only provide first two bit at address 3000 for cfg read and write
			@(posedge fpga_coreclk);
			fpga_as_is_tready <= 1;

			soc_to_fpga_axilite_read_cpl_expect_value = 32'h0000_0002;

			fpga_axilite_read_req(FPGA_to_SOC_IS_BASE);
			//step 2. fpga wait for read completion from soc
			$display($time, "=> test002_fpga_to_soc_cfg_read :wait for soc_to_fpga_axilite_read_cpl_event");
			@(soc_to_fpga_axilite_read_cpl_event);		//wait for fpga get the read cpl.
			$display($time, "=> test002_fpga_to_soc_cfg_read : got soc_to_fpga_axilite_read_cpl_event");

			$display($time, "=> test002_fpga_to_soc_cfg_read : soc_to_fpga_axilite_read_cpl_captured=%x", soc_to_fpga_axilite_read_cpl_captured);

			//Data part
			check_cnt = check_cnt + 1;
			if ( soc_to_fpga_axilite_read_cpl_expect_value !== soc_to_fpga_axilite_read_cpl_captured) begin
				$display($time, "=> test002_fpga_to_soc_cfg_read [ERROR] soc_to_fpga_axilite_read_cpl_expect_value=%x, soc_to_fpga_axilite_read_cpl_captured[27:0]=%x", soc_to_fpga_axilite_read_cpl_expect_value, soc_to_fpga_axilite_read_cpl_captured[27:0]);
				error_cnt = error_cnt + 1;
			end	
			else
				$display($time, "=> test002_fpga_to_soc_cfg_read [PASS] soc_to_fpga_axilite_read_cpl_expect_value=%x, soc_to_fpga_axilite_read_cpl_captured[27:0]=%x", soc_to_fpga_axilite_read_cpl_expect_value, soc_to_fpga_axilite_read_cpl_captured[27:0]);

		// to user project

			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;

			fpga_axilite_write(FPGA_to_SOC_UP_BASE , 4'b1111, 32'h0000_005A);
			// my user project provides bit 0~7 at address 0000 for cfg read and write
			@(posedge fpga_coreclk);
			fpga_as_is_tready <= 1;

			soc_to_fpga_axilite_read_cpl_expect_value = 32'h0000_005A;

			fpga_axilite_read_req(FPGA_to_SOC_UP_BASE);
			//step 2. fpga wait for read completion from soc
			$display($time, "=> test002_fpga_to_soc_cfg_read :wait for soc_to_fpga_axilite_read_cpl_event");
			@(soc_to_fpga_axilite_read_cpl_event);		//wait for fpga get the read cpl.
			$display($time, "=> test002_fpga_to_soc_cfg_read : got soc_to_fpga_axilite_read_cpl_event");

			$display($time, "=> test002_fpga_to_soc_cfg_read : soc_to_fpga_axilite_read_cpl_captured=%x", soc_to_fpga_axilite_read_cpl_captured);

			//Data part
			check_cnt = check_cnt + 1;
			if ( soc_to_fpga_axilite_read_cpl_expect_value !== soc_to_fpga_axilite_read_cpl_captured) begin
				$display($time, "=> test002_fpga_to_soc_cfg_read [ERROR] soc_to_fpga_axilite_read_cpl_expect_value=%x, soc_to_fpga_axilite_read_cpl_captured[27:0]=%x", soc_to_fpga_axilite_read_cpl_expect_value, soc_to_fpga_axilite_read_cpl_captured[27:0]);
				error_cnt = error_cnt + 1;
			end	
			else
				$display($time, "=> test002_fpga_to_soc_cfg_read [PASS] soc_to_fpga_axilite_read_cpl_expect_value=%x, soc_to_fpga_axilite_read_cpl_captured[27:0]=%x", soc_to_fpga_axilite_read_cpl_expect_value, soc_to_fpga_axilite_read_cpl_captured[27:0]);


		// to aa internal register

			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;

			fpga_axilite_write(FPGA_to_SOC_AA_BASE + AA_Internal_Reg_Offset, 4'b1111, 32'h0000_0001);
			// AA module aa_reg provides bit 0 at address 2100 to Enable Interrupt
			@(posedge fpga_coreclk);
			fpga_as_is_tready <= 1;

			cfg_read_data_expect_value = 32'h0000_0001;

			soc_aa_cfg_read(AA_Internal_Reg_Offset, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test002_aa_internal_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
				end	
			else
				$display($time, "=> test002_aa_internal_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");


			$display("test002_aa_internal_soc_cfg: AA internal reg read/write test - end");
			$display("--------------------------------------------------------------------");

			$display($time, "=> test002_fpga_to_soc_cfg_test done");

			#1000;

		end
	endtask

	task test003;
		begin
			$display("test003: concurrent test");

			fork
				test003_fpga_con_rw();
				test003_soc_con_rw();
			join
		end
	endtask

	reg [31:0] delay1;
	reg [31:0] delay2;

	task test003_fpga_con_rw;
		begin
			fpga_axilite_write(FPGA_to_SOC_IS_BASE, 4'b1111, 32'h3a3a_3a3a);

			delay1 = {$random}%500;
			#delay1;

			fpga_axilite_write(FPGA_to_SOC_UP_BASE, 4'b1111, 32'h3a3a_3a3a);

			delay1 = {$random}%500;
			#delay1;

			fpga_axilite_write(FPGA_to_SOC_AA_BASE + AA_MailBox_Reg_Offset, 4'b1111, 1'b0);

			delay1 = {$random}%500;
			#delay1;
			
			fpga_axilite_read_req(FPGA_to_SOC_IS_BASE);
			@(soc_to_fpga_axilite_read_cpl_event);
			$display($time, "=> test003_fpga_to_soc_cfg_read : soc_to_fpga_axilite_read_cpl_captured=%x", soc_to_fpga_axilite_read_cpl_captured);

			delay1 = {$random}%500;
			#delay1;

			fpga_axilite_read_req(FPGA_to_SOC_UP_BASE);
			@(soc_to_fpga_axilite_read_cpl_event);
			$display($time, "=> test003_fpga_to_soc_cfg_read : soc_to_fpga_axilite_read_cpl_captured=%x", soc_to_fpga_axilite_read_cpl_captured);
		end
	endtask

	task test003_soc_con_rw;
		begin
			soc_aa_cfg_write(SOC_to_FPGA_MailBox_Base, 4'b0001, 1'd0);

			delay2 = {$random}%500;
			#delay2;

			soc_aa_cfg_read(0, 4'b1111);

			delay2 = {$random}%500;
			#delay2;

			soc_aa_cfg_write(SOC_to_FPGA_MailBox_Base, 4'b1111, 1'd1);

			delay2 = {$random}%500;
			#delay2;

			soc_aa_cfg_read(0, 4'b1111);

			cfg_read_data_expect_value = 1'd1;

			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test003_aa_internal_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
				end	
			else
				$display($time, "=> test003_aa_internal_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");
		end
	endtask

	// soc write mailbox and fpga read mailbox
	// fpga write mailbox and soc read mailbox
	task test004;
		begin
			$display("test004: mailbox test 1");

			test004_mailbox_test_1();
		end
	endtask

	task test004_mailbox_test_1;
		begin
			for(i = 0; i < 8; i = i + 1) begin
				fpga_axilite_write(FPGA_to_SOC_AA_BASE + AA_MailBox_Reg_Offset, 4'b1111, i);

				soc_aa_cfg_read(AA_MailBox_Reg_Offset, 4'b1111);
				cfg_read_data_expect_value = i;

				if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
					$display($time, "=> test004_aa_internal_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
					error_cnt = error_cnt + 1;
					end	
				else
					$display($time, "=> test004_aa_internal_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				
				soc_aa_cfg_write(AA_MailBox_Reg_Offset, 4'b1111, i + 1);


				@(soc_to_fpga_mailbox_write_event);


				soc_to_fpga_mailbox_write_data_expect_value = i + 1;
				if ( soc_to_fpga_mailbox_write_data_expect_value !== soc_to_fpga_mailbox_write_data_captured) begin
					$display($time, "=> test004_fpga_to_soc_mailbox_read [ERROR] soc_to_fpga_mailbox_write_data_expect_value=%x, soc_to_fpga_mailbox_write_data_captured[27:0]=%x", soc_to_fpga_mailbox_write_data_expect_value, soc_to_fpga_mailbox_write_data_captured[27:0]);
					error_cnt = error_cnt + 1;
				end	
				else
					$display($time, "=> test004_fpga_to_soc_mailbox_read [PASS] soc_to_fpga_mailbox_write_data_expect_value=%x, soc_to_fpga_mailbox_write_data_captured[27:0]=%x", soc_to_fpga_mailbox_write_data_expect_value, soc_to_fpga_mailbox_write_data_captured[27:0]);
			end
			
		end
	endtask

	// fpga write and read mailbox and check correctness
	// soc write and read mailbox and check correctness
	task test005;
		begin
			$display("test005: mailbox test 2");

			test005_mailbox_test_2();
		end
	endtask

	task test005_mailbox_test_2;
	begin
		// fpga_axilite_write(FPGA_to_SOC_AA_BASE + AA_MailBox_Reg_Offset, 4'b1111, 32'h5a5a_5a5a);

		soc_aa_cfg_write(AA_MailBox_Reg_Offset, 4'b1111, 32'h5a5a_5a5a);

		@(soc_to_fpga_mailbox_write_event);


		soc_to_fpga_mailbox_write_data_expect_value = 32'h5a5a_5a5a;
		if ( soc_to_fpga_mailbox_write_data_expect_value !== soc_to_fpga_mailbox_write_data_captured) begin
			$display($time, "=> test005_fpga_to_soc_mailbox_read [ERROR] soc_to_fpga_mailbox_write_data_expect_value=%x, soc_to_fpga_mailbox_write_data_captured[27:0]=%x", soc_to_fpga_mailbox_write_data_expect_value, soc_to_fpga_mailbox_write_data_captured[27:0]);
			error_cnt = error_cnt + 1;
		end	
		else
			$display($time, "=> test005_fpga_to_soc_mailbox_read [PASS] soc_to_fpga_mailbox_write_data_expect_value=%x, soc_to_fpga_mailbox_write_data_captured[27:0]=%x", soc_to_fpga_mailbox_write_data_expect_value, soc_to_fpga_mailbox_write_data_captured[27:0]);


		soc_aa_cfg_write(AA_MailBox_Reg_Offset, 4'b1111, 32'h3a3a_3a3a);
		
		soc_aa_cfg_read(AA_MailBox_Reg_Offset, 4'b1111);
		cfg_read_data_expect_value = 32'h3a3a_3a3a;

		if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
			$display($time, "=> test005_aa_internal_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			error_cnt = error_cnt + 1;
		end	
		else
			$display($time, "=> test005_aa_internal_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
	end			
	endtask

	// user project loop back test
	task test006;
		begin
			$display("test006: user project loop back test");

			soc_cfg_write(32'h3000_5000, 4'b1111, 4'd0); // enable user project 0

			test006_up_loop_test();
		end
	endtask

	task test006_up_loop_test;
		begin

			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;
			
			for(i = 0; i < 16; i = i + 1)begin		
				fpga_axis_req(((i << 4) | 32'h0000_000F), TID_DN_UP, 0);		//target to user project
			end
			
			$display($time, "=> test006_fpga_axis_req done");

			@(soc_to_fpga_axis_event);

			$display($time, "=> test006 finish");
		end
	endtask

	// user DMA and user project configuration rw concurrent test
	task test007;
		begin
			$display("test007: up concurrent test");

			test007_up_concurrent_test();
		end
	endtask

	task test007_up_concurrent_test;

	endtask

	task test008;
		begin
			$display("test008: up downstream test 1");

			soc_cfg_write(32'h3000_5000, 4'b1111, 4'd1); // enable user project 1

			test008_up_downstream_test();
		end
	endtask

	task test008_up_downstream_test;
	begin
		@ (posedge fpga_coreclk);
		fpga_as_is_tready <= 1;

		soc_up_cfg_write(0, 4'b1111, 32'h0000_0001); // write ap start
			
		for(i = 0; i < 40; i = i + 1)begin		
			fpga_axis_req(i, TID_DN_UP, 0);		//target to user project
		end

		$display($time, "=> test008_fpga_axis_req done");

		repeat(150) @(posedge fpga_coreclk);

		cfg_read_data_expect_value = 32'h0000_0004;
		soc_up_cfg_read(0, 4'b1111); // read ap done

		check_cnt = check_cnt + 1;
		if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
			$display($time, "=> test008_up_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			error_cnt = error_cnt + 1;
			end	
		else
			$display($time, "=> test008_up_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
		$display("-----------------");

		$display("test008_up_downstream_test: UP downstream test - end");
		$display("--------------------------------------------------------------------");

		#100;
	end
	endtask

	task test010;
		begin
			$display("test010: integrated upstream test");

			soc_cfg_write(32'h3000_5000, 4'b1111, 4'd3); // enable user project 3
			soc_cfg_write(32'h3000_1000, 4'b1111, 1); // enable la module
			soc_cfg_write(32'h3000_2000, 4'b1111, 1); // enable aa module


			test010_integrated_test_upstream();
		end
	endtask

	task test010_integrated_test_upstream;
		begin
			soc_up_cfg_write(0, 4'b1111, 32'h0000_0001); // write ap start

			fpga_as_is_tready <= 1;

			fork
				@(soc_to_fpga_axis_event);
				@(la_axis_event);
			join

			cfg_read_data_expect_value = 32'h0000_0004;
			soc_up_cfg_read(0, 4'b1111); // read ap done

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test010_up_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
				end	
			else
				$display($time, "=> test010_up_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");

			$display("test010_integrated_test_upstream - end");
			$display("--------------------------------------------------------------------");

			#100;

		end
	endtask

	

	initial begin		//get soc wishbone read data result.
		while (1) begin
			@(posedge soc_coreclk);
			if (wbs_ack==1 && wbs_we == 0) begin
				//$display($time, "=> get wishbone read data result be : cfg_read_data_captured =%x, wbs_rdata=%x", cfg_read_data_captured, wbs_rdata);
				cfg_read_data_captured = wbs_rdata ;		//use block assignment
				//$display($time, "=> get wishbone read data result af : cfg_read_data_captured =%x, wbs_rdata=%x", cfg_read_data_captured, wbs_rdata);
				#0 -> soc_cfg_read_event;
				$display($time, "=> soc wishbone read data result : send soc_cfg_read_event"); 
			end	
		end
	end


	initial begin		//when soc cfg write to AA, then AA in soc generate soc_to_fpga_mailbox_write, 
	   stream_data_addr_or_data = 0;
		while (1) begin
			@(posedge fpga_coreclk);
			//New AA version, all stream data with last = 1.  
			if (fpga_is_as_tvalid == 1 && fpga_is_as_tid == TID_UP_AA && fpga_is_as_tuser == TUSER_AXILITE_WRITE && fpga_is_as_tlast == 1) begin
			
                if(stream_data_addr_or_data == 1'b0) begin
                    //Address
                    $display($time, "=> get soc_to_fpga_mailbox_write_addr_captured be : soc_to_fpga_mailbox_write_addr_captured =%x, fpga_is_as_tdata=%x", soc_to_fpga_mailbox_write_addr_captured, fpga_is_as_tdata);
                    soc_to_fpga_mailbox_write_addr_captured = fpga_is_as_tdata ;		//use block assignment
                    $display($time, "=> get soc_to_fpga_mailbox_write_addr_captured af : soc_to_fpga_mailbox_write_addr_captured =%x, fpga_is_as_tdata=%x", soc_to_fpga_mailbox_write_addr_captured, fpga_is_as_tdata);
                    //Next should be data
                    stream_data_addr_or_data = 1; 
                end else begin
                    //Data
                    $display($time, "=> get soc_to_fpga_mailbox_write_data_captured be : soc_to_fpga_mailbox_write_data_captured =%x, fpga_is_as_tdata=%x", soc_to_fpga_mailbox_write_data_captured, fpga_is_as_tdata);
                    soc_to_fpga_mailbox_write_data_captured = fpga_is_as_tdata ;		//use block assignment
                    $display($time, "=> get soc_to_fpga_mailbox_write_data_captured af : soc_to_fpga_mailbox_write_data_captured =%x, fpga_is_as_tdata=%x", soc_to_fpga_mailbox_write_data_captured, fpga_is_as_tdata);
                    #0 -> soc_to_fpga_mailbox_write_event;
                    $display($time, "=> soc_to_fpga_mailbox_write_data_captured : send soc_to_fpga_mailbox_write_event");                    
                    //Next should be address
                    stream_data_addr_or_data = 0;
                end
			end	
			
			
		end
	end


	initial begin		//get upstream soc_to_fpga_axilite_read_completion
		while (1) begin
			@(posedge fpga_coreclk);
			if (fpga_is_as_tvalid == 1 && fpga_is_as_tid == TID_UP_AA && fpga_is_as_tuser == TUSER_AXILITE_READ_CPL) begin
				$display($time, "=> get soc_to_fpga_axilite_read_cpl_captured be : soc_to_fpga_axilite_read_cpl_captured =%x, fpga_is_as_tdata=%x", soc_to_fpga_axilite_read_cpl_captured, fpga_is_as_tdata);
				soc_to_fpga_axilite_read_cpl_captured = fpga_is_as_tdata ;		//use block assignment
				$display($time, "=> get soc_to_fpga_axilite_read_cpl_captured af : soc_to_fpga_axilite_read_cpl_captured =%x, fpga_is_as_tdata=%x", soc_to_fpga_axilite_read_cpl_captured, fpga_is_as_tdata);
				#0 -> soc_to_fpga_axilite_read_cpl_event;
				$display($time, "=> soc_to_fpga_axilite_read_cpl_captured : send soc_to_fpga_axilite_read_cpl_event");
			end	 
		end
	end

	// tid = 2'b01 tuser = 2'b11 
	initial begin		//get upstream soc_to_fpga_axis - for loop back test
        soc_to_fpga_axis_captured_count = 0;
		while (1) begin
			@(posedge fpga_coreclk);
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				if (fpga_is_as_tvalid == 1 && fpga_is_as_tid == TID_UP_UP && fpga_is_as_tuser == TUSER_AXIS) begin
					soc_to_fpga_axis_captured_count = soc_to_fpga_axis_captured_count+1;
					$display($time, "=> get soc_to_fpga_axis be : soc_to_fpga_axis_captured_count=%d,  soc_to_fpga_axis_captured[%d] =%x, fpga_is_as_tupsb=%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", soc_to_fpga_axis_captured_count, soc_to_fpga_axis_captured_count, soc_to_fpga_axis_captured[soc_to_fpga_axis_captured_count], fpga_is_as_tupsb, fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
					soc_to_fpga_axis_captured[soc_to_fpga_axis_captured_count] = {fpga_is_as_tupsb, fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata} ;		//use block assignment
					$display($time, "=> get soc_to_fpga_axis af : soc_to_fpga_axis_captured_count=%d,  soc_to_fpga_axis_captured[%d] =%x, fpga_is_as_tupsb=%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", soc_to_fpga_axis_captured_count, soc_to_fpga_axis_captured_count, soc_to_fpga_axis_captured[soc_to_fpga_axis_captured_count], fpga_is_as_tupsb, fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
				end	
				if (soc_to_fpga_axis_captured_count == fpga_axis_test_length && fpga_is_as_tvalid == 1) begin
					$display($time, "=> soc_to_fpga_axis_captured : send soc_to_fpga_axiis_event");
					soc_to_fpga_axis_captured_count = 0;
					#0 -> soc_to_fpga_axis_event;
				end
			`else
				if (fpga_is_as_tvalid == 1 && fpga_is_as_tid == TID_UP_UP && fpga_is_as_tuser == TUSER_AXIS) begin
					soc_to_fpga_axis_captured_count = soc_to_fpga_axis_captured_count+1;					
					$display($time, "=> get soc_to_fpga_axis be : soc_to_fpga_axis_captured_count=%d,  soc_to_fpga_axis_captured[%d] =%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", soc_to_fpga_axis_captured_count, soc_to_fpga_axis_captured_count, soc_to_fpga_axis_captured[soc_to_fpga_axis_captured_count], fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
					soc_to_fpga_axis_captured[soc_to_fpga_axis_captured_count] = {fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata} ;		//use block assignment
					$display($time, "=> get soc_to_fpga_axis af : soc_to_fpga_axis_captured_count=%d,  soc_to_fpga_axis_captured[%d] =%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", soc_to_fpga_axis_captured_count, soc_to_fpga_axis_captured_count, soc_to_fpga_axis_captured[soc_to_fpga_axis_captured_count], fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);	
				end	
				if (soc_to_fpga_axis_captured_count == fpga_axis_test_length) begin
					$display($time, "=> soc_to_fpga_axis_captured : send soc_to_fpga_axiis_event");
					soc_to_fpga_axis_captured_count = 0;
					#0 -> soc_to_fpga_axis_event;
				end					
			`endif
		end
	end

	localparam la_axis_test_length = 16;

	reg [31:0] la_axis_cnt;
	reg [31:0] la_axis_captured [la_axis_test_length : 0];

	initial begin		//get la stram data
        la_axis_cnt = 0;
		while (1) begin
			@(posedge fpga_coreclk);
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				if (fpga_is_as_tvalid == 1 && fpga_is_as_tid == TID_UP_LA && fpga_is_as_tuser == TUSER_AXIS) begin
					la_axis_cnt = la_axis_cnt+1;
					$display($time, "=> get soc_to_fpga_axis be : la_axis_cnt=%d,  la_axis_captured[%d] =%x, fpga_is_as_tupsb=%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", la_axis_cnt, la_axis_cnt, la_axis_captured[la_axis_cnt], fpga_is_as_tupsb, fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
					la_axis_captured[la_axis_cnt] = {fpga_is_as_tupsb, fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata} ;		//use block assignment
					$display($time, "=> get soc_to_fpga_axis af : la_axis_cnt=%d,  la_axis_captured[%d] =%x, fpga_is_as_tupsb=%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", la_axis_cnt, la_axis_cnt, la_axis_captured[la_axis_cnt], fpga_is_as_tupsb, fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
				end	
				if (la_axis_cnt == la_axis_test_length && fpga_is_as_tvalid == 1) begin
					$display($time, "=> la_axis_captured : send soc_to_fpga_axiis_event");
					la_axis_cnt = 0;
					#0 -> la_axis_event;
				end
			`else
				if (fpga_is_as_tvalid == 1 && fpga_is_as_tid == TID_UP_LA && fpga_is_as_tuser == TUSER_AXIS) begin
					la_axis_cnt = la_axis_cnt+1;
					$display($time, "=> get soc_to_fpga_axis be : la_axis_cnt=%d,  la_axis_captured[%d] =%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", la_axis_cnt, la_axis_cnt, la_axis_captured[la_axis_cnt], fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
					la_axis_captured[la_axis_cnt] = {fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata} ;		//use block assignment
					$display($time, "=> get soc_to_fpga_axis af : la_axis_cnt=%d,  la_axis_captured[%d] =%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", la_axis_cnt, la_axis_cnt, la_axis_captured[la_axis_cnt], fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
				end	
				if (la_axis_cnt == la_axis_test_length) begin
					$display($time, "=> la_axis_captured : send soc_to_fpga_axiis_event");
					la_axis_cnt = 0;
					#0 -> la_axis_event;
				end
			`endif
		end
	end

	localparam aa_axis_test_length = 16;


	reg [31:0] aa_axis_cnt;
	reg [31:0] aa_axis_captured [aa_axis_test_length - 1: 0];

	initial begin		//get aa stram data
        aa_axis_cnt = 0;
		while (1) begin
			@(posedge fpga_coreclk);
			`ifdef
				if (fpga_is_as_tvalid == 1 && fpga_is_as_tid == TID_UP_AA && fpga_is_as_tuser == TUSER_AXIS) begin
					aa_axis_cnt = aa_axis_cnt+1;
					$display($time, "=> get soc_to_fpga_axis be : aa_axis_cnt=%d,  aa_axis_captured[%d] =%x, fpga_is_as_tupsb=%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", aa_axis_cnt, aa_axis_cnt, aa_axis_captured[aa_axis_cnt], fpga_is_as_tupsb, fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
					aa_axis_captured[aa_axis_cnt] = {fpga_is_as_tupsb, fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata} ;		//use block assignment
					$display($time, "=> get soc_to_fpga_axis af : aa_axis_cnt=%d,  aa_axis_captured[%d] =%x, fpga_is_as_tupsb=%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", aa_axis_cnt, aa_axis_cnt, aa_axis_captured[aa_axis_cnt], fpga_is_as_tupsb, fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
				end	
				if (aa_axis_cnt == aa_axis_test_length) begin
					$display($time, "=> aa_axis_captured : send soc_to_fpga_axiis_event");
					aa_axis_cnt = 0;
					#0 -> aa_axis_event;
				end
			`else
				if (fpga_is_as_tvalid == 1 && fpga_is_as_tid == TID_UP_AA && fpga_is_as_tuser == TUSER_AXIS) begin
					aa_axis_cnt = aa_axis_cnt+1;
					$display($time, "=> get soc_to_fpga_axis be : aa_axis_cnt=%d,  aa_axis_captured[%d] =%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", aa_axis_cnt, aa_axis_cnt, aa_axis_captured[aa_axis_cnt], fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
					aa_axis_captured[aa_axis_cnt] = {fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata} ;		//use block assignment
					$display($time, "=> get soc_to_fpga_axis af : aa_axis_cnt=%d,  aa_axis_captured[%d] =%x, fpga_is_as_tstrb=%x, fpga_is_as_tkeep=%x , fpga_is_as_tlast=%x, fpga_is_as_tdata=%x", aa_axis_cnt, aa_axis_cnt, aa_axis_captured[aa_axis_cnt], fpga_is_as_tstrb, fpga_is_as_tkeep , fpga_is_as_tlast, fpga_is_as_tdata);
				end	
				if (aa_axis_cnt == aa_axis_test_length) begin
					$display($time, "=> aa_axis_captured : send soc_to_fpga_axiis_event");
					aa_axis_cnt = 0;
					#0 -> aa_axis_event;
				end
			`endif
		end
	end

	task fpga_axilite_write;
		input [27:0] address;
		input [3:0] BE;
		input [31:0] data;
		begin
			fpga_as_is_tdata <= (BE<<28) + address;	//for axilite write address phase
			//$strobe($time, "=> fpga_as_is_tdata in address phase = %x", fpga_as_is_tdata);
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				fpga_as_is_tupsb <=  5'b00000;
			`endif
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  TID_DN_AA ;		//target to Axis-Axilite
			fpga_as_is_tuser <=  TUSER_AXILITE_WRITE;		//for axilite write
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end

			fpga_as_is_tdata <=  data;	//for axilite write data phase
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				fpga_as_is_tupsb <=  5'b00000;
			`endif
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  TID_DN_AA;		//target to Axis-Axilite
			fpga_as_is_tuser <=  TUSER_AXILITE_WRITE;		//for axilite write
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			fpga_as_is_tvalid <= 0;
		
		end
	endtask


	

	task fpga_as_to_is_init;
		//input [7:0] compare_data;

		begin
			//init fpga as to is signal, set fpga_as_is_tready = 1 for receives data from soc
			@ (posedge fpga_coreclk);
			fpga_as_is_tdata <=  32'h0;
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				fpga_as_is_tupsb <=  5'b00000;
			`endif
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  TID_DN_UP;
			fpga_as_is_tuser <=  TUSER_AXIS;
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 0;
			fpga_as_is_tready <= 1;
			$display($time, "=> fpga_as_to_is_init done");
		end
	endtask

	task fpga_axilite_read_req;
		input [31:0] address;
		begin
			fpga_as_is_tdata <= address;	//for axilite read address req phase
			$strobe($time, "=> fpga_axilite_read_req in address req phase = %x - tvalid", fpga_as_is_tdata);
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				fpga_as_is_tupsb <=  5'b00000;
			`endif
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  TID_DN_AA;		//target to Axis-Axilite
			fpga_as_is_tuser <=  TUSER_AXILITE_READ_REQ;		//for axilite read req
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			$display($time, "=> fpga_axilite_read_req in address req phase = %x - transfer", fpga_as_is_tdata);
			fpga_as_is_tvalid <= 0;
		
		end
	endtask

	task fpga_is_as_data_valid;
		// input [31:0] address;
		begin
			fpga_as_is_tready <= 1;		//TODO change to other location for set fpga_as_is_tready
			
			$strobe($time, "=> fpga_is_as_data_valid wait fpga_is_as_tvalid");
			@ (posedge fpga_coreclk);
			while (fpga_is_as_tvalid == 0) begin		// wait util fpga_is_as_tvalid == 1 
					@ (posedge fpga_coreclk);
			end
			$strobe($time, "=> fpga_is_as_data_valid wait fpga_is_as_tvalid done, fpga_is_as_tvalid = %b", fpga_is_as_tvalid);
		
		end
	endtask

	task fpga_axis_req;
		input [31:0] data;
		input [1:0] tid;
		input mode;	//o ffor noram, 1 for random data
		reg [31:0] tdata;
		`ifdef USER_PROJECT_SIDEBAND_SUPPORT
			reg [pUSER_PROJECT_SIDEBAND_WIDTH-1:0]tupsb;
		`endif
		reg [3:0] tstrb;
		reg [3:0] tkeep;
		reg tlast;
		
		begin
			if (mode) begin		//for random data
				tdata = $random;
				`ifdef USER_PROJECT_SIDEBAND_SUPPORT
					tupsb = $random;
				`endif
				tstrb = $random;
				tkeep = $random;
				tlast = $random;
			end
			else begin
				tdata = data;
				`ifdef USER_PROJECT_SIDEBAND_SUPPORT
					//tupsb = 5'b00000;
					tupsb = 0;
				`endif
				tstrb = 4'b0000;
				tkeep = 4'b0000;
				tlast = (tdata == 32'h0000_00ff);
			end
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				fpga_as_is_tupsb <= tupsb;
			`endif
			fpga_as_is_tstrb <=  tstrb;
			fpga_as_is_tkeep <=  tkeep;
			fpga_as_is_tlast <=  tlast;
			fpga_as_is_tdata <= tdata;	//for axis write data
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				$strobe($time, "=> fpga_axis_req send data, fpga_as_is_tupsb = %b, fpga_as_is_tstrb = %b, fpga_as_is_tkeep = %b, fpga_as_is_tlast = %b, fpga_as_is_tdata = %x", fpga_as_is_tupsb, fpga_as_is_tstrb, fpga_as_is_tkeep, fpga_as_is_tlast, fpga_as_is_tdata);
			`else	
				$strobe($time, "=> fpga_axis_req send data, fpga_as_is_tstrb = %b, fpga_as_is_tkeep = %b, fpga_as_is_tlast = %b, fpga_as_is_tdata = %x", fpga_as_is_tstrb, fpga_as_is_tkeep, fpga_as_is_tlast, fpga_as_is_tdata);
			`endif
			
			fpga_as_is_tid <=  tid;		//set target
			fpga_as_is_tuser <=  TUSER_AXIS;		//for axis req
			fpga_as_is_tvalid <= 1;
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				soc_to_fpga_axis_expect_value[soc_to_fpga_axis_expect_count] <= {tupsb, tstrb, tkeep, tlast, tdata};
			`else	
				soc_to_fpga_axis_expect_value[soc_to_fpga_axis_expect_count] <= {tstrb, tkeep, tlast, tdata};
			`endif
			soc_to_fpga_axis_expect_count <= soc_to_fpga_axis_expect_count+1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			fpga_as_is_tvalid <= 0;
		
		end
	endtask

	task fpga_axilite_write_req;
		input [27:0] address;
		input [3:0] BE;
		input [31:0] data;

		begin
			fpga_as_is_tdata[27:0] <= address;	//for axilite write address phase
			fpga_as_is_tdata[31:28] <= BE;	
			$strobe($time, "=> fpga_axilite_write_req in address phase = %x - tvalid", fpga_as_is_tdata);
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				fpga_as_is_tupsb <=  5'b00000;
			`endif
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  TID_DN_AA;		//target to Axis-Axilite
			fpga_as_is_tuser <=  TUSER_AXILITE_WRITE;		//for axilite write req
			fpga_as_is_tlast <=  1'b0;
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			$display($time, "=> fpga_axilite_write_req in address phase = %x - transfer", fpga_as_is_tdata);

			fpga_as_is_tdata <= data;	//for axilite write data phase
			$strobe($time, "=> fpga_axilite_write_req in data phase = %x - tvalid", fpga_as_is_tdata);
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				fpga_as_is_tupsb <=  5'b00000;
			`endif
			fpga_as_is_tstrb <=  4'b0000;
			fpga_as_is_tkeep <=  4'b0000;
			fpga_as_is_tid <=  TID_DN_AA;		//target to Axis-Axilite
			fpga_as_is_tuser <=  TUSER_AXILITE_WRITE;		//for axilite write req
			fpga_as_is_tlast <=  1'b1;		//tlast = 1
			fpga_as_is_tvalid <= 1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			$display($time, "=> fpga_axilite_write_req in data phase = %x - transfer", fpga_as_is_tdata);
			
			
			fpga_as_is_tvalid <= 0;
		
		end
	endtask




/*	
	task test00n;
		begin
		end
	endtask
*/

	//apply reset
	task soc_apply_reset;
		input real delta1;		// for POR De-Assert
		input real delta2;		// for reset De-Assert
		begin
			#(40);
			$display($time, "=> soc POR Assert"); 
			soc_resetb = 0;
			//$display($time, "=> soc reset Assert"); 
			//soc_rst = 1;
			#(delta1);

			$display($time, "=> soc POR De-Assert"); 
			soc_resetb = 1;

			#(delta2);
			//$display($time, "=> soc reset De-Assert"); 
			//soc_rst = 0;
		end	
	endtask
	
	task fpga_apply_reset;
		input real delta1;		// for POR De-Assert
		input real delta2;		// for reset De-Assert
		begin
			#(40);
			$display($time, "=> fpga POR Assert"); 
			fpga_resetb = 0;
			$display($time, "=> fpga reset Assert"); 
			fpga_rst = 1;
			#(delta1);

			$display($time, "=> fpga POR De-Assert"); 
			fpga_resetb = 1;

			#(delta2);
			$display($time, "=> fpga reset De-Assert"); 
			fpga_rst = 0;
		end
	endtask

	task soc_is_cfg_write;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		input [31:0] data;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= IS_BASE;			
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_wdata <= data;
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b1;	

			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end

			$display($time, "=> soc_is_cfg_write : wbs_adr=%x, wbs_sel=%b, wbs_wdata=%x", wbs_adr, wbs_sel, wbs_wdata); 
		end
	endtask

	task soc_is_cfg_read;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= IS_BASE;			
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b0;	

			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end

			$display($time, "=> soc_is_cfg_read : wbs_adr=%x, wbs_sel=%b", wbs_adr, wbs_sel); 
			//#1;		//add delay to make sure cfg_read_data_captured get the correct data 
			@(soc_cfg_read_event);
			$display($time, "=> soc_is_cfg_read : got soc_cfg_read_event"); 
		end
	endtask

	task soc_aa_cfg_write;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		input [31:0] data;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= AA_BASE;
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_wdata <= data;
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b1;	
			
			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end

			$display($time, "=> soc_aa_cfg_write : wbs_adr=%x, wbs_sel=%b, wbs_wdata=%x", wbs_adr, wbs_sel, wbs_wdata); 
		end
	endtask

	task soc_aa_cfg_read;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= AA_BASE;
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b0;		
			
			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end
			$display($time, "=> soc_aa_cfg_read : wbs_adr=%x, wbs_sel=%b", wbs_adr, wbs_sel); 
			//#1;		//add delay to make sure cfg_read_data_captured get the correct data 
			@(soc_cfg_read_event);
			$display($time, "=> soc_aa_cfg_read : got soc_cfg_read_event"); 
		end
	endtask
	
	task soc_up_cfg_write;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		input [31:0] data;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= UP_BASE;
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_wdata <= data;
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b1;	
			
			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end

			$display($time, "=> soc_up_cfg_write : wbs_adr=%x, wbs_sel=%b, wbs_wdata=%x", wbs_adr, wbs_sel, wbs_wdata); 
		end
	endtask	

	task soc_up_cfg_read;
		input [11:0] offset;		//4K range
		input [3:0] sel;
		
		begin
			@ (posedge soc_coreclk);		
			wbs_adr <= UP_BASE;
			wbs_adr[11:2] <= offset[11:2];	//only provide DW address 
			
			wbs_sel <= sel;
			wbs_cyc <= 1'b1;
			wbs_stb <= 1'b1;
			wbs_we <= 1'b0;		
			
			@(posedge soc_coreclk);
			while(wbs_ack==0) begin
				@(posedge soc_coreclk);
			end
			
			$display($time, "=> soc_up_cfg_read : wbs_adr=%x, wbs_sel=%b", wbs_adr, wbs_sel); 
			//#1;		//add delay to make sure cfg_read_data_captured get the correct data 
			@(soc_cfg_read_event);
			$display($time, "=> soc_up_cfg_read : got soc_cfg_read_event"); 
		end
	endtask


	task fpga_cfg_write;		//input addr, data, strb and valid_delay 
		input [pADDR_WIDTH-1:0] axi_awaddr;
		input [pDATA_WIDTH-1:0] axi_wdata;
		input [3:0] axi_wstrb;
		input [7:0] valid_delay;
		
		begin
			fpga_axi_awaddr <= axi_awaddr;
			fpga_axi_awvalid <= 0;
			fpga_axi_wdata <= axi_wdata;
			fpga_axi_wstrb <= axi_wstrb;
			fpga_axi_wvalid <= 0;
			//$display($time, "=> fpga_delay_valid before : valid_delay=%x", valid_delay); 
			repeat (valid_delay) @ (posedge fpga_coreclk);
			//$display($time, "=> fpga_delay_valid after  : valid_delay=%x", valid_delay); 
			fpga_axi_awvalid <= 1;
			fpga_axi_wvalid <= 1;
			@ (posedge fpga_coreclk);
			while (fpga_axi_awready == 0) begin		//assume both fpga_axi_awready and fpga_axi_wready assert as the same time.
					@ (posedge fpga_coreclk);
			end
			$display($time, "=> fpga_cfg_write : fpga_axi_awaddr=%x, fpga_axi_awvalid=%b, fpga_axi_awready=%b, fpga_axi_wdata=%x, axi_wstrb=%x, fpga_axi_wvalid=%b, fpga_axi_wready=%b", fpga_axi_awaddr, fpga_axi_awvalid, fpga_axi_awready, fpga_axi_wdata, axi_wstrb, fpga_axi_wvalid, fpga_axi_wready); 
			fpga_axi_awvalid <= 0;
			fpga_axi_wvalid <= 0;
		end
		
	endtask

endmodule
