module ra1shd128x32m4h3v2
(
input wire [7-1:0] A,
input wire [32-1:0] D,
input wire CLK,
input wire CEN,
input wire OEN,
input wire WEN,
output reg [32-1:0] Q
);
	reg [32-1:0] mem [128-1:0];

	always @(posedge CLK) begin
		if (~CEN) begin
			if (~WEN) begin
				mem[A] <= D;
				Q <= {32{1'bX}} ;
			end
			else begin
				Q <= mem[A];
			end
		end
	end

endmodule

module ra1shd32x64m4h3v2
(
input wire [5-1:0] A,
input wire [64-1:0] D,
input wire CLK,
input wire CEN,
input wire WEN,
input wire OEN,
output reg [64-1:0] Q
);
	reg [64-1:0] mem [32-1:0];

	always @(posedge CLK) begin
		if (~CEN) begin
			if (~WEN) begin
				mem[A] <= D;
				Q <= {64{1'bX}} ;
			end
			else begin
				Q <= mem[A];
			end
		end
	end

endmodule
module ra1shd16x100m4h3v2
(
input wire [4-1:0] A,
input wire [100-1:0] D,
input wire CLK,
input wire CEN,
input wire WEN,
input wire OEN,
output reg [100-1:0] Q
);
	reg [100-1:0] mem [16-1:0];

	always @(posedge CLK) begin
		if (~CEN) begin
			if (~WEN) begin
				mem[A] <= D;
				Q <= {100{1'bX}} ;
			end
			else begin
				Q <= mem[A];
			end
		end
	end

endmodule

module ra1shd80x64m4h3v2
(
input wire [7-1:0] A,
input wire [64-1:0] D,
input wire CLK,
input wire CEN,
input wire WEN,
input wire OEN,
output reg [64-1:0] Q
);
	reg [64-1:0] mem [80-1:0];

	always @(posedge CLK) begin
		if (~CEN) begin
			if (~WEN) begin
				mem[A] <= D;
				Q <= {64{1'bX}} ;
			end
			else begin
				Q <= mem[A];
			end
		end
	end

endmodule


module ra1shd1024x64m4h3v2
(
input wire [10-1:0] A,
input wire [64-1:0] D,
input wire CLK,
input wire CEN,
input wire WEN,
input wire OEN,
output reg [64-1:0] Q
);
	reg [64-1:0] mem [1024-1:0];

	always @(posedge CLK) begin
		if (~CEN) begin
			if (~WEN) begin
				mem[A] <= D;
				Q <= {64{1'bX}} ;
			end
			else begin
				Q <= mem[A];
			end
		end
	end

endmodule

