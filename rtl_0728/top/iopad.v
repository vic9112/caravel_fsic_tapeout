//`include "fsic_defines.v"


`default_nettype wire

module sky130_ef_io__gpiov2_pad_wrapped (VDDIO, VSSIO, VCCD, VSSD, IN_H, 
    PAD, DM, HLD_H_N, IN, INP_DIS, IB_MODE_SEL, ENABLE_H, ENABLE_VDDA_H,
    ENABLE_INP_H, OE_N, TIE_HI_ESD, TIE_LO_ESD, SLOW, VTRIP_SEL, HLD_OVR,
    ANALOG_EN, ANALOG_SEL, ENABLE_VDDIO, ENABLE_VSWITCH_H, ANALOG_POL, OUT
    );

input OUT;  		
input OE_N;  		
input HLD_H_N;		
input ENABLE_H;
input ENABLE_INP_H;	
input ENABLE_VDDA_H;	
input ENABLE_VSWITCH_H;	
input ENABLE_VDDIO;	
input INP_DIS;		
input IB_MODE_SEL;
input VTRIP_SEL;	
input SLOW;		
input HLD_OVR;		
input ANALOG_EN;	
input ANALOG_SEL;	
input ANALOG_POL;	
input [2:0] DM;		

inout VDDIO;    
inout VCCD;
inout VSSD;
inout VSSIO;

inout PAD;

output IN;
output IN_H;
output TIE_HI_ESD, TIE_LO_ESD;

//only support below mode for DM[2:0]
// 3'b001 input (output disable), no pullup or pulldown
// 3'b010 input (output disable), with pullup
// 3'b011 input (output disable), with pulldown
// 3'b110 output enable
// others, set to default mode = 3'b001

reg oe;
reg PAD_pullup;
reg PAD_pulldown;

  always @(*) begin
    case( DM[2:0] )
      3'b001: begin
          oe = 0;
          PAD_pullup = 0;
          PAD_pulldown = 0;
        end
      3'b010: begin
          oe = 0;
          PAD_pullup = 1;
          PAD_pulldown = 0;
        end
      3'b011: begin
          oe = 0;
          PAD_pullup = 0;
          PAD_pulldown = 1;
        end
      3'b110: begin
          oe = 1;
          PAD_pullup = 0;
          PAD_pulldown = 0;
        end
      default: begin
          oe = 0;
          PAD_pullup = 0;
          PAD_pulldown = 0;
        end
    endcase
 end   

`ifdef USE_EDK_IO
  B16I1025_EW gpiov2_pad(
		.VDDIO(VDDIO), 
		.VSSIO(VSSIO), 
		.VDD(VCCD), 
		.VSS(VSSD), 
    .DIN(OUT),
    .DOUT(IN),
    .EN(oe),
    .PADIO(PAD),
    .PULL_DOWN(PAD_pulldown),
    .PULL_UP(PAD_pullup),
    .R_EN(~oe)    
  );
`endif //USE_EDK_IO

`ifdef USE_PDK18_IO
  PDUW24DGZ gpiov2_pad(
    .I(OUT),
    .C(IN),
    .OEN(~oe),
    .PAD(PAD),
    .REN(~PAD_pullup)
    );
`endif //USE_PDK18_IO

endmodule








