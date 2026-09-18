# Day 02 — Text-Based Verilog Design Flow

## 1. Objective

Today we will understand the complete text-based RTL design flow:

```text
Specification
      ↓
Verilog RTL
      ↓
Compilation
      ↓
Simulation
      ↓
Waveform Analysis
      ↓
Synthesis
      ↓
Netlist
      ↓
Implementation
```

We will use:

* Verilog
* Icarus Verilog
* GTKWave
* Linux terminal
* Text editor

Today's main practical design is a:

> 2-bit Comparator

---

# 2. What is Text-Based Design?

In text-based hardware design, we describe hardware using HDL source code.

For example:

```verilog
assign y = a & b;
```

Instead of drawing an AND gate graphically, we describe the required hardware using Verilog.

The HDL tool interprets the code and produces the corresponding hardware representation.

---

# 3. Complete RTL Design Flow

## Step 1 — Specification

First determine what the circuit must do.

Example:

> Compare two 2-bit numbers and indicate whether A is greater than B, equal to B, or less than B.

---

## Step 2 — RTL Design

Write Verilog code.

```text
specification
     ↓
RTL code
```

---

## Step 3 — Compilation

The Verilog compiler checks the source code.

For example:

```bash
iverilog
```

It detects things such as:

* syntax errors
* undeclared signals
* incorrect module connections
* invalid Verilog constructs

---

## Step 4 — Simulation

Simulation checks whether the RTL behaves correctly.

We use:

```bash
vvp
```

with Icarus Verilog.

---

## Step 5 — Waveform Analysis

The simulator can create:

```text
VCD
```

files.

GTKWave displays the signal transitions.

```text
Verilog
   ↓
Icarus
   ↓
VCD
   ↓
GTKWave
```

---

# 4. Simulation vs Synthesis

This distinction is extremely important.

## Simulation

Simulation answers:

> "Does my Verilog behave as expected?"

It models the behavior described by the HDL.

---

## Synthesis

Synthesis answers:

> "What hardware can be built from this RTL?"

For example:

```verilog
assign y = a & b;
```

can synthesize into an AND gate.

---

# 5. RTL

RTL means:

> Register Transfer Level

At RTL we describe:

* combinational logic
* registers
* clocked logic
* data movement
* control logic

Example:

```verilog
always @(posedge clk)
    q <= d;
```

represents a clocked storage element.

---

# 6. Design File vs Testbench

We normally separate:

```text
Design
   ↓
DUT

Testbench
   ↓
drives DUT
   ↓
checks DUT
```

Example:

```text
rtl/
    comparator_2bit.v

tb/
    tb_comparator_2bit.v
```

---

# 7. Today's Design — 2-bit Comparator

Inputs:

```text
A[1:0]
B[1:0]
```

Outputs:

```text
A_greater
A_equal
A_less
```

Meaning:

```text
A > B → A_greater = 1
A = B → A_equal   = 1
A < B → A_less    = 1
```

Only one output should be `1` for valid 0/1 inputs.

---

# 8. Truth Table

Because A and B are 2-bit numbers:

```text
A = 00, 01, 10, 11
B = 00, 01, 10, 11
```

There are:

```text
4 × 4 = 16
```

combinations.

| A  | B  | A>B | A=B | A<B |
| -- | -- | --: | --: | --: |
| 00 | 00 |   0 |   1 |   0 |
| 00 | 01 |   0 |   0 |   1 |
| 00 | 10 |   0 |   0 |   1 |
| 00 | 11 |   0 |   0 |   1 |
| 01 | 00 |   1 |   0 |   0 |
| 01 | 01 |   0 |   1 |   0 |
| 01 | 10 |   0 |   0 |   1 |
| 01 | 11 |   0 |   0 |   1 |
| 10 | 00 |   1 |   0 |   0 |
| 10 | 01 |   1 |   0 |   0 |
| 10 | 10 |   0 |   1 |   0 |
| 10 | 11 |   0 |   0 |   1 |
| 11 | 00 |   1 |   0 |   0 |
| 11 | 01 |   1 |   0 |   0 |
| 11 | 10 |   1 |   0 |   0 |
| 11 | 11 |   0 |   1 |   0 |

---

# 9. Comparator RTL

Create:

```text
Day_02/
└── rtl/
    └── comparator_2bit.v
```

Code:

```verilog
module comparator_2bit (
    input  wire [1:0] a,
    input  wire [1:0] b,
    output wire       a_greater,
    output wire       a_equal,
    output wire       a_less
);

    assign a_greater = (a > b);
    assign a_equal   = (a == b);
    assign a_less    = (a < b);

endmodule
```

---

# 10. Important Observation

These operators:

```verilog
>
==
<
```

are relational/equality operators.

For example:

```verilog
a > b
```

produces a Boolean result.

This is synthesizable RTL.

The synthesis tool can create comparator hardware.

---

# 11. Testbench

Create:

```text
Day_02/
└── tb/
    └── tb_comparator_2bit.v
```

Use:

```verilog
`timescale 1ns/1ps

module tb_comparator_2bit;

    reg [1:0] a;
    reg [1:0] b;

    wire a_greater;
    wire a_equal;
    wire a_less;

    comparator_2bit dut (
        .a(a),
        .b(b),
        .a_greater(a_greater),
        .a_equal(a_equal),
        .a_less(a_less)
    );

    initial begin

        $dumpfile("sim/comparator_2bit.vcd");
        $dumpvars(0, tb_comparator_2bit);

        a = 2'b00; b = 2'b00; #10;
        a = 2'b00; b = 2'b01; #10;
        a = 2'b00; b = 2'b10; #10;
        a = 2'b00; b = 2'b11; #10;

        a = 2'b01; b = 2'b00; #10;
        a = 2'b01; b = 2'b01; #10;
        a = 2'b01; b = 2'b10; #10;
        a = 2'b01; b = 2'b11; #10;

        a = 2'b10; b = 2'b00; #10;
        a = 2'b10; b = 2'b01; #10;
        a = 2'b10; b = 2'b10; #10;
        a = 2'b10; b = 2'b11; #10;

        a = 2'b11; b = 2'b00; #10;
        a = 2'b11; b = 2'b01; #10;
        a = 2'b11; b = 2'b10; #10;
        a = 2'b11; b = 2'b11; #10;

        $finish;

    end

endmodule
```

---

# 12. Create Directory

From your terminal:

```bash
mkdir -p ~/Verilog_50_Days/Day_02/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_02
```

Check:

```bash
tree
```

Expected:

```text
.
├── rtl
├── sim
├── tb
└── wave
```

---

# 13. Compile

From:

```text
~/Verilog_50_Days/Day_02
```

run:

```bash
iverilog -o sim/comparator_2bit_sim rtl/comparator_2bit.v tb/tb_comparator_2bit.v
```

If there are no errors, compilation succeeded.

---

# 14. Run Simulation

```bash
vvp sim/comparator_2bit_sim
```

Expected:

```text
VCD info: dumpfile sim/comparator_2bit.vcd opened for output.
```

---

# 15. Open GTKWave

```bash
gtkwave sim/comparator_2bit.vcd
```

Add:

```text
a
b
a_greater
a_equal
a_less
```

---

# 16. What You Should See

For:

```text
A = 00
B = 00
```

you should see:

```text
a_greater = 0
a_equal   = 1
a_less    = 0
```

For:

```text
A = 10
B = 01
```

you should see:

```text
a_greater = 1
a_equal   = 0
a_less    = 0
```

For:

```text
A = 01
B = 11
```

you should see:

```text
a_greater = 0
a_equal   = 0
a_less    = 1
```

---

# 17. Important Day 2 Experiment

Your uploaded roadmap specifically asks you to observe the comparator when the input drivers are removed in the testbench.

After your normal simulation works, try this experiment.

Temporarily remove the assignments:

```verilog
a = 2'b00;
b = 2'b00;
```

or comment them out.

For example:

```verilog
initial begin

    $dumpfile("sim/comparator_2bit.vcd");
    $dumpvars(0, tb_comparator_2bit);

    #100;

    $finish;

end
```

Now run:

```bash
iverilog -o sim/comparator_2bit_sim rtl/comparator_2bit.v tb/tb_comparator_2bit.v
vvp sim/comparator_2bit_sim
gtkwave sim/comparator_2bit.vcd
```

---

# 18. What Happens When Inputs Are Not Driven?

This is an important Verilog concept.

Because:

```verilog
reg [1:0] a;
reg [1:0] b;
```

are not initialized or assigned a value, simulation starts with unknown values.

Typically:

```text
a = XX
b = XX
```

Therefore comparator outputs can also become unknown:

```text
a_greater = X
a_equal   = X
a_less    = X
```

This is a **simulation initialization issue**, not necessarily a hardware failure.

We will study initialization and `X/Z` behavior much more deeply on Day 8.

---

# 19. Why Is X Important?

Verilog has four-state logic:

```text
0 → logic 0
1 → logic 1
X → unknown
Z → high impedance
```

For RTL verification, `X` is extremely important.

An unexpected `X` can indicate:

* missing reset
* uninitialized register
* incomplete assignment
* multiple-driver problems
* incorrect testbench stimulus
* unknown input

---

# 20. Text-Based Design Advantages

### 1. Easy to modify

Changing:

```verilog
2'b10
```

to:

```verilog
4'b1010
```

can be much easier than redrawing a large schematic.

### 2. Reusable

A module can be instantiated multiple times.

### 3. Parameterizable

We can later write:

```verilog
parameter WIDTH = 8;
```

and create reusable designs.

### 4. Version control

Verilog source files can easily be managed with Git.

### 5. Automation

Compilation and simulation can be scripted.

---

# 21. Text-Based Design Disadvantages

* Syntax errors can occur.
* Hardware behavior is not always obvious from code.
* Poor RTL can infer unintended hardware.
* Large designs require good organization.
* Simulation does not automatically prove that the RTL is functionally correct.

Therefore:

> Knowing Verilog syntax is not enough. You must understand the hardware implied by the RTL.

---

# 22. Compilation vs Simulation

Remember this distinction:

```text
iverilog
   ↓
Compile
```

while:

```text
vvp
   ↓
Execute simulation
```

and:

```text
gtkwave
   ↓
View waveform
```

So:

```text
iverilog → compile
vvp      → simulate
GTKWave  → visualize
```

---

# 23. Basic Debugging Flow

If compilation fails:

```text
Read compiler error
       ↓
Find line number
       ↓
Check syntax
       ↓
Fix RTL/TB
       ↓
Compile again
```

If compilation succeeds but output is wrong:

```text
Check testbench
       ↓
Check expected truth table
       ↓
Check RTL
       ↓
Check waveform
```

---

# 24. Practice Question 1 — Half Subtractor

Design:

```text
Half Subtractor
```

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

Do this in order:

```text
Truth table
     ↓
Boolean equation
     ↓
Verilog
     ↓
Testbench
     ↓
Icarus
     ↓
GTKWave
```

---

# 25. Practice Question 2 — 4-bit Comparator

Upgrade today's comparator from:

```text
2-bit
```

to:

```text
4-bit
```

Inputs:

```verilog
a[3:0]
b[3:0]
```

Outputs:

```text
a_greater
a_equal
a_less
```

Verify all **selected boundary cases**:

```text
0 vs 0
0 vs 15
15 vs 0
7 vs 7
8 vs 7
7 vs 8
15 vs 15
```

---

# 26. Practice Question 3 — Missing Driver

Create a testbench where:

```text
a
```

is driven but:

```text
b
```

is never initialized.

Observe the waveform.

Answer:

1. What value does `b` have?
2. What happens to the outputs?
3. Why?
4. Is this a simulation problem or a synthesis problem?

---

# 27. Practice Question 4 — Debugging

The following code contains an error:

```verilog
module and_gate (
    input wire a,
    input wire b,
    output wire y
)

assign y = a & b;

endmodule
```

Find the problem.

Correct it and simulate it.

---

# 28. Practice Question 5 — Design Flow

Write the correct order:

```text
Simulation
Implementation
Specification
Synthesis
RTL Coding
Waveform Analysis
```

---

# 29. Placement Interview Questions

### Q1

What is RTL?

### Q2

What is the difference between simulation and synthesis?

### Q3

What does Icarus Verilog do?

### Q4

What does `vvp` do?

### Q5

What is GTKWave?

### Q6

What is a VCD file?

### Q7

What happens when a Verilog `reg` is not initialized?

### Q8

What does `X` mean?

### Q9

What does `Z` mean?

### Q10

Can all Verilog code be synthesized?

### Q11

What is a DUT?

### Q12

Why should RTL and testbench normally be separate?

### Q13

Why is a testbench required?

### Q14

What is the difference between functional simulation and synthesis?

### Q15

Why is waveform analysis useful?

---

# 30. Day 2 Golden Concept

Remember this:

```text
        DESIGN FLOW

Specification
      ↓
Architecture
      ↓
RTL Coding
      ↓
Compilation
      ↓
Simulation
      ↓
Waveform Verification
      ↓
Synthesis
      ↓
Gate-Level Netlist
      ↓
Implementation
```

And remember the three commands:

```bash
iverilog    # compile
vvp         # simulate
gtkwave     # view waveform
```

---

# 31. Day 2 Checklist

Before Day 3, you should understand:

* [ ] Text-based RTL design
* [ ] RTL
* [ ] Specification
* [ ] RTL coding
* [ ] Compilation
* [ ] Simulation
* [ ] Waveform
* [ ] Synthesis
* [ ] Netlist
* [ ] Implementation
* [ ] DUT
* [ ] Testbench
* [ ] VCD
* [ ] Icarus Verilog
* [ ] VVP
* [ ] GTKWave
* [ ] 2-bit comparator
* [ ] 16 input combinations
* [ ] Unknown `X`
* [ ] High impedance `Z`
* [ ] Missing testbench driver
* [ ] Basic RTL debugging

---

# Day 2 Assignment

Complete these **before Day 3**:

### Mandatory

1. 2-bit Comparator
2. Half Subtractor
3. 4-bit Comparator
4. Missing-driver `X` experiment
5. GTKWave verification

### Interview preparation

Answer all 15 interview questions without looking at the notes.

### Evidence

For each design, keep:

```text
RTL
Testbench
Compilation command
Simulation output
VCD
GTKWave screenshot
```

Your Day 2 folder should finally look like:

```text
Day_02/
├── README.md
├── rtl/
│   ├── comparator_2bit.v
│   ├── half_subtractor.v
│   └── comparator_4bit.v
├── tb/
│   ├── tb_comparator_2bit.v
│   ├── tb_half_subtractor.v
│   └── tb_comparator_4bit.v
├── sim/
│   ├── comparator_2bit_sim
│   ├── comparator_2bit.vcd
│   ├── half_subtractor_sim
│   ├── half_subtractor.vcd
│   ├── comparator_4bit_sim
│   └── comparator_4bit.vcd
└── wave/
```

**Do not move to Day 3 until the 2-bit comparator works in Icarus and you have checked its 16 cases in GTKWave.**
