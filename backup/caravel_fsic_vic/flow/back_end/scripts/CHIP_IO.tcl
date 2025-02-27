################################################################################
# Date: 7/30/2024            
# Name: Vic Chen             
################################################################################

set_signal_io_constraints \
        -io_guide_object ring1.left \
        -constraint \
        {{200} core_vdd1 padframe/pad_clock/iopad_CLK por/pad/iopad_RST padframe/pad_gpio/iopad_GPIO padframe/pad_flash_io0/iopad_FIO0 padframe/pad_flash_io1/iopad_FIO1 padframe/pad_flash_csb/iopad_FCSB padframe/pad_flash_clk/iopad_FCLK padframe/mprj_pads/pad0/iopad_MPRJ0 padframe/mprj_pads/pad1/iopad_MPRJ1 padframe/mprj_pads/pad2/iopad_MPRJ2 padframe/mprj_pads/pad3/iopad_MPRJ3 padframe/mprj_pads/pad4/iopad_MPRJ4 io_vss2};

set_signal_io_constraints \
        -io_guide_object ring1.bottom \
        -constraint \
        {{200} io_vdd1 padframe/mprj_pads/pad5/iopad_MPRJ5 padframe/mprj_pads/pad6/iopad_MPRJ6 padframe/mprj_pads/pad7/iopad_MPRJ7 padframe/mprj_pads/pad8/iopad_MPRJ8 padframe/mprj_pads/pad9/iopad_MPRJ9 padframe/mprj_pads/pad10/iopad_MPRJ10 padframe/mprj_pads/pad11/iopad_MPRJ11 padframe/mprj_pads/pad12/iopad_MPRJ12 padframe/mprj_pads/pad13/iopad_MPRJ13 padframe/mprj_pads/pad14/iopad_MPRJ14 padframe/mprj_pads/pad15/iopad_MPRJ15 padframe/mprj_pads/pad16/iopad_MPRJ16 core_vss1};

set_signal_io_constraints \
        -io_guide_object ring1.right \
        -constraint \
        {{200} core_vdd2 padframe/mprj_pads/pad17/iopad_MPRJ17 padframe/mprj_pads/pad18/iopad_MPRJ18 padframe/mprj_pads/pad19/iopad_MPRJ19 padframe/mprj_pads/pad20/iopad_MPRJ20 padframe/mprj_pads/pad21/iopad_MPRJ21 padframe/mprj_pads/pad22/iopad_MPRJ22 padframe/mprj_pads/pad23/iopad_MPRJ23 padframe/mprj_pads/pad24/iopad_MPRJ24 padframe/mprj_pads/pad25/iopad_MPRJ25 padframe/mprj_pads/pad26/iopad_MPRJ26 padframe/mprj_pads/pad27/iopad_MPRJ27 padframe/mprj_pads/pad28/iopad_MPRJ28 io_vss1};

set_signal_io_constraints \
        -io_guide_object ring1.top \
        -constraint \
        {{200} io_vdd2 padframe/mprj_pads/pad29/iopad_MPRJ29 padframe/mprj_pads/pad30/iopad_MPRJ30 padframe/mprj_pads/pad31/iopad_MPRJ31 padframe/mprj_pads/pad32/iopad_MPRJ32 padframe/mprj_pads/pad33/iopad_MPRJ33 padframe/mprj_pads/pad34/iopad_MPRJ34 padframe/mprj_pads/pad35/iopad_MPRJ35 padframe/mprj_pads/pad36/iopad_MPRJ36 padframe/mprj_pads/pad37/iopad_MPRJ37 core_vss2};