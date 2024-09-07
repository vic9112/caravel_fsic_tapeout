//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: nthuyouwei
// 
// Create Date: 09/06/2024 10:00:00 AM
// Design Name: 
// Module Name: fifo
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




/*****************  how to use this fifo
This is a FIFO designed using a single port sram. Due to the nature of the single port sram, we cannot read and write simultaneously. 
To solve this prob, I used double data width to solve the problem by reading two data entries at once, aiming to maintain the latency the same as a normal FIFO under ideal conditions (i.e., 1T delay for reading). 
In the worst case, if write/read commands arrive simultaneously, we will first check if writing is possible before reading, which could cause a maximum delay of 3T for reads.

Additionally, this design has two modes:

- mode = 1: The read protocol uses the AXI-stream protocol, and the write protocol operates such that when `w_rdy` is 1, it indicates that the FIFO has at least the threshold space available for writing. 
When the other end receives `w_rdy` as 1, it can send `w_vld`, as the FIFO will write directly upon receiving `w_vld`.

- mode = 0: Both read and write protocols use the AXI-stream protocol. Note: `w_rdy` = !full.
***********************/


/********************setting
WIDTH is datawidth.
depth is fifo depth.
sram_datawidth is usually double of WIDTH(sram_datawidth>=2*WIDTH).
mode is 1/0
*******************/


module fifo
#( parameter WIDTH = 45,
   parameter depth= 64,
   parameter sram_datawidth= 128,
   parameter mode=1 // mode 1 is for as, 0 is for la
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
    output [WIDTH-1:0] data_out,
    // use for above_TH 
    input [7:0] TH_reg,
    // external sram io
    output sram_we,
    output[$clog2(depth)-1:0] sram_addr,
    output[sram_datawidth-1:0]sram_din,
    input [sram_datawidth-1:0] sram_dout
    );   
    localparam IDLE = 2'd0, WAIT_SRAM_READ = 2'd1, WAIT_FIFO_READ = 2'd2, NORMAL = 2'd3; // state machine part
    localparam sram_addr_width=$clog2(depth);
    localparam ptr_width=sram_addr_width+2; // LSB note even/odd times, MSB to decide full or not 
    reg [1:0] state;
    reg [1:0] state_next;
    reg [ptr_width-1:0] w_ptr;
    reg [ptr_width-1:0] r_ptr;
    wire [ptr_width-1:0] w_ptr_next;
    wire [ptr_width-1:0] r_ptr_next;
    assign w_ptr_next=w_ptr+1'b1;
    assign r_ptr_next=r_ptr+1'b1;
    wire empty;
    ///////////////////  above TH part//////////////////

                                         
    wire above_TH;
    assign above_TH=({w_ptr[ptr_width-1]==~r_ptr[ptr_width-1],w_ptr[ptr_width-2:0]}-{1'b0,r_ptr[ptr_width-2:0]})>TH_reg;
    
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

    wire w_rdy_mode;
    assign w_rdy_mode=mode|w_rdy;
    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            w_ptr<=0;
        end
        else begin
            if(w_vld & w_rdy_mode )w_ptr<=w_ptr_next;
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
// above th can remove if you not use 
    assign w_rdy= (mode==1)? ~above_TH : ~((w_ptr[ptr_width-1]==~r_ptr[ptr_width-1])&(w_ptr[ptr_width-2:0]==r_ptr[ptr_width-2:0]));  // not use full and empty 
    reg [WIDTH-1:0]data_in_l;

    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            data_in_l<=0;
        end
        else begin
            if(w_vld & w_rdy_mode)
            data_in_l<=data_in;
            else 
            data_in_l<=data_in_l;
        end
    end 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

    reg sram_read_flag;
    wire sram_read_flag_next;
    assign sram_read_flag_next=((state==WAIT_SRAM_READ)&(~sram_we))|((state==NORMAL) & ~(~r_ptr[0] & r_vld &r_rdy) & (~sram_we & !(r_ptr_next[ptr_width-2:1]==w_ptr[ptr_width-2:1])));
    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)
            sram_read_flag<=0;
        else 
            sram_read_flag<=sram_read_flag_next;
    end 


    assign sram_we= w_vld & w_ptr[0]; // only write in sram in w_ptr[0]==1 mean even times.
    // when we is w_ptr and ,re is r_ptr_next or r_ptr decided by state machine case.  
    assign sram_addr=(sram_we)?w_ptr[ptr_width-2:1]:(state==NORMAL)?r_ptr_next[ptr_width-2:1]:r_ptr[ptr_width-2:1];
    assign sram_din ={{{sram_datawidth-2*WIDTH}{1'b0}},data_in,data_in_l};//from latch and input data
    
    
    
    
    /////////////////// Read part ///////////////////////////
    wire [WIDTH-1:0] sram_out_even;
    wire [WIDTH-1:0] sram_out_odd;
    assign sram_out_even = sram_dout[WIDTH-1:0];
    assign sram_out_odd = sram_dout[2*WIDTH-1:WIDTH];



    reg [WIDTH-1:0] data_out_odd;
    reg [WIDTH-1:0] data_out_even;
       
    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            data_out_odd<=0;
        end
        else begin
            if(sram_read_flag)
            data_out_odd<=sram_out_odd;
            else 
            data_out_odd<=data_out_odd;
        end
    end 
    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            data_out_even<=0;
        end
        else begin
            if(sram_read_flag)
            data_out_even<=sram_out_even;
            else 
            data_out_even<=data_out_even;
        end
    end 
    reg [WIDTH-1:0] data_out_odd_l;
    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            data_out_odd_l<=0;
        end
        else begin
            if(~r_ptr[0])begin
                if(sram_read_flag)
                data_out_odd_l<=sram_out_odd;
                else 
                data_out_odd_l<=data_out_odd;
            end
            else 
            data_out_odd_l<=data_out_odd_l;
        end
    end 

    reg r_vld_even;
    assign empty=(w_ptr==r_ptr);


    // there are three conidtion :1. when r_ptr_next=w_ptr is always 1 becuase data is from data_l. and 2. state if is normal can divide into two condition read even or odd times to decide.and contion isn't normal only when state==WAIT fifo read can be 1.
    assign r_vld=((r_ptr_next==w_ptr)?1'b1:(state==NORMAL)?((r_ptr[0])?1'b1:r_vld_even):state==WAIT_FIFO_READ)& !empty;
    assign data_out=(r_ptr_next==w_ptr)?data_in_l: (state==NORMAL)?((r_ptr[0])?data_out_odd_l:(sram_read_flag)?sram_out_even:data_out_even):(sram_read_flag)?sram_out_odd:data_out_odd;  

  

    always@(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n) begin 
            r_vld_even <= 1'b0;
        end
        else begin
            if(state==NORMAL)begin
                if(~r_ptr[0] & r_vld &r_rdy)
                    r_vld_even <= 1'b0;
                else if (~sram_we & !(r_ptr_next[ptr_width-2:1]==w_ptr[ptr_width-2:1]))  //r_ptr_next[ptr_width-2:1]==w_ptr[ptr_width-2:1] to avoid reading before writing.
                    r_vld_even <= 1'b1;
                else 
                    r_vld_even<=r_vld_even;
                end
            else r_vld_even<=1'b0;
        end
    end

endmodule



