module reset_as_por(
    input clk,
    input PAD,
    output wire rstb_h,
    output wire porb_h,
    output wire porb_l,
    output wire por_l
  );

  wire rst_pad;
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

  rstpad pad (
    .rst_pad(rst_pad),
    .PAD(PAD)
  );

endmodule

