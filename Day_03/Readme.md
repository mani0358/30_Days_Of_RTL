# Day 03 — Graphic-Based Design Flow

## 1. Day 3 Objective

By the end of Day 3, you should understand:

* What a **graphic-based design flow** is
* Difference between **text-based** and **graphic-based** design
* How a digital circuit is represented graphically
* How a graphical/block representation maps to RTL
* Design → simulation → waveform verification
* How hierarchy/block diagrams are used in RTL design
* How to translate a simple block diagram into Verilog
* How to verify the design using **Icarus Verilog + GTKWave**

---

# 2. What Is Graphic-Based Design?

In a **graphic-based design flow**, the designer represents a digital system using graphical elements such as:

* Blocks
* Gates
* Registers
* Multiplexers
* Adders
* Comparators
* Connections
* Input/output ports

Instead of initially writing the complete RTL description as text, the designer thinks about the circuit as a collection of interconnected blocks.

For example:

```text
        A ─────┐
               │
               ▼
             ┌─────┐
        B ──►│ AND │──────► Y
             └─────┘
```

This represents:

```text
Y = A & B
```

The graphical representation helps us understand **what hardware blocks exist and how they are connected**.

---

# 3. Why Graphic-Based Design Is Important

Large digital systems can contain thousands or millions of logic elements.

A graphical representation helps a designer understand:

```text
Input
  │
  ▼
┌──────────┐
│ Block A  │
└────┬─────┘
     │
     ▼
┌──────────┐
│ Block B  │
└────┬─────┘
     │
     ▼
┌──────────┐
│ Block C  │
└────┬─────┘
     │
     ▼
  Output
```

This gives a **high-level view of the architecture**.

For placement interviews, remember:

> **Graphic-based design emphasizes the structure and interconnection of hardware blocks.**

---

# 4. Text-Based vs Graphic-Based Design

| Feature                    | Text-Based            | Graphic-Based                     |
| -------------------------- | --------------------- | --------------------------------- |
| Representation             | HDL code              | Blocks/gates/connections          |
| Main focus                 | RTL description       | Hardware structure                |
| Editing                    | Text editor           | Graphical/design tool             |
| Example                    | `assign y = a & b;`   | AND gate block                    |
| Large designs              | Code hierarchy        | Block hierarchy                   |
| Simulation                 | HDL simulator         | Usually connected to design tools |
| Understanding architecture | Requires reading code | Often easier visually             |

Neither representation eliminates the need to understand the underlying hardware.

---

# 5. Basic Graphic Elements

A digital design can be represented using blocks such as:

### AND gate

```text
A ───┐
     │
     ▼
   ┌─────┐
B ─►│ AND │──► Y
   └─────┘
```

Equation:

```text
Y = A & B
```

### OR gate

```text
A ───┐
     │
     ▼
   ┌────┐
B ─►│ OR │──► Y
   └────┘
```

Equation:

```text
Y = A | B
```

### NOT gate

```text
A ───►┌─────┐
      │ NOT │──► Y
      └─────┘
```

Equation:

```text
Y = ~A
```

---

# 6. Block-Level Representation

Instead of showing every individual gate, we can represent a circuit using functional blocks.

Example: 2-bit comparator

```text
        ┌───────────────────┐
 A[1:0] │                   │
 ──────►│                   │
        │  2-BIT            │──► A > B
 B[1:0] │  COMPARATOR       │──► A = B
 ──────►│                   │──► A < B
        │                   │
        └───────────────────┘
```

The entire comparator can be treated as one block.

Inside the block, there may be several gates.

This is the basic idea behind **hierarchical design**.

---

# 7. Hierarchical Design

A large design is divided into smaller modules.

For example:

```text
                 TOP MODULE
                     │
       ┌─────────────┼─────────────┐
       │             │             │
       ▼             ▼             ▼
   ┌────────┐    ┌────────┐    ┌────────┐
   │ Adder  │    │ MUX    │    │ Reg    │
   └────────┘    └────────┘    └────────┘
```

Each block can itself contain smaller blocks.

Example:

```text
CPU
 │
 ├── ALU
 │    ├── Adder
 │    ├── Subtractor
 │    └── Logic Unit
 │
 ├── Register File
 │
 └── Control Unit
```

This is extremely important in real RTL projects.

---

# 8. Graphic Design → RTL

Suppose the graphical circuit is:

```text
A ───────┐
         │
         ▼
       ┌─────┐
B ─────► AND │────► Y
       └─────┘
```

The corresponding Verilog is:

```verilog
module and_gate (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a & b;

endmodule
```

So:

```text
GRAPHICAL BLOCK
       ↓
Hardware relationship
       ↓
Boolean equation
       ↓
Verilog RTL
```

---

# 9. Day 3 Practical

## Design: 2:1 Multiplexer

We will use a simple graphical representation.

```text
              ┌─────────┐
I0 ──────────►│         │
              │   MUX   ├────► Y
I1 ──────────►│   2:1   │
              │         │
S  ──────────►│ Select  │
              └─────────┘
```

A 2:1 MUX has:

```text
Inputs  : I0, I1
Select  : S
Output  : Y
```

---

# 10. MUX Truth Table

| S | I0 | I1 | Y |
| - | -- | -- | - |
| 0 | 0  | 0  | 0 |
| 0 | 0  | 1  | 0 |
| 0 | 1  | 0  | 1 |
| 0 | 1  | 1  | 1 |
| 1 | 0  | 0  | 0 |
| 1 | 0  | 1  | 1 |
| 1 | 1  | 0  | 0 |
| 1 | 1  | 1  | 1 |

Therefore:

```text
S = 0 → Y = I0
S = 1 → Y = I1
```

Boolean equation:

```text
Y = (~S & I0) | (S & I1)
```

---

# 11. Verilog RTL

Create:

```text
~/Verilog_50_Days/Day_03/rtl/mux_2to1.v
```

Code:

```verilog
module mux_2to1 (
    input  wire i0,
    input  wire i1,
    input  wire s,
    output wire y
);

    assign y = (~s & i0) | (s & i1);

endmodule
```

---

# 12. Testbench

Create:

```text
~/Verilog_50_Days/Day_03/tb/tb_mux_2to1.v
```

Code:

```verilog
`timescale 1ns/1ps

module tb_mux_2to1;

    reg  i0;
    reg  i1;
    reg  s;

    wire y;

    mux_2to1 dut (
        .i0(i0),
        .i1(i1),
        .s(s),
        .y(y)
    );

    initial begin

        $dumpfile("sim/mux_2to1.vcd");
        $dumpvars(0, tb_mux_2to1);

        // S = 0 → Y should follow I0
        s = 0; i0 = 0; i1 = 0; #10;
        s = 0; i0 = 0; i1 = 1; #10;
        s = 0; i0 = 1; i1 = 0; #10;
        s = 0; i0 = 1; i1 = 1; #10;

        // S = 1 → Y should follow I1
        s = 1; i0 = 0; i1 = 0; #10;
        s = 1; i0 = 0; i1 = 1; #10;
        s = 1; i0 = 1; i1 = 0; #10;
        s = 1; i0 = 1; i1 = 1; #10;

        $finish;

    end

endmodule
```

---

# 13. Directory Setup

Run:

```bash
mkdir -p ~/Verilog_50_Days/Day_03/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_03
```

Check:

```bash
tree
```

Expected:

```text
Day_03
├── rtl
├── tb
├── sim
└── wave
```

After creating the files:

```text
Day_03
├── rtl
│   └── mux_2to1.v
├── tb
│   └── tb_mux_2to1.v
├── sim
└── wave
```

---

# 14. Compile

Run:

```bash
iverilog -o sim/mux_2to1_sim rtl/mux_2to1.v tb/tb_mux_2to1.v
```

If there is no error, compilation succeeded.

---

# 15. Run Simulation

```bash
vvp sim/mux_2to1_sim
```

You should see:

```text
VCD info: dumpfile sim/mux_2to1.vcd opened for output.
```

---

# 16. Open Waveform

Run:

```bash
gtkwave sim/mux_2to1.vcd
```

Add:

```text
i0
i1
s
y
```

to the waveform window.

Verify:

```text
S = 0 → Y = I0
S = 1 → Y = I1
```

---

# 17. Truth-Table Verification

This is the most important verification.

For:

```text
Y = (~S & I0) | (S & I1)
```

### Case 1

```text
S = 0
I0 = 0
I1 = 1
```

Then:

```text
Y = (~0 & 0) | (0 & 1)
  = (1 & 0) | 0
  = 0
```

Correct.

### Case 2

```text
S = 0
I0 = 1
I1 = 0
```

```text
Y = (~0 & 1) | (0 & 0)
  = 1
```

Correct.

### Case 3

```text
S = 1
I0 = 0
I1 = 1
```

```text
Y = (~1 & 0) | (1 & 1)
  = 0 | 1
  = 1
```

Correct.

### Case 4

```text
S = 1
I0 = 1
I1 = 0
```

```text
Y = (~1 & 1) | (1 & 0)
  = 0 | 0
  = 0
```

Correct.

Therefore:

```text
S=0 → I0 selected
S=1 → I1 selected
```

---

# 18. Design Flow You Should Remember

Day 2 focused on the **text-based flow**.

Day 3 adds the graphical perspective:

```text
Specification
     ↓
Block Diagram
     ↓
Identify Inputs/Outputs
     ↓
Identify Hardware Blocks
     ↓
Boolean/RTL Description
     ↓
Verilog RTL
     ↓
Testbench
     ↓
Compile
     ↓
Simulation
     ↓
Waveform
     ↓
Verification
```

---

# 19. Design vs Testbench

### Design

The design describes the actual hardware.

Example:

```verilog
module mux_2to1 (...);
```

### Testbench

The testbench applies inputs and observes outputs.

Example:

```verilog
initial begin
    s = 0;
    i0 = 1;
    i1 = 0;
end
```

The testbench is normally **not synthesized as part of the intended hardware**.

Remember:

> **RTL = hardware description**
>
> **Testbench = verification environment**

---

# 20. Common Interview Question

### Q1. What is graphic-based design?

**Answer:**

Graphic-based design represents a digital system using graphical elements such as blocks, gates, registers, multiplexers and their interconnections.

---

### Q2. What is hierarchical design?

**Answer:**

Hierarchical design divides a large digital system into smaller modules or blocks, where each block can itself contain smaller modules.

---

### Q3. Why is hierarchy useful?

**Answer:**

It makes a large design easier to understand, develop, verify, reuse and maintain.

---

### Q4. What is a block diagram?

**Answer:**

A block diagram is a graphical representation of a system showing its major functional blocks and their interconnections.

---

### Q5. What is the difference between a block and a gate?

**Answer:**

A gate normally represents a basic logic operation, while a block can represent a larger functional unit such as an ALU, register file, comparator or multiplexer.

---

### Q6. What does RTL describe?

**Answer:**

RTL describes the behavior and transfer of data between registers and the combinational logic operating on that data.

---

### Q7. What is the purpose of a testbench?

**Answer:**

A testbench applies stimulus to the design under test and checks/observes its outputs during simulation.

---

### Q8. What is the purpose of GTKWave?

**Answer:**

GTKWave is used to view and analyze simulation waveforms generated by the simulator.

---

# 21. Placement-Level Questions

Try answering these yourself before looking at the answers.

### Q1.

For a 2:1 MUX, when `S=0`, which input reaches the output?

**Answer:** `I0`

### Q2.

For a 2:1 MUX, when `S=1`, which input reaches the output?

**Answer:** `I1`

### Q3.

Write the Boolean equation of a 2:1 MUX.

**Answer:**

```text
Y = (~S & I0) | (S & I1)
```

### Q4.

What is hierarchical design?

**Answer:**

Breaking a large design into smaller interconnected modules.

### Q5.

What is the difference between RTL and testbench?

**Answer:**

RTL describes the intended hardware; the testbench provides simulation stimulus and verification.

---

# 22. Day 3 Assignment

Complete these without copying the solution first.

## Assignment 1 — 2:1 MUX

Implement:

```text
Y = (~S & I0) | (S & I1)
```

Verify all 8 input combinations.

---

## Assignment 2 — 4:1 MUX

Draw the block diagram:

```text
             ┌─────────┐
I0 ─────────►│         │
I1 ─────────►│         │
I2 ─────────►│  4:1    ├──► Y
I3 ─────────►│  MUX    │
S1 ─────────►│         │
S0 ─────────►│         │
             └─────────┘
```

Determine the truth table.

Then write the Boolean equation and Verilog RTL.

---

## Assignment 3 — Hierarchy

Create:

```text
TOP
 │
 ├── AND gate
 │
 └── OR gate
```

Then create a top-level module connecting them.

---

## Assignment 4 — Waveform

For the 2:1 MUX:

1. Compile it.
2. Run it.
3. Open GTKWave.
4. Add `i0`, `i1`, `s`, `y`.
5. Verify that `y` follows `i0` when `s=0`.
6. Verify that `y` follows `i1` when `s=1`.

---

# 23. Day 3 Checklist

Before moving to Day 4, you should be able to explain:

* [ ] What graphic-based design means
* [ ] Text-based vs graphic-based design
* [ ] What a block diagram is
* [ ] What hierarchical design means
* [ ] Why hierarchy is useful
* [ ] How a graphical block becomes RTL
* [ ] Difference between RTL and testbench
* [ ] 2:1 MUX truth table
* [ ] 2:1 MUX Boolean equation
* [ ] Write a 2:1 MUX in Verilog
* [ ] Compile with Icarus
* [ ] Run with VVP
* [ ] View waveforms using GTKWave

---

# 24. Day 3 Golden Rule

Remember this flow:

```text
          GRAPHICAL VIEW
                ↓
           BLOCK DIAGRAM
                ↓
       INPUTS / OUTPUTS
                ↓
        LOGIC RELATIONSHIP
                ↓
            RTL CODE
                ↓
           TESTBENCH
                ↓
           SIMULATION
                ↓
            WAVEFORM
                ↓
           VERIFICATION
```

**Day 3 assignment: 2:1 MUX + 4:1 MUX + hierarchical design.**
