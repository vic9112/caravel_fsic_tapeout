module RAM256 #(parameter USE_LATCH = 1,
    WSIZE     = 4
)
(

    input   wire                 CLK,    // FO: 2
    input   wire [WSIZE-1:0]     WE0,     // FO: 2
    input   wire                 EN0,     // FO: 2
    input   wire [7:0]           A0,      // FO: 5
    input   wire [(WSIZE*8-1):0] Di0,     // FO: 2
    output  wire [(WSIZE*8-1):0] Do0
    );
    
    wire [1:0]             SEL0;
    wire [(WSIZE*8-1):0]    Do0_pre[1:0]; 
    assign SEL0[0] = EN0 && (~A0[7]);
    assign SEL0[1] = EN0 && ( A0[7]);
    
    generate
        genvar i;
        for (i=0; i< 2; i=i+1) begin : BANK128
            RAM128 RAM128 ( .CLK(CLK), .EN0(SEL0[i]), .WE0(WE0), .Di0(Di0), .Do0(Do0_pre[i]), .A0(A0[6:0]) );        
        end
    endgenerate
    
    assign Do0 = A0[7]? Do0_pre[1]:Do0_pre[0];
                                                                                                                                                          
endmodule
