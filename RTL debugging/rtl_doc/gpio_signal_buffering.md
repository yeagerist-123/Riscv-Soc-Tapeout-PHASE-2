# GPIO Signal Buffering Module Documentation

## Module Overview

The `gpio_signal_buffering` module is a structural buffering macro used to improve signal integrity for long GPIO management wires in a System-on-Chip (SoC). It inserts a predefined number of buffer stages between the management (housekeeping) logic and the GPIO control logic, based on estimated physical wire lengths.

This module is not functional logic; it exists purely for physical design correctness (timing, slew, and routability).

---

## Module Interface

### Input Signals

| Signal | Width | Description |
|---|---|---|
| `mgmt_io_in_unbuf` | [30:0] | Unbuffered GPIO input signals coming from GPIO pads toward management logic |
| `mgmt_io_out_unbuf` | [30:0] | Unbuffered GPIO output signals driven from management logic toward GPIO pads |
| `mgmt_io_oeb_unbuf` | [2:0] | Unbuffered Output Enable Bar (OEB) signals for selected GPIOs |

### Output Signals

| Signal | Width | Description |
|---|---|---|
| `mgmt_io_in_buf` | [30:0] | Buffered GPIO input signals delivered to management logic |
| `mgmt_io_out_buf` | [30:0] | Buffered GPIO output signals delivered to GPIO pads |
| `mgmt_io_oeb_buf` | [2:0] | Buffered OEB signals |

---

## Functional Description

### High-Level Functionality

The module performs pure signal buffering:
- Buffered outputs must be functionally identical to unbuffered inputs.
- ❌ No logic modification
- ❌ No inversion
- ❌ No gating
- ❌ No clocking

Only buffer insertion is performed.

### Why Buffering Is Required

In large SoCs:
- GPIOs are physically far from the management block
- Some wires exceed 7–8 mm
- Long wires cause:
  - Excessive delay
  - Poor slew
  - Routing congestion
  - Timing violations

To mitigate this, buffers are inserted approximately every 1.3 mm.

### Buffering Strategy

- Buffer count per GPIO is determined from estimated Manhattan wire length
- Right-hand side GPIOs require fewer buffers
- Left-hand side GPIOs require more buffers
- OEB signals require separate buffering

**Total buffers instantiated:**
- 95 for `mgmt_io_in`
- 95 for `mgmt_io_out`
- 6 for `mgmt_io_oeb`
- **196 buffers total**

---

## Internal Implementation

### Buffer Cell Used

- Standard cell: `buffd7`
- Drive strength: 7×
- Technology: SCL180
- Power model: Implicit power

```verilog
module buffd7 (I, Z);
```

### Structural Buffer Chain

Each long signal is passed through a chain of buffers:

```
unbuffered signal
   ↓
buffer stage 1
   ↓
buffer stage 2
   ↓
buffer stage N
   ↓
buffered signal
```

This is implemented using:

```verilog
wire [195:0] buf_in;
wire [195:0] buf_out;

buffd7 signal_buffers [195:0] (
    .I(buf_in),
    .Z(buf_out)
);
```

---

## Verification Philosophy

### What Is Verified

✔ Correct signal propagation  
✔ Correct buffer chain connectivity  
✔ No missing or miswired signals  

Verification criterion:
```
mgmt_io_*_buf == mgmt_io_*_unbuf
```

### What Is NOT Verified Here

❌ Timing improvement  
❌ Slew correction  
❌ Drive strength effects  
❌ IR drop or EM  

These are validated during:
- Static Timing Analysis (STA)
- Place & Route
- Signoff checks

---

## Migration from Sky130 to SCL180

This module was originally derived from a Sky130-based reference design. The following changes were made to achieve a complete and clean transition to SCL180.

### Changes Made for Sky130 → SCL180 Transition

#### 1. Removal of Explicit Power Pins (CRITICAL)

**Sky130 Style (Removed):**
```verilog
.VPWR(vccd),
.VGND(vssd),
.VPB(vccd),
.VNB(vssd)
```

**SCL180 Style (Final):**
```verilog
buffd7 (
    .I(...),
    .Z(...)
);
```

**Reason:**
SCL180 standard cells use implicit power. Explicit power pins do not exist in the foundry simulation models.

#### 2. Removal of USE_POWER_PINS Conditional Logic

All occurrences of:
```verilog
`ifdef USE_POWER_PINS
`ifndef USE_POWER_PINS
```

were completely removed.

**Reason:**
These macros are Sky130-specific and incompatible with SCL180.

#### 3. Removal of Sky130-Specific Decap References

**Removed:**
```verilog
sky130_ef_sc_hd__decap_12
```

**Reason:**
Sky130-specific cell. Decap insertion is handled automatically by PD tools in SCL180.

#### 4. Technology-Clean Standard Cell Binding

- `buffd7` is now resolved directly from SCL180 PDK
- No dummy models
- No Sky130 libraries
- No mixed-technology simulation

#### 5. Comment and Documentation Cleanup

Removed references to:
- Caravel
- Sky130
- Efabless-specific assumptions

Added SCL180-specific notes to clarify technology intent.

---

## Final Status Summary

| Aspect | Status |
|---|---|
| Sky130 dependencies | ❌ Removed |
| Explicit power pins | ❌ Removed |
| Standard cell library | ✅ SCL180 only |
| Functional verification | ✅ Passed |
| Tapeout suitability | ✅ Structurally clean |

---

## Key Takeaway

The `gpio_signal_buffering` module is a technology-adapted, structurally verified buffering macro that ensures signal integrity for long GPIO management wires and has been fully migrated from Sky130 assumptions to native SCL180 standard-cell usage.
