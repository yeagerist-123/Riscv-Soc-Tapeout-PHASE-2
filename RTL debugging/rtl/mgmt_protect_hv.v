`default_nettype wire
/*----------------------------------------------------------------------*/
/* mgmt_protect_hv:                                                      */
/* High-voltage management protection logic (FS120 / SCL180)             */
/* Power is handled in CDL/SPICE, not in Verilog.                        */
/*----------------------------------------------------------------------*/

module mgmt_protect_hv (
    output mprj_vdd_logic1,
    output mprj2_vdd_logic1
);

    wire mprj_vdd_logic1_h;
    wire mprj2_vdd_logic1_h;

    // Generate logic-high in HV domain (functional intent only)
    dummy_scl180_conb_1 mprj_logic_high_hvl (
        .HI(mprj_vdd_logic1_h),
        .LO()
    );

    dummy_scl180_conb_1 mprj2_logic_high_hvl (
        .HI(mprj2_vdd_logic1_h),
        .LO()
    );

    // Level shifting resolved physically (IO / PD flow)
    assign mprj_vdd_logic1  = mprj_vdd_logic1_h;
    assign mprj2_vdd_logic1 = mprj2_vdd_logic1_h;

endmodule

`default_nettype wire

