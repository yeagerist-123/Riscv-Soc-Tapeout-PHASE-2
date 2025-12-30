`timescale 1ns/1ps

module tb_user_analog_project_wrapper;

    reg wb_clk_i;
    reg wb_rst_i;

    // Minimal signals
    reg  [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_out;

    // Tie-offs
    wire [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_oeb;
    wire [`MPRJ_IO_PADS-`ANALOG_PADS-1:0] io_in_3v3;

    assign io_in_3v3 = io_in;
    assign io_oeb    = {(`MPRJ_IO_PADS-`ANALOG_PADS){1'b0}};

    // Clock
    always #5 wb_clk_i = ~wb_clk_i;

    initial begin
        wb_clk_i = 0;
        wb_rst_i = 1;

        io_in = '0;

        #50;
        wb_rst_i = 0;

        // Drive pattern
        #20;
        io_in = 'hA5A5;

        #20;
        if (io_out !== io_in) begin
            $display("❌ ERROR: io_out does not match io_in");
            $finish;
        end

        $display("✅ user_analog_project_wrapper TB check PASSED");
        $finish;
    end

    user_analog_project_wrapper dut (
        .wb_clk_i (wb_clk_i),
        .wb_rst_i (wb_rst_i),

        .wbs_stb_i(1'b0),
        .wbs_cyc_i(1'b0),
        .wbs_we_i (1'b0),
        .wbs_sel_i(4'b0),
        .wbs_dat_i(32'b0),
        .wbs_adr_i(32'b0),
        .wbs_ack_o(),
        .wbs_dat_o(),

        .la_data_in (128'b0),
        .la_data_out(),
        .la_oenb    (128'b0),

        .io_in      (io_in),
        .io_in_3v3  (io_in_3v3),
        .io_out     (io_out),
        .io_oeb     (),

        .gpio_analog(),
        .gpio_noesd(),
        .io_analog(),
        .io_clamp_high(),
        .io_clamp_low(),

        .user_clock2(1'b0),
        .user_irq()
    );

endmodule

