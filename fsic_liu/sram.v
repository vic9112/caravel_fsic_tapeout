/*********************************************************************
*  SAED_EDK90nm_SRAM : SRAM1RW64x128 Verilog description            *
*  ---------------------------------------------------------------   *
*  Filename      : SRAM1RW64x128.v                                  *
*  SRAM name     : SRAM1RW64x128                                    *
*  Word width    : 128   bits                                        *
*  Word number   : 64                                                *
*  Adress width  : 6     bits                                        *
**********************************************************************/

//`timescale 1ns/100fs

`define numAddr 6
`define numWords 64
`define wordLength 128


module SRAM1RW64x128 (A,CE,WEB,OEB,CSB,I,O);

input 				CE;
input 				WEB;
input 				OEB;
input 				CSB;

input 	[`numAddr-1:0] 		A;
input 	[`wordLength-1:0] 	I;
output 	[`wordLength-1:0] 	O;

/*reg   [`wordLength-1:0]   	memory[`numWords-1:0];*/
/*reg  	[`wordLength-1:0]	data_out;*/
wire 	[`wordLength-1:0] 	O;

wire 				RE;
wire 				WE;

SRAM1RW64x128_1bit sram_IO0 ( CE, WEB,  A, OEB, CSB, I[0], O[0]);
SRAM1RW64x128_1bit sram_IO1 ( CE, WEB,  A, OEB, CSB, I[1], O[1]);
SRAM1RW64x128_1bit sram_IO2 ( CE, WEB,  A, OEB, CSB, I[2], O[2]);
SRAM1RW64x128_1bit sram_IO3 ( CE, WEB,  A, OEB, CSB, I[3], O[3]);
SRAM1RW64x128_1bit sram_IO4 ( CE, WEB,  A, OEB, CSB, I[4], O[4]);
SRAM1RW64x128_1bit sram_IO5 ( CE, WEB,  A, OEB, CSB, I[5], O[5]);
SRAM1RW64x128_1bit sram_IO6 ( CE, WEB,  A, OEB, CSB, I[6], O[6]);
SRAM1RW64x128_1bit sram_IO7 ( CE, WEB,  A, OEB, CSB, I[7], O[7]);
SRAM1RW64x128_1bit sram_IO8 ( CE, WEB,  A, OEB, CSB, I[8], O[8]);
SRAM1RW64x128_1bit sram_IO9 ( CE, WEB,  A, OEB, CSB, I[9], O[9]);
SRAM1RW64x128_1bit sram_IO10 ( CE, WEB,  A, OEB, CSB, I[10], O[10]);
SRAM1RW64x128_1bit sram_IO11 ( CE, WEB,  A, OEB, CSB, I[11], O[11]);
SRAM1RW64x128_1bit sram_IO12 ( CE, WEB,  A, OEB, CSB, I[12], O[12]);
SRAM1RW64x128_1bit sram_IO13 ( CE, WEB,  A, OEB, CSB, I[13], O[13]);
SRAM1RW64x128_1bit sram_IO14 ( CE, WEB,  A, OEB, CSB, I[14], O[14]);
SRAM1RW64x128_1bit sram_IO15 ( CE, WEB,  A, OEB, CSB, I[15], O[15]);
SRAM1RW64x128_1bit sram_IO16 ( CE, WEB,  A, OEB, CSB, I[16], O[16]);
SRAM1RW64x128_1bit sram_IO17 ( CE, WEB,  A, OEB, CSB, I[17], O[17]);
SRAM1RW64x128_1bit sram_IO18 ( CE, WEB,  A, OEB, CSB, I[18], O[18]);
SRAM1RW64x128_1bit sram_IO19 ( CE, WEB,  A, OEB, CSB, I[19], O[19]);
SRAM1RW64x128_1bit sram_IO20 ( CE, WEB,  A, OEB, CSB, I[20], O[20]);
SRAM1RW64x128_1bit sram_IO21 ( CE, WEB,  A, OEB, CSB, I[21], O[21]);
SRAM1RW64x128_1bit sram_IO22 ( CE, WEB,  A, OEB, CSB, I[22], O[22]);
SRAM1RW64x128_1bit sram_IO23 ( CE, WEB,  A, OEB, CSB, I[23], O[23]);
SRAM1RW64x128_1bit sram_IO24 ( CE, WEB,  A, OEB, CSB, I[24], O[24]);
SRAM1RW64x128_1bit sram_IO25 ( CE, WEB,  A, OEB, CSB, I[25], O[25]);
SRAM1RW64x128_1bit sram_IO26 ( CE, WEB,  A, OEB, CSB, I[26], O[26]);
SRAM1RW64x128_1bit sram_IO27 ( CE, WEB,  A, OEB, CSB, I[27], O[27]);
SRAM1RW64x128_1bit sram_IO28 ( CE, WEB,  A, OEB, CSB, I[28], O[28]);
SRAM1RW64x128_1bit sram_IO29 ( CE, WEB,  A, OEB, CSB, I[29], O[29]);
SRAM1RW64x128_1bit sram_IO30 ( CE, WEB,  A, OEB, CSB, I[30], O[30]);
SRAM1RW64x128_1bit sram_IO31 ( CE, WEB,  A, OEB, CSB, I[31], O[31]);
SRAM1RW64x128_1bit sram_IO32 ( CE, WEB,  A, OEB, CSB, I[32], O[32]);
SRAM1RW64x128_1bit sram_IO33 ( CE, WEB,  A, OEB, CSB, I[33], O[33]);
SRAM1RW64x128_1bit sram_IO34 ( CE, WEB,  A, OEB, CSB, I[34], O[34]);
SRAM1RW64x128_1bit sram_IO35 ( CE, WEB,  A, OEB, CSB, I[35], O[35]);
SRAM1RW64x128_1bit sram_IO36 ( CE, WEB,  A, OEB, CSB, I[36], O[36]);
SRAM1RW64x128_1bit sram_IO37 ( CE, WEB,  A, OEB, CSB, I[37], O[37]);
SRAM1RW64x128_1bit sram_IO38 ( CE, WEB,  A, OEB, CSB, I[38], O[38]);
SRAM1RW64x128_1bit sram_IO39 ( CE, WEB,  A, OEB, CSB, I[39], O[39]);
SRAM1RW64x128_1bit sram_IO40 ( CE, WEB,  A, OEB, CSB, I[40], O[40]);
SRAM1RW64x128_1bit sram_IO41 ( CE, WEB,  A, OEB, CSB, I[41], O[41]);
SRAM1RW64x128_1bit sram_IO42 ( CE, WEB,  A, OEB, CSB, I[42], O[42]);
SRAM1RW64x128_1bit sram_IO43 ( CE, WEB,  A, OEB, CSB, I[43], O[43]);
SRAM1RW64x128_1bit sram_IO44 ( CE, WEB,  A, OEB, CSB, I[44], O[44]);
SRAM1RW64x128_1bit sram_IO45 ( CE, WEB,  A, OEB, CSB, I[45], O[45]);
SRAM1RW64x128_1bit sram_IO46 ( CE, WEB,  A, OEB, CSB, I[46], O[46]);
SRAM1RW64x128_1bit sram_IO47 ( CE, WEB,  A, OEB, CSB, I[47], O[47]);
SRAM1RW64x128_1bit sram_IO48 ( CE, WEB,  A, OEB, CSB, I[48], O[48]);
SRAM1RW64x128_1bit sram_IO49 ( CE, WEB,  A, OEB, CSB, I[49], O[49]);
SRAM1RW64x128_1bit sram_IO50 ( CE, WEB,  A, OEB, CSB, I[50], O[50]);
SRAM1RW64x128_1bit sram_IO51 ( CE, WEB,  A, OEB, CSB, I[51], O[51]);
SRAM1RW64x128_1bit sram_IO52 ( CE, WEB,  A, OEB, CSB, I[52], O[52]);
SRAM1RW64x128_1bit sram_IO53 ( CE, WEB,  A, OEB, CSB, I[53], O[53]);
SRAM1RW64x128_1bit sram_IO54 ( CE, WEB,  A, OEB, CSB, I[54], O[54]);
SRAM1RW64x128_1bit sram_IO55 ( CE, WEB,  A, OEB, CSB, I[55], O[55]);
SRAM1RW64x128_1bit sram_IO56 ( CE, WEB,  A, OEB, CSB, I[56], O[56]);
SRAM1RW64x128_1bit sram_IO57 ( CE, WEB,  A, OEB, CSB, I[57], O[57]);
SRAM1RW64x128_1bit sram_IO58 ( CE, WEB,  A, OEB, CSB, I[58], O[58]);
SRAM1RW64x128_1bit sram_IO59 ( CE, WEB,  A, OEB, CSB, I[59], O[59]);
SRAM1RW64x128_1bit sram_IO60 ( CE, WEB,  A, OEB, CSB, I[60], O[60]);
SRAM1RW64x128_1bit sram_IO61 ( CE, WEB,  A, OEB, CSB, I[61], O[61]);
SRAM1RW64x128_1bit sram_IO62 ( CE, WEB,  A, OEB, CSB, I[62], O[62]);
SRAM1RW64x128_1bit sram_IO63 ( CE, WEB,  A, OEB, CSB, I[63], O[63]);
SRAM1RW64x128_1bit sram_IO64 ( CE, WEB,  A, OEB, CSB, I[64], O[64]);
SRAM1RW64x128_1bit sram_IO65 ( CE, WEB,  A, OEB, CSB, I[65], O[65]);
SRAM1RW64x128_1bit sram_IO66 ( CE, WEB,  A, OEB, CSB, I[66], O[66]);
SRAM1RW64x128_1bit sram_IO67 ( CE, WEB,  A, OEB, CSB, I[67], O[67]);
SRAM1RW64x128_1bit sram_IO68 ( CE, WEB,  A, OEB, CSB, I[68], O[68]);
SRAM1RW64x128_1bit sram_IO69 ( CE, WEB,  A, OEB, CSB, I[69], O[69]);
SRAM1RW64x128_1bit sram_IO70 ( CE, WEB,  A, OEB, CSB, I[70], O[70]);
SRAM1RW64x128_1bit sram_IO71 ( CE, WEB,  A, OEB, CSB, I[71], O[71]);
SRAM1RW64x128_1bit sram_IO72 ( CE, WEB,  A, OEB, CSB, I[72], O[72]);
SRAM1RW64x128_1bit sram_IO73 ( CE, WEB,  A, OEB, CSB, I[73], O[73]);
SRAM1RW64x128_1bit sram_IO74 ( CE, WEB,  A, OEB, CSB, I[74], O[74]);
SRAM1RW64x128_1bit sram_IO75 ( CE, WEB,  A, OEB, CSB, I[75], O[75]);
SRAM1RW64x128_1bit sram_IO76 ( CE, WEB,  A, OEB, CSB, I[76], O[76]);
SRAM1RW64x128_1bit sram_IO77 ( CE, WEB,  A, OEB, CSB, I[77], O[77]);
SRAM1RW64x128_1bit sram_IO78 ( CE, WEB,  A, OEB, CSB, I[78], O[78]);
SRAM1RW64x128_1bit sram_IO79 ( CE, WEB,  A, OEB, CSB, I[79], O[79]);
SRAM1RW64x128_1bit sram_IO80 ( CE, WEB,  A, OEB, CSB, I[80], O[80]);
SRAM1RW64x128_1bit sram_IO81 ( CE, WEB,  A, OEB, CSB, I[81], O[81]);
SRAM1RW64x128_1bit sram_IO82 ( CE, WEB,  A, OEB, CSB, I[82], O[82]);
SRAM1RW64x128_1bit sram_IO83 ( CE, WEB,  A, OEB, CSB, I[83], O[83]);
SRAM1RW64x128_1bit sram_IO84 ( CE, WEB,  A, OEB, CSB, I[84], O[84]);
SRAM1RW64x128_1bit sram_IO85 ( CE, WEB,  A, OEB, CSB, I[85], O[85]);
SRAM1RW64x128_1bit sram_IO86 ( CE, WEB,  A, OEB, CSB, I[86], O[86]);
SRAM1RW64x128_1bit sram_IO87 ( CE, WEB,  A, OEB, CSB, I[87], O[87]);
SRAM1RW64x128_1bit sram_IO88 ( CE, WEB,  A, OEB, CSB, I[88], O[88]);
SRAM1RW64x128_1bit sram_IO89 ( CE, WEB,  A, OEB, CSB, I[89], O[89]);
SRAM1RW64x128_1bit sram_IO90 ( CE, WEB,  A, OEB, CSB, I[90], O[90]);
SRAM1RW64x128_1bit sram_IO91 ( CE, WEB,  A, OEB, CSB, I[91], O[91]);
SRAM1RW64x128_1bit sram_IO92 ( CE, WEB,  A, OEB, CSB, I[92], O[92]);
SRAM1RW64x128_1bit sram_IO93 ( CE, WEB,  A, OEB, CSB, I[93], O[93]);
SRAM1RW64x128_1bit sram_IO94 ( CE, WEB,  A, OEB, CSB, I[94], O[94]);
SRAM1RW64x128_1bit sram_IO95 ( CE, WEB,  A, OEB, CSB, I[95], O[95]);
SRAM1RW64x128_1bit sram_IO96 ( CE, WEB,  A, OEB, CSB, I[96], O[96]);
SRAM1RW64x128_1bit sram_IO97 ( CE, WEB,  A, OEB, CSB, I[97], O[97]);
SRAM1RW64x128_1bit sram_IO98 ( CE, WEB,  A, OEB, CSB, I[98], O[98]);
SRAM1RW64x128_1bit sram_IO99 ( CE, WEB,  A, OEB, CSB, I[99], O[99]);
SRAM1RW64x128_1bit sram_IO100 ( CE, WEB,  A, OEB, CSB, I[100], O[100]);
SRAM1RW64x128_1bit sram_IO101 ( CE, WEB,  A, OEB, CSB, I[101], O[101]);
SRAM1RW64x128_1bit sram_IO102 ( CE, WEB,  A, OEB, CSB, I[102], O[102]);
SRAM1RW64x128_1bit sram_IO103 ( CE, WEB,  A, OEB, CSB, I[103], O[103]);
SRAM1RW64x128_1bit sram_IO104 ( CE, WEB,  A, OEB, CSB, I[104], O[104]);
SRAM1RW64x128_1bit sram_IO105 ( CE, WEB,  A, OEB, CSB, I[105], O[105]);
SRAM1RW64x128_1bit sram_IO106 ( CE, WEB,  A, OEB, CSB, I[106], O[106]);
SRAM1RW64x128_1bit sram_IO107 ( CE, WEB,  A, OEB, CSB, I[107], O[107]);
SRAM1RW64x128_1bit sram_IO108 ( CE, WEB,  A, OEB, CSB, I[108], O[108]);
SRAM1RW64x128_1bit sram_IO109 ( CE, WEB,  A, OEB, CSB, I[109], O[109]);
SRAM1RW64x128_1bit sram_IO110 ( CE, WEB,  A, OEB, CSB, I[110], O[110]);
SRAM1RW64x128_1bit sram_IO111 ( CE, WEB,  A, OEB, CSB, I[111], O[111]);
SRAM1RW64x128_1bit sram_IO112 ( CE, WEB,  A, OEB, CSB, I[112], O[112]);
SRAM1RW64x128_1bit sram_IO113 ( CE, WEB,  A, OEB, CSB, I[113], O[113]);
SRAM1RW64x128_1bit sram_IO114 ( CE, WEB,  A, OEB, CSB, I[114], O[114]);
SRAM1RW64x128_1bit sram_IO115 ( CE, WEB,  A, OEB, CSB, I[115], O[115]);
SRAM1RW64x128_1bit sram_IO116 ( CE, WEB,  A, OEB, CSB, I[116], O[116]);
SRAM1RW64x128_1bit sram_IO117 ( CE, WEB,  A, OEB, CSB, I[117], O[117]);
SRAM1RW64x128_1bit sram_IO118 ( CE, WEB,  A, OEB, CSB, I[118], O[118]);
SRAM1RW64x128_1bit sram_IO119 ( CE, WEB,  A, OEB, CSB, I[119], O[119]);
SRAM1RW64x128_1bit sram_IO120 ( CE, WEB,  A, OEB, CSB, I[120], O[120]);
SRAM1RW64x128_1bit sram_IO121 ( CE, WEB,  A, OEB, CSB, I[121], O[121]);
SRAM1RW64x128_1bit sram_IO122 ( CE, WEB,  A, OEB, CSB, I[122], O[122]);
SRAM1RW64x128_1bit sram_IO123 ( CE, WEB,  A, OEB, CSB, I[123], O[123]);
SRAM1RW64x128_1bit sram_IO124 ( CE, WEB,  A, OEB, CSB, I[124], O[124]);
SRAM1RW64x128_1bit sram_IO125 ( CE, WEB,  A, OEB, CSB, I[125], O[125]);
SRAM1RW64x128_1bit sram_IO126 ( CE, WEB,  A, OEB, CSB, I[126], O[126]);
SRAM1RW64x128_1bit sram_IO127 ( CE, WEB,  A, OEB, CSB, I[127], O[127]);


endmodule


module SRAM1RW64x128_1bit (CE_i, WEB_i,  A_i, OEB_i, CSB_i, I_i, O_i);

input CSB_i;
input OEB_i;
input CE_i;
input WEB_i;

input 	[`numAddr-1:0] 	A_i;
input 	[0:0] I_i;

output 	[0:0] O_i;

reg 	[0:0]O_i;
reg    	[0:0]  	memory[`numWords-1:0];
reg  	[0:0]	data_out;


// w_vldite Mode
and u1 (RE, ~CSB_i,  WEB_i);
and u2 (WE, ~CSB_i, ~WEB_i);


always @ (posedge CE_i) 
	if (RE)
		data_out <= memory[A_i];
always @ (posedge CE_i) 
	if (WE)
		memory[A_i] <= I_i;
		

always @ (data_out or OEB_i)
	if (!OEB_i) 
		O_i <= data_out;
	else
		O_i <=  1'bz;


endmodule

