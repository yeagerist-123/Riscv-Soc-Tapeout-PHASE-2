`timescale 1ns/1ps
`default_nettype wire

module tb_mgmt_protect_hv;

    // DUT outputs
    wire mprj_vdd_logic1;
    wire mprj2_vdd_logic1;

    // Instantiate DUT
    mgmt_protect_hv dut (
        .mprj_vdd_logic1  (mprj_vdd_logic1),
        .mprj2_vdd_logic1 (mprj2_vdd_logic1)
    );

    // Dump waveform
    initial begin
        $dumpfile("mgmt_protect_hv.vcd");
        $dumpvars(0, tb_mgmt_protect_hv);
    end

    // Test sequence
    initial begin
        #10;

        // Check logic-high generation
        if (mprj_vdd_logic1 !== 1'b1) begin
            $display("❌ ERROR: mprj_vdd_logic1 is not logic 1");
            $finish;
        end

        if (mprj2_vdd_logic1 !== 1'b1) begin
            $display("❌ ERROR: mprj2_vdd_logic1 is not logic 1");
            $finish;
        end

        $display("✅ mgmt_protect_hv TB PASSED: constant logic-high verified");
        #10;
        $finish;
    end

endmodule

`default_nettype wire

