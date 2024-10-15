`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/15/2023 10:02:45 AM
// Design Name: 
// Module Name: LOGIC_ANLZ
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

// Function Description:
//   - Monitor signals provided by user project. Support up to 24 monitoring signals
//   - Support signal conditioning to trigger signal logging  (Currently, done by host program)
//   - Compress (Waveform compression, e.g. Run-Length-Encoding RLE) the logged signals and sent them to remote users using the Axis port. Waveform can be displayed in remote environments.
//   - Waveform log is designed to be saved in .vcd file format, it can be open by gtkwave.


module LOGIC_ANLZ #( parameter pADDR_WIDTH   = 15,
                     parameter pDATA_WIDTH   = 32
                   )
(
    //AxiLite
    output wire           axi_awready,
    output wire           axi_wready,
    output wire           axi_arready,
    output wire   [31: 0] axi_rdata,
    output wire           axi_rvalid,

    input  wire           axi_awvalid,
    input  wire   [14: 0] axi_awaddr,
    input  wire           axi_wvalid,
    input  wire   [31: 0] axi_wdata,
    input  wire   [3: 0]  axi_wstrb,
    input  wire           axi_arvalid,
    input  wire   [14: 0] axi_araddr,
    input  wire           axi_rready,
    input  wire           cc_la_enable,
    // input  wire           enable_la,     // Jiin : it is internal configuration register

    //AxiS  
    output wire   [31: 0] m_tdata,
    output wire   [3: 0]  m_tstrb,
    output wire   [3: 0]  m_tkeep,
    output wire           m_tlast,
    output wire           m_tvalid,
    output wire   [1: 0]  m_tuser,
    output wire           la_hpri_req,
    input  wire           m_tready,

    //User singals
    input  wire   [23: 0] up_la_data,

    //Generic
    input  wire           user_clock2,
    input  wire           axi_clk,
    input  wire           axi_reset_n,
    input  wire           axis_clk,
    input  wire           uck2_rst_n,
    input  wire           axis_rst_n
);
    localparam FIFO_DEPTH               = 32;  
    localparam AXIS_PKT_LEN             = 8; 
    localparam H_THRESH_DEFAULT         = 7'h40;
    localparam L_THRESH_DEFAULT         = 7'b10; 	

wire trace_push_ok;
reg [23:0] la_enable;
reg [6:0] h_thresh;
reg [6:0] l_thresh;
reg [6:0] pop_cond;
reg enable_la;              // Jiin configuratin register at 'h10  - it is used to reset enable_la
reg [7:0] rc_count;
reg [23:0] r_la_data;       // latched up_la_data;
wire la_change;             // la signal changed       
wire trace_push;            // trace is push into FIFO
wire fifo_full;
wire [31:0] trace_packet;
reg [7:0] fifo_count;       // Jiin: parameterize the size of fifo_count with FIFO_depth use $clog2
reg [7:0] tx_count;         // count # of transfer
reg la_hpri_req_o;


assign axi_awready  = axi_awvalid & axi_wvalid;
assign axi_wready   = axi_awvalid & axi_wvalid;

// axilite read - axi_rdata can be available when axi_arvalid (axi_araddr) is valid

assign axi_rvalid   = axi_arvalid;
assign axi_rdata    = (axi_araddr[11:2] == 10'h000) ? {8'b0, la_enable} :   
                      (axi_araddr[11:2] == 10'h001) ? {25'b0, h_thresh} :       // @'h4
                      (axi_araddr[11:2] == 10'h002) ? {25'b0, l_thresh} :       // @'h8
                      (axi_araddr[11:2] == 10'h003) ? {25'b0, pop_cond} :       // @'hc
                      (axi_araddr[11:2] == 10'h004) ? {31'b0, enable_la} : 32'hFFFFFFFF;  // Jiin @'h10
assign axi_arready  = axi_arvalid;

// Jiin : enable_la is the internal configuration register, we can not use enable_la to reset configuration register
//   use axi_reset_n instead
always @ ( posedge axi_clk or negedge axi_reset_n ) begin
    if( !axi_reset_n) begin
        la_enable   <= 24'h0;
        h_thresh    <= H_THRESH_DEFAULT;
        l_thresh    <= L_THRESH_DEFAULT;
        pop_cond    <= AXIS_PKT_LEN;
        enable_la   <= 1'b0;
    end 
    else if( cc_la_enable & axi_awvalid & axi_wvalid) begin
        if( axi_awaddr[11:2] == 10'h000) la_enable <= axi_wdata[23:0];
        if( axi_awaddr[11:2] == 10'h001) h_thresh  <= axi_wdata[6:0];
        if( axi_awaddr[11:2] == 10'h002) l_thresh  <= axi_wdata[6:0];
        if( axi_awaddr[11:2] == 10'h003) pop_cond  <= axi_wdata[6:0];
        if( axi_awaddr[11:2] == 10'h004) enable_la <= axi_wdata[0];         // Jiin: add configuration : enable_la
    end
end

assign la_change = |(la_enable & ( up_la_data != r_la_data)); 

// fifo full handling
//  - push null-packet all 0
//  - flush FIFO 
//  - restart - 
// issue: when fifo_full, do we still count rc?
// - rc continues count
// - signal waveform recovery
//   - when receive null-packet -> generate a cycle of 'x' signals
//   - generate signal waveforms with non-null packet with rc 


always @ ( posedge axi_clk or negedge enable_la) begin  // note: cc_la_enable to reset
    if( !enable_la ) begin
        rc_count  <= 8'h01;
        r_la_data <= 24'b0;
    end 
    else begin
        if( !la_change & rc_count != 8'hff)             // signal is not changed
            rc_count <= rc_count + 1;
        else begin
            r_la_data <= up_la_data;
            rc_count <= 8'h01;
        end
    end 
end


// trace_push : condition to push a trace into fifo
// 1. signal changes - la_change
// 2. rc_count reach 255
// 3. fifo_full -> push null packet (issue : use fifo_full - 1 or fifo_count == l_thread)

// --- FIFO Instance -----


`ifdef USE_PDK_SRAM
    localparam sram_datawidth=64;
`else
    localparam sram_datawidth=128;
`endif
    wire sram_we;
    wire [$clog2(FIFO_DEPTH)-1:0] sram_addr;
    wire [sram_datawidth-1:0]sram_din;
    wire [sram_datawidth-1:0] sram_dout;

// --- FIFO Instance -----
fifo #(.WIDTH(32),.depth(FIFO_DEPTH),.sram_datawidth(sram_datawidth),.mode(0)) la_fifo
(
    .axis_clk (axis_clk) ,
    .axi_reset_n (enable_la),
    .w_vld (trace_push),          // fifo push
    .w_rdy (trace_push_ok),          // w_rdy
    .data_in (trace_packet),
    .r_rdy (m_tready),          // directly connect to axis r_ready
    .r_vld (m_tvalid),          // connect to axis r_valid
    .data_out (m_tdata),
    .TH_reg(8'd0),
    .sram_we(sram_we),
    .sram_addr(sram_addr),
    .sram_din(sram_din),
    .sram_dout(sram_dout)
);

`ifdef USE_PDK_SRAM

    ra1shd32x64m4h3v2 la_SRAM32x64(
        .CLK(axis_clk),
        .WEN(~sram_we),// WEB =1 is read WEB=0 is w_vldite
        .OEN(1'b0),
        .CEN(1'b0),
        .A(sram_addr),
        .D(sram_din),
        .Q(sram_dout)
    );

`else
    SRAM1RW64x128 la_SRAM1RW64x128(
        .CE(axis_clk),
        .WEB(~sram_we),// WEB =1 is read WEB=0 is w_vldite
        .OEB(1'b0),
        .CSB(1'b0),
        .A(sram_addr),
        .I(sram_din),
        .O(sram_dout)
    );
`endif
// fifo pop & fifo push , m_tvalid is the fifo_empty , trace_push_ok is the fifo_full - JIANG
wire fifo_pop = m_tready & m_tvalid;
wire fifo_push = trace_push & trace_push_ok;

//  FIFO depth counter - it is used to asserts la_hpri_req
//  Jiin: explain the trace push logic
//  push condition
//  1. signal change: la_change
//  2. rc (repeat-count) reach maximum, i.e. rc = 8'hff
//  3. fifo_full_push - fifo_full & push (null_pakcet) - JIANG
//      r_block_push - block fifo push when fifo full
//      from fifo_full -> la_hpri_req_o (change to 1)
//      at the end of the r_block_push, push a null-packet (use la_hpri_req_o and r_block_push) - JIANG
//      from fifo_full -> la_hpri_req_o (change to 0)

reg r_block_push; 
wire fifo_full_push;

always @ ( posedge axi_clk or negedge enable_la )begin
      if(!enable_la) begin
        r_block_push <= 0;
      end 
      else if( trace_push_ok == 1'b0) r_block_push <= 1;
      else if( la_hpri_req_o == 1'b0) r_block_push <= 0; // delay one cycle(from fifo_count < l_thresh) - JIANG
    end

assign fifo_full_push = ((r_block_push == 1'b1) & (la_hpri_req_o == 1'b0)); // (fifo_full_push == 1'b0 & (la_hpri_req_o == 1'b1) the end of r_block_push
assign trace_push = ((la_change | (rc_count == 8'hff)) & !r_block_push)  | fifo_full_push; 

assign trace_packet = {32{!fifo_full_push}} & {rc_count, (r_la_data & la_enable)}; 

assign la_hpri_req = la_hpri_req_o;
  always @ ( posedge axi_clk or negedge enable_la ) begin
    if(!enable_la) begin
        fifo_count <= 8'b0;
        la_hpri_req_o <= 0; 
    end
    else begin
        // if(fifo_full) la_hpri_req_o <= 1 ;
        if(fifo_count >= h_thresh)  la_hpri_req_o <= 1;
        if(fifo_count < l_thresh) la_hpri_req_o <= 0;
        if( fifo_push & !fifo_pop) fifo_count <= fifo_count + 1;
        if(!fifo_push &  fifo_pop) fifo_count <= fifo_count - 1;
    end
  end
assign m_tuser = 2'b00;
assign m_tstrb = 4'b1111;
assign m_tkeep = 4'b1111;
assign m_tlast = (tx_count == pop_cond);
//assign m_tvalid = fifo_count > 0;

// m_tlast 
// 1. transfer count reaches AXIS_PKT_LEN - 1
// 2. reach repeat count = 255, then flush it out - this is to avoid staff un-issued traces
// 3. fifo empty 
// Check upstream Axi-switch will still transfer data when there is no tlast

  always @ ( posedge axi_clk or negedge enable_la ) begin 
    if( !enable_la ) 
        tx_count <= 1;
       else begin 
        if(tx_count == pop_cond)
            tx_count <= 1;
        else if(fifo_pop)
            tx_count <= tx_count + 1;
       end
    end
// ----    Jiin - comment out the following
endmodule
