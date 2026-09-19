# Day 10 — Behavioral Modeling & 3:8 Demultiplexer

## 1. Day 10 Objective

By the end of Day 10, you should understand:

* What behavioral modeling means in Verilog
* How `always` blocks are used
* Difference between dataflow and behavioral modeling
* Procedural assignment
* Why `reg` is used for a signal assigned inside `always`
* `always @(*)`
* Basic `if/else` and `case`
* How to model a 3:8 demultiplexer
* How to verify all possible input combinations
* How to simulate using Icarus Verilog
* How to inspect the waveform using GTKWave

### Day 10 roadmap assignment

**Behavioral Modeling → 3:8 Demux**

---

# 2. What is Behavioral Modeling?

In behavioral modeling, we describe **what the circuit should do** rather than directly describing the gates.

For example, instead of writing:

```verilog
assign y = a & b;
```

we can describe the behavior using an `always` block:

```verilog
always @(*) begin
    y = a & b;
end
```

The second description is called **behavioral/procedural modeling**.

The synthesis tool can convert synthesizable behavioral RTL into equivalent hardware.

---

# 3. Dataflow vs Behavioral Modeling

You learned dataflow modeling on Day 9.

### Dataflow

```verilog
assign y = a & b;
```

We describe the relationship:

```text
a,b ──> AND ──> y
```

### Behavioral

```verilog
always @(*) begin
    y = a & b;
end
```

We describe the behavior:

```text
Whenever an input changes:
    calculate y
```

Both can synthesize to the same combinational hardware.

---

# 4. What is an `always` Block?

An `always` block repeatedly executes a procedural block whenever its sensitivity condition is triggered.

Basic syntax:

```verilog
always @(*) begin
    // procedural statements
end
```

Example:

```verilog
always @(*) begin
    y = a & b;
end
```

For combinational logic, `@(*)` tells Verilog to automatically include signals read inside the block in the sensitivity list.

---

# 5. Why Do We Use `reg`?

In traditional Verilog, a signal assigned inside an `always` block is declared as a variable, commonly using `reg`.

Example:

```verilog
output reg y;

always @(*) begin
    y = a & b;
end
```

Remember:

> `reg` does NOT automatically mean a physical register.

The hardware depends on the behavior described.

For example:

```verilog
always @(*) begin
    y = a & b;
end
```

describes combinational logic, even though `y` is declared `reg`.

---

# 6. Blocking Assignment `=`

For combinational behavioral logic, we normally use:

```verilog
=
```

Example:

```verilog
always @(*) begin
    y = a & b;
end
```

This is called a **blocking assignment**.

The statement executes immediately in procedural order.

We will study blocking and nonblocking assignments in much greater detail later in the roadmap.

---

# 7. What is a Demultiplexer?

A **demultiplexer (DEMUX)** takes:

* One data input
* Select inputs
* Multiple outputs

and sends the input data to **one selected output**.

For a **3:8 DEMUX**:

```text
             ┌─────────────┐
       D ───►│             │──► Y0
      S2 ───►│             │──► Y1
      S1 ───►│   3 : 8     │──► Y2
      S0 ───►│    DEMUX     │──► Y3
             │             │──► Y4
             │             │──► Y5
             │             │──► Y6
             │             │──► Y7
             └─────────────┘
```

There is:

```text
1 data input
3 select inputs
8 outputs
```

Because:

$$
2^3 = 8
$$

So three select bits can select one of eight outputs.

---

# 8. 3:8 DEMUX Operation

Let:

```text
D  = Data input
S2 S1 S0 = Select inputs
Y0-Y7 = Outputs
```

When:

```text
D = 1
```

the selected output becomes `1`.

All other outputs remain `0`.

When:

```text
D = 0
```

all outputs become `0`.

---

# 9. Truth Table

This is important for placement and viva.

### When D = 0

Regardless of the select input:

```text
All outputs = 0
```

| D | S2 | S1 | S0 | Y7 | Y6 | Y5 | Y4 | Y3 | Y2 | Y1 | Y0 |
| - | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| 0 | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  |
| 0 | 0  | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  |
| 0 | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  |
| 0 | 0  | 1  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  |
| 0 | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  |
| 0 | 1  | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  |
| 0 | 1  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  |
| 0 | 1  | 1  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  |

### When D = 1

Exactly one output becomes `1`.

| D | S2 | S1 | S0 | Y7 | Y6 | Y5 | Y4 | Y3 | Y2 | Y1 | Y0 |
| - | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| 1 | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 1  |
| 1 | 0  | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 1? |

Careful: for `S=001`, the selected output is **Y1**, so the correct row is:

| D | S2 | S1 | S0 | Y7 | Y6 | Y5 | Y4 | Y3 | Y2 | Y1 | Y0 |
| - | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- | -- |
| 1 | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 1  |
| 1 | 0  | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 1  | 0  |
| 1 | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 1  | 0  | 0  |
| 1 | 0  | 1  | 1  | 0  | 0  | 0  | 0  | 1  | 0  | 0  | 0  |
| 1 | 1  | 0  | 0  | 0  | 0  | 0  | 1  | 0  | 0  | 0  | 0  |
| 1 | 1  | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  |
| 1 | 1  | 1  | 0  | 0  | 0  | 1  | 0  | 0  | 0  | 0  | 0  |
| 1 | 1  | 1  | 1  | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 0  |

Therefore:

```text
S2 S1 S0 = 000 → Y0 = D
S2 S1 S0 = 001 → Y1 = D
S2 S1 S0 = 010 → Y2 = D
S2 S1 S0 = 011 → Y3 = D
S2 S1 S0 = 100 → Y4 = D
S2 S1 S0 = 101 → Y5 = D
S2 S1 S0 = 110 → Y6 = D
S2 S1 S0 = 111 → Y7 = D
```

---

# 10. Boolean Equations

The outputs can also be represented using Boolean equations:

$$
Y_0 = D\overline{S_2}\overline{S_1}\overline{S_0}
$$

$$
Y_1 = D\overline{S_2}\overline{S_1}S_0
$$

$$
Y_2 = D\overline{S_2}S_1\overline{S_0}
$$

$$
Y_3 = D\overline{S_2}S_1S_0
$$

$$
Y_4 = DS_2\overline{S_1}\overline{S_0}
$$

$$
Y_5 = DS_2\overline{S_1}S_0
$$

$$
Y_6 = DS_2S_1\overline{S_0}
$$

$$
Y_7 = DS_2S_1S_0
$$

These equations confirm that only the selected output receives `D`.

---

# 11. Behavioral RTL

Create:

```text
~/Verilog_50_Days/Day_10/rtl/3to8_demux.v
```

Code:

```verilog
module demux_3to8 (
    input  wire       d,
    input  wire [2:0] sel,
    output reg  [7:0] y
);

    always @(*) begin

        // Default: all outputs OFF
        y = 8'b00000000;

        case (sel)

            3'b000: y[0] = d;
            3'b001: y[1] = d;
            3'b010: y[2] = d;
            3'b011: y[3] = d;
            3'b100: y[4] = d;
            3'b101: y[5] = d;
            3'b110: y[6] = d;
            3'b111: y[7] = d;

            default: y = 8'b00000000;

        endcase
    end

endmodule
```

---

# 12. Why Do We Set `y = 0` First?

This line is very important:

```verilog
y = 8'b00000000;
```

We first assign a value to every output.

Then the selected output is assigned:

```verilog
y[sel] = d;
```

This ensures that every possible execution of the combinational block assigns the output.

Otherwise, incomplete assignments can infer **latches** in combinational behavioral RTL.

For example, this style is dangerous:

```verilog
always @(*) begin
    case(sel)
        3'b000: y[0] = d;
        3'b001: y[1] = d;
    endcase
end
```

What happens to the other outputs?

They may retain their previous values, potentially causing unintended storage/latch behavior.

---

# 13. Why `case`?

The select input has eight possible values:

```text
000
001
010
011
100
101
110
111
```

`case` makes the selection behavior very easy to read:

```verilog
case (sel)
    3'b000: ...
    3'b001: ...
    ...
endcase
```

This is one of the common uses of behavioral modeling.

We will study `case`, `if/else`, priority behavior, and related coding styles more deeply in later days.

---

# 14. Testbench

Create:

```text
~/Verilog_50_Days/Day_10/tb/tb_3to8_demux.v
```

```verilog
`timescale 1ns/1ps

module tb_demux_3to8;

    reg       d;
    reg [2:0] sel;
    wire [7:0] y;

    demux_3to8 dut (
        .d(d),
        .sel(sel),
        .y(y)
    );

    integer i;

    initial begin

        $dumpfile("sim/demux_3to8.vcd");
        $dumpvars(0, tb_demux_3to8);

        // Test D = 0
        d = 1'b0;

        for (i = 0; i < 8; i = i + 1) begin
            sel = i;
            #10;
        end

        // Test D = 1
        d = 1'b1;

        for (i = 0; i < 8; i = i + 1) begin
            sel = i;
            #10;
        end

        $finish;

    end

endmodule
```

---

# 15. Why This Testbench Is Complete

There are:

```text
1 data input
3 select inputs
```

Therefore:

$$
2^4 = 16
$$

total input combinations.

The testbench checks:

```text
D = 0 → 8 combinations
D = 1 → 8 combinations
```

Total:

```text
8 + 8 = 16
```

So we verify **every possible input combination**.

---

# 16. Expected Results

### D = 0

For every select value:

```text
Y = 00000000
```

### D = 1

| SEL | Expected Y |
| --- | ---------- |
| 000 | 00000001   |
| 001 | 00000010   |
| 010 | 00000100   |
| 011 | 00001000   |
| 100 | 00010000   |
| 101 | 00100000   |
| 110 | 01000000   |
| 111 | 10000000   |

This is effectively a **one-hot output** when `D=1`.

---

# 17. Setup Directory

Run:

```bash
mkdir -p ~/Verilog_50_Days/Day_10/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_10
```

Check:

```bash
tree
```

Expected:

```text
Day_10/
├── rtl/
│   └── 3to8_demux.v
├── tb/
│   └── tb_3to8_demux.v
├── sim/
└── wave/
```

---

# 18. Compile

Run:

```bash
iverilog -o sim/demux_3to8_sim rtl/3to8_demux.v tb/tb_3to8_demux.v
```

If there are no errors, the design compiled successfully.

---

# 19. Run Simulation

```bash
vvp sim/demux_3to8_sim
```

Expected:

```text
VCD info: dumpfile sim/demux_3to8.vcd opened for output.
```

---

# 20. Open GTKWave

```bash
gtkwave sim/demux_3to8.vcd
```

Add:

```text
d
sel
y
```

You should observe:

```text
D=0
Y=00000000
```

for every select value.

Then:

```text
D=1

SEL=000 → Y=00000001
SEL=001 → Y=00000010
SEL=010 → Y=00000100
SEL=011 → Y=00001000
SEL=100 → Y=00010000
SEL=101 → Y=00100000
SEL=110 → Y=01000000
SEL=111 → Y=10000000
```

---

# 21. Behavioral Modeling — Important Points

Remember these:

### 1. `always`

Used for procedural descriptions.

```verilog
always @(*) begin
    ...
end
```

### 2. `reg`

Traditional Verilog variable type used when the signal is assigned procedurally.

```verilog
output reg y;
```

### 3. Blocking assignment

```verilog
y = value;
```

Commonly used for combinational procedural logic.

### 4. `case`

Useful when behavior depends on multiple discrete choices.

```verilog
case(sel)
    ...
endcase
```

### 5. Complete assignment

Make sure every output gets a value for every possible path.

This helps prevent unintended latch inference.

---

# 22. Demux vs Decoder

This is a common viva question.

### Decoder

Usually:

```text
n inputs → 2^n outputs
```

and the outputs indicate the selected input combination.

For example:

```text
3-to-8 decoder
```

has:

```text
3 inputs
8 outputs
```

### Demultiplexer

Has:

```text
1 data input
select inputs
multiple outputs
```

The selected output receives the data.

For our circuit:

```text
D = data
S2,S1,S0 = select
Y0-Y7 = outputs
```

So:

> A demultiplexer routes one data input to one of multiple outputs according to the select inputs.

---

# 23. Common Mistakes

### Mistake 1 — Forgetting `reg`

Incorrect:

```verilog
output wire [7:0] y;

always @(*) begin
    y = 8'b0;
end
```

Traditional Verilog does not allow a procedural assignment to a `wire`.

Use:

```verilog
output reg [7:0] y;
```

---

### Mistake 2 — Forgetting the default assignment

Bad combinational style:

```verilog
always @(*) begin
    case(sel)
        ...
    endcase
end
```

Better:

```verilog
always @(*) begin
    y = 8'b0;

    case(sel)
        ...
    endcase
end
```

---

### Mistake 3 — Using the wrong output

For:

```text
SEL = 101
```

the selected output is:

```text
Y5
```

not `Y4` or `Y6`.

Because:

$$
101_2 = 5_{10}
$$

---

### Mistake 4 — Confusing DEMUX with MUX

MUX:

```text
Many inputs → One output
```

DEMUX:

```text
One input → Many outputs
```

---

# 24. Placement Interview Questions

### Q1. What is behavioral modeling?

Behavioral modeling describes the operation or behavior of a digital circuit using procedural constructs such as `always`, `if`, and `case`.

### Q2. What is an `always` block?

An `always` block repeatedly executes a procedural statement/block whenever its sensitivity condition is triggered.

### Q3. What does `always @(*)` mean?

It creates an automatically determined sensitivity list containing signals read by the procedural block.

### Q4. Why is `reg` used for the DEMUX output?

Because the output `y` is assigned inside an `always` procedural block.

### Q5. Does `reg` mean hardware register?

No. `reg` is a Verilog variable type. Hardware depends on the behavior described.

### Q6. Why use blocking assignment for combinational logic?

Blocking assignment `=` executes immediately in procedural order and is commonly used for combinational procedural descriptions.

### Q7. What is a 3:8 DEMUX?

A circuit with one data input, three select inputs, and eight outputs that routes the data to the selected output.

### Q8. Why are there eight outputs?

Because three select bits provide:

$$
2^3=8
$$

possible selections.

### Q9. What happens when D=0?

All outputs are zero.

### Q10. What happens when D=1?

The output selected by `S2S1S0` becomes `1`; all other outputs remain zero.

### Q11. What is the difference between a MUX and DEMUX?

MUX:

```text
Many → One
```

DEMUX:

```text
One → Many
```

### Q12. Why do we give `y` a default value?

To ensure the combinational block assigns outputs on every execution path and avoid unintended latch inference.

---

# 25. Day 10 Assignment

Complete these yourself:

### Assignment 1 — 3:8 DEMUX

Implement:

```text
D + S2 + S1 + S0 → Y[7:0]
```

using behavioral modeling.

### Assignment 2 — Use `if/else`

Implement the same DEMUX using `if/else` instead of `case`.

### Assignment 3 — Compare

Implement the DEMUX using:

1. Dataflow
2. Behavioral
3. Structural

Then compare the RTL styles.

### Assignment 4 — Verification

Verify all:

$$
2^4=16
$$

input combinations.

### Assignment 5 — Debugging

Remove:

```verilog
y = 8'b00000000;
```

from the behavioral block and study what happens during simulation.

Understand **why incomplete combinational assignments can lead to inferred storage/latches**.

---

# 26. Day 10 Golden Concept

You should be able to explain this without looking at notes:

```text
Behavioral Modeling
       ↓
always block
       ↓
Combinational behavior
       ↓
case(sel)
       ↓
3:8 DEMUX
       ↓
Testbench
       ↓
16 combinations
       ↓
Icarus Verilog
       ↓
GTKWave
       ↓
Verify output
```

### Most important code pattern

```verilog
always @(*) begin

    y = 8'b0;

    case (sel)
        3'b000: y[0] = d;
        3'b001: y[1] = d;
        3'b010: y[2] = d;
        3'b011: y[3] = d;
        3'b100: y[4] = d;
        3'b101: y[5] = d;
        3'b110: y[6] = d;
        3'b111: y[7] = d;
        default: y = 8'b0;
    endcase

end
```

### One-line interview answer

> **Behavioral modeling describes circuit operation using procedural constructs such as `always`, `if`, and `case`, allowing synthesizable RTL to represent the intended hardware behavior.**

---

# Day 10 Checklist

* [ ] Understand behavioral modeling
* [ ] Understand `always @(*)`
* [ ] Understand procedural assignment
* [ ] Understand blocking `=`
* [ ] Understand why `reg` is used
* [ ] Understand DEMUX operation
* [ ] Know the complete 3:8 DEMUX truth table
* [ ] Write 3:8 DEMUX RTL
* [ ] Write the testbench
* [ ] Verify all 16 combinations
* [ ] Run Icarus Verilog
* [ ] Open GTKWave
* [ ] Understand latch inference from incomplete combinational assignment
* [ ] Answer placement questions

# Day 10 Final Formula

For a 3:8 DEMUX:

$$
\boxed{\text{One Data Input + 3 Select Inputs → 8 Outputs}}
$$

and:

$$
\boxed{Y_i=D\quad\text{when}\quad SEL=i}
$$

Otherwise:

$$
\boxed{Y_j=0,\quad j\neq i}
$$
