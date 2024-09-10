`timescale 1 ns / 1 ps

module CFG_CTRL #( parameter pADDR_WIDTH   = 12,
                   parameter pDATA_WIDTH   = 32
                 )
(
	//////////////////////////////////////
	// FPGA AXI-Lite, from Axis-Axilite //
	//////////////////////////////////////

	//FPGA AXI-Lite介面（輸入）(8個)
	input  wire          aa_cfg_awvalid,	//AXI-Lite寫地址有效信號
	input  wire  [31: 0] aa_cfg_awaddr,		//AXI-Lite寫地址
	input  wire          aa_cfg_wvalid,		//AXI-Lite寫數據有效信號
	input  wire  [31: 0] aa_cfg_wdata,		//AXI-Lite寫數據
	input  wire   [3: 0] aa_cfg_wstrb,		//AXI-Lite寫字節選擇信號
	input  wire          aa_cfg_arvalid,	//AXI-Lite讀地址有效信號
	input  wire  [31: 0] aa_cfg_araddr,		//AXI-Lite讀地址
	input  wire          aa_cfg_rready,		//AXI-Lite讀數據準備好信號

	//FPGA AXI-Lite介面（輸出）(5個)
	output wire  [31: 0] aa_cfg_rdata,		//AXI-Lite讀數據
	output wire          aa_cfg_rvalid,		//AXI-Lite讀數據有效信號

	output wire          aa_cfg_awready,	//AXI-Lite寫地址準備好信號
	output wire          aa_cfg_wready,		//AXI-Lite寫數據準備好信號
	output wire          aa_cfg_arready,	//AXI-Lite讀地址準備好信號
	
	/////////////////////
	// AXI-Lite Master //
	/////////////////////
	//AXI-Lite Master介面（輸入）(5個*5)
	input  wire          axi_wready1,		//for AXIL_AXIS		//各個AXI-Lite寫數據準備好信號
	input  wire          axi_awready1,							//各個AXI-Lite寫地址準備好信號
	input  wire          axi_arready1,							//各個AXI-Lite讀地址準備好信號
	input  wire  [31: 0] axi_rdata1,							//各個AXI-Lite讀數據
	input  wire          axi_rvalid1,							//各個AXI-Lite讀數據有效信號
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

	//AXI-Lite Master介面（輸出）(8個)
	output wire          axi_awvalid,		//AXI-Lite寫地址有效信號
	output wire  [14: 0] axi_awaddr,		//AXI-Lite寫地址
	output wire          axi_wvalid,		//AXI-Lite寫數據有效信號
	output wire  [31: 0] axi_wdata,			//AXI-Lite寫數據
	output wire   [3: 0] axi_wstrb,			//AXI-Lite寫字節選擇信號
	output wire          axi_arvalid,		//AXI-Lite讀地址有效信號
	output wire  [14: 0] axi_araddr,		//AXI-Lite讀地址
	output wire          axi_rready,		//AXI-Lite讀數據準備好信號
	
	//////////////////////
	// Target Selection //
	//////////////////////
	//目標選擇（輸出）
	output wire          cc_aa_enable,
	output wire          cc_as_enable,
	output wire          cc_is_enable,
	output wire          cc_la_enable,
	output wire          cc_up_enable,
	output wire   [4: 0] user_prj_sel,  // -- Jiin extend with parameterized
	
	////////////////////////
	// Wishbone interface //
	////////////////////////
	//Wishbone介面(輸入)(8個)
	input  wire          wb_rst,		//Wishbone重置信號
	input  wire          wb_clk,		//Wishbone時鐘信號
	input  wire  [31: 0] wbs_adr,		//Wishbone從屬地址
	input  wire  [31: 0] wbs_wdata,		//Wishbone寫數據
	input  wire   [3: 0] wbs_sel,		//Wishbone字節選擇信號
	input  wire          wbs_cyc,		//Wishbone週期信號
	input  wire          wbs_stb,		//Wishbone選擇信號
	input  wire          wbs_we,		//Wishbone寫使能信號
	//(輸出)(2個)
	output wire          wbs_ack,		//Wishbone應答信號
	output wire  [31: 0] wbs_rdata,		//Wishbone讀數據
	
	//////////////////////////
	// Top AXI-Lite Signals //
	//////////////////////////
	//上層AXI-Lite信號
	input  wire          axi_clk,		//AXI時鐘
	input  wire          axi_reset_n,	//AXI復位信號（低有效）

	input  wire          user_clock2,	//用戶時鐘2(無用)
	input  wire          uck2_rst_n		//用戶時鐘2復位信號（低有效）

	/*
	output wire wb_axi_request_t,
	output wire wb_axi_request_done_t,
	output wire f_axi_request_t,
	output wire f_axi_request_done_t,

	output wire m_axi_request_t,
	output wire m_axi_request_done_t,

	output wire [31:0] a,
	output wire [31:0] b
	*/

);
	/*
	assign wb_axi_request_t	= wb_axi_request;
	assign wb_axi_request_done_t = wb_axi_request_done;
	assign f_axi_request_t = f_axi_request;
	assign f_axi_request_done_t = f_axi_request_done;
	assign m_axi_request_t = m_axi_request;
	assign m_axi_request_done_t = m_axi_request_done;

	assign a = f_axi_rdata;
	assign b = wb_axi_rdata;
	*/

	////////////////////////////
	// Internal Signals begin //
	////////////////////////////	
	//reg wb_fsm_reg;					//Wishbone狀態機寄存器
	wire wb_axi_request;				//Wishbone AXI請求信號
	reg wb_axi_request_rw;				//Wishbone AXI請求讀寫信號
	wire [31:0] wb_axi_request_add;
	wire [3:0] wb_axi_wstrb;			//Wishbone AXI寫字節選擇信號			
	wire wb_axi_request_done;			//Wishbone AXI請求完成信號
	wire [31:0] wb_axi_rdata;

	wire f_axi_request;					//AXI請求信號
	reg f_axi_request_rw;				//AXI請求讀寫信號
	wire [3:0] f_axi_wstrb;				//AXI寫字節選擇信號
	wire f_axi_request_done;			//AXI請求完成信號
	wire [31:0] f_axi_request_add;		//AXI請求地址
	wire [31:0] f_axi_wdata;
	wire [31:0] f_axi_rdata;
	
	
	reg axi_grant_o_reg;				//AXI許可寄存器
	wire m_axi_request;					//主AXI請求信號
	wire m_axi_request_rw;				//主AXI請求讀寫信號
	wire [3:0] m_axi_wstrb;				//主AXI寫字節選擇信號
	wire m_axi_request_done;			//主AXI請求完成信號
	wire [31:0] m_axi_request_add;		//主AXI請求地址
	wire [31:0] m_axi_wdata;			//主AXI寫數據
	
	wire m_axi_awready;					//主AXI寫地址準備好信號
	wire m_axi_wready;					//主AXI寫數據準備好信號
	wire m_axi_arready;					//主AXI讀地址準備好信號
	wire [31:0] m_axi_rdata;			//主AXI讀數據
	wire m_axi_rvalid;					//主AXI讀數據有效信號
	
	wire cc_enable;						//目標啟用信號
	wire cc_sub_enable;					//子目標啟用信號
	wire cc_axi_awvalid;				//控制信號AXI寫地址有效
	wire cc_axi_wvalid;					//控制信號AXI寫數據有效

	
	//////////////////////////////////////
	// Internal signals for Ports begin //
	//////////////////////////////////////

	reg [4: 0] user_prj_sel_o;
	
	///////////////////////////////////
	// Assignment for Internal begin //
	///////////////////////////////////
	assign m_axi_request = axi_grant_o_reg ? f_axi_request : wb_axi_request;
	assign m_axi_request_done = axi_grant_o_reg ? f_axi_request_done : wb_axi_request_done;
	assign m_axi_request_rw = axi_grant_o_reg ? f_axi_request_rw : wb_axi_request_rw;
	assign m_axi_wstrb = axi_grant_o_reg ? f_axi_wstrb : wb_axi_wstrb;
	assign m_axi_request_add = axi_grant_o_reg ? f_axi_request_add : wb_axi_request_add;
	assign m_axi_wdata = axi_grant_o_reg ? aa_cfg_wdata : wbs_wdata;


	assign m_axi_awready = ((((((({1{cc_up_enable}} & axi_awready2) | ({1{cc_la_enable}} & axi_awready0)) | ({1{cc_aa_enable}} & axi_awready1)) | ({1{cc_is_enable}} & axi_awready3)) | ({1{cc_as_enable}} & axi_awready4)) | ({1{cc_enable}} & cc_axi_awvalid/*axi_awready5*/)) | ({1{cc_sub_enable}} & axi_awvalid));
	assign m_axi_wready = ((((((({1{cc_up_enable}} & axi_wready2) | ({1{cc_la_enable}} & axi_wready0)) | ({1{cc_aa_enable}} & axi_wready1)) | ({1{cc_is_enable}} & axi_wready3)) | ({1{cc_as_enable}} & axi_wready4)) | ({1{cc_enable}} & cc_axi_wvalid/*axi_wready5*/)) | ({1{cc_sub_enable}} & axi_wvalid));
	assign m_axi_arready = ((((((({1{cc_up_enable}} & axi_arready2) | ({1{cc_la_enable}} & axi_arready0)) | ({1{cc_aa_enable}} & axi_arready1)) | ({1{cc_is_enable}} & axi_arready3)) | ({1{cc_as_enable}} & axi_arready4)) | ({1{cc_enable}} & 1/*axi_arready5*/)) | ({1{cc_sub_enable}} & axi_arvalid));
	assign m_axi_rdata = ((((((({32{cc_up_enable}} & axi_rdata2) | ({32{cc_la_enable}} & axi_rdata0)) | ({32{cc_aa_enable}} & axi_rdata1)) | ({32{cc_is_enable}} & axi_rdata3)) | ({32{cc_as_enable}} & axi_rdata4)) | ({32{cc_enable}} & {27'b0, user_prj_sel_o}/*axi_rdata5*/)) | ({32{cc_sub_enable}} & 32'hFFFFFFFF));
	assign m_axi_rvalid = ((((((({1{cc_up_enable}} & axi_rvalid2) | ({1{cc_la_enable}} & axi_rvalid0)) | ({1{cc_aa_enable}} & axi_rvalid1)) | ({1{cc_is_enable}} & axi_rvalid3)) | ({1{cc_as_enable}} & axi_rvalid4)) | ({1{cc_enable}} & 1/*axi_rvalid5*/)) | ({1{cc_sub_enable}} & axi_arvalid));
	
	assign cc_axi_awvalid = axi_awvalid && cc_enable;
	assign cc_axi_wvalid = axi_wvalid && cc_enable;

	////////////////////////////////
	// Assignment for Ports begin //
	////////////////////////////////
	//assign aa_cfg_rdata = aa_cfg_rdata_o;
	reg down2;
	assign aa_cfg_rdata = (down2 && aa_cfg_rready) ? f_axi_rdata : 0;
	assign aa_cfg_rvalid = (down2 && aa_cfg_rready) ? 1 : 0;
	assign aa_cfg_awready = aa_cfg_awvalid ? 1 : 0;
	assign aa_cfg_wready = (down2 && aa_cfg_wvalid) ? 1 : 0;
	assign aa_cfg_arready = aa_cfg_arvalid ? 1 : 0;


	reg axi_out;
	always @ ( posedge axi_clk or negedge axi_reset_n )
	begin
		if ( !axi_reset_n ) begin
			axi_out <= 0;
		end else 
		begin
			if(m_axi_request) begin
				axi_out <= 1;
			end
			if(m_axi_request_done) begin
				axi_out <= 0;
			end
		end
	end
	

	assign axi_awvalid = axi_out && m_axi_request_rw;
	assign axi_awaddr = axi_awvalid ? m_axi_request_add[14:0] : 0;
	assign axi_wvalid = axi_awvalid;
	assign axi_wdata = axi_awvalid ? m_axi_wdata : 0;
	assign axi_wstrb = axi_awvalid ? m_axi_wstrb : 0;
	assign axi_arvalid = axi_out && !m_axi_request_rw;
	assign axi_araddr = axi_arvalid ? m_axi_request_add[14:0] : 0;
	assign axi_rready = axi_out && !m_axi_request_rw;

	assign user_prj_sel = user_prj_sel_o;

	/////////////////////////////////
	// Always for Target Selection //
	/////////////////////////////////	

	reg [3:0] target_sel;
	always @ ( posedge axi_clk or negedge axi_reset_n)
	begin
    	if ( !axi_reset_n )
    	begin
        	target_sel <= 4'b0000;
    	end else
    	begin
        	case (m_axi_request_add[31:12])
            	20'h30002: target_sel <= 4'b0001;
            	20'h30004: target_sel <= 4'b0010;
            	20'h30003: target_sel <= 4'b0011;
            	20'h30001: target_sel <= 4'b0100;
            	20'h30000: target_sel <= 4'b0101;
            	20'h30005: target_sel <= 4'b0110;
            	default: target_sel <= 4'b0000;
        	endcase
    	end
	end

	assign cc_aa_enable = (target_sel == 4'b0001);
	assign cc_as_enable = (target_sel == 4'b0010);
	assign cc_is_enable = (target_sel == 4'b0011);
	assign cc_la_enable = (target_sel == 4'b0100);
	assign cc_up_enable = (target_sel == 4'b0101);
	assign cc_enable = (target_sel == 4'b0110);
	assign cc_sub_enable = (m_axi_request_add[31:12] >= 20'h30006) && (m_axi_request_add[31:12] <= 20'h3FFFF);
	

	////////////////////////////////////////////
	// Always for Wishbone Interface handling //
	////////////////////////////////////////////

	// --WB--
	assign wb_axi_request = !wb_rst && wbs_cyc && wbs_stb;
	assign wb_axi_request_done = (wbs_we==1)? (!axi_grant_o_reg && (m_axi_awready && m_axi_wready) && wbs_cyc): (!axi_grant_o_reg && (m_axi_rvalid) && wbs_cyc);
	assign wb_axi_request_add = wbs_adr;

	assign wbs_ack = wb_axi_request_done;
	assign wb_axi_wstrb = (wb_axi_request && wbs_we) ? wbs_sel : wb_axi_wstrb ;

	assign wbs_rdata = (wb_axi_request_done && !wb_axi_request_rw)?  wb_axi_rdata : 0;

	//wb_axi_request_rw
	always @ ( posedge wb_clk or posedge wb_rst)
	begin
		if ( wb_rst ) 
		begin
			wb_axi_request_rw = 0;			
		end else
		begin
			if(wbs_cyc)begin
				if(wbs_we)
					wb_axi_request_rw = 1;
				else
					wb_axi_request_rw = 0;
			end
		end
	end

	/////////////////////////////////////////////////
	// Always for FPGA-AXI-Lite Interface handling //
	////////////////////////////////////////////////

	assign f_axi_wstrb = aa_cfg_wvalid ? aa_cfg_wstrb : 0;

	//f_axi_request_rw
	always @ ( posedge axi_clk or negedge axi_reset_n)
	begin
		if ( !axi_reset_n )
		begin
			f_axi_request_rw = 0;
		end else
		begin
			if(aa_cfg_wvalid)
				f_axi_request_rw = 1;
			
			if( aa_cfg_arvalid)
				f_axi_request_rw = 0;
		end
	end


	reg aa_w;
	wire [31:0] f_axi_add1;
	wire [31:0] f_axi_add2;
	assign f_axi_add1 = aa_w ? aa_cfg_awaddr : aa_cfg_araddr;
	assign f_axi_add2 = (aa_cfg_awvalid || aa_cfg_arvalid || !axi_reset_n) ? f_axi_add1 : f_axi_add2;
	assign f_axi_request_add = f_axi_request ? f_axi_add2 : 0;

	always @ ( posedge axi_clk or negedge axi_reset_n)
	begin
		if ( !axi_reset_n )
		begin
			aa_w <= 0;
		end else
		begin
			if(aa_cfg_awvalid) 
				aa_w <= 1;
		
			if(aa_cfg_arvalid) 
				aa_w <= 0;
		end
	end

	// --f_axi_request_add
	/*
	always @ ( posedge axi_clk or negedge axi_reset_n)
	begin
		if ( !axi_reset_n )
		begin
			f_axi_request_add <= 0;
		end else
		begin
			if(f_axi_request && !f_axi_request_done)
			begin
				if(aa_cfg_awvalid)
					f_axi_request_add <= aa_cfg_awaddr;
				if(aa_cfg_arvalid)
					f_axi_request_add <= aa_cfg_araddr;
			end else
			begin
				f_axi_request_add <= 0;
			end
		end
	end
	*/
	/////////////////////////////////////////////////
	// Always for requests grant - axi_grant_o_reg //
	/////////////////////////////////////////////////
	always @( posedge wb_clk or posedge wb_rst )
	begin
		if ( wb_rst ) begin
			axi_grant_o_reg <= 1'b0;
		end else begin
			case (axi_grant_o_reg)
				1'b0: begin
					if ((~wb_axi_request)) begin
						if (f_axi_request) begin
							axi_grant_o_reg <= 1'b1;
						end
					end
				end
				1'b1: begin
					if ((~f_axi_request)) begin
						if (wb_axi_request) begin
							axi_grant_o_reg <= 1'b0;
						end
					end
				end			
			endcase
		end
	end		

	///////////////////////////////////////////////////
	// Always for AXI-Lite Master Interface handling //
	///////////////////////////////////////////////////
	
	// ---f_axi_request_done ---////////////////////////////////////////////////////////////////////
	wire axi_r;
	wire axi_w;
	reg axi_r_end;
	reg axi_w_end;
	reg down;
	
	
	assign axi_w = (axi_grant_o_reg && (m_axi_awready && m_axi_wready) && !axi_w_end);
	assign axi_r = (axi_grant_o_reg && m_axi_rvalid && !axi_r_end);
	// ---f_axi_request_done
	assign f_axi_request_done = (axi_r && aa_cfg_rready) || (axi_w && aa_cfg_wvalid);

	//f_axi_request
	assign f_axi_request = (aa_cfg_rready && !axi_r_end) || (aa_cfg_wvalid && !axi_w_end);
	
	always @ ( posedge axi_clk or negedge axi_reset_n )
	begin
		if ( !axi_reset_n ) begin
			axi_r_end <= 0;
			axi_w_end <= 0;
		end else begin
			if(axi_r) 
				axi_r_end <= 1;
			else
				axi_r_end <= 0;

			if(axi_w)
				axi_w_end <= 1;
			else	
				axi_w_end <= 0;

			if(f_axi_request_done)
				down2 <= 1;
			else
				down2 <= 0;	
		end
	end

	assign f_axi_rdata = (f_axi_request_done) ? m_axi_rdata : f_axi_rdata;
	assign wb_axi_rdata = (wb_axi_request_done) ? m_axi_rdata : wb_axi_rdata;
	/*
	always @ ( posedge axi_clk or negedge axi_reset_n)
	begin
		if ( !axi_reset_n )
		begin
			f_axi_rdata <= 0;
		end else
		begin
			if(f_axi_request_done) 
				f_axi_rdata <= m_axi_rdata;
			else
				f_axi_rdata <= f_axi_rdata;	
		end
	end

	always @ ( posedge axi_clk or negedge axi_reset_n)
	begin
		if ( !axi_reset_n )
		begin
			wb_axi_rdata <= 0;
		end else
		begin
			if(wb_axi_request_done) 
				wb_axi_rdata <= m_axi_rdata;
			else
				wb_axi_rdata <= wb_axi_rdata;	
		end
	end
	*/
	///////////////////////////////////////////
	// Always for AXI-Lite CC Slave response //
	///////////////////////////////////////////	

	always @ ( posedge axi_clk or negedge axi_reset_n ) 
	begin	
		if ( !axi_reset_n ) begin
			user_prj_sel_o <= 5'b0;
		end else begin
			if ( cc_axi_awvalid && cc_axi_wvalid ) begin
				if (axi_awaddr[11:0] == 12'h000 && (axi_wstrb[0] == 1) ) begin //offset 0
					user_prj_sel_o <= axi_wdata[4:0];
				end
				else begin
					user_prj_sel_o <= user_prj_sel_o;
				end
			end
		end
	end	

endmodule
