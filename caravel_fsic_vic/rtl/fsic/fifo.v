module fifo
#( parameter WIDTH = 45,
   parameter depth= 16,
   parameter sram_datawidth= 100
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
    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            w_ptr<=0;
        end
        else begin
            if(w_vld)w_ptr<=w_ptr_next;
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
    assign w_rdy=~above_TH;  // not use full and empty 
    reg [WIDTH-1:0]data_in_l;

    always @(posedge axis_clk or negedge axi_reset_n) begin
        if (!axi_reset_n)begin 
            data_in_l<=0;
        end
        else begin
            if(w_vld)
            data_in_l<=data_in;
            else 
            data_in_l<=data_in_l;
        end
    end 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////



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


    // there are three conidtion :1. when r_ptr_next=w_ptr is always 1 becuase data is from data_l. and 2. state if is normal can divide into two condition read even or odd times to decide.and contion isn't normal only when state==WAIT fifo read can be 1.
    assign r_vld=((r_ptr_next==w_ptr)?1'b1:(state==NORMAL)?((r_ptr[0])?1'b1:r_vld_even):state==WAIT_FIFO_READ)& !empty;
    assign data_out=(r_ptr_next==w_ptr)?data_in_l: (state==NORMAL)?((r_ptr[0])?data_out_odd:sram_out_even):sram_out_odd;  

  

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



