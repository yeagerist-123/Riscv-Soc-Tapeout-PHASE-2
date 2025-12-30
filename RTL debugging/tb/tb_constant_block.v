`timescale 1ns/1ps
`default_nettype wire

module tb_constant_block;

    wire one;
    wire zero;

    // DUT instantiation (no power pins)
    constant_block dut (
        .one(one),
        .zero(zero)
    );

    // VCD generation
    initial begin
        $dumpfile("constant_block.vcd");
        $dumpvars(0, tb_constant_block);
    end

    // Functional checks
    initial begin
        #1;

        if (one !== 1'b1)
            $fatal("ERROR: one is not HIGH");

        if (zero !== 1'b0)
            $fatal("ERROR: zero is not LOW");

        $display("✅ constant_block verification PASSED");

        #5;
        $finish;
    end

endmodule

`default_nettype wire

