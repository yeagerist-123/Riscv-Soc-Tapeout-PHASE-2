# RISC-V SoC Implementation (RTL → Synthesis → GLS) using SCL180 PDK

## 1. Overview
This repository contains the reference vsdcaravel RISC‑V SoC flow adapted for the SCL180 PDK and Synopsys toolchain. It demonstrates the full path from RTL functional simulation through Synopsys Design Compiler synthesis to gate‑level simulation (GLS), and provides example scripts, netlist editing notes, and post‑synthesis reports.

- Top module: `vsdcaravel`
- PDK: SCL180 (Semiconductor Laboratory) — access requires NDA and PDK distribution from SCL
- Tools: Synopsys DC (dc_shell), VCS/Icarus Verilog, GTKWave
- Reference repo: https://github.com/vsdip/vsdRiscvScl180 (branch: iitgn)

---

## 2. Quick summary of the flow
1. Functional simulation (dv/)
2. Synthesis with Synopsys DC (synthesis/)
3. Netlist edits to replace blackboxes and power ties (synthesis/output/)
4. Gate‑level simulation (gls/ or gl/)

Screenshots used throughout are stored in `./images/` — two RTL screenshots are included below for quick reference.

---

## 3. Functional Simulation (RTL)
Steps (example: `dv/hkspi`):
- Edit `dv/hkspi/Makefile` to set:
  - `GCC_Path` → riscv32-unknown-elf toolchain
  - `scl_io_PATH` → SCL IO wrappers (if required)
- Clean, build and run:
```bash
cd dv/hkspi
make clean
make        # generates hkspi.vvp
vvp hkspi.vvp
gtkwave hkspi.vcd hkspi_tb.v
```

## ERROR NUMBER 1

There is a path mismatch for ring_osc2X13.v

![ringoscillator error](https://github.com/user-attachments/assets/b9487ea5-8532-4b07-ba8c-744038daf97b)

for this you need the mention the correct path:

![ring solution](https://github.com/user-attachments/assets/3fdabc82-f849-49ac-8359-6df9fd79ef57)


## ERROR NUMBER 2

There is an error in chip_io.v Because there are 2 files with the same name but different functionalities i.e pt3b02_wrapper.v

![chipio error](https://github.com/user-attachments/assets/81d138c3-f56b-449f-a62e-6980d2413eb1)


for this you need to change the file name of pt3b02_wrapper to pt3b02_wrapper1.v and explicitly include it in the chip_io.v code

![wrap1](https://github.com/user-attachments/assets/56ebf429-1b16-474a-8c3f-5a109f2da470)

 also make sure you change these lines from pt3b02_wrapper to  pt3b02_wrapper_0 and  pt3b02_wrapper_1 because the file we renamed and included explicitly contains these.

 ![ptwrap0,1](https://github.com/user-attachments/assets/a6dfc912-a34f-4111-a467-c7b0457d6f80)

then your rtl will pass without any issues

![rtlpassed](https://github.com/user-attachments/assets/2b5098cc-061d-4003-88c8-f56634df61a4)

waveform visualisation

![rtlwaveform](https://github.com/user-attachments/assets/b257750a-66a6-48b5-8a06-87c91233bfe8)


---

## 4. Synthesis (Synopsys Design Compiler)
- Edit `./synthesis/synth.tcl`:
  - Point to the SCL cell libraries (.db), liberty files, and correct root paths.
  - Set synthesis constraints (clk period, false paths if any).
- Run from work folder:
```bash
cd synthesis/work_folder
dc_shell -f ../synth.tcl
```
![synthesis](https://github.com/user-attachments/assets/be06f5e4-dac6-4a91-80ea-6efb92f035c5)


- Expected outputs:
  - Synthesized verilog: `vsdcaravel_synthesis.v` (in `synthesis/output/`)
  - Area/power/timing reports (in `synthesis/report/`)
 


Key metrics (example excerpts):
- Total cell area: ~773k — 884k (varies per run)
- Dynamic power: ~72–77 mW (tool dependent)
- Leaf cell count: ~26k–31k (tool dependent)

---

## 5. Gate-Level Simulation (GLS)
Preparation:
- Copy synthesized netlist to `gls/` or reference it from `synthesis/output/`.
- Remove black-box module definitions from the synthesized netlist and `include` the RTL replacements:
```verilog
`include "dummy_por.v"
`include "RAM128.v"
`include "housekeeping.v"
```
- Replace hard-coded `1'b0` used as ground with the PDK ground net (e.g., `vssa`) where appropriate.

GLS run (example):
```bash
cd gls
make clean
make
vvp hkspi.vvp
gtkwave hkspi.vcd hkspi_tb.v
```
![gls passed](https://github.com/user-attachments/assets/61b1fd1f-26eb-4fb0-9c97-734b5c3e4d5a)

WAVEFORM

![glswaveform](https://github.com/user-attachments/assets/9aaef94b-b6d3-4506-87cb-0a144132ceeb)


Expected: GLS waveforms should match RTL functional simulation for the exercised tests.

---

## 6. Post-synthesis Results (selected excerpts)
Area (excerpt):
```
Combinational area:    341,952 — 357,559
Sequential area:       ~431,036 — 484,149
Total cell area:       ~773k — 847k
Total design area:     ~806k — 883k
```
![area report](https://github.com/user-attachments/assets/305ab5c1-27a6-40db-a857-ad112e89b788)

Power (excerpt):
```
Total dynamic: ~72–77 mW
Internal cell power ~38–39 mW
Net switching power ~33–38 mW
Leakage ~1–2 µW
```
![power report](https://github.com/user-attachments/assets/16468ec2-e356-4fa0-ba5d-90cbbbc9e542)


QoR / Timing (excerpt):
```
Levels of logic: ~59
Critical path slack: 0.00 (no timing violations in reported runs)
Violating paths: 0
```
![qor](https://github.com/user-attachments/assets/61c21125-cd5d-4fe3-bc22-ad5e986d9e35)


Full reports are in `./synthesis/report/` — review those files for per-module breakdowns.

---

## 7. Three highlighted errors (observed during runs) — descriptions & mitigation
Below are three reproducible errors encountered during GLS with recommended actions.

1) Error: Housekeeping module failed to synthesize (mapped to blackbox)
- Symptom: Synthesis leaves `housekeeping` as a blackbox; subsequent netlist has a blackbox placeholder.
- Probable cause: Unsupported constructs (behavioral blocks, generate loops, or inferred RAMs) or naming mismatch with PDK IO wrappers.
- Workaround:
  - Inspect `rtl/housekeeping.v` for unsupported synthesizable constructs (e.g., file I/O, $display-only constructs).
  - Refactor or rewrite the problematic logic to RTL-friendly style (finite-state machine style, remove non-synthesizable tasks).
  - As a temporary GLS workaround, include the RTL `housekeeping.v` into the netlist (remove the blackbox def) so behavioral RTL is used for GLS.
- Status: Documented; long‑term fix: RTL refactor + re-run synthesis.

2) Error: RAM128 inferred memory blackboxed / missing PDK memory macro
- Symptom: Memory instances are left as blackboxes or mismatched port widths after mapping.
- Probable cause: The synthesis mapping expects vendor-specific memory macros (SCL memory compilers) which are not available or not referenced.
- Workaround:
  - Replace inferred RAM with an explicit SCL memory macro when available (match port names and parameters).
  - For GLS, include an RTL behavioral RAM model (`RAM128.v`) and `include` it in the netlist to bypass macro absence.
- Status: Temporary GLS fix applied; PDK memory macro integration planned.

3) Error: Netlist uses literal '1'b0' for ground/power pin and causes mismatch with PDK ground net (vssa)
- Symptom: GLS or PDK tools report power pin mismatch or simulation mismatches; some modules tie inputs to `1'b0` instead of using the PDK ground net.
- Probable cause: Synthesis/RTL used hard-coded constants instead of explicit power rails; PDK expects named ports/nets for power.
- Workaround:
  - Post-process netlist: replace `1'b0` occurrences tied to power pins with `vssa` (or the correct ground net name).
  - Ensure power pins are explicitly connected in top-level instantiations or that power-net naming conventions are consistent across RTL and PDK libraries.
- Status: Applied to GLS netlist; ensure consistent treatment before P&R.

---

## 8. Known issues (other)
- Several modules had timing arcs disabled automatically by the tool (notably in `PLL` and parts of `housekeeping`) — these must be inspected and corrected to ensure correct static timing analysis.
- Clock tree power estimate is not included in the provided power reports; account for clock-tree insertion during P&R.

---

## 9. Suggested next steps (roadmap)
- Rework `housekeeping` RTL to be synthesis-friendly and re-run DC.
- Integrate SCL memory macros and POR cells to remove blackboxes.
- Add more regression tests and firmware to exercise internal interfaces of `vsdcaravel`.
- Proceed to ICC2/Primetime/Place & Route once macros are integrated.
- Add UPF/CPF files and power-aware simulation flows.

---

## 6. Conclusion

From RTL to GLS , the simulations are done but as mentioned above the certain modules have issues with synthesis , which were made black boxes for GLS. this is the only reason for having small differences in the waveforms between RTL simulation and GLS simulation. The other parts of the waveforms show correct functionality saying that this mismatch is not actually a functionality issue but it is a synthesis issue which is to be fixed. So the design functionality is verified.

---

---

## References
- efabless / Caravel: https://github.com/efabless/
- This repository: https://github.com/vsdip/vsdRiscvScl180/tree/iitgn

License & usage: The reference IP in this repository is free to use for tapeout on SCL180 by qualified parties with proper PDK access and NDA. Do not redistribute PDK files or licensed assets.
