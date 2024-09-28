`default_nettype wire

// T18 IO PAD
module PDUW04DGZ (I, OEN, REN, PAD, C);
    input I, OEN, REN;
    inout PAD;
    output C;

    reg pull;

    not    (RE, REN);
    buf    (C, PAD);
    bufif0 (PAD, I, OEN);

endmodule

// T18 input PAD
module PDDWDGZ (PAD, C, REN);
    input PAD, REN;
    output C;

    reg pull;

    not    (RE ,REN);
    buf    (C, PAD);

endmodule

// T18 Schmitt trigger 
module PDISDGZ (PAD, C);
    input PAD;
    output C;
    buf (C, PAD);
endmodule