# user_analog_project_wrapper Module

## Overview

`user_analog_project_wrapper` is a structural top-level wrapper that exposes all digital, analog, and control interfaces required for integrating a user analog or mixed-signal project into the Caravel / VSDCaravel SoC.

This module does not implement user functionality. Its purpose is to enumerate pins, connect buses, and preserve padframe compatibility, especially during PDK migration (Sky130 → SCL180).

---

## Inputs and Outputs

### 1. Power Pins (conditional)

```
vdda1, vdda2   // 3.3V analog supplies
vssa1, vssa2   // analog ground
vccd1, vccd2   // 1.8V digital supplies
vssd1, vssd2   // digital ground
```

These pins power the user analog and digital domains. They are enabled when `USE_POWER_PINS` is defined.

---

### 2. Wishbone Slave Interface (Management → User)

```
wb_clk_i, wb_rst_i
wbs_stb_i, wbs_cyc_i, wbs_we_i
wbs_sel_i[3:0]
wbs_dat_i[31:0], wbs_adr_i[31:0]
wbs_ack_o, wbs_dat_o[31:0]
```

Provides a Wishbone slave interface from the management SoC.

The address space is internally split into:
- User address space
- Debug address space (last two registers)

---

### 3. Logic Analyzer Interface

```
la_data_in[127:0]
la_data_out[127:0]
la_oenb[127:0]
```

Used by the management SoC for signal probing, debug, and bring-up.

---

### 4. Digital GPIO Interface

```
io_in
io_in_3v3
io_out
io_oeb
```

Interfaces with the Caravel GPIO padframe.
- `io_in_3v3` provides a 3.3V copy of the GPIO input.
- `io_oeb` controls output enable (active low).

---

### 5. Analog GPIO Interface

```
gpio_analog
gpio_noesd
io_analog
io_clamp_high
io_clamp_low
```

Direct analog connections to GPIO pads. Intended for low-frequency / low-voltage analog signals. Some pads have no ESD protection, which must be handled by the user design.

---

### 6. Other Interfaces

```
user_clock2    // Independent user clock
user_irq[2:0]  // User interrupt outputs
```

---

## Internal Functionality

### GPIO Passthrough

```verilog
assign io_out = io_in;
```

Implements a simple passthrough from input to output. This is intentionally added to allow structural and connectivity verification through simulation. No user logic is present.

### Wishbone Address Decode

The Wishbone address space is split into:
- User space
- Debug space (decoded using `wbs_adr_i[31:3]`)

Debug accesses are routed to the `debug_regs` module. User Wishbone accesses are currently tied off.

---

## Verification Methodology

### Objective

To verify that the `user_analog_project_wrapper`:
- Elaborates correctly on the SCL180 PDK
- Preserves Caravel padframe assumptions
- Maintains correct structural connectivity after PDK migration

### Verification Approach

RTL-level, testbench-driven verification using Synopsys VCS. No firmware or RISC-V toolchain dependency.

The following were compiled:
- `user_analog_project_wrapper.v`
- `debug_regs.v`
- Caravel global definitions (`defines.v`)
- Standalone testbench

### What the Testbench Checked

- Successful elaboration of the wrapper
- Resolution of global macros:
  - `MPRJ_IO_PADS`
  - `ANALOG_PADS`
- GPIO passthrough behavior (`io_out = io_in`)
- Absence of unexpected X or Z values
- Correct structural integration of the `debug_regs` block

---

## Verification Outcome

✅ Module compiled and simulated successfully in VCS  
✅ Structural connectivity validated  
✅ GPIO passthrough confirmed  
✅ No issues observed due to Sky130 → SCL180 migration
