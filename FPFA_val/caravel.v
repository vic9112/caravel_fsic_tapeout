
 `default_nettype wire
module caravel (

    // All top-level I/O are package-facing pins
// FPGA:  remove vdd,vss,vcc


    inout gpio, // Used for external LDO control

    //mprj input from FPGA
    input [38-1:0] mprj_i,
    //mprj out to FPGA
    output [38-1:0] mprj_o,
    //mprj out enable to FPGA
    output [38-1:0] mprj_en,

    input clock, // CMOS core clock input, not a crystal
    input resetb, // Reset input (sense inverted)

    output flash_csb,
    output flash_clk,
    output flash_io0,
    input flash_io1 //Willy debug
);
    wire [37:0] mprj_io;
    assign mprj_en[0]=0;
    
    assign mprj_en[1]=1;
    
    assign mprj_en[2]=0;
    assign mprj_en[3]=0;
    assign mprj_en[4]=0;
    assign mprj_en[5]=0;
    
    assign mprj_en[6]=1;
    
    assign mprj_en[7]=0;
    assign mprj_en[8]=0;
    assign mprj_en[9]=0;
    assign mprj_en[10]=0;
    assign mprj_en[11]=0;
    assign mprj_en[12]=0;
    assign mprj_en[13]=0;
    assign mprj_en[14]=0;
    assign mprj_en[15]=0;
    assign mprj_en[16]=0;
    assign mprj_en[17]=0;
    assign mprj_en[18]=0; 
    assign mprj_en[20]=0;
    assign mprj_en[21]=0;
    
    assign mprj_en[22]=1;
    assign mprj_en[23]=1;
    assign mprj_en[24]=1;  
    assign mprj_en[25]=1;
    assign mprj_en[26]=1;
    assign mprj_en[27]=1;  
    assign mprj_en[28]=1;
    assign mprj_en[29]=1;
    assign mprj_en[30]=1;  
    assign mprj_en[31]=1;
    assign mprj_en[32]=1;
    assign mprj_en[33]=1;  
    assign mprj_en[34]=1;
    assign mprj_en[35]=1;
    
    assign mprj_en[36]=0;     
    assign mprj_en[37]=1;     
    /*
    assign mprj_io[0] = mprj_i[0];
    
    assign mprj_o[1] = mprj_io[1];
    
    assign mprj_io[2] = mprj_i[2];
    assign mprj_io[3] = mprj_i[3];
    assign mprj_io[4] = mprj_i[4];
    assign mprj_io[5] = mprj_i[5];
    
    assign mprj_o[6] = mprj_io[6];
    
    assign mprj_io[7] = mprj_i[7];
    assign mprj_io[8]  = mprj_i[8];
    assign mprj_io[9]  = mprj_i[9];
    assign mprj_io[10] = mprj_i[10];
    assign mprj_io[11] = mprj_i[11];
    assign mprj_io[12] = mprj_i[12];
    assign mprj_io[13] = mprj_i[13];
    assign mprj_io[14] = mprj_i[14];
    assign mprj_io[15] = mprj_i[15];
    assign mprj_io[16] = mprj_i[16];
    assign mprj_io[17] = mprj_i[17];
    assign mprj_io[18] = mprj_i[18];
    assign mprj_io[19] = mprj_i[19];
    assign mprj_io[20] = mprj_i[20];
    assign mprj_io[21] = mprj_i[21];

    assign mprj_o[22] = mprj_io[22];
    assign mprj_o[23] = mprj_io[23];
    assign mprj_o[24] = mprj_io[24];
    assign mprj_o[25] = mprj_io[25];
    assign mprj_o[26] = mprj_io[26];
    assign mprj_o[27] = mprj_io[27];
    assign mprj_o[28] = mprj_io[28];
    assign mprj_o[29] = mprj_io[29];
    assign mprj_o[30] = mprj_io[30];
    assign mprj_o[31] = mprj_io[31];
    assign mprj_o[32] = mprj_io[32];
    assign mprj_o[33] = mprj_io[33];
    assign mprj_o[34] = mprj_io[34];
    assign mprj_o[35] = mprj_io[35];



    assign mprj_io[36] = mprj_i[36];
    assign mprj_o[37] = mprj_io[37];*/


caravel_top caravel_top(
    .mprj_io(mprj_io),
    .mprj__in(mprj_i),
    .mprj__out(mprj_o),
    //Willy debug - e
    .clock(clock), // CMOS core clock input, not a crystal
    .resetb(resetb), 

    .flash_csb(flash_csb),
    .flash_clk(flash_clk),
    .flash_io0(flash_io0),
    .flash_io1(flash_io1), //Willy debug

    .gpio(gpio) // Used for external LDO control
);

endmodule
