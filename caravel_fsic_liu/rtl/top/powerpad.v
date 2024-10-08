// [Vic]: Using power pad for ESD protection and clamping
module powerpad (
    inout VDDIO,
    inout VSSIO,
    inout VCCD,
    inout VSSD,
    inout VDDIO_PAD,
    inout VSSIO_PAD,
    inout VCCD_PAD,
    inout VSSD_PAD
);

    // I/O power pad
    IOVDD_EW io_power_pad(
        .VDDIOPAD(VDDIO_PAD),
        .VDDIO(VDDIO),
        .VSSIO(VSSIO),
        .VDD(VCCD),
        .VSS(VSSD)
        );

    // Core power pad
    VDD_EW core_power_pad(
        .VDDPAD(VCCD_PAD),
        .VDDIO(VDDIO),
        .VSSIO(VSSIO),
        .VDD(VCCD),
        .VSS(VSSD)
        );

    // I/O ground pad
    IOVSS_EW io_ground_pad(
        .VSSIOPAD(VSSIO_PAD),
        .VDDIO(VDDIO),
        .VSSIO(VSSIO),
        .VDD(VCCD),
        .VSS(VSSD)
        );

    // Core ground pad
    VSS_EW core_ground_pad(
        .VSSPAD(VSSD_PAD),
        .VDDIO(VDDIO),
        .VSSIO(VSSIO),
        .VDD(VCCD),
        .VSS(VSSD)
        );

endmodule