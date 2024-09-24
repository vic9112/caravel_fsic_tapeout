//===========================================================
// Modified by Vic Chen
// Sep 9, 2024
//===========================================================
// Update:
// 9/9: add port `rst_pad`
//===========================================================


module reset_as_por(
    input clk,
    input rst_pad,
    output wire rstb_h,
    output wire porb_h,
    output wire porb_l,
    output wire por_l
  );

  reg [1:0] de_glitch;

  reg [2:0] cnt;

  assign porb_h = rst_pad; 
  assign porb_l = rst_pad;
  assign por_l = !rst_pad;
  assign rstb_h = cnt[2];

  always @(posedge clk or negedge rst_pad) begin
    if(!rst_pad)
      cnt[2:0] <= 3'b000;
    else begin
      cnt[0] <= rst_pad;
      cnt[1] <= cnt[0];
      cnt[2] <= cnt[1];
    end
  end

endmodule

