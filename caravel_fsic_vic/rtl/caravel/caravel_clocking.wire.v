// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

//tony_debug `default_nettype none
// This routine synchronizes the 

module caravel_clocking(
`ifdef USE_POWER_PINS
input wire VPWR,
input wire VGND,
`endif
input wire resetb,
input wire ext_clk,
input wire ext_reset,
output wire resetb_sync //  Output propagated and buffered reset
);

    // Reset assignment.  "reset" comes from POR, while "ext_reset"
    // comes from standalone SPI (and is normally zero unless
    // activated from the SPI).

    // Staged-delay reset
    reg [2:0] reset_delay;

    // Vic: remove assigning core_clk here, change core_clk to ext_clk
    always @(negedge ext_clk or negedge resetb) begin
        if (resetb == 1'b0) begin
        reset_delay <= 3'b111;
        end else begin
        reset_delay <= {1'b0, reset_delay[2:1]};
        end
    end

    assign resetb_sync = ~(reset_delay[0] | ext_reset);

endmodule
//tony_debug `default_nettype wire
