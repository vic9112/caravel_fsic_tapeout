`timescale 1 ns / 1 ps

/********************************************************************************
1. Create request signals for WB and AA
    WB request (wb_request) signal is set by CYC & STB, reset by ACK
    AA request (aa_request)  - the following is from AA side
        -for write is from (awvalid & wvalid) till wready - 
              register (aa_w_req) set by (awvalid & wvalid) reset by wready
         - for read from (arvalid)  till (rvalid)
             register (aa_r_req) - set by arvalid, and reset by rvalid 
      aa_reqeust = aa_w_req | aa_r_req;

2. arbitration state machine for wb_request, aa_request
    state: idle, grant_wb, grant_aa,   [1:0]
              idle = 
             grant_wb =   10  - entry when  wb_request
             grant_aa =   11 - entry when aa_request & ~wb_request
	To simplify - WB has higher priority
    grant_wb = state[1] & !state[0];
    grant_aa  = state[1] & state[0]    - use for addres/data selection

3. m_axi signal generation
    waddr, data directly from wb_addr, wb_data (if grant_wb), aa waddr, wdata (if grant_aa)
    if grant_aa, m_axi and aa bus signal are directly connected, i.e.
    m-awvalid = aa_awvalid
    m_valid = aa_valid
    m_arready = aa_arvlid
    aa_rvalid = m_rvalid
    m_awvalid - aa_awvalid

  
4. wb, aa bus
    wb ack - m_wready (if write), (m_rvalid & m_ready) - read
    aa  - directly connect to m_axi bus signals 

5. generate cc_xx_enable

**********************************************************************/

module CFG_CTRL #( parameter pADDR_WIDTH   = 12,
                   parameter pDATA_WIDTH   = 32
                 )
(
	//////////////////////////////////////
	// FPGA AXI-Lite, from Axis-Axilite //
	//////////////////////////////////////
	input  wire          aa_cfg_awvalid,
	input  wire  [31: 0] aa_cfg_awaddr,
	input  wire          aa_cfg_wvalid,
	input  wire  [31: 0] aa_cfg_wdata,
	input  wire   [3: 0] aa_cfg_wstrb,
	input  wire          aa_cfg_arvalid,
	input  wire  [31: 0] aa_cfg_araddr,
	input  wire          aa_cfg_rready,
	output wire  [31: 0] aa_cfg_rdata,
	output wire          aa_cfg_rvalid,
	output wire          aa_cfg_awready,
	output wire          aa_cfg_wready,
	output wire          aa_cfg_arready,
	
	/////////////////////
	// AXI-Lite Master //
	/////////////////////
	input  wire          axi_wready1,		//for AXIL_AXIS
	input  wire          axi_awready1,
	input  wire          axi_arready1,
	input  wire  [31: 0] axi_rdata1,
	input  wire          axi_rvalid1,
	input  wire          axi_awready4,		//for AXIL_SWITCH
	input  wire          axi_wready4,
	input  wire          axi_arready4,
	input  wire  [31: 0] axi_rdata4,
	input  wire          axi_rvalid4,
	input  wire          axi_awready3,		//for IO_SERDES
	input  wire          axi_wready3,
	input  wire          axi_arready3,
	input  wire  [31: 0] axi_rdata3,
	input  wire          axi_rvalid3,
	input  wire          axi_awready0,		//for LOGIC_ANLZ
	input  wire          axi_wready0,
	input  wire          axi_arready0,
	input  wire  [31: 0] axi_rdata0,
	input  wire          axi_rvalid0,
	input  wire          axi_awready2,		//for USERSUBSYS
	input  wire          axi_wready2,
	input  wire          axi_arready2,
	input  wire  [31: 0] axi_rdata2,
	input  wire          axi_rvalid2,
	output wire          axi_awvalid,
	output wire  [14: 0] axi_awaddr,
	output wire          axi_wvalid,
	output wire  [31: 0] axi_wdata,
	output wire   [3: 0] axi_wstrb,
	output wire          axi_arvalid,
	output wire  [14: 0] axi_araddr,
	output wire          axi_rready,	
	
	//////////////////////
	// Target Selection //
	//////////////////////
	output wire          cc_aa_enable,
	output wire          cc_as_enable,
	output wire          cc_is_enable,
	output wire          cc_la_enable,
	output wire          cc_up_enable,
	output wire   [4: 0] user_prj_sel,
	
	////////////////////////
	// Wishbone interface //
	////////////////////////	
	input  wire          wb_rst,
	input  wire          wb_clk,
	input  wire  [31: 0] wbs_adr,
	input  wire  [31: 0] wbs_wdata,
	input  wire   [3: 0] wbs_sel,
	input  wire          wbs_cyc,
	input  wire          wbs_stb,
	input  wire          wbs_we,
	output wire          wbs_ack,
	output wire  [31: 0] wbs_rdata,
	
	//////////////////////////
	// Top AXI-Lite Signals //
	//////////////////////////
	input  wire          user_clock2,
	input  wire          axi_clk,
	input  wire          axi_reset_n,
	input  wire          uck2_rst_n

	
);


// --------------------
// 0. for output signal
// --------------------
wire		axi_awready;
wire 		axi_wready;
wire		axi_arready;
wire		axi_rvalid;
wire [31:0] axi_rdata;

reg [4:0] user_prj_sel_o;

//  -----------------------------------
// 1. Generate request signals from wb, aa
//  ------------------------------------
wire wb_req = wbs_cyc & wbs_stb;			// WB request - when both wb_cyc & wb_stb make sure address/data is available

/***********************
// -for write is from (awvalid & wvalid) till wready - 
              register (aa_w_req) set by (awvalid & wvalid) reset by wready
         - for read from (arvalid)  till (rvalid)
             register (aa_r_req) - set by arvalid, and reset by rvalid 
********************/
reg r_aa_req_r;				// aa read request
always @(posedge axi_clk or negedge axi_reset_n ) begin
	if( !axi_reset_n) begin
		r_aa_req_r <= 0;
	end else if(aa_cfg_arvalid & !r_aa_req_r) begin
		r_aa_req_r <= 1;
	end else if( aa_cfg_rvalid) begin			//aa_cfg_rvalid <= m_rvalid
		r_aa_req_r <= 0;
	end
end

reg r_aa_req_w;				// aa write request 
always @(posedge axi_clk or negedge axi_reset_n ) begin
	if( !axi_reset_n) begin
		r_aa_req_w <= 0;
	end else if(aa_cfg_awvalid & aa_cfg_wvalid & !r_aa_req_w) begin
		r_aa_req_w <= 1;
	end else if( aa_cfg_wready ) begin			//aa_cfg_wready <= m_wready
		r_aa_req_w <= 0;
	end
end

wire aa_req = r_aa_req_r | r_aa_req_w;

/* ************************************************
// 2. arbitration
//  state: idle, grant_wb, grant_aa,   [1:0]
              idle = 
             grant_wb =  10 - entry when wb_request & ( last_aa | ~aa_request)
             grant_aa =  11 - entry when aa_request & (~last_aa | ~wb_request)
	To simplify: wb has higher priority
    grant_wb = state[1] & !state[0];
    grant_aa = state[1] & state[0]    - use for addres/data selection
************************************************/
localparam IDLE = 2'b00;
localparam GRANT_WB = 2'b10;
localparam GRANT_AA = 2'b11;

reg [1:0] arb_state;
always @(posedge axi_clk or negedge axi_reset_n ) begin
	if( !axi_reset_n) begin
		arb_state <= IDLE;
	end else begin
		case (arb_state) 
			IDLE : 
				begin
					if( wb_req ) arb_state <= GRANT_WB;
					else if( aa_req ) arb_state <= GRANT_AA;
					else arb_state <= arb_state;
				end
			GRANT_WB: 
				begin 		// wait for ACK
					if( wb_req )	arb_state <= arb_state;
					else			arb_state <= IDLE;
				end
			GRANT_AA:
				begin
					if( aa_req )	arb_state <= arb_state;
					else			arb_state <= IDLE;
				end
			default:
				arb_state <= arb_state;
		endcase
	end
end
wire grant_wb = (arb_state == GRANT_WB);
wire grant_aa = (arb_state == GRANT_AA);

/*
reg arb_state;
always @( posedge wb_clk or posedge wb_rst )
begin
	if ( wb_rst ) begin
		arb_state <= 1'b0;
	end else begin
		case (arb_state)
			1'b0: begin
				if ((~wb_req)) begin
					if (aa_req) begin
						arb_state <= 1'b1;
					end
				end
			end
			1'b1: begin
				if ((~aa_req)) begin
					if (wb_req) begin
						arb_state <= 1'b0;
					end
				end
			end			
		endcase
	end
end		
*/
/****************************************************
  3. Generate m_axi signals 

  	output wire          axi_awvalid,
	output wire  [14: 0] axi_awaddr,
	output wire          axi_wvalid,
	output wire  [31: 0] axi_wdata,
	output wire   [3: 0] axi_wstrb,

	output wire          axi_arvalid,
	output wire  [14: 0] axi_araddr,
	output wire          axi_rready,	
*****************************************************/
assign axi_awaddr = ({15{grant_wb}} & wbs_adr[14:0]) 
                  | ({15{grant_aa}} & aa_cfg_awaddr[14:0]) ;

assign axi_araddr = ({15{grant_wb}} & wbs_adr[14:0]) 
                  | ({15{grant_aa}} & aa_cfg_araddr[14:0]) ;

assign axi_wdata  = ({32{grant_wb}} & wbs_wdata) 
                  | ({32{grant_aa}} & aa_cfg_wdata) ;

assign axi_wstrb  = ({4{grant_wb}} & wbs_sel) 
                  | ({4{grant_aa}} & aa_cfg_wstrb) ;



// axi_awvalid deasserts when axi_awready asserts
reg		wb_axi_awvalid;
always @(posedge axi_clk or negedge axi_reset_n ) begin
	if( !axi_reset_n) begin
		wb_axi_awvalid <= 1'b0;
	end else begin
		if(grant_wb & wbs_we & wb_req & ~axi_awready)  wb_axi_awvalid <= 1;
		else wb_axi_awvalid <= 0;
	end
end

assign axi_awvalid = (grant_wb & wb_axi_awvalid) | (grant_aa & aa_cfg_awvalid);

// -- axi_wvalid-----------------
//wb_w = (grant_wb & wbs_we & wb_req)
//aa_w = (grant_aa & aa_cfg_wvalid)
//---------------------------
assign axi_wvalid  = (grant_wb & wbs_we & wb_req) | (grant_aa & aa_cfg_wvalid);

// axi_arvalid deasserts when axi_arready asserts
reg  	wb_axi_arvalid;
always @(posedge axi_clk or negedge axi_reset_n ) begin
	if( !axi_reset_n) begin
		wb_axi_arvalid <= 1'b0;
	end else begin
		if(grant_wb & ~wbs_we & wb_req & ~axi_arready)  wb_axi_arvalid <= 1;
		else wb_axi_arvalid <= 0;
	end
end

assign axi_arvalid = (grant_wb & wb_axi_arvalid) | (grant_aa & aa_cfg_arvalid);

// -- axi_rready-----------------------
//wb_r = (grant_wb & ~wbs_we & wb_req)
//aa_r = (grant_aa & aa_cfg_rready)
//-----------------------------------
assign axi_rready = (grant_wb & ~wbs_we & wb_req) | (grant_aa & aa_cfg_rready);	


/* -----------------------8/30 shao-fu -------------------------------------------
 4.1 Generate WB output
    output wire          wbs_ack,
	output wire  [31: 0] wbs_rdata,
 ---------------------- */

//wbs_ack
assign wbs_ack = grant_wb & ((wbs_we & axi_wvalid & axi_wready) | (~wbs_we & axi_rvalid & axi_rready));
//assign wbs_ack = grant_wb & ((wbs_we & m_awready & m_wready) | (~wbs_we & m_rvalid));

// -----
// read-data select from axi_rdata_x
assign wbs_rdata = axi_rdata;


/****************************************************
  5. Generate output signal 
/
	output wire          cc_aa_enable,
	output wire          cc_as_enable,
	output wire          cc_is_enable,
	output wire          cc_la_enable,
	output wire          cc_up_enable,
	output wire   [4: 0] user_prj_sel,
*****************************************************/
wire cc_aa_enable_r;
wire cc_as_enable_r;
wire cc_is_enable_r;
wire cc_la_enable_r;
wire cc_up_enable_r;
wire cc_enable_r;
wire cc_sub_enable_r;

wire cc_aa_enable_w;
wire cc_as_enable_w;
wire cc_is_enable_w;
wire cc_la_enable_w;
wire cc_up_enable_w;
wire cc_enable_w;
wire cc_sub_enable_w;

assign cc_aa_enable=cc_aa_enable_w|cc_aa_enable_r;
assign cc_as_enable=cc_as_enable_w|cc_as_enable_r;
assign cc_is_enable=cc_is_enable_w|cc_is_enable_r;
assign cc_la_enable=cc_la_enable_w|cc_la_enable_r;
assign cc_up_enable=cc_up_enable_w|cc_up_enable_r;


//------------------
//5.1 read protocol
//-----------------
wire          m_arready;
wire          m_rvalid;
wire  [31: 0] m_rdata;

wire  [31: 0] m_araddr;
assign m_araddr = ({32{grant_wb}} & wbs_adr) 
                | ({32{grant_aa}} & aa_cfg_araddr) ;

//-- cc_xx_enable_r hold 1 cycle --------------------------------
reg [3:0] target_sel_r;
always @ ( posedge axi_clk or negedge axi_reset_n) begin
	if ( !axi_reset_n ) begin
		target_sel_r <= 4'b0000;
	end else begin
		case (m_araddr[31:12])
			20'h30002: target_sel_r <= 4'b0001;
			20'h30004: target_sel_r <= 4'b0010;
			20'h30003: target_sel_r <= 4'b0011;
			20'h30001: target_sel_r <= 4'b0100;
			20'h30000: target_sel_r <= 4'b0101;
			20'h30005: target_sel_r <= 4'b0110;
			default: target_sel_r <= 4'b0000;
		endcase
	end
end
assign cc_aa_enable_r = (target_sel_r == 4'b0001);
assign cc_as_enable_r = (target_sel_r == 4'b0010);
assign cc_is_enable_r = (target_sel_r == 4'b0011);
assign cc_la_enable_r = (target_sel_r == 4'b0100);
assign cc_up_enable_r = (target_sel_r == 4'b0101);
assign cc_enable_r = (target_sel_r == 4'b0110);
assign cc_sub_enable_r = (m_araddr[31:12] >= 20'h30006) && (m_araddr[31:12] <= 20'h3FFFF);

/*			
assign cc_aa_enable_r = ( m_araddr[31:12] == 20'h30002 )? 1'b1 : 1'b0;
assign cc_as_enable_r = ( m_araddr[31:12] == 20'h30004 )? 1'b1 : 1'b0;
assign cc_is_enable_r = ( m_araddr[31:12] == 20'h30003 )? 1'b1 : 1'b0;
assign cc_la_enable_r = ( m_araddr[31:12] == 20'h30001 )? 1'b1 : 1'b0;
assign cc_up_enable_r = (m_araddr[31:12] == 20'h30000 )? 1'b1 : 1'b0;
assign cc_enable_r = ( m_araddr[31:12] == 20'h30005 )? 1'b1 : 1'b0;
assign cc_sub_enable_r = ( (m_araddr[31:12] >= 20'h30006) && (m_araddr[31:12] <= 20'h3FFFF ) )? 1'b1 : 1'b0;
*/


assign m_arready = ((((((({1{cc_up_enable_r}} & axi_arready2) | ({1{cc_la_enable_r}} & axi_arready0)) | ({1{cc_aa_enable_r}} & axi_arready1)) | ({1{cc_is_enable_r}} & axi_arready3)) | ({1{cc_as_enable_r}} & axi_arready4)) | ({1{cc_enable_r}} & 1'b1)) | ({1{cc_sub_enable_r}} & 1'b1));
assign m_rvalid = ((((((({1{cc_up_enable_r}} & axi_rvalid2) | ({1{cc_la_enable_r}} & axi_rvalid0)) | ({1{cc_aa_enable_r}} & axi_rvalid1)) | ({1{cc_is_enable_r}} & axi_rvalid3)) | ({1{cc_as_enable_r}} & axi_rvalid4)) | ({1{cc_enable_r}} & 1'b1)) | ({1{cc_sub_enable_r}} & 1'b1));
assign m_rdata = ((((((({32{cc_up_enable_r}} & axi_rdata2) | ({32{cc_la_enable_r}} & axi_rdata0)) | ({32{cc_aa_enable_r}} & axi_rdata1)) | ({32{cc_is_enable_r}} & axi_rdata3)) | ({32{cc_as_enable_r}} & axi_rdata4)) | ({32{cc_enable_r}} & { 27'b0, user_prj_sel_o } )) | ({32{cc_sub_enable_r}} & 32'hFFFFFFFF));

wire wb_r = (grant_wb & ~wbs_we & wb_req);
wire aa_r = (grant_aa & aa_cfg_rready);

assign axi_arready = wb_r? m_arready:0;
assign axi_rvalid =  wb_r? m_rvalid :0;
assign axi_rdata = m_rdata;

assign aa_cfg_arready = aa_r? m_arready:0;
assign aa_cfg_rvalid =  aa_r? m_rvalid :0;	
assign aa_cfg_rdata = m_rdata;


//------------------
//5.2 write protocol
//------------------
wire 	m_awready;
wire 	m_wready;



wire [31:0] m_awaddr;
assign m_awaddr = ({32{grant_wb}} & wbs_adr) 
                | ({32{grant_aa}} & aa_cfg_awaddr) ;

//-- cc_xx_enable_w hold 1 cycle --------------------------------
reg [3:0] target_sel_w;
always @ ( posedge axi_clk or negedge axi_reset_n) begin
	if ( !axi_reset_n ) begin
		target_sel_w <= 4'b0000;
	end else begin
		case (m_awaddr[31:12])
			20'h30002: target_sel_w <= 4'b0001;
			20'h30004: target_sel_w <= 4'b0010;
			20'h30003: target_sel_w <= 4'b0011;
			20'h30001: target_sel_w <= 4'b0100;
			20'h30000: target_sel_w <= 4'b0101;
			20'h30005: target_sel_w <= 4'b0110;
			default: target_sel_w <= 4'b0000;
		endcase
	end
end
assign cc_aa_enable_w = (target_sel_w == 4'b0001);
assign cc_as_enable_w = (target_sel_w == 4'b0010);
assign cc_is_enable_w = (target_sel_w == 4'b0011);
assign cc_la_enable_w = (target_sel_w == 4'b0100);
assign cc_up_enable_w = (target_sel_w == 4'b0101);
assign cc_enable_w = (target_sel_w == 4'b0110);
assign cc_sub_enable_w = (m_awaddr[31:12] >= 20'h30006) && (m_awaddr[31:12] <= 20'h3FFFF);
/*
assign cc_aa_enable_w = ( m_awaddr[31:12] == 20'h30002 )? 1'b1 : 1'b0;
assign cc_as_enable_w = ( m_awaddr[31:12] == 20'h30004 )? 1'b1 : 1'b0;
assign cc_is_enable_w = ( m_awaddr[31:12] == 20'h30003 )? 1'b1 : 1'b0;
assign cc_la_enable_w = ( m_awaddr[31:12] == 20'h30001 )? 1'b1 : 1'b0;
assign cc_up_enable_w = (m_awaddr[31:12] == 20'h30000 )? 1'b1 : 1'b0;
assign cc_enable_w = ( m_awaddr[31:12] == 20'h30005 )? 1'b1 : 1'b0;
assign cc_sub_enable_w = ( (m_awaddr[31:12] >= 20'h30006) && (m_awaddr[31:12] <= 20'h3FFFF ) )? 1'b1 : 1'b0;
*/

assign m_awready = ((((((({1{cc_up_enable_w}} & axi_awready2) | ({1{cc_la_enable_w}} & axi_awready0)) | ({1{cc_aa_enable_w}} & axi_awready1)) | ({1{cc_is_enable_w}} & axi_awready3)) | ({1{cc_as_enable_w}} & axi_awready4)) | ({1{cc_enable_w}} & 1'b1)) | ({1{cc_sub_enable_w}} & 1'b1));
assign m_wready = ((((((({1{cc_up_enable_w}} & axi_wready2) | ({1{cc_la_enable_w}} & axi_wready0)) | ({1{cc_aa_enable_w}} & axi_wready1)) | ({1{cc_is_enable_w}} & axi_wready3)) | ({1{cc_as_enable_w}} & axi_wready4)) | ({1{cc_enable_w}} & 1'b1)) | ({1{cc_sub_enable_w}} & 1'b1));

wire wb_w = (grant_wb & wbs_we & wb_req);
wire aa_w = (grant_aa & aa_cfg_wvalid);

assign axi_awready = wb_w? m_awready:0;
assign axi_wready =  wb_w? m_wready :0;
assign aa_cfg_awready = aa_w? m_awready:0;
assign aa_cfg_wready =  aa_w? m_wready :0;	


//------------------
//5.3 user_prj_sel
//------------------
assign user_prj_sel = user_prj_sel_o;

always @ ( posedge axi_clk or negedge axi_reset_n ) begin	
	if ( !axi_reset_n ) begin
		user_prj_sel_o <= 5'b0;
	end else begin
		if ( axi_awvalid && axi_wvalid && cc_enable_w ) begin
			if (axi_awaddr[11:0] == 12'h000 && (axi_wstrb[0] == 1) ) begin 
				user_prj_sel_o <= axi_wdata[4:0];
			end
			else begin
				user_prj_sel_o <= user_prj_sel_o;
			end
		end
		else user_prj_sel_o <= user_prj_sel_o;
	end
end	

endmodule


