# Day 05 — Verilog `reg`

## 1. Day 5 Objective

By the end of Day 5, you should understand:

* What `reg` means in Verilog
* Difference between `wire` and `reg`
* Why `reg` is used in procedural blocks
* `always` blocks
* Procedural assignment
* Blocking assignment `=`
* Basic clocked logic
* How a D Flip-Flop is modeled
* Synthesis meaning of a clocked `always` block
* Testbench generation
* Waveform verification using GTKWave

The Day 5 assignment in your roadmap is:

> **Design and verify a D Flip-Flop.**

---

# 2. What Is `reg`?

In Verilog, `reg` is a **variable data type**.

It is used when a signal is assigned inside a procedural block such as:

```verilog
always
```

or:

```verilog
initial
```

Example:

```verilog
reg y;

always @(*) begin
    y = a & b;
end
```

Here `y` is assigned procedurally, so it is declared as `reg`.

---

# 3. Very Important: `reg` Does NOT Automatically Mean Register

This is one of the most common interview traps.

Do **not** think:

```text
reg → physical register
```

Instead:

```text
reg → Verilog procedural variable
```

The hardware depends on the behavior described by the RTL.

For example:

```verilog
always @(*) begin
    y = a & b;
end
```

uses:

```verilog
reg y;
```

but synthesizes to **combinational logic**, not a register.

---

# 4. Example: `reg` for Combinational Logic

```verilog
module and_gate (
    input  wire a,
    input  wire b,
    output reg  y
);

    always @(*) begin
        y = a & b;
    end

endmodule
```

Hardware:

```text
A ───┐
     ▼
   ┌─────┐
B ─► AND ├──► Y
   └─────┘
```

There is no clock and no storage requirement.

Therefore:

> `reg` does not automatically imply hardware storage.

---

# 5. Why Do We Need `reg`?

Consider:

```verilog
always @(*) begin
    y = a & b;
end
```

The assignment:

```verilog
y = a & b;
```

occurs inside an `always` block.

In traditional Verilog, the destination of a procedural assignment must be a variable such as `reg`.

Therefore:

```verilog
reg y;
```

is required.

---

# 6. `wire` vs `reg`

This is extremely important for placements.

| Feature                            | `wire`                         | `reg`                                     |
| ---------------------------------- | ------------------------------ | ----------------------------------------- |
| Verilog category                   | Net                            | Variable                                  |
| Common assignment                  | `assign`                       | `always` / `initial`                      |
| Procedural assignment              | No                             | Yes                                       |
| Automatically a hardware register? | No                             | No                                        |
| Common use                         | Connections/combinational nets | Procedural modeling                       |
| Can represent combinational logic? | Yes                            | Yes                                       |
| Can represent sequential logic?    | Through connections            | Yes, with appropriate procedural behavior |

Remember:

```text
wire → net
reg  → procedural variable
```

---

# 7. Continuous vs Procedural Assignment

## Continuous assignment

```verilog
wire y;

assign y = a & b;
```

The assignment continuously drives `y`.

---

## Procedural assignment

```verilog
reg y;

always @(*) begin
    y = a & b;
end
```

The assignment occurs procedurally inside the `always` block.

---

# 8. What Is an `always` Block?

An `always` block describes behavior that is repeatedly evaluated during simulation.

Example:

```verilog
always @(*) begin
    y = a & b;
end
```

The:

```text
@(*)
```

means that the block should respond to changes in signals used by the block.

For combinational logic, this is the standard style in traditional Verilog.

---

# 9. Basic `always` Syntax

```verilog
always @(*) begin

    // procedural statements

end
```

Example:

```verilog
always @(*) begin
    y = a | b;
end
```

---

# 10. Procedural Assignment

Inside an `always` block we can write:

```verilog
y = a & b;
```

This is a **blocking assignment**.

The symbol is:

```text
=
```

We will study blocking and nonblocking assignments in more detail later in the roadmap.

For today, remember:

```text
= → blocking assignment
```

---

# 11. Combinational Example

Consider:

```text
Y = (A & B) | C
```

RTL:

```verilog
module combinational_example (
    input  wire a,
    input  wire b,
    input  wire c,
    output reg  y
);

    always @(*) begin
        y = (a & b) | c;
    end

endmodule
```

Here:

```text
a, b, c → inputs
y       → procedural variable
```

There is no clock.

Therefore the intended hardware is combinational.

---

# 12. Now Sequential Logic

Now consider:

```text
D → D Flip-Flop → Q
```

A D Flip-Flop stores data.

The key event is a clock edge.

For a positive-edge-triggered D Flip-Flop:

```text
At rising edge of CLK:

Q(next) = D
```

---

# 13. D Flip-Flop

A D Flip-Flop has:

```text
D   → Data input
CLK → Clock input
Q   → Output
```

Block diagram:

```text
          ┌─────────────┐
D ───────►│             │
          │     DFF     ├────► Q
CLK ─────►│             │
          └─────────────┘
```

For a positive-edge-triggered DFF:

```text
       ↑
CLK ───┘
       │
       Q ← D
```

The value of `D` is captured on the rising edge.

---

# 14. D Flip-Flop Truth/Operation Table

A DFF is edge-triggered, so a simple static truth table is not enough.

Its fundamental operation is:

| Clock event    |  D |     Q(next) |
| -------------- | -: | ----------: |
| Rising edge    |  0 |           0 |
| Rising edge    |  1 |           1 |
| No rising edge |  X | Q(previous) |

The important relationship is:

```text
At ↑CLK:

Q(next) = D
```

So:

```text
D = 0 → Q becomes 0
D = 1 → Q becomes 1
```

on the rising clock edge.

---

# 15. DFF RTL

Create:

```text
~/Verilog_50_Days/Day_05/rtl/dff.v
```

Code:

```verilog
module dff (
    input  wire clk,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin
        q = d;
    end

endmodule
```

---

# 16. Understanding the DFF Code

### Module

```verilog
module dff (
```

Creates the DFF module.

### Inputs

```verilog
input wire clk,
input wire d,
```

The clock and data are inputs.

### Output

```verilog
output reg q
```

`q` is assigned inside the `always` block, so in traditional Verilog it is declared as `reg`.

### Clock event

```verilog
always @(posedge clk)
```

means:

> Execute the block when `clk` changes from 0 to 1.

### Assignment

```verilog
q = d;
```

At the rising clock edge, the D input is transferred to Q.

---

# 17. Hardware Meaning

The RTL:

```verilog
always @(posedge clk) begin
    q = d;
end
```

describes sequential hardware:

```text
             ┌─────────────┐
D ──────────►│             │
             │   D Flip    ├────► Q
CLK ────────►│   Flop      │
             └─────────────┘
```

The key point is:

```text
posedge clk
```

causes the storage behavior.

---

# 18. Why Is `posedge` Important?

Compare:

```verilog
always @(*) 
```

with:

```verilog
always @(posedge clk)
```

### `always @(*)`

Used for combinational logic.

```text
Input changes
     ↓
Logic responds
```

### `always @(posedge clk)`

Used for positive-edge-triggered sequential logic.

```text
Clock rising edge
        ↓
Data captured
```

This distinction is fundamental.

---

# 19. DFF Testbench

Create:

```text
~/Verilog_50_Days/Day_05/tb/tb_dff.v
```

Code:

```verilog
`timescale 1ns/1ps

module tb_dff;

    reg clk;
    reg d;

    wire q;

    dff dut (
        .clk(clk),
        .d(d),
        .q(q)
    );

    // Clock generation
    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin

        $dumpfile("sim/dff.vcd");
        $dumpvars(0, tb_dff);

        d = 0;

        #12;
        d = 1;

        #10;
        d = 0;

        #10;
        d = 1;

        #10;
        d = 0;

        #10;

        $finish;

    end

endmodule
```

---

# 20. Understanding the Clock

This line:

```verilog
forever #5 clk = ~clk;
```

creates a clock.

Starting with:

```text
clk = 0
```

after 5 ns:

```text
clk = 1
```

after another 5 ns:

```text
clk = 0
```

Therefore:

```text
0 → 1 → 0 → 1 → 0 ...
```

The rising edges occur at approximately:

```text
5 ns
15 ns
25 ns
35 ns
45 ns
...
```

---

# 21. Why Does the DFF Capture Data?

Suppose:

```text
D = 1
```

just before a rising clock edge.

At:

```text
↑CLK
```

the DFF captures:

```text
Q = 1
```

If D later changes to 0, Q does not immediately change.

It waits for the next rising edge.

That is the fundamental difference between combinational and sequential logic.

---

# 22. Expected Simulation

With the testbench above, approximately:

|  Time | CLK |  D |  Q |
| ----: | --: | -: | -: |
|  0 ns |   0 |  0 |  X |
|  5 ns |  ↑1 |  0 |  0 |
| 10 ns |   0 |  0 |  0 |
| 12 ns |   0 |  1 |  0 |
| 15 ns |  ↑1 |  1 |  1 |
| 20 ns |   0 |  1 |  1 |
| 22 ns |   0 |  0 |  1 |
| 25 ns |  ↑1 |  0 |  0 |
| 32 ns |   0 |  1 |  0 |
| 35 ns |  ↑1 |  1 |  1 |
| 42 ns |   0 |  0 |  1 |
| 45 ns |  ↑1 |  0 |  0 |

The key observation:

```text
Q changes only at rising edges of CLK.
```

---

# 23. Directory Setup

Run:

```bash
mkdir -p ~/Verilog_50_Days/Day_05/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_05
```

Check:

```bash
tree
```

Expected:

```text
Day_05
├── rtl
├── tb
├── sim
└── wave
```

After creating files:

```text
Day_05
├── rtl
│   └── dff.v
├── tb
│   └── tb_dff.v
├── sim
└── wave
```

---

# 24. Compile

Run:

```bash
iverilog -o sim/dff_sim rtl/dff.v tb/tb_dff.v
```

If there is no error:

```text
Compilation successful
```

---

# 25. Run

```bash
vvp sim/dff_sim
```

Expected:

```text
VCD info: dumpfile sim/dff.vcd opened for output.
```

---

# 26. Open GTKWave

```bash
gtkwave sim/dff.vcd
```

Add:

```text
clk
d
q
```

Then observe:

```text
D changes
    ↓
Q does NOT immediately change
    ↓
Next rising CLK edge
    ↓
Q captures D
```

---

# 27. Truth/Operation Verification

Let's verify the DFF operation manually.

### Case 1

At rising edge:

```text
D = 0
```

Therefore:

```text
Q(next) = 0
```

### Case 2

At rising edge:

```text
D = 1
```

Therefore:

```text
Q(next) = 1
```

### Case 3

After the rising edge:

```text
D changes
```

but there is no new rising edge.

Therefore:

```text
Q remains unchanged
```

This confirms the edge-triggered behavior.

---

# 28. Important Difference

Consider:

```verilog
assign q = d;
```

This would make:

```text
Q = D
```

continuously.

That is **not a D Flip-Flop**.

A DFF requires:

```verilog
always @(posedge clk)
```

so that data is captured at a clock edge.

---

# 29. Combinational vs Sequential

| Combinational                    | Sequential                                        |
| -------------------------------- | ------------------------------------------------- |
| Output depends on current inputs | Output depends on current inputs and stored state |
| No clock required                | Usually clock-controlled                          |
| Example: AND, OR, MUX            | Example: DFF, counter                             |
| `always @(*)` commonly used      | `always @(posedge clk)` commonly used             |
| No intended storage              | Storage/state exists                              |

Examples:

```text
AND gate
MUX
Adder
Comparator
```

are combinational.

Examples:

```text
DFF
Register
Counter
Shift Register
```

are sequential.

---

# 30. A Very Important Interview Point

### Question:

Does this code create a flip-flop?

```verilog
reg q;

always @(*) begin
    q = d;
end
```

### Answer:

No.

There is no clock edge and the intended behavior is combinational.

It describes:

```text
Q = D
```

which is combinational behavior.

A positive-edge-triggered DFF requires:

```verilog
always @(posedge clk)
```

---

# 31. Why `reg` Is Used for DFF Output

The output:

```verilog
q
```

is assigned inside:

```verilog
always @(posedge clk)
```

Therefore in traditional Verilog:

```verilog
output reg q;
```

is appropriate.

Again:

```text
reg keyword
      ≠
physical register automatically
```

The clocked behavior causes the synthesized storage element.

---

# 32. Common Mistakes

## Mistake 1

Writing:

```verilog
wire q;

always @(posedge clk) begin
    q = d;
end
```

In traditional Verilog, this is invalid because `q` is a net and is being assigned procedurally.

Use:

```verilog
reg q;
```

---

## Mistake 2

Using:

```verilog
always @(*)
```

for a DFF.

Wrong for a clocked DFF.

Use:

```verilog
always @(posedge clk)
```

for a positive-edge-triggered DFF.

---

## Mistake 3

Forgetting the clock edge:

```verilog
always begin
    q = d;
end
```

This does not correctly describe the intended edge-triggered DFF.

---

## Mistake 4

Thinking `reg` itself creates storage.

It does not.

The behavior determines whether synthesis infers:

```text
combinational logic
latch
flip-flop
etc.
```

---

# 33. `reg` Vector

Just like `wire`, a `reg` can be a vector.

Example:

```verilog
reg [3:0] data;
```

This represents a 4-bit procedural variable.

You can access:

```text
data[3]
data[2]
data[1]
data[0]
```

This will become important when we build:

* Counters
* Registers
* Shift registers
* ALUs
* FSMs

---

# 34. Multiple `reg` Signals

Example:

```verilog
reg a;
reg b;
reg y;
```

or:

```verilog
reg [7:0] data;
```

The choice depends on the signals needed by the procedural logic.

---

# 35. `initial` and `reg`

A testbench frequently uses:

```verilog
reg a;
reg b;

initial begin
    a = 0;
    b = 0;
end
```

Why?

Because `a` and `b` are being assigned procedurally.

This is why testbench inputs are commonly declared as `reg` in Verilog.

---

# 36. Design vs Testbench

### Design

```verilog
module dff (
    input wire clk,
    input wire d,
    output reg q
);
```

This describes the hardware.

### Testbench

```verilog
reg clk;
reg d;
```

The testbench drives the DUT inputs.

So:

```text
Testbench reg
      ↓
drives
      ↓
DUT input wire
```

---

# 37. Placement Interview Questions

### Q1. What is `reg`?

**Answer:**

`reg` is a Verilog procedural variable data type used as the destination of procedural assignments.

---

### Q2. Does `reg` mean a physical register?

**Answer:**

No. `reg` is a Verilog variable type. Hardware storage is inferred from the described behavior.

---

### Q3. Why can't a traditional Verilog `wire` be assigned inside an `always` block?

**Answer:**

Because a procedural assignment requires a variable data type such as `reg`, while `wire` is a net type.

---

### Q4. What is the difference between `assign` and `always`?

**Answer:**

`assign` is used for continuous assignment to nets, while `always` contains procedural statements.

---

### Q5. What is `always @(*)`?

**Answer:**

It is an always block sensitive to changes in signals referenced by the block and is commonly used to model combinational logic.

---

### Q6. What is `always @(posedge clk)`?

**Answer:**

It executes the procedural block on every rising edge of `clk`, commonly used to model positive-edge-triggered sequential logic.

---

### Q7. How does a DFF work?

**Answer:**

A positive-edge-triggered DFF captures the value of D at the rising edge of the clock and holds that value until the next active edge.

---

### Q8. What happens to Q when D changes between clock edges?

**Answer:**

For an ideal DFF, Q remains at its previously captured value until the next rising clock edge.

---

### Q9. What is the difference between combinational and sequential logic?

**Answer:**

Combinational logic depends on current inputs, while sequential logic also contains state and typically uses a clock to control state updates.

---

### Q10. What does `posedge` mean?

**Answer:**

It means a transition of a signal from logic `0` to logic `1`.

---

# 38. Placement Practice

Predict the output before simulation.

Given:

```text
At 5 ns:
D = 1
CLK = rising edge
```

What is:

```text
Q = ?
```

Answer:

```text
Q = 1
```

Now:

```text
At 8 ns:
D = 0
CLK = 0
```

What is:

```text
Q = ?
```

Answer:

```text
Q = 1
```

Why?

Because there was no new rising edge.

At:

```text
15 ns:
CLK = rising edge
D = 0
```

Therefore:

```text
Q = 0
```

---

# 39. Day 5 Assignment

## Assignment 1 — D Flip-Flop

Implement:

```text
D → DFF → Q
```

using:

```verilog
always @(posedge clk)
```

---

## Assignment 2 — Verify DFF

Test:

```text
D = 0
D = 1
D = 0
D = 1
```

at different points relative to the clock.

Verify that Q changes only at the rising edge.

---

## Assignment 3 — `wire` vs `reg`

Write two versions of an AND gate.

### Version A

Using:

```verilog
wire
assign
```

### Version B

Using:

```verilog
reg
always @(*)
```

Verify that both produce the same truth table:

| A | B | Y |
| - | - | - |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

---

## Assignment 4 — 4-bit `reg`

Create:

```verilog
reg [3:0] data;
```

Use an `always` block to assign different values to it in a testbench.

Observe the waveform.

---

# 40. Day 5 Checklist

Before moving to Day 6, you should be able to explain:

* [ ] What is `reg`?
* [ ] Why is `reg` used in procedural assignments?
* [ ] Why `reg` does not necessarily mean a physical register
* [ ] `wire` vs `reg`
* [ ] Continuous assignment
* [ ] Procedural assignment
* [ ] Blocking assignment `=`
* [ ] `always @(*)`
* [ ] `always @(posedge clk)`
* [ ] What `posedge` means
* [ ] Combinational vs sequential logic
* [ ] D Flip-Flop operation
* [ ] DFF RTL
* [ ] DFF testbench
* [ ] Clock generation
* [ ] GTKWave verification
* [ ] Why Q changes only on the active clock edge

---

# 41. Day 5 Golden Rules

### Rule 1

```text
wire → net
reg  → procedural variable
```

### Rule 2

```verilog
wire y;
assign y = expression;
```

is continuous assignment.

### Rule 3

```verilog
reg y;

always @(*) begin
    y = expression;
end
```

is procedural combinational modeling.

### Rule 4

```verilog
reg q;

always @(posedge clk) begin
    q = d;
end
```

describes positive-edge-triggered sequential behavior.

### Rule 5

Never say:

> "`reg` means hardware register."

Say:

> "`reg` is a Verilog procedural variable; the RTL behavior determines the synthesized hardware."

---

# 42. Day 5 Golden Flow

```text
                    reg
                     ↓
          Procedural variable
                     ↓
              always block
                ↙       ↘
        always @(*)   @(posedge clk)
             ↓               ↓
       Combinational      Sequential
          logic              logic
                             ↓
                           DFF
                             ↓
                        Stored state
```

---

# 43. Day 5 Final Practical Flow

```text
DFF Specification
       ↓
Block Diagram
       ↓
D / CLK / Q
       ↓
Define clock-edge behavior
       ↓
Verilog RTL
       ↓
Testbench
       ↓
Clock generation
       ↓
Icarus compilation
       ↓
Simulation
       ↓
GTKWave
       ↓
Verify Q at every rising edge
```

**Day 5 assignment: D Flip-Flop + `wire`/`reg` comparison + 4-bit `reg` experiment.**
