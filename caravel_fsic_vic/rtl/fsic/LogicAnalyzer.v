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

/* Function Description:
  - Monitor signals provided by user project. Support up to 24 monitoring signals
  - Support signal conditioning to trigger signal logging  (Currently, done by host program)
  - Compress (Waveform compression, e.g. Run-Length-Encoding RLE) the logged signals and sent them to remote users using the Axis port. Waveform can be displayed in remote environments.
  - Waveform log is designed to be saved in .vcd file format, it can be open by gtkwave.
*/

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
    input  wire           enable_la,

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
    localparam FIFO_DEPTH               = 128;  
    localparam AXIS_PKT_LEN             = 8; 
    localparam H_THRESH_DEFAULT         = 7'h40;
    localparam L_THRESH_DEFAULT         = 7'b10; 	

wire trace_push_ok;
reg [23:0] la_enable;
reg [6:0] h_thresh;
reg [6:0] l_thresh;
reg [6:0] pop_cond;
reg [7:0] rc_count;
reg [23:0] r_la_data;       // latched up_la_data;
reg la_reset_n_d1;
wire la_change;             // la signal changed
wire la_reset_n;            // 
wire trace_push;            // trace is push into FIFO
wire fifo_full;
wire [31:0] trace_packet;
reg [7:0] fifo_count;
reg [7:0] tx_count;     // count # of transfer
reg la_hpri_req_o;
wire fifo_pop = m_tready & m_tvalid;// & (fifo_count > 0);
wire fifo_push = trace_push & trace_push_ok;

assign axi_awready  = axi_awvalid & axi_wvalid & la_reset_n;
assign axi_wready   = axi_awvalid & axi_wvalid & la_reset_n;

// axilite read - axi_rdata can be available when axi_arvalid (axi_araddr) is valid,
//              - it is simply a combinational logic
assign axi_rvalid   = axi_arvalid;
assign axi_rdata    = (axi_araddr[11:2] == 10'h000) ? {8'b0, la_enable} : 
                      (axi_araddr[11:2] == 10'h001) ? {25'b0, h_thresh} :
                      (axi_araddr[11:2] == 10'h002) ? {25'b0, l_thresh} :
                      (axi_araddr[11:2] == 10'h003) ? {25'b0, pop_cond} : 32'hFFFFFFFF;
assign axi_arready  = axi_arvalid;

always @ ( posedge axi_clk ) 
    la_reset_n_d1 <= la_reset_n;

always @ ( posedge axi_clk or negedge enable_la ) 
    if( !enable_la) 
        begin
        la_enable   <= 24'h0;
        h_thresh    <= H_THRESH_DEFAULT;
        l_thresh    <= L_THRESH_DEFAULT;
        pop_cond    <= AXIS_PKT_LEN;
        end 
    else if( cc_la_enable & axi_awvalid & axi_wvalid) 
        begin
        if( axi_awaddr[11:2] == 10'h000) la_enable <= axi_wdata[23:0];
        if( axi_awaddr[11:2] == 10'h001) h_thresh  <= axi_wdata[6:0];
        if( axi_awaddr[11:2] == 10'h002) l_thresh  <= axi_wdata[6:0];
        if( axi_awaddr[11:2] == 10'h003) pop_cond  <= axi_wdata[6:0];
        end



assign la_change = (fifo_full) ? la_reset_n : ( up_la_data != r_la_data );
assign la_reset_n = enable_la & ~la_hpri_req_o;

// fifo full handling
//  - push null-packet all 0
//  - flush FIFO 
//  - restart - 

// generate full_reset -> fifo_full till fifo_empty (flush fifo)
// la_reset_n= cc_la_enable & ~full_reset
// Note: we use cc_la_enable to reset, so that we can use software to reset LA
// rc_count - repeat count
// increament when there is no la_change
always @ ( posedge axi_clk or negedge la_reset_n)    // note: cc_la_enable to reset
    if( !la_reset_n ) 
        begin
        rc_count <= 8'h01;
        r_la_data <= 24'b0;
        end
    else  
        if( !la_change & rc_count != 8'hff)       // signal is not changed
            rc_count <= rc_count + 1;
        else 
            begin
            r_la_data <= up_la_data;
            rc_count <= 8'h01;
            end
        
     

// trace_push : condition to push a trace into fifo
// 1. signal changes - la_change
// 2. rc_count reach 255




// --- FIFO Instance -----
la_fifo
#( .WIDTH(32)
   //.DEPTH(128)              // Jiin - use new fifo ip with parameter DEPTH
)   fifo_inst
(
    .axis_clk (axis_clk) ,
    .axi_reset_n (axi_reset_n),
    .w_vld (trace_push),          // fifo push
    .w_rdy (trace_push_ok),          // w_rdy
    .data_in (trace_packet),
    .r_rdy (m_tready),          // directly connect to axis r_ready
    .r_vld (m_tvalid),          // connect to axis r_valid
    .data_out (m_tdata)
);

// FIFO depth counter - it is used to asserts la_hpri_req


assign trace_push = (la_change | (rc_count == 8'hff)) & la_reset_n;
assign fifo_full = fifo_count >= h_thresh;        
assign trace_packet = {32{!fifo_full}} & {rc_count, (r_la_data & la_enable)}; 

assign la_hpri_req = la_hpri_req_o;
always @ ( posedge axi_clk or negedge enable_la )
    if(!enable_la) 
        begin
        fifo_count <= 8'b0;
        la_hpri_req_o <= 0; 
        end
    else 
        begin
        if(fifo_full) la_hpri_req_o <= 1 ;
        if(fifo_count<l_thresh) la_hpri_req_o <= 0;
        if( fifo_push & !fifo_pop) fifo_count <= fifo_count + 1;
        if(!fifo_push &  fifo_pop) fifo_count <= fifo_count - 1;
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


always @ ( posedge axi_clk or negedge enable_la )
    if( !enable_la ) 
        tx_count <= 1;
    else 
        if(tx_count == pop_cond)
            tx_count <= 1;
        else if(fifo_pop)
            tx_count <= tx_count + 1;
            
// ----    Jiin - comment out the following
endmodule




module la_fifo
#( parameter WIDTH = 32
)
(
    input axis_clk ,
    input axi_reset_n ,
    // write protocol
    input   w_vld,
    output  w_rdy,
    input [WIDTH-1:0] data_in,
    // read protocol
    input r_rdy,
    output  r_vld,
    output [WIDTH-1:0] data_out
    );   
    localparam IDLE = 2'd0, WAIT_SRAM_READ = 2'd1, WAIT_FIFO_READ = 2'd2, NORMAL = 2'd3; // state machine part
    localparam sram_addr_width=$clog2(16);
    localparam sram_wordLength=64;
    localparam ptr_width=sram_addr_width+2; // LSB note even/odd times, MSB to decide full or not 
    reg [1:0] state;
    reg [1:0] state_next;
    reg [ptr_width-1:0] w_ptr;
    reg [ptr_width-1:0] r_ptr;
    wire [ptr_width-1:0] w_ptr_next;
    wire [ptr_width-1:0] r_ptr_next;
    assign w_ptr_next=w_ptr+1'b1;
    assign r_ptr_next=r_ptr+1'b1;
    wire sram_we;
    

    ///////////////////  state machine////////// 
    //If it may directly reads from data_l, we need to ensure that it doesn't skip some data when it needs to read from SRAM.
    //After reads from data_l, Since the normal condition should starts with r_ptr[0] == 0, we need to add this state machine to make it corretly exec in normal condition. 
    // w_ptr==r_ptr_next ie reads from data_l.
    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            state<=2'd0;
        end
        else begin
            state<=state_next;
        end
    end 
    wire empty;
    always @(*) begin
        case(state)
            IDLE: begin   
                if(!(w_ptr==r_ptr_next|empty))begin
                    if(r_ptr[0]) state_next=WAIT_SRAM_READ;
                    else state_next=NORMAL;
                end
                else state_next=state;
            end
            WAIT_SRAM_READ: begin
                if(~sram_we) state_next=WAIT_FIFO_READ;
                else state_next=state;
            end
            WAIT_FIFO_READ:begin
                if(r_rdy) state_next=NORMAL;
                else state_next=state;
            end
            NORMAL:begin
                if(w_ptr==r_ptr_next) state_next=IDLE;
                else state_next=state;
            end
        endcase
    end 

    /////////////////////////// ptr part ///////////////////////////////////////////////////////////////////////////
    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            w_ptr<=0;
        end
        else begin
            if(w_vld & w_rdy)w_ptr<=w_ptr_next;
            else  w_ptr<=w_ptr;
        end
    end 
    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            r_ptr<=0;
        end
        else begin
            if(r_rdy & r_vld)r_ptr<=r_ptr_next;
            else  r_ptr<=r_ptr;
        end
    end 

///////////////////////////////// Write part ////////////////////////////////////////////////////////////////
//the MSB is different while the other bits are the same, it indicates that w_ptr has already completed one full cycle ahead of r_ptr, meaning it is full.
    assign w_rdy=~((w_ptr[ptr_width-1]==~r_ptr[ptr_width-1])&(w_ptr[ptr_width-2:0]==r_ptr[ptr_width-2:0])); 
    
    reg [WIDTH-1:0]data_in_l;

    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            data_in_l<=0;
        end
        else begin
            if(w_vld & w_rdy)
            data_in_l<=data_in;
            else 
            data_in_l<=data_in_l;
        end
    end 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


    wire [sram_addr_width-1:0] sram_addr;
    wire [sram_wordLength-1:0]sram_din;
    assign sram_we= w_vld & w_ptr[0]; 
    assign sram_addr=(sram_we)?w_ptr[ptr_width-2:1]:(state==NORMAL)?r_ptr_next[ptr_width-2:1]:r_ptr[ptr_width-2:1];
    assign sram_din ={data_in,data_in_l};
    
    
    
    
    /////////////////// Read part ///////////////////////////
    wire [sram_wordLength-1:0] sram_dout;
    wire [WIDTH-1:0] sram_out_even;
    wire [WIDTH-1:0] sram_out_odd;
    assign sram_out_even = sram_dout[WIDTH-1:0];
    assign sram_out_odd = sram_dout[2*WIDTH-1:WIDTH];



    reg [WIDTH-1:0] data_out_odd;

    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            data_out_odd<=0;
        end
        else begin
            if(~r_ptr[0])
            data_out_odd<=sram_out_odd;
            else 
            data_out_odd<=data_out_odd;
        end
    end 

    reg r_vld_even;
    assign empty=(w_ptr==r_ptr);
    assign r_vld=((r_ptr_next==w_ptr)?1'b1:(state==NORMAL)?((r_ptr[0])?1'b1:r_vld_even):state==WAIT_FIFO_READ)& !empty;
    assign data_out=(r_ptr_next==w_ptr)?data_in_l: (state==NORMAL)?((r_ptr[0])?data_out_odd:sram_out_even):sram_out_odd;  

  

    always@(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n) begin 
            r_vld_even <= 1'b0;
        end
        else begin
            if(!empty) begin
                if(state==NORMAL)begin
                    if(~r_ptr[0] & r_vld &r_rdy)
                        r_vld_even <= 1'b0;
                    else if (~sram_we & !(r_ptr_next[ptr_width-2:1]==w_ptr[ptr_width-2:1]))  // To avoid reading before writing.
                        r_vld_even <= 1'b1;
                    else 
                        r_vld_even<=r_vld_even;
                end
                else r_vld_even<=1'b0;
            end
            else begin
                r_vld_even <= 1'b0;
            end
        end
    end


    ra1shd16x64m4h3v2 SRAM16x64(
        .CLK(axis_clk),
        .WEN(~sram_we),
        .OEN(1'b0),
        .CEN(1'b0),
        .A(sram_addr),
        .D(sram_din),
        .Q(sram_dout)
    );

    /*
    SRAM1RW64x128 la_SRAM1RW64x128(
        .CE(axis_clk),
        .WEB(~sram_we),// WEB =1 is read WEB=0 is w_vldite
        .OEB(1'b0),
        .CSB(1'b0),
        .A(sram_addr),
        .I(sram_din),
        .O(sram_dout)
    );
    */

endmodule

