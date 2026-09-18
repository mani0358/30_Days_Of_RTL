# Day 01 — Verilog Fundamentals + Naming Conventions

## 1. Objective

The objective of Day 01 is to understand the basic structure of a Verilog HDL design and develop good RTL coding habits.

By the end of this day, we should understand:

* What Verilog HDL is
* What RTL means
* What a Verilog module is
* Module ports
* Input and output declarations
* Verilog identifiers
* Naming conventions
* Comments
* `wire` basics
* Basic continuous assignment
* Introduction to `always`
* Difference between design and testbench
* Compilation using Icarus Verilog
* Waveform generation
* Waveform viewing using GTKWave
* Basic Half Adder design

---

# 2. What is Verilog?

Verilog is a Hardware Description Language (HDL).

It is used to describe digital hardware such as:

* Logic gates
* Adders
* Multiplexers
* Registers
* Counters
* FSMs
* Memories
* Processors
* Digital systems

Verilog describes hardware behavior and structure rather than writing a normal sequential software program.

---

# 3. What is RTL?

RTL means:

> Register Transfer Level

RTL describes:

* Data
* Registers
* Combinational logic
* Transfer of data between registers
* Clocked behavior

Typical RTL flow:

```text
Specification
      ↓
RTL Verilog
      ↓
Simulation
      ↓
Synthesis
      ↓
Gate-Level Netlist
      ↓
Implementation
```

---

# 4. Basic Verilog Module

General structure:

```verilog
module module_name (
    input  wire a,
    input  wire b,
    output wire y
);

    // Design logic

endmodule
```

A module is the basic building block of a Verilog design.

---

# 5. Module Name

Example:

```verilog
module half_adder;
```

The module name should clearly indicate what the module does.

Good:

```text
half_adder
full_adder
mux_2to1
counter_4bit
fifo_sync
```

Avoid unclear names such as:

```text
abc
test1
module1
xyz
```

---

# 6. Naming Conventions

Use meaningful names.

## Inputs

Examples:

```text
a
b
clk
rst
enable
data_in
```

## Outputs

Examples:

```text
sum
carry
data_out
q
valid
ready
```

## Clock

Prefer:

```text
clk
```

## Reset

Examples:

```text
rst
reset
rst_n
```

If `_n` is used, it commonly indicates an active-low signal.

Example:

```text
rst_n
```

---

# 7. Verilog Identifiers

Identifiers are names used for:

* Modules
* Signals
* Variables
* Parameters
* Instances

Example:

```verilog
module half_adder;

wire sum;
wire carry;

endmodule
```

Here:

```text
half_adder → module identifier
sum        → signal identifier
carry      → signal identifier
```

---

# 8. Comments

Single-line comment:

```verilog
// This is a comment
```

Multi-line comment:

```verilog
/*
   This is
   a multi-line comment
*/
```

Comments should explain the purpose of important RTL sections.

---

# 9. Input and Output Ports

Example:

```verilog
module example (
    input  wire a,
    input  wire b,
    output wire y
);
```

Here:

```text
a → input
b → input
y → output
```

---

# 10. Half Adder

A Half Adder adds two 1-bit numbers.

Inputs:

```text
A
B
```

Outputs:

```text
SUM
CARRY
```

---

# 11. Half Adder Truth Table

| A | B | SUM | CARRY |
| - | - | --- | ----- |
| 0 | 0 | 0   | 0     |
| 0 | 1 | 1   | 0     |
| 1 | 0 | 1   | 0     |
| 1 | 1 | 0   | 1     |

Therefore:

```text
SUM   = A XOR B
CARRY = A AND B
```

---

# 12. Hardware Structure

```text
       A ─────┬──── XOR ───── SUM
              │
       B ─────┘

       A ─────┬──── AND ───── CARRY
              │
       B ─────┘
```

---

# 13. Verilog Half Adder

File:

```text
rtl/half_adder.v
```

Code:

```verilog
module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);

    assign sum   = a ^ b;
    assign carry = a & b;

endmodule
```

---

# 14. Understanding the Code

```verilog
module half_adder (
```

Starts the module.

```verilog
input wire a,
input wire b,
```

These are the two input signals.

```verilog
output wire sum,
output wire carry
```

These are the two output signals.

```verilog
assign sum = a ^ b;
```

Implements:

```text
SUM = A XOR B
```

```verilog
assign carry = a & b;
```

Implements:

```text
CARRY = A AND B
```

```verilog
endmodule
```

Ends the module.

---

# 15. Why `assign`?

`assign` is a continuous assignment.

For example:

```verilog
assign y = a & b;
```

Whenever `a` or `b` changes, the value of `y` is updated.

We will study dataflow modeling in detail on Day 9.

---

# 16. Testbench

A testbench is used to verify the design.

The testbench:

* generates inputs
* observes outputs
* creates simulation activity
* generates waveform files

The testbench itself is normally not synthesized as part of the hardware design.

---

# 17. Half Adder Testbench

File:

```text
tb/tb_half_adder.v
```

Code:

```verilog
`timescale 1ns/1ps

module tb_half_adder;

    reg a;
    reg b;

    wire sum;
    wire carry;

    half_adder dut (
        .a(a),
        .b(b),
        .sum(sum),
        .carry(carry)
    );

    initial begin

        $dumpfile("sim/half_adder.vcd");
        $dumpvars(0, tb_half_adder);

        a = 0;
        b = 0;
        #10;

        a = 0;
        b = 1;
        #10;

        a = 1;
        b = 0;
        #10;

        a = 1;
        b = 1;
        #10;

        $finish;

    end

endmodule
```

---

# 18. Testbench Structure

The important part is:

```verilog
half_adder dut (
```

`dut` means:

> Device Under Test

Our DUT is:

```text
half_adder
```

---

# 19. Why `reg` in the Testbench?

The testbench needs to drive:

```text
a
b
```

using procedural statements:

```verilog
a = 0;
b = 1;
```

Therefore we use:

```verilog
reg a;
reg b;
```

The output of the DUT is connected to:

```verilog
wire sum;
wire carry;
```

We will study `wire` and `reg` much more deeply on Days 4 and 5.

---

# 20. `$dumpfile`

```verilog
$dumpfile("sim/half_adder.vcd");
```

Creates a VCD waveform file.

VCD means:

> Value Change Dump

---

# 21. `$dumpvars`

```verilog
$dumpvars(0, tb_half_adder);
```

Stores signal changes for GTKWave.

---

# 22. `$finish`

```verilog
$finish;
```

Terminates simulation.

---

# 23. Icarus Verilog Setup

First check:

```bash
iverilog -V
```

Then:

```bash
vvp -V
```

Check GTKWave:

```bash
gtkwave --version
```

If all three work, your environment is ready.

---

# 24. Compile the Design

From:

```text
Verilog_50_Days/Day_01
```

run:

```bash
iverilog -o sim/half_adder_sim rtl/half_adder.v tb/tb_half_adder.v
```

This creates:

```text
sim/half_adder_sim
```

---

# 25. Run Simulation

Run:

```bash
vvp sim/half_adder_sim
```

You should see something similar to:

```text
VCD info: dumpfile sim/half_adder.vcd opened for output.
```

---

# 26. Open GTKWave

Run:

```bash
gtkwave sim/half_adder.vcd
```

Then in GTKWave:

```text
tb_half_adder
   ├── a
   ├── b
   ├── sum
   └── carry
```

Add these signals to the waveform window.

---

# 27. Expected Waveform

The simulation should represent:

```text
Time       A    B    SUM    CARRY
-----------------------------------
0 ns       0    0     0       0
10 ns      0    1     1       0
20 ns      1    0     1       0
30 ns      1    1     0       1
```

This exactly matches the Half Adder truth table.

---

# 28. One-Command Flow

After creating the files:

```bash
iverilog -o sim/half_adder_sim rtl/half_adder.v tb/tb_half_adder.v && vvp sim/half_adder_sim && gtkwave sim/half_adder.vcd
```

---

# 29. Practice Question 1

Design a **Half Subtractor**.

Inputs:

```text
a
b
```

Outputs:

```text
difference
borrow
```

First derive the truth table.

Then derive:

```text
Difference = ?
Borrow     = ?
```

Then write:

```text
half_subtractor.v
tb_half_subtractor.v
```

Run using Icarus Verilog and verify using GTKWave.

---

# 30. Practice Question 2

Design a **2:1 Multiplexer**.

Inputs:

```text
a
b
sel
```

Output:

```text
y
```

Create:

```text
rtl/mux_2to1.v
tb/tb_mux_2to1.v
```

Verify all input/select combinations.

---

# 31. Practice Question 3

Design a **2-bit Comparator**.

Inputs:

```text
a[1:0]
b[1:0]
```

Outputs:

```text
a_greater
a_equal
a_less
```

Verify all:

```text
4 × 4 = 16
```

input combinations.

---

# 32. Practice Question 4 — Naming

Identify whether these are good or poor RTL names:

```text
x1
clk
data_in
A
tmp
rst_n
abc
carry_out
q
signal123
```

Rewrite the poor names using meaningful RTL naming conventions.

---

# 33. Practice Question 5 — Interview

Answer without looking at notes:

### Q1

What is Verilog?

### Q2

What is HDL?

### Q3

What is RTL?

### Q4

What is a module?

### Q5

What is a port?

### Q6

What is the difference between input and output?

### Q7

What does `assign` do?

### Q8

What is a testbench?

### Q9

What is DUT?

### Q10

What is a VCD file?

### Q11

Why do we use GTKWave?

### Q12

What is the difference between simulation and synthesis?

---

# 34. Placement Question

Without writing code first:

Given:

```text
A = 1
B = 1
```

for a Half Adder, calculate:

```text
SUM = ?
CARRY = ?
```

Then verify your answer using:

1. Truth table
2. Boolean equation
3. Verilog simulation
4. GTKWave

This four-way verification method will be our standard approach for important digital-logic problems.

---

# 35. Day 1 Checklist

Before moving to Day 2, you should be able to explain:

* [ ] What is Verilog?
* [ ] What is HDL?
* [ ] What is RTL?
* [ ] What is a module?
* [ ] What are ports?
* [ ] Input vs output
* [ ] Identifier
* [ ] Naming conventions
* [ ] `wire` basics
* [ ] `assign`
* [ ] Testbench
* [ ] DUT
* [ ] `$dumpfile`
* [ ] `$dumpvars`
* [ ] `$finish`
* [ ] VCD
* [ ] Icarus Verilog
* [ ] GTKWave
* [ ] Half Adder truth table
* [ ] Half Adder equations
* [ ] Half Adder RTL
* [ ] Half Adder testbench

---

# 36. Day 1 Golden Rule

Always think:

```text
Specification
     ↓
Truth Table
     ↓
Boolean Equation
     ↓
Hardware
     ↓
Verilog RTL
     ↓
Testbench
     ↓
Icarus Simulation
     ↓
GTKWave
     ↓
Verify
```

This will be the basic workflow we use throughout the 50 days.
