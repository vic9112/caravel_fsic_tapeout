`timescale 1ns / 1ps
module AXIS_SW #(
				parameter pUSER_PROJECT_SIDEBAND_WIDTH   = 5,
				parameter pADDR_WIDTH   = 10,
                parameter pDATA_WIDTH   = 32
                )
(
    input  wire                             axi_reset_n,    
    input  wire                             axis_clk,
    input  wire                             axis_rst_n,
 
    //axi_lite slave interface
    //write addr channel
    input wire 	axi_awvalid,
    input wire 	[14:0] axi_awaddr,		
	output wire	axi_awready,
	//write data channel
	input wire 	axi_wvalid,
	input wire 	[pDATA_WIDTH-1:0] axi_wdata,
	input wire 	[(pDATA_WIDTH/8)-1:0] axi_wstrb,
	output wire	axi_wready,
	//read addr channel
	input wire 	axi_arvalid,
	input wire 	[14:0] axi_araddr,
	output wire axi_arready,
	//read data channel
	output wire axi_rvalid,
	output wire [pDATA_WIDTH-1:0] axi_rdata,
	input wire 	axi_rready,
	input wire 	cc_as_enable,		//axi_lite enable        
    //AXI Stream inputs for User Project grant 0
    input  wire [pDATA_WIDTH-1:0]           up_as_tdata,
	`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		input wire 	[pUSER_PROJECT_SIDEBAND_WIDTH-1:0] up_as_tupsb,
	`endif
    input  wire [pDATA_WIDTH/8-1:0]         up_as_tstrb,
    input  wire [pDATA_WIDTH/8-1:0]         up_as_tkeep,  
    input  wire                             up_as_tlast,      
    input  wire                             up_as_tvalid,
    input  wire [1:0]                       up_as_tuser, 
	input  wire                             up_hpri_req,
    output wire                             as_up_tready,
    //AXI Stream inputs for Axis Axilite grant 1
    input  wire [pDATA_WIDTH-1:0]           aa_as_tdata,
    input  wire [pDATA_WIDTH/8-1:0]         aa_as_tstrb,
    input  wire [pDATA_WIDTH/8-1:0]         aa_as_tkeep,   
    input  wire                             aa_as_tlast,       
    input  wire                             aa_as_tvalid,
    input  wire [1:0]                       aa_as_tuser,       
    output wire                             as_aa_tready,
    //AXI Stream inputs for Logic Analyzer grant 2
    input  wire [pDATA_WIDTH-1:0]           la_as_tdata,
    input  wire [pDATA_WIDTH/8-1:0]         la_as_tstrb,
    input  wire [pDATA_WIDTH/8-1:0]         la_as_tkeep, 
    input  wire                             la_as_tlast,          
    input  wire                             la_as_tvalid,
    input  wire [1:0]                       la_as_tuser,      
	input  wire                             la_hpri_req,
    output wire                             as_la_tready,
    //AXI Stream outputs for IO Serdes
    output  wire [pDATA_WIDTH-1:0]          as_is_tdata,
	`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		output wire 	[pUSER_PROJECT_SIDEBAND_WIDTH-1:0] as_is_tupsb,
	`endif
    output  wire [pDATA_WIDTH/8-1:0]        as_is_tstrb,
    output  wire [pDATA_WIDTH/8-1:0]        as_is_tkeep, 
    output  wire                            as_is_tlast,        
    output  wire [1:0]                      as_is_tid, 
    output  wire                            as_is_tvalid,
    output  wire [1:0]                      as_is_tuser,     
    input	wire                            is_as_tready,
    //Demux
    //AXI Input Stream for IO_Serdes
    input  wire [pDATA_WIDTH-1:0]           is_as_tdata,
	`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		input wire 	[pUSER_PROJECT_SIDEBAND_WIDTH-1:0] is_as_tupsb,
	`endif
    input  wire [pDATA_WIDTH/8-1:0]         is_as_tstrb,    
    input  wire [pDATA_WIDTH/8-1:0]         is_as_tkeep,
    input  wire                             is_as_tlast,
    input  wire [1:0]                       is_as_tid,
    input  wire                             is_as_tvalid,
    input  wire [1:0]                       is_as_tuser,
    output wire                             as_is_tready,
    //AXI Output Stream for User Project
    output wire [pDATA_WIDTH-1:0]           as_up_tdata,
	`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		output wire 	[pUSER_PROJECT_SIDEBAND_WIDTH-1:0] as_up_tupsb,
	`endif
    output wire [pDATA_WIDTH/8-1:0]         as_up_tstrb,    
    output wire [pDATA_WIDTH/8-1:0]         as_up_tkeep,
    output wire                             as_up_tlast,
    output wire                             as_up_tvalid,
    output wire [1:0]                       as_up_tuser,    
    input  wire                             up_as_tready,   
    //AXI Output Stream for Axis_Axilite
    output wire [pDATA_WIDTH-1:0]           as_aa_tdata,
    output wire [pDATA_WIDTH/8-1:0]         as_aa_tstrb,    
    output wire [pDATA_WIDTH/8-1:0]         as_aa_tkeep,
    output wire                             as_aa_tlast,    
    output wire                             as_aa_tvalid,
    output wire [1:0]                       as_aa_tuser, 
    input  wire                             aa_as_tready
);
localparam  USER_WIDTH = 2;
localparam  TID_WIDTH = 2;   
//for arbiter
localparam N = 3; //Upstream master Num for Input port
//source 0 support req/hi_req for user project
//source 1 support req for axilite_axis
//source 2 support req/hi_req for Logic Analyzer
localparam req_mask = 3'b111; //normal request mask for Upstream
localparam hi_req_mask = 3'b101; //high request mask for Upstream 
localparam last_support = 3'b000; //last signal support for hi request
//for Demux
// FIFO depth
localparam  FIFO_DEPTH = 16;   
//FIFO address width
localparam ADDR_WIDTH   = $clog2(FIFO_DEPTH);
//field offset for mem unit 
`ifdef USER_PROJECT_SIDEBAND_SUPPORT
	localparam UPSB_OFFSET  = pDATA_WIDTH;
	localparam STRB_OFFSET  = UPSB_OFFSET + pUSER_PROJECT_SIDEBAND_WIDTH;
`else
	localparam STRB_OFFSET  = pDATA_WIDTH;
`endif
localparam KEEP_OFFSET  = STRB_OFFSET + pDATA_WIDTH/8;
localparam LAST_OFFSET  = KEEP_OFFSET + pDATA_WIDTH/8;
localparam TID_OFFSET   = LAST_OFFSET + 1;
localparam USER_OFFSET  = TID_OFFSET  + TID_WIDTH;
localparam WIDTH        = USER_OFFSET + USER_WIDTH;


/////////////////////////////////////////////////////for axi_lite/////////////////////////////////////////
//write addr channel

//axi_lite reg
//FIFO threshold setting
reg [ADDR_WIDTH-1:0] TH_reg; //offset0, bit3:0
wire axi_awvalid_in;
wire axi_wvalid_in;
wire axi_awready_out;
wire axi_wready_out;

assign axi_awvalid_in = axi_awvalid && cc_as_enable;
assign axi_awready = axi_awready_out;
//write data channel
assign axi_wvalid_in = axi_wvalid && cc_as_enable;
assign axi_wready = axi_wready_out;
// if both axi_awvalid_in=1 and axi_wvalid_in=1 then output axi_awready_out = 1 and axi_wready_out = 1
assign axi_awready_out = (axi_awvalid_in && axi_wvalid_in) ? 1'b1 : 1'b0;
assign axi_wready_out = (axi_awvalid_in && axi_wvalid_in) ? 1'b1 : 1'b0;
//write register
always @(posedge axis_clk or negedge axi_reset_n)  begin
	if ( !axi_reset_n ) begin
		TH_reg <= 4'h6;
	end
	else begin
		if ( axi_awvalid_in && axi_wvalid_in ) begin		//when axi_awvalid_in=1 and axi_wvalid_in=1 means axi_awready_out=1 and axi_wready_out=1
			if (axi_awaddr[11:2] == 10'h000 && (axi_wstrb[0] == 1) ) begin //offset 0 //axi_awaddr is DW address
				TH_reg <= axi_wdata[3:0];
			end
			else begin
				TH_reg <= TH_reg;
			end
		end
	end
end
//axis_switch always output axi_arready = 1 and don't care the axi_arvalid & axi_araddr
//axis_switch only support 1 register bits in offset 0. config read other address offset is reserved.
assign axi_arready = 1;
// axis_switch  always output axi_rvalid = 1 and axi_rdata =  { 28'b0, TH_reg}
assign axi_rvalid = 1;
assign axi_rdata =  { 28'b0, TH_reg };

/////////////////////////////////////////////////////////////////////////////////////////////////////////




//////////////////////////////////////////////////Upstream///////////////////////////////////////////
//For Arbiter
wire [N-1:0]                req, hi_req;
wire  [N-1:0]                grant;


reg [pDATA_WIDTH-1:0]       m_axis_tdata_reg;
`ifdef USER_PROJECT_SIDEBAND_SUPPORT
	reg [pUSER_PROJECT_SIDEBAND_WIDTH-1:0]     m_axis_tupsb_reg;
`endif
reg [pDATA_WIDTH/8-1:0]     m_axis_tstrb_reg;
reg [pDATA_WIDTH/8-1:0]     m_axis_tkeep_reg; 
reg                         m_axis_tlast_reg;        
reg                         m_axis_tvalid_reg;
reg [USER_WIDTH-1:0]        m_axis_tuser_reg;     
reg [TID_WIDTH-1:0]         m_axis_tid_reg;






//for Abiter
assign  req[0] = up_as_tvalid & req_mask[0];
assign  req[1] = aa_as_tvalid & req_mask[1];
assign  req[2] = la_as_tvalid & req_mask[2];
assign  hi_req[0] = up_hpri_req & hi_req_mask[0];
assign  hi_req[1] = hi_req_mask[1];
assign  hi_req[2] = la_hpri_req & hi_req_mask[2];
assign  as_is_tdata     = m_axis_tdata_reg;
`ifdef USER_PROJECT_SIDEBAND_SUPPORT
	assign  as_is_tupsb     = m_axis_tupsb_reg;
`endif
assign  as_is_tstrb     = m_axis_tstrb_reg;
assign  as_is_tkeep     = m_axis_tkeep_reg; 
assign  as_is_tlast     = m_axis_tlast_reg;        
assign  as_is_tvalid    = m_axis_tvalid_reg;
assign  as_is_tuser     = m_axis_tuser_reg;   
assign  as_is_tid       = m_axis_tid_reg;
assign  as_up_tready = grant[0] && is_as_tready;    
assign  as_aa_tready = grant[1] && is_as_tready;
assign  as_la_tready = grant[2] && is_as_tready;    

 

always @(*) begin
  case (grant)
    3'b001: begin   					// For UP 
        m_axis_tdata_reg  = up_as_tdata;
`ifdef USER_PROJECT_SIDEBAND_SUPPORT
        m_axis_tupsb_reg  = up_as_tupsb;
`endif
        m_axis_tstrb_reg  = up_as_tstrb;
        m_axis_tkeep_reg  = up_as_tkeep;
        m_axis_tvalid_reg = up_as_tvalid; 
        m_axis_tuser_reg  = up_as_tuser;
        m_axis_tid_reg    = 2'b00;  
        m_axis_tlast_reg  = up_as_tlast;  
    end
    3'b010: begin  						// For AA 
        m_axis_tdata_reg  = aa_as_tdata;
        m_axis_tstrb_reg  = aa_as_tstrb;
        m_axis_tkeep_reg  = aa_as_tkeep;
        m_axis_tvalid_reg = aa_as_tvalid;   
        m_axis_tuser_reg  = aa_as_tuser;
        m_axis_tid_reg    = 2'b01; 
        m_axis_tlast_reg  = aa_as_tlast;              
    end	
    3'b100: begin  						// For LA 
        m_axis_tdata_reg  = la_as_tdata;
        m_axis_tstrb_reg  = la_as_tstrb;
        m_axis_tkeep_reg  = la_as_tkeep;	
        m_axis_tvalid_reg = la_as_tvalid; 
        m_axis_tuser_reg  = la_as_tuser;
        m_axis_tid_reg    = 2'b10; 
        m_axis_tlast_reg  = la_as_tlast;    
    end
    default: begin
        m_axis_tdata_reg  = 32'h0000_0000;
`ifdef USER_PROJECT_SIDEBAND_SUPPORT
        m_axis_tupsb_reg  = 5'b0000_0;
`endif
        m_axis_tstrb_reg  = 4'b0000;
        m_axis_tkeep_reg  = 4'b0000;
        m_axis_tvalid_reg = 1'b0;
        m_axis_tuser_reg  = 2'b00;
        m_axis_tid_reg    = 2'b00; 
        m_axis_tlast_reg  = 0;           
    end
  endcase  
end


reg [2:0] cnt;
//////////  counter for arbiter ack ///////////

always @(posedge axis_clk or negedge axi_reset_n)  begin
	if ( !axi_reset_n ) begin
	    cnt <= 3'b000;
	end
	else begin
		if ( grant!=3'b000 & (grant&hi_req)==3'b000 ) begin	// when grant is not in the hi_req state, after trransfer cnt+1.	
            if(as_is_tvalid & is_as_tready)  cnt<=cnt+1;
            else cnt<=cnt;      
		end
        else 
        cnt <= 3'b000;
	end
end
// scalable arb
arbiter #(.PORTS(3)) arbiter
    (
        .axis_clk(axis_clk),
        .axi_reset_n(axi_reset_n),
        .req(req),
        .hi_req(hi_req),
	    .ack((as_is_tvalid & is_as_tready & as_is_tlast)|cnt==3'b111), // tlast or cnt=3'b111 would go to the change state.
        .grant(grant)
    );


/////////////////////////////////// Downstream//////////////////////////////////////////////////
wire D_m_axis_tvalid; // Downstream master axis tvalid
wire D_m_axis_tready; // Downstream master axis tready
wire [WIDTH-1:0] s_axis; // slave from is.
wire [WIDTH-1:0] m_axis;
generate
    assign s_axis[pDATA_WIDTH-1:0]                  = is_as_tdata;
	`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		assign s_axis[UPSB_OFFSET +: pUSER_PROJECT_SIDEBAND_WIDTH]     = is_as_tupsb;
	`endif
    assign s_axis[STRB_OFFSET +: pDATA_WIDTH/8]     = is_as_tstrb;
    assign s_axis[KEEP_OFFSET +: pDATA_WIDTH/8]     = is_as_tkeep;
    assign s_axis[LAST_OFFSET]                      = is_as_tlast;
    assign s_axis[TID_OFFSET   +: TID_WIDTH]        = is_as_tid;
    assign s_axis[USER_OFFSET +: USER_WIDTH]        = is_as_tuser;
endgenerate




assign D_m_axis_tready=(as_up_tvalid && up_as_tready) | (as_aa_tvalid && aa_as_tready);

assign as_up_tvalid =(m_axis[TID_OFFSET +: TID_WIDTH]==2'b00) && D_m_axis_tvalid; 
assign as_up_tdata = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b00) ? m_axis[pDATA_WIDTH - 1:0]: 0;
`ifdef USER_PROJECT_SIDEBAND_SUPPORT
assign as_up_tupsb = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b00) ? m_axis[UPSB_OFFSET +: pUSER_PROJECT_SIDEBAND_WIDTH]: 0;
`endif
assign as_up_tstrb = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b00) ? m_axis[STRB_OFFSET +: pDATA_WIDTH/8]: 0;
assign as_up_tkeep = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b00) ? m_axis[KEEP_OFFSET +: pDATA_WIDTH/8]: 0;
assign as_up_tlast = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b00) ? m_axis[LAST_OFFSET]: 0;
assign as_up_tuser = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b00) ? m_axis[USER_OFFSET +: USER_WIDTH]: 0;


assign as_aa_tvalid =(m_axis[TID_OFFSET +: TID_WIDTH]==2'b01) && D_m_axis_tvalid;
assign as_aa_tdata = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b01) ? m_axis[pDATA_WIDTH-1:0]: 0;
assign as_aa_tstrb = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b01) ? m_axis[STRB_OFFSET +: pDATA_WIDTH/8]: 0;
assign as_aa_tkeep = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b01) ? m_axis[KEEP_OFFSET +: pDATA_WIDTH/8]: 0;
assign as_aa_tlast = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b01) ? m_axis[LAST_OFFSET]: 0;
assign as_aa_tuser = (m_axis[TID_OFFSET +: TID_WIDTH]==2'b01) ? m_axis[USER_OFFSET +: USER_WIDTH]: 0;

    localparam fifo_depth=16;
    localparam sram_datawidth=100;
    wire sram_we;
    wire [$clog2(fifo_depth)-1:0] sram_addr;
    wire [sram_datawidth-1:0]sram_din;
    wire [sram_datawidth-1:0] sram_dout;

    fifo #(.WIDTH(WIDTH),.depth(fifo_depth),.sram_datawidth(sram_datawidth)) fifo
    (
        .axis_clk(axis_clk),
        .axi_reset_n(axi_reset_n),
        .w_vld(is_as_tvalid),
        .w_rdy(as_is_tready),
        .data_in(s_axis),
        .r_vld(D_m_axis_tvalid),
        .r_rdy(D_m_axis_tready),
        .data_out(m_axis),
        .TH_reg({4'd0,TH_reg}),
        .sram_we(sram_we),
        .sram_addr(sram_addr),
        .sram_din(sram_din),
        .sram_dout(sram_dout)
    );

`ifdef USE_PDK_SRAM
    ra1shd16x100m4h3v2 SRAM16x100(
        .CLK(axis_clk),
        .WEN(~sram_we),
        .OEN(1'b0),
        .CEN(1'b0),
        .A(sram_addr),
        .D(sram_din),
        .Q(sram_dout)
    );
`else
    SRAM1RW64x128 SRAM1RW64x128(
        .CE(axis_clk),
        .WEB(~sram_we),// WEB =1 is read WEB=0 is w_vldite
        .OEB(1'b0),
        .CSB(1'b0),
        .A(sram_addr),
        .I(sram_din),
        .O(sram_dout)
    );
`endif

endmodule
