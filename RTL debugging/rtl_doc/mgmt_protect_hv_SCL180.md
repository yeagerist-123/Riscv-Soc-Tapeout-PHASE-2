# mgmt_protect_hv Module – SCL180 (FS120) Migration & Verification Documentation

## Module Overview

The `mgmt_protect_hv` module implements the high-voltage (3.3V) portion of the management protection logic. Its primary role is to generate constant logic-high control signals that are used by downstream logic and I/O structures.

This module is intentionally separated from the low-voltage logic so that it can be associated with a different standard-cell library during synthesis and physical design.

---

## Inputs and Outputs

### Inputs

None. The module is purely combinational and internally generates constant logic levels.

### Outputs

| Signal | Description |
|---|---|
| `mprj_vdd_logic1` | Constant logic-high control signal |
| `mprj2_vdd_logic1` | Constant logic-high control signal |

---

## Functional Description

Internally, the module:
- Instantiates constant generator cells (`dummy_scl180_conb_1`)
- Uses the `HI` output of these cells to generate logic-high values
- Propagates these logic-high values directly to the module outputs

There is no clocking, no state, and no conditional behavior. The module's functional intent is static logic-high generation.

---

## Original Implementation Characteristics

The original version of `mgmt_protect_hv` (derived from Sky130-based designs) contained:
- Explicit power pins (`vccd`, `vssd`, `vdda`, `vssa`)
- Conditional compilation using `USE_POWER_PINS`
- Sky130-specific HV-to-LV level shifter cells
- Explicit power wiring in RTL

This style is appropriate for Sky130, where power pins are exposed in Verilog models.

---

## Technology Constraint from SCL180 (FS120)

Based on the FS120 standard-cell delivery documentation:

**Proven facts from documentation:**
- FS120 provides separate representations:
  - `verilog/` → functional/timing models
  - `cdl/`, `spc/` → physical netlists with VDD/VSS
- Power (VDD/VSS) is defined only in CDL/SPICE, not in Verilog
- FS120 Verilog models do not expose power pins

**Therefore:** RTL must not attempt to connect power pins when instantiating FS120 Verilog cells.

This is not an assumption; it is a direct consequence of the library delivery structure.

---

## Changes Made to mgmt_protect_hv

### Removal of Power Pins from Module Interface

**Removed:**
```
vccd, vssd, vdda1, vssa1, vdda2, vssa2
```

**Reason:**
FS120 Verilog models are power-agnostic. Power connectivity is resolved during physical design and LVS using CDL/SPICE netlists.

---

### Removal of USE_POWER_PINS Conditional Logic

**Removed:**
```verilog
`ifdef USE_POWER_PINS
...
`endif
```

**Reason:**
FS120 Verilog cells do not support power pin connections, so conditional power wiring in RTL is invalid and causes compilation errors.

---

### Removal of Sky130-Specific Level Shifters

**Removed:**
```
sky130_fd_sc_hvl__lsbufhv2lv_1
```

**Reason:**
- Sky130 cells are not compatible with SCL180
- Voltage-domain handling is resolved in I/O cells and physical design, not in RTL
- RTL must remain technology-clean for SCL180

---

### Power-Agnostic Constant Generation

**Current Implementation:**
```verilog
dummy_scl180_conb_1 (
    .HI(signal),
    .LO()
);
```

**Reason:**
The FS120 constant generator Verilog model exposes only functional outputs, consistent with the library's intended usage.

---

## Final Functional Behavior (Unchanged)

Importantly:
- The functional intent of the module did not change
- Both outputs still resolve to logic 1
- Only technology binding was modified, not logic behavior
- This was confirmed using the same functional testbench, demonstrating behavioral equivalence before and after migration

---

## Verification Summary

### Verification Method

RTL-level functional simulation using Synopsys VCS with:
- FS120 standard-cell Verilog models
- Power-agnostic testbench

### Result

✔ Both outputs evaluated to constant logic-high  
✔ No unresolved modules  
✔ No power-pin related compilation errors
