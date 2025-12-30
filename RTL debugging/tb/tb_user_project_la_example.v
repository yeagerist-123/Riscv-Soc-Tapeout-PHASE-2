
`default_nettype none

module tb_user_project_la_example;

    reg  [127:0] la_data_in;
    reg  [127:0] la_oenb;
    wire [127:0] la_data_out;

    // DUT instantiation
    user_project_la_example dut (
        .la_data_in (la_data_in),
        .la_data_out(la_data_out),
        .la_oenb    (la_oenb)
    );

    initial begin
        $display("==== LA FUNCTIONAL TEST START ====");

        // Default values
        la_data_in = 128'h0;
        la_oenb    = 128'hFFFFFFFF; // all outputs disabled
        #10;

        // -------------------------------
        // Test 1: LA0 -> LA1
        // -------------------------------
        la_data_in[31:0] = 32'hA5A5A5A5;
        la_oenb[31:0]    = 32'h0;   // enable LA0 output
        #10;

        $display("LA0 -> LA1: OUT = %h (expected A5A5A5A5)", la_data_out[63:32]);

        // -------------------------------
        // Test 2: Disable LA0 (Hi-Z)
        // -------------------------------
        la_oenb[31:0] = 32'hFFFFFFFF;
        #10;

        $display("LA0 disabled, LA1 should be Z: %h", la_data_out[63:32]);

        // -------------------------------
        // Test 3: LA1 -> LA0
        // -------------------------------
        la_data_in[63:32] = 32'h12345678;
        la_oenb[63:32]    = 32'h0;
        #10;

        $display("LA1 -> LA0: OUT = %h (expected 12345678)", la_data_out[31:0]);

        // -------------------------------
        // Test 4: LA2 -> LA3
        // -------------------------------
        la_data_in[95:64] = 32'hCAFEBABE;
        la_oenb[95:64]    = 32'h0;
        #10;

        $display("LA2 -> LA3: OUT = %h (expected CAFEBABE)", la_data_out[127:96]);

        // -------------------------------
        // Test 5: LA3 -> LA2
        // -------------------------------
        la_data_in[127:96] = 32'hDEADBEEF;
        la_oenb[127:96]    = 32'h0;
        #10;

        $display("LA3 -> LA2: OUT = %h (expected DEADBEEF)", la_data_out[95:64]);

        $display("==== LA FUNCTIONAL TEST END ====");
        $finish;
    end

endmodule

`default_nettype wire

