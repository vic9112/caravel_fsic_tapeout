`timescale 1 ns / 1 ps

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


////////////////////////////for outputsignal/////////////////////
wire cc_aa_enable_w;
wire cc_as_enable_w;
wire cc_is_enable_w;
wire cc_la_enable_w;
wire cc_up_enable_w;

wire cc_aa_enable_r;
wire cc_as_enable_r;
wire cc_is_enable_r;
wire cc_la_enable_r;
wire cc_up_enable_r;

assign cc_aa_enable=cc_aa_enable_w|cc_aa_enable_r;
assign cc_as_enable=cc_as_enable_w|cc_as_enable_r;
assign cc_is_enable=cc_is_enable_w|cc_is_enable_r;
assign cc_la_enable=cc_la_enable_w|cc_la_enable_r;
assign cc_up_enable=cc_up_enable_w|cc_up_enable_r;

reg [4:0]user_prj_sel_o;
assign user_prj_sel=user_prj_sel_o;

reg          m_arvalid;
reg  [31: 0] m_araddr;
reg          m_rready;
reg          m_awvalid;
reg  [31: 0] m_awaddr;
reg          m_wvalid;
reg  [31: 0] m_wdata;
reg   [3: 0] m_wstrb;

assign axi_awvalid=m_awvalid;
assign axi_awaddr=m_awaddr[14:0];
assign axi_wvalid=m_wvalid;
assign axi_wdata=m_wdata;
assign axi_wstrb=m_wstrb;
assign axi_arvalid=m_arvalid;
assign axi_araddr=m_araddr[14:0];
assign axi_rready=m_rready;





///////////////// wb2axi////////////////////////////// 
wire          wb_cfg_awvalid;
wire  [31: 0] wb_cfg_awaddr;
wire          wb_cfg_wvalid;
wire  [31: 0] wb_cfg_wdata;
wire   [3: 0] wb_cfg_wstrb;
wire          wb_cfg_arvalid;
wire  [31: 0] wb_cfg_araddr;
wire          wb_cfg_rready;
wire  [31: 0] wb_cfg_rdata;
wire          wb_cfg_rvalid;
wire          wb_cfg_awready;
wire          wb_cfg_wready;
wire          wb_cfg_arready;

wire w_en;
wire r_en;
assign  w_en=wbs_cyc & wbs_stb & wbs_we;
assign  r_en=wbs_cyc & wbs_stb & ~wbs_we;
assign wb_cfg_awvalid = w_en;
assign wb_cfg_wvalid  = w_en;

assign wb_cfg_arvalid = r_en;
assign wb_cfg_rready  = r_en;

assign wb_cfg_awaddr=wbs_adr;
assign wb_cfg_araddr=wbs_adr;

assign wb_cfg_wdata=wbs_wdata;
assign wbs_rdata=wb_cfg_rdata;
assign wb_cfg_wstrb=wbs_sel;

assign wbs_ack=(w_en & wb_cfg_awready & wb_cfg_wready )| (r_en & wb_cfg_rvalid );


////////////////////  write protocol /////////////////////////////////////////

wire          m_awready;
wire          m_wready;
wire [1:0] w_grant;
wire cc_enable_w;
wire cc_sub_enable_w;

assign cc_aa_enable_w = ( m_awaddr[31:12] == 20'h30002 )? 1'b1 : 1'b0;
assign cc_as_enable_w = ( m_awaddr[31:12] == 20'h30004 )? 1'b1 : 1'b0;
assign cc_is_enable_w = ( m_awaddr[31:12] == 20'h30003 )? 1'b1 : 1'b0;
assign cc_la_enable_w = ( m_awaddr[31:12] == 20'h30001 )? 1'b1 : 1'b0;
assign cc_up_enable_w = (m_awaddr[31:12] == 20'h30000 )? 1'b1 : 1'b0;
assign cc_enable_w = ( m_awaddr[31:12] == 20'h30005 )? 1'b1 : 1'b0;
assign cc_sub_enable_w = ( (m_awaddr[31:12] >= 20'h30006) && (m_awaddr[31:12] <= 20'h3FFFF ) )? 1'b1 : 1'b0;

assign m_awready = ((((((({1{cc_up_enable_w}} & axi_awready2) | ({1{cc_la_enable_w}} & axi_awready0)) | ({1{cc_aa_enable_w}} & axi_awready1)) | ({1{cc_is_enable_w}} & axi_awready3)) | ({1{cc_as_enable_w}} & axi_awready4)) | ({1{cc_enable_w}} & 1'b1)) | ({1{cc_sub_enable_w}} & 1'b1));
assign m_wready = ((((((({1{cc_up_enable_w}} & axi_wready2) | ({1{cc_la_enable_w}} & axi_wready0)) | ({1{cc_aa_enable_w}} & axi_wready1)) | ({1{cc_is_enable_w}} & axi_wready3)) | ({1{cc_as_enable_w}} & axi_wready4)) | ({1{cc_enable_w}} & 1'b1)) | ({1{cc_sub_enable_w}} & 1'b1));

assign wb_cfg_wready=(w_grant==2'b01)?m_wready:0;
assign aa_cfg_wready=(w_grant==2'b10)?m_wready:0;

assign wb_cfg_awready=(w_grant==2'b01)? m_awready:0;
assign aa_cfg_awready=(w_grant==2'b10)? m_awready:0;


wire [1:0]	w_req;
assign w_req[0]=wb_cfg_awvalid & wb_cfg_wvalid;
assign w_req[1]=aa_cfg_awvalid & aa_cfg_wvalid;



always @(*) begin
  case (w_grant)
    2'b01: begin   				
		m_awvalid=wb_cfg_awvalid;
		m_awaddr=wb_cfg_awaddr;
		m_wvalid=wb_cfg_wvalid;
		m_wdata=wb_cfg_wdata;
		m_wstrb=wb_cfg_wstrb;
    end
    2'b10: begin  				
   		m_awvalid=aa_cfg_awvalid;
		m_awaddr=aa_cfg_awaddr;
		m_wvalid=aa_cfg_wvalid;
		m_wdata=aa_cfg_wdata;
		m_wstrb=aa_cfg_wstrb;         
    end	
    default: begin
    	m_awvalid=0;
		m_awaddr=0;
		m_wvalid=0;
		m_wdata=0;
		m_wstrb=0;   
    end
  endcase  
end


	arbiter #(.PORTS(2)) w_arbiter
    (
        .axis_clk(axi_clk),
        .axi_reset_n(axi_reset_n),
        .req(w_req),
        .hi_req(2'b00), // no high req in this arb
        .ack(m_wready & m_awready), // should change 
        .grant(w_grant)
    );

//////////////////////////////////////  read protocol //////////////////////////////////////////////


wire  [31: 0] m_rdata;
wire          m_rvalid;
wire          m_arready;
wire [1:0]	r_req;
wire [1:0] r_grant;
assign r_req[0]=wb_cfg_arvalid & wb_cfg_rready;
assign r_req[1]=aa_cfg_arvalid & aa_cfg_rready;


wire cc_enable_r;
wire cc_sub_enable_r;

assign cc_aa_enable_r = ( m_araddr[31:12] == 20'h30002 )? 1'b1 : 1'b0;
assign cc_as_enable_r = ( m_araddr[31:12] == 20'h30004 )? 1'b1 : 1'b0;
assign cc_is_enable_r = ( m_araddr[31:12] == 20'h30003 )? 1'b1 : 1'b0;
assign cc_la_enable_r = ( m_araddr[31:12] == 20'h30001 )? 1'b1 : 1'b0;
assign cc_up_enable_r = (m_araddr[31:12] == 20'h30000 )? 1'b1 : 1'b0;
assign cc_enable_r = ( m_araddr[31:12] == 20'h30005 )? 1'b1 : 1'b0;
assign cc_sub_enable_r = ( (m_araddr[31:12] >= 20'h30006) && (m_araddr[31:12] <= 20'h3FFFF ) )? 1'b1 : 1'b0;

assign m_arready = ((((((({1{cc_up_enable_r}} & axi_arready2) | ({1{cc_la_enable_r}} & axi_arready0)) | ({1{cc_aa_enable_r}} & axi_arready1)) | ({1{cc_is_enable_r}} & axi_arready3)) | ({1{cc_as_enable_r}} & axi_arready4)) | ({1{cc_enable_r}} & 1'b1)) | ({1{cc_sub_enable_r}} & 1'b1));
assign m_rdata = ((((((({32{cc_up_enable_r}} & axi_rdata2) | ({32{cc_la_enable_r}} & axi_rdata0)) | ({32{cc_aa_enable_r}} & axi_rdata1)) | ({32{cc_is_enable_r}} & axi_rdata3)) | ({32{cc_as_enable_r}} & axi_rdata4)) | ({32{cc_enable_r}} & { 27'b0, user_prj_sel_o } )) | ({32{cc_sub_enable_r}} & 32'hFFFFFFFF));
assign m_rvalid = ((((((({1{cc_up_enable_r}} & axi_rvalid2) | ({1{cc_la_enable_r}} & axi_rvalid0)) | ({1{cc_aa_enable_r}} & axi_rvalid1)) | ({1{cc_is_enable_r}} & axi_rvalid3)) | ({1{cc_as_enable_r}} & axi_rvalid4)) | ({1{cc_enable_r}} & 1'b1)) | ({1{cc_sub_enable_r}} & 1'b1));


assign wb_cfg_arready=(r_grant==2'b01)?m_arready:0;
assign aa_cfg_arready=(r_grant==2'b10)?m_arready:0;
assign wb_cfg_rvalid=(r_grant==2'b01)?m_rvalid:0;
assign aa_cfg_rvalid=(r_grant==2'b10)?m_rvalid:0;

assign wb_cfg_rdata=m_rdata;
assign aa_cfg_rdata=m_rdata;



always @(*) begin
  case (r_grant)
    2'b01: begin   				
		m_arvalid=wb_cfg_arvalid;
		m_araddr=wb_cfg_araddr;
		m_rready=wb_cfg_rready;
    end
    2'b10: begin  				
		m_arvalid=aa_cfg_arvalid;
		m_araddr=aa_cfg_araddr;
		m_rready=aa_cfg_rready;    
    end	
    default: begin
		m_arvalid=0;
		m_araddr=0;
		m_rready=0;    
    end
  endcase  
end

	arbiter #(.PORTS(2)) r_arbiter
    (
        .axis_clk(axi_clk),
        .axi_reset_n(axi_reset_n),
        .req(r_req),
        .hi_req(2'b00), // no high req in this arbiter
        .ack(m_rvalid), // check rvalid come behind arready
        .grant(r_grant)
    );
/////////////////////////////////////  config register////////////////////////////////////

	always @ ( posedge axi_clk or negedge axi_reset_n ) 
	begin	
		if ( !axi_reset_n ) begin
			user_prj_sel_o <= 5'b0;
		end else begin
			if ( m_awvalid && m_wvalid && cc_enable_w ) begin
				if (m_awaddr[11:0] == 12'h000 && (m_wstrb[0] == 1) ) begin //offset 0
					user_prj_sel_o <= m_wdata[4:0];
				end
				else begin
					user_prj_sel_o <= user_prj_sel_o;
				end
			end
			else user_prj_sel_o <= user_prj_sel_o;
		end
	end	
endmodule


