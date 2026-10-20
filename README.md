# Approximate-Adder-and-Multiplier
Verilog implementations of FPGA-optimized approximate multipliers and pipelined adders using LUT6_2 and CARRY4 primitives.

# FPGA-Based Approximate Arithmetic Modules

This repository contains standalone Verilog implementations for hardware-optimized approximate arithmetic modules targeting Xilinx 7-Series FPGAs (such as the Artix-7 family)[cite: 1, 5]. The repository features two distinct, independently operating functional blocks designed for different optimization and workflow use cases: a custom pipelined adder (`dadda_nocarry_lsb`) and a compressor-based approximate multiplier (`multiplier_1`).

---

## Overview of Independent Modules

Each module in this repository serves a completely different operational workflow and can be utilized independently depending on your design requirements:

### 1. Pipelined Adder / Accumulator (`dadda_nocarry_lsb`)
* **Independent Functionality:** Operates as a specialized, high-throughput pipelined arithmetic adder rather than a standalone multiplier[cite: 8, 10]. It is structured to process and accumulate partial products[cite: 9, 10].
* **Core Mechanisms:**
  * **Direct and Unregistered Assignments:** Lower bits are directly passed from input terms, bypassing complex logic stages[cite: 10].
  * **LUT-Level Processing:** Middle bits (columns 4 through 11) are evaluated using `LUT6_2` primitives to generate localized `sum_wire` and `carry_wire` outputs[cite: 5, 10].
  * **Pipeline Gated Clocks:** Upper critical paths are isolated using a gated clock (`gated_clk = clk & enable`) coupled with register stages (`sum` and `carry`) to achieve high-frequency timing stability[cite: 10].
  * **Carry Chain Integration:** Leverages cascaded `CARRY4` primitives (`C0`, `C1`, `C2`) to route fast carry propagation across wider bit-widths up to the final 16-bit `result`[cite: 6, 8, 10].

### 2. Compressor Tree Multiplier (`multiplier_1`)
* **Independent Functionality:** Operates as a standalone 8-bit approximate multiplier utilizing an advanced compressor-based reduction tree structure[cite: 1, 4].
* **Core Mechanisms:**
  * **Parallel Partial-Product Generation:** Utilizes `LUT6_2` configured with dual-AND gate logic (`INIT = 64'hF000F00088888888`) to simultaneously compute multiple partial products per look-up table[cite: 5, 15, 16].
  * **Custom Compressors (`acfgi1` & `ac6g1`):** Employs tailored 4:2 and 2:2 approximate compressor modules mapped to specific 64-bit `INIT` masks for high-speed logic reduction[cite: 1, 4, 13, 16].
  * **Standard Arithmetic Elements:** Integrates exact full adders (`fa`) and half adders (`ha`) synthesized via single `LUT6_2` primitives[cite: 1, 5].
  * **Carry Ripple-Chain Stage:** Resolves final multiplication outputs utilizing a dedicated three-stage `CARRY4` chain (`rca0`, `rca1`, `rca2`)[cite: 5, 6].

---

## Getting Started & Usage

1. Add the specific Verilog module files to your Xilinx Vivado design project depending on which standalone component you need to test[cite: 18].
2. Set either `dadda_nocarry_lsb` or `multiplier_1` as your independent top-level module for behavioral simulation and synthesis.
3. Target the Xilinx Artix-7 FPGA primitive library (`xc7a100tcsg324-1` or equivalent) for optimal primitive mapping[cite: 1, 18].

---

## Citation & Reference

If you utilize these architectures in your research or academic projects, please cite the foundational work[cite: 1]:

> **B. Chandrababu Naik, Kalpaj Kashyap, Sri Hari A S, Anju Thomas, and Varun P. Gopi**, *"Hardware-Efficient Approximate Multipliers Using LUT-Based Compressors and Adders"*, Department of Electronics and Communication Engineering, National Institute of Technology Tiruchirappalli & Vellore Institute of Technology[cite: 1].
