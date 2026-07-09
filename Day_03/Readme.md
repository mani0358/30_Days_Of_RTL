# Day 03 - 2-Bit Comparator & D Flip-Flop (Verilog)

## 📚 Objective

The objective of this project is to understand the design, simulation, and verification of combinational and sequential circuits using Verilog HDL.

This project includes:

- 2-Bit Comparator
- Positive Edge Triggered D Flip-Flop (Asynchronous Reset)

The designs were simulated using **Icarus Verilog** and verified using **GTKWave**.

---

# Folder Structure

```
Day_03/
│── comparator.v
│── tb_comparator.v
│── d_ff.v
│── tb_d_ff.v
│── wave.vcd
│── README.md
```

---

# 1. 2-Bit Comparator

## Description

A 2-bit comparator compares two 2-bit binary numbers and generates three outputs.

| Output | Description |
|---------|-------------|
| a_gt_b | High when A > B |
| a_lt_b | High when A < B |
| a_eq_b | High when A = B |

---

## Truth Table

| A | B | A>B | A<B | A=B |
|---|---|:---:|:---:|:---:|
|00|00|0|0|1|
|00|01|0|1|0|
|00|10|0|1|0|
|00|11|0|1|0|
|01|00|1|0|0|
|01|01|0|0|1|
|01|10|0|1|0|
|01|11|0|1|0|
|10|00|1|0|0|
|10|01|1|0|0|
|10|10|0|0|1|
|10|11|0|1|0|
|11|00|1|0|0|
|11|01|1|0|0|
|11|10|1|0|0|
|11|11|0|0|1|

---

## Comparator Logic

```
A > B  → a_gt_b = 1

A < B  → a_lt_b = 1

A == B → a_eq_b = 1
```

---

# 2. D Flip-Flop

## Description

A positive edge-triggered D Flip-Flop stores one bit of data.

The output changes only on the rising edge of the clock.

An asynchronous reset clears the output immediately whenever reset becomes HIGH.

---

## Truth Table

| Reset | Clock | D | Q(next) |
|-------|-------|---|---------|
|1|X|X|0|
|0|↑|0|0|
|0|↑|1|1|
|0|0/1 (No Rising Edge)|X|Previous Value|

---

## Working

- Reset has highest priority.
- When reset is HIGH, output becomes 0 immediately.
- When reset is LOW, output follows input D only on the positive edge of the clock.
- Between clock edges, the output retains its previous value.

---

# Simulation

## Compile Comparator

```bash
iverilog -o sim comparator.v tb_comparator.v
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

## Compile D Flip-Flop

```bash
iverilog -o sim d_ff.v tb_d_ff.v
```

Run Simulation

```bash
vvp sim
```

Open GTKWave

```bash
gtkwave wave.vcd
```

---

# Learning Outcomes

After completing this project, I learned:

- Verilog module creation
- Port declaration
- Continuous assignment (`assign`)
- Relational operators (`>`, `<`, `==`)
- Sequential logic using `always`
- Positive edge-triggered circuits
- Asynchronous reset
- Testbench creation
- Clock generation
- Simulation using Icarus Verilog
- Waveform analysis using GTKWave

---

# Tools Used

- Verilog HDL
- Icarus Verilog
- GTKWave
- Ubuntu Linux
- Visual Studio Code

---

# Author

**Manjinder Singh**

VLSI | Digital Design | Verilog HDL Learning Journey

GitHub Placement Preparation Series
