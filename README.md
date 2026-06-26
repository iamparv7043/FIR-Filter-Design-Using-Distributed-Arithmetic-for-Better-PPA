# FIR Filter Design Using Distributed Arithmetic (DA)

A **16-Tap Low Pass FIR Filter** implemented in **Verilog HDL** using the **Distributed Arithmetic (DA)** technique. This design replaces conventional multipliers with Look-Up Tables (LUTs), shift operations, and accumulation, resulting in a hardware-efficient architecture suitable for FPGA implementation.

---

## 📌 Project Overview

Finite Impulse Response (FIR) filters are widely used in Digital Signal Processing (DSP). Traditional FIR filters require multiple multipliers, which increase hardware complexity and power consumption. Distributed Arithmetic (DA) eliminates these multipliers by using precomputed LUTs, making the implementation more area and power efficient.

This project implements a **16-tap Low Pass FIR Filter** using DA architecture and verifies its functionality through simulation and FPGA synthesis.

---

## ✨ Features

- 16-Tap Low Pass FIR Filter
- Multiplier-less Distributed Arithmetic implementation
- LUT-based coefficient storage
- Shift-and-Accumulate architecture
- Verilog HDL implementation
- FPGA Synthesizable
- Efficient hardware utilization

---

# 🏗️ Architecture

The filter architecture consists of:

- 16-stage input shift register
- Four 16×13-bit LUTs
- Shift-and-Accumulate unit
- Adder
- Output Register

![Architecture](images/Architecture.png)

---

# ⚙️ Working Principle

1. Input samples are loaded into a 16-stage shift register.
2. One bit from each sample is processed during every clock cycle.
3. These bits generate LUT addresses.
4. LUTs output precomputed partial sums.
5. Partial sums are shifted according to the current bit position.
6. The accumulator adds shifted values.
7. After processing all 10 input bits, the filtered output is obtained.

This implementation completely eliminates hardware multipliers.

---

# 📊 Filter Specifications

| Parameter | Value |
|-----------|-------|
| Filter Type | Low Pass FIR |
| Filter Order | 16 |
| Input Width | 10-bit |
| Output Width | 22-bit |
| Architecture | Distributed Arithmetic |
| LUT Size | 16 × 13-bit |
| HDL | Verilog |

---

# 📑 Filter Coefficients

| Tap | Coefficient | Tap | Coefficient |
|-----|------------|-----|------------|
| h(0) | 0.0328 | h(8) | 0.5763 |
| h(1) | 0.0816 | h(9) | -0.0550 |
| h(2) | -0.0065 | h(10) | -0.0694 |
| h(3) | -0.0047 | h(11) | 0.0847 |
| h(4) | 0.0847 | h(12) | -0.0047 |
| h(5) | -0.0694 | h(13) | -0.0065 |
| h(6) | -0.0550 | h(14) | 0.0816 |
| h(7) | 0.5763 | h(15) | 0.0328 |

---

# 📈 Simulation Result

The waveform below shows the filtered output generated after processing all input bits using the Distributed Arithmetic architecture.

![Simulation](images/Sim.png)
---

# 📉 Frequency Response

The magnitude response confirms the Low Pass FIR filter characteristics with a flat passband and significant attenuation in the stopband.

![Frequency Response](images/Filter_Response.png)

---

# 🛠️ Synthesis Report

The design was successfully synthesized for FPGA implementation.

### Synthesis Report

![Synthesis Report](images/Synthesis_rpt.png)

---

# 🚀 Advantages

- Eliminates hardware multipliers
- Lower silicon area
- Reduced power consumption
- FPGA-friendly implementation
- Efficient LUT utilization
- Suitable for fixed-coefficient DSP applications

---

# 🧪 Tools Used

- Xilinx ISE Design Suite
- ModelSim
- MATLAB

---

# 📌 Conclusion

A **16-Tap Low Pass FIR Filter** based on **Distributed Arithmetic (DA)** was successfully designed and implemented in Verilog HDL. The architecture replaces conventional multipliers with LUTs, shift operations, and accumulation, resulting in a hardware-efficient implementation. Simulation and synthesis results verify the correctness of the design while demonstrating reduced hardware complexity, making it suitable for FPGA and low-power DSP applications.
