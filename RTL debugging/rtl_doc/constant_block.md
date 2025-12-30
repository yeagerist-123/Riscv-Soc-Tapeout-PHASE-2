# Constant Block – SCL180 Technology Migration & Verification Documentation

## Block Overview

The `constant_block` module is a utility macro that generates logic-high (1) and logic-low (0) constants and provides buffered outputs suitable for driving internal control logic and I/O-related signals.

This block exists because:
- Foundry constant cells (HI, LO) have weak drive strength
- Directly driving logic or I/O control signals from these cells can violate drive and ESD requirements
- Buffering is required to safely distribute constant values

---

## Module Interface

### Outputs

| Signal | Width | Description |
|---|---|---|
| `one` | 1 bit | Buffered logic-high output |
| `zero` | 1 bit | Buffered logic-low output |

### Internal Signals

| Signal | Description |
|---|---|
| `one_unbuf` | Raw logic-high from constant cell |
| `zero_unbuf` | Raw logic-low from constant cell |

There are no functional inputs to this block.

---

## Functional Description

From a functional perspective, the block implements:

```verilog
one  = 1'b1
zero = 1'b0
```

Internally:
- A dedicated constant generator cell produces raw HI and LO signals
- These signals are passed through buffer cells to improve drive capability
- Buffered outputs are exposed at the module boundary

The block contains:
- ❌ No clocking
- ❌ No state
- ❌ No logic decisions

It is purely structural and physical-design driven.

---

## Original Issue: Sky130-Oriented Power Handling

The initial version of the block was derived from a Sky130/Caravel-style reference design, which included:
- `USE_POWER_PINS` macros
- Explicit power ports (`vccd`, `vssd`)
- Explicit power pin connections (`VPWR`, `VGND`, `VPB`, `VNB`)

This style is valid for Sky130, but incorrect for SCL180.

---

## Why Sky130 Uses Power Pins but SCL180 Does Not

### Sky130 Power Philosophy

Sky130 standard cells expose power and bulk pins. Power is treated as a logical connection. RTL often includes explicit power wiring for:
- Accurate transistor-level simulation
- Body-bias experiments
- Open-source flexibility

This is why macros like `USE_POWER_PINS` exist in Sky130-based designs.

### SCL180 Power Philosophy

SCL180 follows a traditional foundry tapeout methodology:
- Power is implicit, not part of RTL
- Power distribution is handled exclusively by:
  - Power rings
  - Power straps
  - Tap cells
  - Physical design tools
- Standard-cell RTL models expose only signal pins

For example:
```verilog
module buffda (I, Z);
```

Because of this:
- RTL must not declare or connect power
- Any Sky130-style power logic becomes a technology mismatch

---

## Changes Made for Sky130 → SCL180 Migration

The following changes were applied to make the block fully SCL180-clean and tapeout-compatible.

### Removal of Explicit Power Pins

**Removed from module interface:**
- `vccd`
- `vssd`

**Removed from all instantiations:**
- `VPWR`
- `VGND`
- `VPB`
- `VNB`

**Reason:**
SCL180 standard cells use implicit power and do not expose these ports.

### Complete Removal of USE_POWER_PINS

All conditional compilation related to:
```verilog
`ifdef USE_POWER_PINS
```

was removed.

**Reason:**
This macro exists solely to support Sky130's explicit-power methodology and is invalid for SCL180.

### Alignment with Native SCL180 Cells

The block now instantiates only SCL180-native cells with matching interfaces:
- `dummy_scl180_conb_1` → constant generator (HI, LO)
- `buffda` → output buffer (I, Z)

No dummy wrappers or altered cell definitions were introduced.

### Testbench Cleanup

The original testbench included:
- `supply1` / `supply0`
- Power pin connections to the DUT

These were removed. The final testbench:
- Instantiates the DUT without power pins
- Verifies only functional correctness
- Matches SCL180's implicit power model

### Resolution of timescale Compilation Issue

A VCS compilation error occurred due to inconsistent use of `timescale` directives across RTL and foundry library files.

**Fix applied:**
- Removed the `timescale` directive from the testbench
- Avoided modifying foundry standard-cell models

**Reason:**
Verilog-2001 requires consistent `timescale` usage across a compilation unit, and foundry library files must not be edited.

---

## Final SCL180-Clean constant_block

```verilog
module constant_block (
    output one,
    output zero
);

    wire one_unbuf;
    wire zero_unbuf;

    dummy_scl180_conb_1 const_source (
        .HI(one_unbuf),
        .LO(zero_unbuf)
    );

    buffda const_one_buf (
        .I(one_unbuf),
        .Z(one)
    );

    buffda const_zero_buf (
        .I(zero_unbuf),
        .Z(zero)
    );

endmodule
```

---

## Verification Summary

### Verification Type

- RTL functional verification
- Power-agnostic, consistent with SCL180 methodology

### Checks Performed

- Verified `one == 1'b1`
- Verified `zero == 1'b0`

### Tools Used

- Synopsys VCS
- Native SCL180 standard-cell simulation models

---

## Final Status

| Aspect | Status |
|---|---|
| Sky130 dependencies | ❌ Removed |
| Explicit power handling | ❌ Removed |
| SCL180 cell usage | ✅ Native |
