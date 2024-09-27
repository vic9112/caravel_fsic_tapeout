//===========================================================
// Author: Vic Chen
// Email: s179038@gmail.com
// Date:  Sep 27, 2024
//===========================================================
`default_nettype wire

// IO signal
//==========================
// 0:  mprj[0] - JTAG ---- I
// 1:  mprj[1] - SDO ----- O
// 2:  mprj[2] - SDI ----- I
// 3:  mprj[3] - CSB ----- I
// 4:  mprj[4] - SCK ----- I
// 5:  mprj[5] - ser_rx -- I
// 6:  mprj[6] - ser_tx -- O
// 7:  mprj[7] - irq ----- I
//--------------------------
// 8 ~ 21:
//     mprj[20:8] - RXD -- I
//     mprj[21] - RXCLK -- I
//--------------------------
// 22 ~ 35:
//     mprj[34:22] - TXD - O
//     mprj[35] - TXCLK -- O
//--------------------------
// 36: mprj[36] - IOCLK -- I
// 37: mprj[37] - NOTUSE - I
//==========================
// 38: clock ------------- I
// 39: flash_csb --------- O
// 40: flash_clk --------- O
// 41: flash_io0 --------- O
// 42: flash_io1 --------- I
// 43: gpio -------------- I

module pads_config (
    input         clk,
    input         resetb, // reset, active low
    // Wishbone Slave ports
    input         wb_clk_i,
    input         wb_rst_i,
    input         wbs_stb_i,
    input         wbs_cyc_i,
    input         wbs_we_i,
    input   [3:0] wbs_sel_i,
    input  [31:0] wbs_dat_i,
    input  [31:0] wbs_adr_i,
    output        wbs_ack_o,
    output [31:0] wbs_dat_o,
    // Output REN/OEN
    output [43:0] re_n,
    output [43:0] oe_n
);

    reg [43:0] r_OEN;
    reg        ACK;

    wire [37:0] cnfg_en; // Configure Enable
    wire        cnfg_decode; // Check target address
    wire        cnfg_vld;
  
    assign cnfg_decode = (wbs_adr_i[31:12] == 20'h3000_6)? 1'b1 : 1'b0;
    assign cnfg_vld = wbs_cyc_i & wbs_stb_i;

    assign wbs_ack_o = ACK;

    // Initially, set all ports to INPUT
    // Pull-up/down Resistor Enable: 0: Enable, 1: Disable
    // Reset period, force ren=0, i.e. enable pull-up/down resistors
    generate
        genvar i;
        for (i = 0; i < 44; i = i + 1) begin : AND_RST_OEN
            assign re_n[i] = 1'b1 & resetb;
            assign oe_n[i] = r_OEN[i] | (~resetb);
        end
    endgenerate

    // Caravel FSIC initial IO state when reset
    always @(posedge clk or negedge resetb) begin
        if (~resetb) begin
            r_OEN[0]     <=   {{1'b1}};  // JTAG
            r_OEN[1]     <=   {{1'b0}};  // SDO
            r_OEN[5:2]   <=  {4{1'b1}};  // SDI, CSB, SCK, ser_rx
            r_OEN[6]     <=   {{1'b0}};  // ser_tx
            r_OEN[21:7]  <= {15{1'b1}};  // irq, RXD, RXCLK
            r_OEN[35:22] <= {14{1'b0}};  // TXD, TXCLK
            r_OEN[36]    <=   {{1'b1}};  // IOCLK
            r_OEN[37]    <=   {{1'b1}};  // mprj[37
            r_OEN[38]    <=   {{1'b1}};  // clock
            r_OEN[41:39] <=  {3{1'b0}};  // flash_csb, flash_clk, flash_io0
            r_OEN[43:42] <=  {2{1'b1}};  // flash_io1, gpio
        end else begin
            integer i;
            for (i = 0; i < 44; i = i + 1) begin
                if (cnfg_en[i]) r_OEN[i] <= wbs_dat_i;
            end
        end
    end

    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wbs_rst_i) begin
            ACK <= 0;
        end else begin
            if (cnfg_decode & cnfg_vld)
                ACK <= 1;
            else
                ACK <= 0;
        end
    end

    // WRITE
    assign cnfg_en[0]  = ((wbs_adr_i[7:0] == 8'h00) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[1]  = ((wbs_adr_i[7:0] == 8'h01) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[2]  = ((wbs_adr_i[7:0] == 8'h02) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[3]  = ((wbs_adr_i[7:0] == 8'h03) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[4]  = ((wbs_adr_i[7:0] == 8'h04) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[5]  = ((wbs_adr_i[7:0] == 8'h05) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[6]  = ((wbs_adr_i[7:0] == 8'h06) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[7]  = ((wbs_adr_i[7:0] == 8'h07) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[8]  = ((wbs_adr_i[7:0] == 8'h08) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[9]  = ((wbs_adr_i[7:0] == 8'h09) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[10] = ((wbs_adr_i[7:0] == 8'h0a) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[11] = ((wbs_adr_i[7:0] == 8'h0b) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[12] = ((wbs_adr_i[7:0] == 8'h0c) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[13] = ((wbs_adr_i[7:0] == 8'h0d) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[14] = ((wbs_adr_i[7:0] == 8'h0e) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[15] = ((wbs_adr_i[7:0] == 8'h0f) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[16] = ((wbs_adr_i[7:0] == 8'h10) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[17] = ((wbs_adr_i[7:0] == 8'h11) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[18] = ((wbs_adr_i[7:0] == 8'h12) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[19] = ((wbs_adr_i[7:0] == 8'h13) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[20] = ((wbs_adr_i[7:0] == 8'h14) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[21] = ((wbs_adr_i[7:0] == 8'h15) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[22] = ((wbs_adr_i[7:0] == 8'h16) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[23] = ((wbs_adr_i[7:0] == 8'h17) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[24] = ((wbs_adr_i[7:0] == 8'h18) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[25] = ((wbs_adr_i[7:0] == 8'h19) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[26] = ((wbs_adr_i[7:0] == 8'h1a) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[27] = ((wbs_adr_i[7:0] == 8'h1b) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[28] = ((wbs_adr_i[7:0] == 8'h1c) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[29] = ((wbs_adr_i[7:0] == 8'h1d) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[30] = ((wbs_adr_i[7:0] == 8'h1e) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[31] = ((wbs_adr_i[7:0] == 8'h1f) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[32] = ((wbs_adr_i[7:0] == 8'h20) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[33] = ((wbs_adr_i[7:0] == 8'h21) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[34] = ((wbs_adr_i[7:0] == 8'h22) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[35] = ((wbs_adr_i[7:0] == 8'h23) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[36] = ((wbs_adr_i[7:0] == 8'h24) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;
    assign cnfg_en[37] = ((wbs_adr_i[7:0] == 8'h25) && wbs_we_i & (cnfg_decode & cnfg_vld))? 1'b1 : 1'b0;

    // READ
    assign wbs_dat_o = ((wbs_adr_i[7:0] == 8'h00) && (!wbs_we_i))? r_OEN[0] :
                       ((wbs_adr_i[7:0] == 8'h01) && (!wbs_we_i))? r_OEN[1] :
                       ((wbs_adr_i[7:0] == 8'h02) && (!wbs_we_i))? r_OEN[2] :
                       ((wbs_adr_i[7:0] == 8'h03) && (!wbs_we_i))? r_OEN[3] :
                       ((wbs_adr_i[7:0] == 8'h04) && (!wbs_we_i))? r_OEN[4] :
                       ((wbs_adr_i[7:0] == 8'h05) && (!wbs_we_i))? r_OEN[5] :
                       ((wbs_adr_i[7:0] == 8'h06) && (!wbs_we_i))? r_OEN[6] :
                       ((wbs_adr_i[7:0] == 8'h07) && (!wbs_we_i))? r_OEN[7] :
                       ((wbs_adr_i[7:0] == 8'h08) && (!wbs_we_i))? r_OEN[8] :
                       ((wbs_adr_i[7:0] == 8'h09) && (!wbs_we_i))? r_OEN[9] :
                       ((wbs_adr_i[7:0] == 8'h0a) && (!wbs_we_i))? r_OEN[10] :
                       ((wbs_adr_i[7:0] == 8'h0b) && (!wbs_we_i))? r_OEN[11] :
                       ((wbs_adr_i[7:0] == 8'h0c) && (!wbs_we_i))? r_OEN[12] :
                       ((wbs_adr_i[7:0] == 8'h0d) && (!wbs_we_i))? r_OEN[13] :
                       ((wbs_adr_i[7:0] == 8'h0e) && (!wbs_we_i))? r_OEN[14] :
                       ((wbs_adr_i[7:0] == 8'h0f) && (!wbs_we_i))? r_OEN[15] :
                       ((wbs_adr_i[7:0] == 8'h10) && (!wbs_we_i))? r_OEN[16] :
                       ((wbs_adr_i[7:0] == 8'h11) && (!wbs_we_i))? r_OEN[17] :
                       ((wbs_adr_i[7:0] == 8'h12) && (!wbs_we_i))? r_OEN[18] :
                       ((wbs_adr_i[7:0] == 8'h13) && (!wbs_we_i))? r_OEN[19] :
                       ((wbs_adr_i[7:0] == 8'h14) && (!wbs_we_i))? r_OEN[20] :
                       ((wbs_adr_i[7:0] == 8'h15) && (!wbs_we_i))? r_OEN[21] :
                       ((wbs_adr_i[7:0] == 8'h16) && (!wbs_we_i))? r_OEN[22] :
                       ((wbs_adr_i[7:0] == 8'h17) && (!wbs_we_i))? r_OEN[23] :
                       ((wbs_adr_i[7:0] == 8'h18) && (!wbs_we_i))? r_OEN[24] :
                       ((wbs_adr_i[7:0] == 8'h19) && (!wbs_we_i))? r_OEN[25] :
                       ((wbs_adr_i[7:0] == 8'h1a) && (!wbs_we_i))? r_OEN[26] :
                       ((wbs_adr_i[7:0] == 8'h1b) && (!wbs_we_i))? r_OEN[27] :
                       ((wbs_adr_i[7:0] == 8'h1c) && (!wbs_we_i))? r_OEN[28] :
                       ((wbs_adr_i[7:0] == 8'h1d) && (!wbs_we_i))? r_OEN[29] :
                       ((wbs_adr_i[7:0] == 8'h1e) && (!wbs_we_i))? r_OEN[30] :
                       ((wbs_adr_i[7:0] == 8'h1f) && (!wbs_we_i))? r_OEN[31] :
                       ((wbs_adr_i[7:0] == 8'h20) && (!wbs_we_i))? r_OEN[32] :
                       ((wbs_adr_i[7:0] == 8'h21) && (!wbs_we_i))? r_OEN[33] :
                       ((wbs_adr_i[7:0] == 8'h22) && (!wbs_we_i))? r_OEN[34] :
                       ((wbs_adr_i[7:0] == 8'h23) && (!wbs_we_i))? r_OEN[35] :
                       ((wbs_adr_i[7:0] == 8'h24) && (!wbs_we_i))? r_OEN[36] :
                       ((wbs_adr_i[7:0] == 8'h25) && (!wbs_we_i))? r_OEN[37] :
                                                                   32'd0;

    
endmodule
