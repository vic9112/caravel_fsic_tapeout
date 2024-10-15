//`include "fsic_defines.v"

module RAM128 #(parameter USE_LATCH = 1,
                          WSIZE     = 4
)
(
    input   wire                 CLK,   
    input   wire [WSIZE-1:0]     WE0,   
    input   wire                 EN0,   
    input   wire [6:0]           A0,    
    input   wire [(WSIZE*8-1):0] Di0,   
    output  wire [(WSIZE*8-1):0] Do0
    );
    wire [(WSIZE*8-1):0]    Do0_pre[1:0]; 
    wire we;
    assign we = (WE0[3] && WE0[2] && WE0[1] && WE0[0]);
    ra1shd128x32m4h3v2 RAM128x32 ( .CLK(CLK), .CEN(~EN0), .WEN(~we), .OEN(1'b0), .D(Di0), .Q(Do0), .A(A0[6:0]) );

  
endmodule
