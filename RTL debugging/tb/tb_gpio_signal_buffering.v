`timescale 1ns/1ps

module tb_gpio_signal_buffering;

    // Inputs
    reg  [30:0] mgmt_io_in_unbuf;
    reg  [30:0] mgmt_io_out_unbuf;
    reg  [2:0]  mgmt_io_oeb_unbuf;

    // Outputs
    wire [30:0] mgmt_io_in_buf;
    wire [30:0] mgmt_io_out_buf;
    wire [2:0]  mgmt_io_oeb_buf;

    // DUT instantiation
    gpio_signal_buffering dut (
        .mgmt_io_in_unbuf (mgmt_io_in_unbuf),
        .mgmt_io_out_unbuf(mgmt_io_out_unbuf),
        .mgmt_io_oeb_unbuf(mgmt_io_oeb_unbuf),
        .mgmt_io_oeb_buf  (mgmt_io_oeb_buf),
        .mgmt_io_in_buf   (mgmt_io_in_buf),
        .mgmt_io_out_buf  (mgmt_io_out_buf)
    );

    // Test sequence
    initial begin
        $display("Starting GPIO Signal Buffering Functional Test");

        // Initialize
        mgmt_io_in_unbuf  = 0;
        mgmt_io_out_unbuf = 0;
        mgmt_io_oeb_unbuf = 0;

        #10;

        // Apply random vectors
        repeat (10) begin
            mgmt_io_in_unbuf  = $random;
            mgmt_io_out_unbuf = $random;
            mgmt_io_oeb_unbuf = $random;

            #10;

            // Functional checks
            if (mgmt_io_in_buf !== mgmt_io_in_unbuf)
                $error("ERROR: mgmt_io_in mismatch");

            if (mgmt_io_out_buf !== mgmt_io_out_unbuf)
                $error("ERROR: mgmt_io_out mismatch");

            if (mgmt_io_oeb_buf !== mgmt_io_oeb_unbuf)
                $error("ERROR: mgmt_io_oeb mismatch");

            $display("PASS: IN=%h OUT=%h OEB=%b",
                     mgmt_io_in_unbuf,
                     mgmt_io_out_unbuf,
                     mgmt_io_oeb_unbuf);
        end

        $display("GPIO Signal Buffering Functional Test PASSED");
        $finish;
    end

endmodule

