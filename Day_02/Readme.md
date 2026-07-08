# Day 02 - Verilog RTL Design

## Overview

Day 02 focuses on learning **RTL (Register Transfer Level) design** using Verilog HDL. The objective was to understand how to write synthesizable Verilog code, simulate it, and verify the functionality using a text-based design flow.

This day's work includes:

- 8:1 Multiplexer Design
- Half Adder Design
- Full Adder Design using Two Half Adders (Structural Modeling)

---

## Topics Covered

- Verilog Module Declaration
- Input and Output Port Declaration
- Wire and Register Data Types
- Continuous Assignment (`assign`)
- Structural Modeling
- Module Instantiation
- Case Statement
- Sequential Logic using `always @(posedge clk)`
- Testbench Development
- Waveform Generation using GTKWave

---

## Implemented Designs

### 1. 8:1 Multiplexer

**Description**

Designed an 8-to-1 Multiplexer using Verilog. The design selects one of eight 8-bit inputs based on a 3-bit select signal.

**Concepts Learned**

- Case Statement
- Sequential Logic
- Pipeline Registers
- Clocked Design
- RTL Coding Style

---

### 2. Half Adder

**Description**

Implemented a Half Adder using Dataflow Modeling.

**Logic Equations**

```
Sum   = A ⊕ B
Carry = A · B
```

---

### 3. Full Adder

**Description**

Implemented a Full Adder using **Structural Modeling** by connecting two Half Adders and one OR gate.

**Logic Equations**

```
Sum  = A ⊕ B ⊕ Cin
Cout = AB + Cin(A ⊕ B)
```

---

## Project Structure

```
Day_02/
│
├── mux_8to1.v
├── half_adder.v
├── full_adder.v
├── tb_mux_8to1.v
├── tb_full_adder.v
└── README.md
```

---

## Text-Based Design Flow

The complete RTL design flow was performed using command-line tools.

### 1. RTL Coding

Write synthesizable Verilog HDL modules.

### 2. Functional Simulation

Compile the design using Icarus Verilog.

```bash
iverilog -o sim *.v
```

### 3. Run Simulation

```bash
vvp sim
```

### 4. Generate Waveform

```verilog
$dumpfile("wave.vcd");
$dumpvars(0, testbench_name);
```

### 5. View Waveform

```bash
gtkwave wave.vcd
```

---

## Tools Used

- Ubuntu Linux
- Icarus Verilog
- GTKWave
-  Nano Editor
- Bash Terminal

---

## Learning Outcomes

After completing Day 02, I learned:

- Writing synthesizable Verilog RTL code
- Creating reusable Verilog modules
- Structural Modeling
- Dataflow Modeling
- Module Instantiation
- Writing Testbenches
- Functional Verification
- Waveform Analysis
- Text-Based Design Flow
- Basic Digital Design Implementation

---

## Commands Used

Compile

```bash
iverilog -o sim *.v
```

Run Simulation

```bash
vvp sim
```

Open Waveform

```bash
gtkwave wave.vcd
```

---

## Future Work

- Ripple Carry Adder
- 4:1 Multiplexer
- Decoder
- Encoder
- Priority Encoder
- Comparator
- ALU Design

---

## Author

**Manjinder Singh**

VLSI Design Learning Journey

Day 02 — RTL Design using Verilog HDL
