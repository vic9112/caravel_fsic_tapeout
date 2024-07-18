
//`include "fsic_defines.v"

module reset_as_por(
    input clk,
    input PAD,
    output wire rstb_h,
    output wire porb_h,
    output wire porb_l,
    output wire por_l
  );

  wire resetb_in;
  reg [1:0] de_glitch;

  reg [2:0] cnt;

  assign porb_h = resetb_in; 
  assign porb_l = resetb_in;
  assign por_l = !resetb_in;
  assign rstb_h = cnt[2];

  always @(posedge clk or negedge resetb_in) begin
    if(!resetb_in)
      cnt[2:0] <= 3'b000;
    else begin
      cnt[0] <= resetb_in;
      cnt[1] <= cnt[0];
      cnt[2] <= cnt[1];
    end
  end

`ifdef  USE_EDK_IO
  ISH1025_EW reset_pad(
    .DOUT(resetb_in),
    .R_EN(1'b1),
    .PADIO(PAD)
  );
`endif //USE_EDK_IO

`ifdef USE_PDK18_IO
  PDDSDGZ reset_pad(    
    .C(resetb_in),
    .PAD(PAD)
  );
`endif //USE_PDK18_IO




endmodule

