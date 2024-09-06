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
  
`ifdef USE_EDK_SRAM
    generate
        genvar i;
        for (i=0; i< 4; i=i+1) begin : BANK128x8
        
            SRAM1RW128x8 RAM128x8 (`ifdef USE_POWER_PINS .VPWR(VPWR), .VGND(VGND),  `endif .CE(CLK), .CSB(~EN0), .WEB(~WE0[i]), .OEB(1'b0), .I(Di0[8*i +: 8]), .O(Do0[8*i +: 8]), .A(A0[6:0]) );
        /*
        `ifdef USE_PDK_SRAM
            ra1shd128x8m16h3v2 RAM128x8 (`ifdef USE_POWER_PINS .VPWR(VPWR), .VGND(VGND),  `endif .CLK(CLK), .CEN(~EN0), .WEN(~WE0[i]), .OEN(1'b0), .D(Di0[8*i +: 8]), .Q(Do0[8*i +: 8]), .A(A0[6:0]) );
        `endif //USE_PDK_SRAM
        */        
        end
    endgenerate
`endif  //USE_EDK_SRAM

`ifdef USE_PDK_SRAM
    wire we;
  assign we = (WE0[3] && WE0[2] && WE0[1] && WE0[0]);
    ra1shd128x32m4h3v2 RAM128x32 ( .CLK(CLK), .CEN(~EN0), .WEN(~we), .OEN(1'b0), .D(Di0), .Q(Do0), .A(A0[6:0]) );
`endif
  
endmodule
