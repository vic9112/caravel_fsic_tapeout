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

module mprj_io_buffer (
input wire VPWR,
input wire VGND,
input wire [(`MPRJ_IO_PADS_1-1):0] mgmt_gpio_in,
output wire [(`MPRJ_IO_PADS_1-1):0] mgmt_gpio_in_buf,
input wire [2:0] mgmt_gpio_oeb,
output wire [2:0] mgmt_gpio_oeb_buf,
input wire [(`MPRJ_IO_PADS_1-1):0] mgmt_gpio_out,
output wire [(`MPRJ_IO_PADS_1-1):0] mgmt_gpio_out_buf
);


clkbuffer BUF[(`MPRJ_IO_PADS_2*2+3)-1:0] (
    .VPWR(VPWR),
    .VGND(VGND),
    .VPB(VPWR),
    .VNB(VGND),
    .A({mgmt_gpio_in, mgmt_gpio_oeb, mgmt_gpio_out}), 
    .X({mgmt_gpio_in_buf, mgmt_gpio_oeb_buf, mgmt_gpio_out_buf})
); 

endmodule