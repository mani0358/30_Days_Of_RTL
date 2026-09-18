# Day 04 — Verilog `wire`

## 1. Day 4 Objective

By the end of Day 4, you should understand:

* What a `wire` is
* Why `wire` is called a **net**
* How a `wire` gets its value
* Continuous assignment using `assign`
* Connecting modules using `wire`
* `wire` with logic gates
* `wire` with expressions
* Vector/bus `wire`
* Multiple-bit wires
* Difference between `wire` and `reg`
* Common `wire` mistakes
* Practical RTL design using `wire`
* Simulation and waveform verification

The Day 4 assignment in your roadmap is specifically:

> **Study and practice the Verilog `wire` data type.**

---

# 2. What Is `wire`?

In Verilog, `wire` represents a **net**.

A net represents a physical connection through which a signal can propagate.

Think of it like an electrical wire:

```text
Source ───────────────► Destination
          wire
```

For example:

```verilog
wire y;

assign y = a & b;
```

Here:

```text
a & b → drives → y
```

---

# 3. Basic Syntax

The basic syntax is:

```verilog
wire signal_name;
```

Example:

```verilog
wire a;
wire b;
wire y;
```

You can then drive the wire:

```verilog
assign y = a & b;
```

---

# 4. Important Concept

A `wire` **does not store a value by itself**.

It represents a connection.

For example:

```verilog
wire y;

assign y = a & b;
```

Whenever `a` or `b` changes, the value of `y` changes according to:

```text
Y = A AND B
```

So think:

```text
wire → connection
```

rather than:

```text
wire → storage
```

---

# 5. Physical Hardware Analogy

Consider:

```text
       ┌─────┐
A ─────► AND ├─────── Y
B ─────►     │
       └─────┘
```

The connection from the AND gate to `Y` can be represented in Verilog as:

```verilog
wire y;
```

The AND operation drives it:

```verilog
assign y = a & b;
```

Therefore:

```text
Hardware connection
       ↓
Verilog net
       ↓
wire
```

---

# 6. `wire` With `assign`

One of the most common uses of `wire` is continuous assignment.

Example:

```verilog
module and_gate (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a & b;

endmodule
```

Here:

```text
a → input
b → input
y → output wire
```

and:

```verilog
assign y = a & b;
```

continuously drives `y`.

---

# 7. What Does "Continuous" Mean?

Consider:

```verilog
assign y = a & b;
```

This does not mean:

```text
calculate once
```

Instead, it means:

```text
continuously maintain:

y = a & b
```

If:

```text
a = 0
b = 1
```

then:

```text
y = 0
```

If `a` changes:

```text
a = 1
```

then:

```text
y = 1
```

because:

```text
1 & 1 = 1
```

---

# 8. `wire` Example

```verilog
module example (
    input  wire a,
    input  wire b,
    output wire y
);

    wire temp;

    assign temp = a & b;
    assign y    = temp;

endmodule
```

Hardware:

```text
A ───┐
     │
     ▼
   ┌─────┐
B ─► AND │──► temp ───► Y
   └─────┘
```

Here `temp` is an internal wire.

---

# 9. Internal Wires

Not every wire needs to be a module port.

Example:

```verilog
module logic_circuit (
    input  wire a,
    input  wire b,
    input  wire c,
    output wire y
);

    wire temp;

    assign temp = a & b;
    assign y = temp | c;

endmodule
```

The signal:

```text
temp
```

is an **internal wire**.

It connects internal pieces of the circuit.

---

# 10. More Than One Internal Wire

Example:

```verilog
module logic_circuit (
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    output wire y
);

    wire w1;
    wire w2;

    assign w1 = a & b;
    assign w2 = c & d;
    assign y  = w1 | w2;

endmodule
```

Hardware representation:

```text
A ───┐
     ▼
   ┌─────┐
B ─► AND ├──► w1 ──┐
   └─────┘         │
                   ▼
                 ┌────┐
                 │ OR ├──► Y
                   ▲
   ┌─────┐         │
C ─► AND ├──► w2 ──┘
D ───┘
   └─────┘
```

Equation:

```text
Y = (A & B) | (C & D)
```

---

# 11. `wire` as a Bus

A `wire` can represent multiple bits.

Example:

```verilog
wire [3:0] data;
```

This creates a 4-bit wire:

```text
data[3]
data[2]
data[1]
data[0]
```

So:

```text
wire [3:0] data
```

represents:

```text
4 bits
```

---

# 12. Example of a 4-bit Wire

```verilog
module bus_example (
    input  wire [3:0] a,
    output wire [3:0] y
);

    assign y = a;

endmodule
```

If:

```text
a = 1011
```

then:

```text
y = 1011
```

The wire connects all four bits.

---

# 13. Bit Selection

You can access an individual bit.

Example:

```verilog
wire [3:0] data;
```

Individual bits:

```verilog
data[3]
data[2]
data[1]
data[0]
```

For:

```text
data = 1011
```

we have:

```text
data[3] = 1
data[2] = 0
data[1] = 1
data[0] = 1
```

---

# 14. Part Selection

You can select multiple bits.

Example:

```verilog
wire [7:0] data;
```

You can write:

```verilog
data[7:4]
```

or:

```verilog
data[3:0]
```

Example:

```text
data = 11010110

data[7:4] = 1101
data[3:0] = 0110
```

---

# 15. Wire With Logic Expressions

A wire can be driven by expressions.

Examples:

```verilog
assign y1 = a & b;
assign y2 = a | b;
assign y3 = a ^ b;
assign y4 = ~a;
```

Therefore:

```text
AND → &
OR  → |
XOR → ^
NOT → ~
```

---

# 16. Multiple Continuous Assignments

You can have several wires:

```verilog
wire w1;
wire w2;
wire w3;

assign w1 = a & b;
assign w2 = c | d;
assign w3 = w1 ^ w2;
```

This describes combinational hardware.

---

# 17. Important Rule

A wire must have a **driver**.

For example:

```verilog
wire y;
```

by itself does not define how `y` obtains its value.

You need something to drive it:

```verilog
assign y = a & b;
```

or a module output connection:

```verilog
some_module u1 (
    .out(y)
);
```

---

# 18. What Happens If a Wire Is Not Driven?

Example:

```verilog
module example (
    input  wire a,
    output wire y
);

    // y has no driver

endmodule
```

`y` is not being driven by any source.

During simulation, it can remain:

```text
Z
```

or otherwise not have the expected logic value depending on how it is used.

Remember the four Verilog logic states:

```text
0
1
X
Z
```

Where:

```text
0 = logic 0
1 = logic 1
X = unknown
Z = high impedance
```

---

# 19. `wire` and Module Connections

This is one of the most important practical uses.

Suppose we have an AND gate:

```verilog
module and_gate (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a & b;

endmodule
```

Now connect it to another module.

```verilog
module top (
    input  wire a,
    input  wire b,
    output wire y
);

    wire and_out;

    and_gate u1 (
        .a(a),
        .b(b),
        .y(and_out)
    );

    assign y = and_out;

endmodule
```

The signal:

```text
and_out
```

is an internal connection between modules.

---

# 20. Hardware View

```text
                 TOP
        ┌────────────────────┐
        │                    │
A ─────►│                    │
B ─────►│   AND_GATE         │
        │       │            │
        │       │ and_out    │
        │       ▼            │
        │      wire          │
        │       │            │
        │       ▼            │
        │       Y            │
        └────────────────────┘
```

This is why understanding `wire` is essential for **structural RTL** and hierarchy.

---

# 21. Day 4 Practical

## Design

Implement:

```text
Y = (A & B) | (C & D)
```

Block diagram:

```text
A ───┐
     │
     ▼
   ┌─────┐
B ─► AND ├──► W1 ───┐
   └─────┘          │
                    ▼
                  ┌────┐
                  │ OR ├──► Y
                    ▲
   ┌─────┐          │
C ─► AND ├──► W2 ───┘
D ───┘
   └─────┘
```

We will explicitly use internal `wire` signals.

---

# 22. Truth Table

We have:

```text
W1 = A & B
W2 = C & D
Y  = W1 | W2
```

The output is:

```text
Y = 1
```

when either:

```text
A = B = 1
```

or:

```text
C = D = 1
```

A complete 4-input truth table contains:

```text
2^4 = 16
```

combinations.

| A | B | C | D | W1 | W2 | Y |
| - | - | - | - | -- | -- | - |
| 0 | 0 | 0 | 0 | 0  | 0  | 0 |
| 0 | 0 | 0 | 1 | 0  | 0  | 0 |
| 0 | 0 | 1 | 0 | 0  | 0  | 0 |
| 0 | 0 | 1 | 1 | 0  | 1  | 1 |
| 0 | 1 | 0 | 0 | 0  | 0  | 0 |
| 0 | 1 | 0 | 1 | 0  | 0  | 0 |
| 0 | 1 | 1 | 0 | 0  | 0  | 0 |
| 0 | 1 | 1 | 1 | 0  | 1  | 1 |
| 1 | 0 | 0 | 0 | 0  | 0  | 0 |
| 1 | 0 | 0 | 1 | 0  | 0  | 0 |
| 1 | 0 | 1 | 0 | 0  | 0  | 0 |
| 1 | 0 | 1 | 1 | 0  | 1  | 1 |
| 1 | 1 | 0 | 0 | 1  | 0  | 1 |
| 1 | 1 | 0 | 1 | 1  | 0  | 1 |
| 1 | 1 | 1 | 0 | 1  | 0  | 1 |
| 1 | 1 | 1 | 1 | 1  | 1  | 1 |

This gives us a complete truth-table verification.

---

# 23. RTL Code

Create:

```text
~/Verilog_50_Days/Day_04/rtl/wire_example.v
```

Code:

```verilog
module wire_example (
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    output wire y
);

    wire w1;
    wire w2;

    assign w1 = a & b;
    assign w2 = c & d;
    assign y  = w1 | w2;

endmodule
```

---

# 24. Testbench

Create:

```text
~/Verilog_50_Days/Day_04/tb/tb_wire_example.v
```

Code:

```verilog
`timescale 1ns/1ps

module tb_wire_example;

    reg a;
    reg b;
    reg c;
    reg d;

    wire y;

    wire_example dut (
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .y(y)
    );

    initial begin

        $dumpfile("sim/wire_example.vcd");
        $dumpvars(0, tb_wire_example);

        a = 0; b = 0; c = 0; d = 0; #10;
        a = 0; b = 0; c = 0; d = 1; #10;
        a = 0; b = 0; c = 1; d = 0; #10;
        a = 0; b = 0; c = 1; d = 1; #10;

        a = 0; b = 1; c = 0; d = 0; #10;
        a = 0; b = 1; c = 0; d = 1; #10;
        a = 0; b = 1; c = 1; d = 0; #10;
        a = 0; b = 1; c = 1; d = 1; #10;

        a = 1; b = 0; c = 0; d = 0; #10;
        a = 1; b = 0; c = 0; d = 1; #10;
        a = 1; b = 0; c = 1; d = 0; #10;
        a = 1; b = 0; c = 1; d = 1; #10;

        a = 1; b = 1; c = 0; d = 0; #10;
        a = 1; b = 1; c = 0; d = 1; #10;
        a = 1; b = 1; c = 1; d = 0; #10;
        a = 1; b = 1; c = 1; d = 1; #10;

        $finish;

    end

endmodule
```

---

# 25. Directory Setup

Run:

```bash
mkdir -p ~/Verilog_50_Days/Day_04/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_04
```

Then:

```bash
tree
```

Expected:

```text
Day_04
├── rtl
│   └── wire_example.v
├── tb
│   └── tb_wire_example.v
├── sim
└── wave
```

---

# 26. Compile

Run:

```bash
iverilog -o sim/wire_example_sim rtl/wire_example.v tb/tb_wire_example.v
```

If there are no errors, compilation is successful.

---

# 27. Run

```bash
vvp sim/wire_example_sim
```

Expected:

```text
VCD info: dumpfile sim/wire_example.vcd opened for output.
```

---

# 28. Open GTKWave

```bash
gtkwave sim/wire_example.vcd
```

Add:

```text
a
b
c
d
w1
w2
y
```

Observe how the internal wires change.

---

# 29. Waveform Verification

For:

```text
A=0 B=0 C=1 D=1
```

we have:

```text
W1 = A & B
   = 0 & 0
   = 0

W2 = C & D
   = 1 & 1
   = 1

Y = W1 | W2
  = 0 | 1
  = 1
```

Therefore:

```text
W1 = 0
W2 = 1
Y  = 1
```

GTKWave should show exactly this.

---

# 30. Another Verification

For:

```text
A=1 B=1 C=0 D=0
```

we get:

```text
W1 = 1 & 1 = 1
W2 = 0 & 0 = 0

Y = 1 | 0 = 1
```

Therefore:

```text
W1 = 1
W2 = 0
Y  = 1
```

Again, verify this in GTKWave.

---

# 31. `wire` vs `reg`

This is a **very important placement question**.

| `wire`                                          | `reg`                                           |
| ----------------------------------------------- | ----------------------------------------------- |
| Net data type                                   | Variable data type                              |
| Represents a connection                         | Used for procedural assignments                 |
| Commonly driven by `assign`                     | Commonly assigned inside `always`/`initial`     |
| Does not represent procedural storage by itself | Can hold a procedural value between assignments |
| Common in combinational connections             | Used in procedural modeling                     |

Example:

```verilog
wire y;

assign y = a & b;
```

Whereas:

```verilog
reg y;

always @(*) begin
    y = a & b;
end
```

We will study `reg` properly on **Day 5**.

---

# 32. Very Important Correction

Do not think:

> "`wire` means physical wire and `reg` means physical register."

That is an oversimplification.

In Verilog:

```text
wire → net
reg  → variable
```

A `reg` does **not automatically mean a hardware register**.

For example:

```verilog
always @(*) begin
    y = a & b;
end
```

can describe combinational hardware even though `y` is declared as `reg`.

Hardware storage depends on the RTL behavior, not simply on the keyword `reg`.

---

# 33. Common Mistake

### Wrong:

```verilog
wire y;

always @(*) begin
    y = a & b;
end
```

In traditional Verilog, a procedural assignment requires a variable such as `reg`, not a `wire`.

Correct:

```verilog
reg y;

always @(*) begin
    y = a & b;
end
```

Or use continuous assignment:

```verilog
wire y;

assign y = a & b;
```

This distinction will become much clearer on Day 5.

---

# 34. Another Common Mistake

Do not drive the same wire from multiple unrelated continuous assignments unless you deliberately understand Verilog's net-resolution behavior.

Avoid:

```verilog
wire y;

assign y = a;
assign y = b;
```

For ordinary RTL logic, prefer one clear driver.

---

# 35. `wire` With Vector Signals

Example:

```verilog
wire [7:0] data;
```

This represents:

```text
8-bit bus
```

You can assign:

```verilog
assign data = 8'b10101010;
```

or:

```verilog
assign data = input_data;
```

---

# 36. Concatenation With Wires

Example:

```verilog
wire [3:0] a;
wire [3:0] b;
wire [7:0] y;

assign y = {a, b};
```

If:

```text
a = 1010
b = 1100
```

then:

```text
y = 10101100
```

The `{ }` operator is called **concatenation**.

---

# 37. Why `wire` Matters in RTL

As designs become larger, you will have:

```text
Module A
   │
   │ wire
   ▼
Module B
   │
   │ wire
   ▼
Module C
   │
   ▼
Output
```

Internal wires allow modules and logic blocks to communicate.

This becomes especially important when we study:

* Structural modeling
* Hierarchy
* Adders
* Counters
* FSMs
* Memories
* Pipelines
* Processor datapaths

---

# 38. Interview Questions

### Q1. What is a `wire` in Verilog?

**Answer:**

`wire` is a net data type used to represent a connection between hardware elements and is normally driven by a continuous assignment or module output.

---

### Q2. Does a wire store data?

**Answer:**

A wire represents a net/connection; it does not provide procedural storage like a variable.

---

### Q3. How do you assign a value to a wire?

**Answer:**

Typically using continuous assignment:

```verilog
assign y = expression;
```

or by connecting it to a module output.

---

### Q4. Can a wire be used inside a module?

**Answer:**

Yes.

Example:

```verilog
wire temp;
```

---

### Q5. Can a wire be a vector?

**Answer:**

Yes.

Example:

```verilog
wire [7:0] data;
```

---

### Q6. What is an internal wire?

**Answer:**

A wire declared inside a module to connect internal logic or module instances.

---

### Q7. What is a continuous assignment?

**Answer:**

An assignment using `assign` that continuously drives a net according to an expression.

Example:

```verilog
assign y = a & b;
```

---

### Q8. What happens if a wire has no driver?

**Answer:**

It does not receive a meaningful driven logic value; depending on the simulation context, an undriven net can appear as high impedance (`Z`).

---

### Q9. What is the difference between a wire and a reg?

**Answer:**

`wire` is a net data type, while `reg` is a procedural variable type in Verilog. A `reg` does not necessarily represent a physical register.

---

### Q10. Can `wire` be assigned inside an `always` block?

**Answer:**

In traditional Verilog, a `wire` cannot be the target of a procedural assignment. Use a procedural variable such as `reg`, or use a continuous `assign` for a wire.

---

# 39. Placement Questions

### Question 1

What is the output?

```verilog
wire y;
assign y = a & b;
```

For:

```text
a = 1
b = 0
```

Answer:

```text
y = 0
```

---

### Question 2

What is the output?

```verilog
assign y = a | b;
```

For:

```text
a = 0
b = 1
```

Answer:

```text
y = 1
```

---

### Question 3

What is the output?

```verilog
assign y = a ^ b;
```

For:

```text
a = 1
b = 1
```

Answer:

```text
y = 0
```

---

### Question 4

How many combinations exist for four 1-bit inputs?

```text
2^4 = 16
```

---

### Question 5

What is the meaning of:

```verilog
wire [7:0] data;
```

Answer:

An 8-bit wire/bus with indices:

```text
7 6 5 4 3 2 1 0
```

---

# 40. Day 4 Assignment

## Assignment 1 — Basic Wire

Create:

```verilog
wire a;
wire b;
wire y;

assign y = a & b;
```

Verify the AND truth table.

---

## Assignment 2 — Multiple Wires

Implement:

```text
W1 = A & B
W2 = C | D
Y  = W1 ^ W2
```

Use separate internal wires.

Verify all 16 combinations.

---

## Assignment 3 — 4-bit Bus

Create:

```verilog
wire [3:0] a;
wire [3:0] b;
wire [3:0] y;

assign y = a ^ b;
```

Test:

```text
a = 1010
b = 1100
```

Calculate `y` before running the simulation.

---

## Assignment 4 — Module Connection

Create:

```text
AND gate
   ↓
OR gate
   ↓
Output
```

Use an internal `wire` between the two modules.

Structure:

```text
A ─────┐
       ▼
     AND ───► wire ───► OR ───► Y
       ▲                 ▲
B ─────┘                 C
```

---

# 41. Day 4 Checklist

Before moving to Day 5, make sure you can explain:

* [ ] What is `wire`?
* [ ] What is a net?
* [ ] Why is `wire` used?
* [ ] How does `assign` drive a wire?
* [ ] What is continuous assignment?
* [ ] What is an internal wire?
* [ ] How are wires used between modules?
* [ ] How to declare a vector wire
* [ ] Bit selection
* [ ] Part selection
* [ ] Concatenation
* [ ] `wire` vs `reg`
* [ ] What happens when a wire has no driver
* [ ] How to verify a wire-based circuit
* [ ] How to view internal wires in GTKWave

---

# 42. Day 4 Golden Rule

Remember:

```text
wire
 ↓
NET / CONNECTION
 ↓
DRIVEN BY A SOURCE
 ↓
assign / MODULE OUTPUT
 ↓
SIGNAL PROPAGATES
```

The most important syntax today is:

```verilog
wire y;

assign y = expression;
```

For example:

```verilog
wire w1;
wire w2;
wire y;

assign w1 = a & b;
assign w2 = c & d;
assign y  = w1 | w2;
```

Think of `wire` as the **connection that carries the result of hardware logic from one point to another**.

---

# 43. Day 4 Final Workflow

```text
Understand circuit
       ↓
Draw block/gate diagram
       ↓
Identify internal connections
       ↓
Declare wires
       ↓
Write continuous assignments
       ↓
Write testbench
       ↓
Compile
       ↓
Simulate
       ↓
Open GTKWave
       ↓
Check internal wires
       ↓
Verify truth table
```

**Day 4 assignment: Basic `wire` + multiple internal wires + 4-bit bus + module-to-module connection.**

