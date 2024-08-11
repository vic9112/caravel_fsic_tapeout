/*--------------------------------------------------------------------------------*/
/* MIT License                                                                    */
/*                                                                                */
/* Copyright (c) 2023 VIA NEXT Technologies, Inc - <Hurry Lin>                    */
/*                                                                                */
/* Permission is hereby granted, free of charge, to any person obtaining a copy   */
/* of this software and associated documentation files (the "Software"), to deal  */
/* in the Software without restriction, including without limitation the rights   */
/* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      */
/* copies of the Software, and to permit persons to whom the Software is          */
/* furnished to do so, subject to the following conditions:                       */
/*                                                                                */
/* The above copyright notice and this permission notice shall be included in all */
/* copies or substantial portions of the Software.                                */
/*                                                                                */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     */
/* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       */
/* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    */
/* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         */
/* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  */
/* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  */
/* SOFTWARE.                                                                      */
/*--------------------------------------------------------------------------------*/


`timescale 1ns / 1ps
// scalable arb 
module arbiter #(
    parameter PORTS = 3
)
(
    input  wire                     axis_clk,
    input  wire                     axi_reset_n,

    input  wire [PORTS-1:0]         req,
    input  wire [PORTS-1:0]         hi_req,
    input  wire                     ack,
    output wire [PORTS-1:0]         grant
);

reg [PORTS-1:0] grant_reg, grant_next;
reg grant_valid_reg, grant_valid_next;

assign grant =(grant_valid_reg)?grant_reg:0;

wire request_valid;
wire [$clog2(PORTS)-1:0] request_index;
wire [PORTS-1:0] request_mask;

wire hi_request_valid;
wire [$clog2(PORTS)-1:0] hi_request_index;
wire [PORTS-1:0] hi_request_mask;

priority_encoder #(
    .WIDTH(PORTS)
)
priority_encoder_inst (
    .input_unencoded(req),
    .output_valid(request_valid),
    .output_encoded(request_index),
    .output_unencoded(request_mask)
);


priority_encoder #(
    .WIDTH(PORTS)
)
priority_encoder_inst_hi (
    .input_unencoded(hi_req),
    .output_valid(hi_request_valid),
    .output_encoded(hi_request_index),
    .output_unencoded(hi_request_mask)
);


reg [PORTS-1:0] mask_reg , mask_next;

wire masked_request_valid;
wire [$clog2(PORTS)-1:0] masked_request_index;
wire [PORTS-1:0] masked_request_mask;

wire hi_masked_request_valid;
wire [$clog2(PORTS)-1:0] hi_masked_request_index;
wire [PORTS-1:0] hi_masked_request_mask;

priority_encoder #(
    .WIDTH(PORTS)
)
priority_encoder_masked (
    .input_unencoded(req & mask_reg),
    .output_valid(masked_request_valid),
    .output_encoded(masked_request_index),
    .output_unencoded(masked_request_mask)
);

priority_encoder #(
    .WIDTH(PORTS)
)
priority_encoder_masked_hi (
    .input_unencoded(hi_req & mask_reg),
    .output_valid(hi_masked_request_valid),
    .output_encoded(hi_masked_request_index),
    .output_unencoded(hi_masked_request_mask)
);

always @* begin
    if(ack)
        grant_next = 0;
    else if (grant_reg & req)
        grant_next = grant_reg;
    else if (hi_request_valid) begin
        if (hi_masked_request_valid)
            grant_next = hi_masked_request_mask;
        else 
            grant_next = hi_request_mask;
    end
    else if (request_valid) begin
        if (masked_request_valid) 
            grant_next = masked_request_mask;
        else 
            grant_next = request_mask;
    end
    else    grant_next = 0;
end

always @* begin
    if(ack)
        grant_valid_next = 0;
    else if (grant_reg & req)
        grant_valid_next = grant_valid_reg; 
    else if (hi_request_valid) begin
        if (hi_masked_request_valid)
            grant_valid_next = 1;
        else
            grant_valid_next = 1;
    end
    else if (request_valid) begin
        if (masked_request_valid)
            grant_valid_next = 1; 
        else 
            grant_valid_next = 1;
    end
    else grant_valid_next = 0;
end

always @* begin
    if(ack) begin
        mask_next = mask_reg;
    end
    else if (grant_reg & req) begin
        mask_next = mask_reg;
    end 
    else if (hi_request_valid) begin
        if (hi_masked_request_valid) 
            mask_next = {PORTS{1'b1}} << (hi_masked_request_index + 1);
        else 
            mask_next = {PORTS{1'b1}} << (hi_request_index + 1);
    end
    else if (request_valid) begin
        if (masked_request_valid) 
            mask_next = {PORTS{1'b1}} << (masked_request_index + 1);
        else
            mask_next = {PORTS{1'b1}} << (request_index + 1);
    end
    else    mask_next = mask_reg;
end

always @(posedge axis_clk or negedge axi_reset_n) begin
    if (!axi_reset_n)
        grant_reg <= 0;
    else 
        grant_reg <= grant_next;
end

always @(posedge axis_clk or negedge axi_reset_n) begin
    if (!axi_reset_n) 
        grant_valid_reg <= 0;
    else 
        grant_valid_reg <= grant_valid_next;
end

always @(posedge axis_clk or negedge axi_reset_n) begin
    if (!axi_reset_n)
        mask_reg <= 0;
    else
        mask_reg <= mask_next;
end


endmodule


// state-machine arb not scalable
// module arbiter
// #( parameter N = 3
// )
// (
//     input axis_clk ,
//     input axi_reset_n ,
//     input [N-1:0]req,
//     input [N-1:0]hi_req,
//     input last,
//     output [N-1:0]grant
//     );   

// reg [N:0]grant_next;
// reg [N:0]grant_reg;
// localparam WAIT_0 = 4'b0001, WAIT_1 = 4'b0010, WAIT_2 = 4'b0100, GRANT_0=4'b1001, GRANT_1=4'b1010, GRANT_2=4'b1100;

// assign grant=(grant_reg[3])?grant_reg[2:0]:0;
// always @* begin
//     case(grant_reg)
//     WAIT_0:begin 
//         if(hi_req[1]) grant_next=GRANT_1;
//         else if (hi_req[2]) grant_next=GRANT_2;
//         else if (hi_req[0]) grant_next=GRANT_0;
//         else if (req[1])grant_next=GRANT_1;
//         else if (req[2])grant_next=GRANT_2;
//         else if (req[0])grant_next=GRANT_0;
//         else grant_next=grant_reg;
//     end

//     WAIT_1:begin 
//         if(hi_req[2]) grant_next=GRANT_2;
//         else if (hi_req[0]) grant_next=GRANT_0;
//         else if (hi_req[1]) grant_next=GRANT_1;
//         else if (req[2])grant_next=GRANT_2;
//         else if (req[0])grant_next=GRANT_0;
//         else if (req[1])grant_next=GRANT_1;
//         else grant_next=grant_reg;
//     end

//     WAIT_2:begin 
//         if(hi_req[0]) grant_next=GRANT_0;
//         else if (hi_req[1]) grant_next=GRANT_1;
//         else if (hi_req[2]) grant_next=GRANT_2;
//         else if (req[0])grant_next=GRANT_0;
//         else if (req[1])grant_next=GRANT_1;
//         else if (req[2])grant_next=GRANT_2;
//         else grant_next=grant_reg;
//     end

//     GRANT_0:begin
//         if(last) grant_next=WAIT_0;
//         else grant_next=grant_reg;
//     end

//     GRANT_1:begin
//         if(last) grant_next=WAIT_1;
//         else grant_next=grant_reg;
//     end
//     GRANT_2:begin
//         if(last) grant_next=WAIT_2;
//         else grant_next=grant_reg;
//     end
//     endcase
// end

//     always @(posedge axis_clk or negedge axi_reset_n) begin
//         if (!axi_reset_n)begin 
//             grant_reg<=WAIT_0;
//         end
//         else begin
//             grant_reg<=grant_next;
//         end
//     end 

// endmodule