# Day 14 — Continuous Assignment

## 1. Day 14 Objective

Today you will learn:

* What continuous assignment means
* The `assign` statement
* How continuous assignments work
* `wire` and continuous assignment
* Scalar and vector assignments
* Expression-based assignments
* Multiple continuous assignments
* Conditional operator `?:`
* Continuous assignment vs procedural assignment
* Common mistakes
* RTL examples
* Testbench and GTKWave verification
* Placement/interview questions

---

# 2. What Is Continuous Assignment?

A continuous assignment continuously drives a value onto a **net**.

Basic syntax:

```verilog
assign net_name = expression;
```

Example:

```verilog
assign y = a & b;
```

This means:

```text
Whenever a or b changes,
recalculate a & b
and drive the result onto y.
```

Conceptually:

```text
        a ──┐
            AND ─────► y
        b ──┘
```

---

# 3. Why Is It Called "Continuous"?

Consider:

```verilog
assign y = a & b;
```

There is no explicit sequence such as:

```text
do this
then wait
then do that
```

Instead, the relationship is continuously maintained:

$$
Y=A\cdot B
$$

If:

```text
a = 0, b = 1
```

then:

```text
y = 0
```

If `a` changes to `1`:

```text
a = 1, b = 1
```

then:

```text
y = 1
```

The assignment continuously responds to changes in its input expression.

---

# 4. Basic Syntax

```verilog
assign output = expression;
```

Examples:

```verilog
assign y = a & b;
```

```verilog
assign y = a | b;
```

```verilog
assign y = a ^ b;
```

```verilog
assign y = ~a;
```

```verilog
assign y = a + b;
```

```verilog
assign y = a - b;
```

---

# 5. Continuous Assignment and `wire`

The traditional Verilog form is:

```verilog
wire y;

assign y = a & b;
```

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
a,b → inputs
y   → net
assign → continuously drives y
```

---

# 6. Important Rule

For traditional Verilog:

> A continuous assignment drives a **net**, commonly a `wire`.

For example:

```verilog
wire y;

assign y = a & b;
```

Do not confuse this with procedural assignment:

```verilog
reg y;

always @(*) begin
    y = a & b;
end
```

The two styles can describe the same combinational hardware, but they use different Verilog modeling mechanisms.

---

# 7. Continuous Assignment Example

Let's implement:

$$
Y=(A\&B)|(C\&D)
$$

RTL:

```verilog
module continuous_example (
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

    assign y = w1 | w2;

endmodule
```

Hardware:

```text
A ──┐
    AND ── w1 ──┐
B ──┘           │
                OR ─── Y
C ──┐           │
    AND ── w2 ──┘
D ──┘
```

This is pure dataflow/continuous-assignment modeling.

---

# 8. Truth Table

For:

$$
Y=(A B)+(C D)
$$

where multiplication represents AND and addition represents OR:

| A | B | C | D | AB | CD |  Y |
| - | - | - | - | -: | -: | -: |
| 0 | 0 | 0 | 0 |  0 |  0 |  0 |
| 0 | 0 | 0 | 1 |  0 |  0 |  0 |
| 0 | 0 | 1 | 0 |  0 |  0 |  0 |
| 0 | 0 | 1 | 1 |  0 |  1 |  1 |
| 0 | 1 | 0 | 0 |  0 |  0 |  0 |
| 0 | 1 | 0 | 1 |  0 |  0 |  0 |
| 0 | 1 | 1 | 0 |  0 |  0 |  0 |
| 0 | 1 | 1 | 1 |  0 |  1 |  1 |
| 1 | 0 | 0 | 0 |  0 |  0 |  0 |
| 1 | 0 | 0 | 1 |  0 |  0 |  0 |
| 1 | 0 | 1 | 0 |  0 |  0 |  0 |
| 1 | 0 | 1 | 1 |  0 |  1 |  1 |
| 1 | 1 | 0 | 0 |  1 |  0 |  1 |
| 1 | 1 | 0 | 1 |  1 |  0 |  1 |
| 1 | 1 | 1 | 0 |  1 |  0 |  1 |
| 1 | 1 | 1 | 1 |  1 |  1 |  1 |

Verification:

```text
Y = 1
when AB = 1 OR CD = 1
```

---

# 9. Vector Continuous Assignment

Continuous assignments can also operate on vectors.

Example:

```verilog
module vector_example (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [3:0] y
);

    assign y = a & b;

endmodule
```

This performs bitwise AND:

```text
y[3] = a[3] & b[3]
y[2] = a[2] & b[2]
y[1] = a[1] & b[1]
y[0] = a[0] & b[0]
```

Example:

```text
a = 1010
b = 1100

y = 1000
```

---

# 10. Bitwise vs Logical Operators

This is extremely important.

### Bitwise AND

```verilog
&
```

Example:

```verilog
assign y = a & b;
```

For:

```text
a = 4'b1010
b = 4'b1100
```

result:

```text
1000
```

### Logical AND

```verilog
&&
```

This treats operands as logical conditions and produces a single Boolean result.

For placement interviews:

> `&` is bitwise AND, while `&&` is logical AND.

Similarly:

```text
|   → bitwise OR
||  → logical OR

^   → bitwise XOR
!   → logical NOT
~   → bitwise NOT
```

---

# 11. Multiple Continuous Assignments

You can have multiple `assign` statements in one module.

Example:

```verilog
module multiple_assign (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);

    assign sum   = a ^ b;
    assign carry = a & b;

endmodule
```

This implements a half adder.

Truth table:

| A | B | Sum | Carry |
| - | - | --- | ----- |
| 0 | 0 | 0   | 0     |
| 0 | 1 | 1   | 0     |
| 1 | 0 | 1   | 0     |
| 1 | 1 | 0   | 1     |

Equations:

$$
Sum=A\oplus B
$$

$$
Carry=A\cdot B
$$

---

# 12. Continuous Assignment with Arithmetic

You can use arithmetic operators.

Example:

```verilog
module adder (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [4:0] sum
);

    assign sum = a + b;

endmodule
```

Why 5 bits?

Maximum:

$$
15+15=30
$$

and:

$$
30_{10}=11110_2
$$

which requires 5 bits.

Therefore:

```text
4-bit + 4-bit → 5-bit result
```

---

# 13. Continuous Assignment with Comparison

Example:

```verilog
module comparator (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire       greater
);

    assign greater = (a > b);

endmodule
```

The output is a 1-bit Boolean result.

Example:

```text
A = 9
B = 4

greater = 1
```

---

# 14. Conditional Operator

The conditional operator is:

```verilog
condition ? true_value : false_value
```

It is extremely useful with continuous assignments.

Example:

```verilog
assign y = sel ? b : a;
```

This implements a 2:1 multiplexer.

---

# 15. 2:1 MUX Using Continuous Assignment

```verilog
module mux_2to1 (
    input  wire a,
    input  wire b,
    input  wire sel,
    output wire y
);

    assign y = sel ? b : a;

endmodule
```

Operation:

| Sel | Y |
| --- | - |
| 0   | A |
| 1   | B |

Therefore:

$$
Y=\bar{S}A+SB
$$

---

# 16. Why `?:` Is Useful

Instead of:

```verilog
always @(*) begin
    if (sel)
        y = b;
    else
        y = a;
end
```

we can write:

```verilog
assign y = sel ? b : a;
```

Both can describe a combinational MUX.

The second is compact dataflow-style RTL.

---

# 17. Continuous Assignment vs Procedural Assignment

This is an important placement question.

### Continuous assignment

```verilog
assign y = a & b;
```

Usually uses:

```text
wire
```

and is evaluated continuously.

### Procedural assignment

```verilog
always @(*) begin
    y = a & b;
end
```

Uses a procedural variable such as:

```text
reg
```

in traditional Verilog.

---

# 18. Comparison

| Feature                 | Continuous Assignment          | Procedural Assignment                     |
| ----------------------- | ------------------------------ | ----------------------------------------- |
| Keyword                 | `assign`                       | `always`                                  |
| Traditional destination | `wire`                         | `reg`                                     |
| Evaluation              | Continuous                     | When procedural block executes            |
| Common use              | Simple combinational equations | Complex combinational/sequential behavior |
| Example                 | `assign y=a&b;`                | `always @(*) y=a&b;`                      |

---

# 19. Continuous Assignment Does Not Mean Sequential

Example:

```verilog
assign y = a + b;
```

There is:

```text
No clock
No state
No memory
```

Therefore it describes combinational behavior.

---

# 20. Continuous Assignment Cannot Replace a Clocked Register

Consider:

```verilog
always @(posedge clk)
    q <= d;
```

This describes a clocked storage element.

You cannot simply replace it with:

```verilog
assign q = d;
```

because that changes the hardware behavior.

First:

```text
D ──► Flip-Flop ──► Q
       ▲
       │
      CLK
```

Second:

```text
D ───────────────► Q
```

The second has no storage.

---

# 21. Continuous Assignment and Hardware

When synthesis sees:

```verilog
assign y = a & b;
```

it can infer the equivalent combinational hardware:

```text
A ──┐
    AND ── Y
B ──┘
```

When you write:

```verilog
assign y = a ? b : c;
```

synthesis can infer:

```text
        ┌─────┐
B ─────►│     │
        │ MUX ├──► Y
C ─────►│     │
        └──┬──┘
           ▲
           S
```

RTL describes behavior; synthesis maps it to available hardware.

---

# 22. Common Mistake — Driving the Same Wire Multiple Times

Avoid unintentionally doing:

```verilog
assign y = a;
assign y = b;
```

Now `y` has multiple continuous drivers.

This can result in resolved values such as `X` depending on the drivers.

For normal synthesizable RTL:

> Give a signal a clear single intended driver.

---

# 23. Common Mistake — Confusing `=` and `assign`

These are completely different:

```verilog
assign y = a & b;
```

is a continuous assignment.

Whereas:

```verilog
always @(*) begin
    y = a & b;
end
```

uses a procedural blocking assignment.

The `=` inside `always` is **not** the same thing as the `assign` keyword.

---

# 24. Day 14 Practical Lab

We will implement a small ALU-like combinational circuit using continuous assignments.

Specification:

```text
op = 00 → AND
op = 01 → OR
op = 10 → XOR
op = 11 → ADD
```

Inputs:

```text
A = 4 bits
B = 4 bits
op = 2 bits
```

Output:

```text
Y = 4 bits
```

---

# 25. RTL

Create:

```text
~/Verilog_50_Days/Day_14/rtl/alu_continuous.v
```

```verilog
module alu_continuous (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] op,
    output wire [3:0] y
);

    assign y = (op == 2'b00) ? (a & b) :
               (op == 2'b01) ? (a | b) :
               (op == 2'b10) ? (a ^ b) :
                                (a + b);

endmodule
```

This uses nested conditional operators.

---

# 26. ALU Operation Table

| `op` | Operation | Output   |
| ---- | --------- | -------- |
| `00` | AND       | `A & B`  |
| `01` | OR        | `A \| B` |
| `10` | XOR       | `A ^ B`  |
| `11` | ADD       | `A + B`  |

Example:

```text
A = 1010
B = 1100
```

For `op=00`:

```text
1010
1100
----
1000
```

For `op=01`:

```text
1010
1100
----
1110
```

For `op=10`:

```text
1010
1100
----
0110
```

For `op=11`:

```text
1010
1100
----
0110
```

The output is only 4 bits, so any carry beyond bit 3 is discarded.

---

# 27. Testbench

Create:

```text
~/Verilog_50_Days/Day_14/tb/tb_alu_continuous.v
```

```verilog
`timescale 1ns/1ps

module tb_alu_continuous;

    reg  [3:0] a;
    reg  [3:0] b;
    reg  [1:0] op;

    wire [3:0] y;

    integer i;
    integer j;
    integer k;

    reg [3:0] expected;

    alu_continuous dut (
        .a(a),
        .b(b),
        .op(op),
        .y(y)
    );

    initial begin

        $dumpfile("sim/alu_continuous.vcd");
        $dumpvars(0, tb_alu_continuous);

        for (k = 0; k < 4; k = k + 1) begin

            for (i = 0; i < 16; i = i + 1) begin

                for (j = 0; j < 16; j = j + 1) begin

                    a  = i;
                    b  = j;
                    op = k;

                    #1;

                    case (op)
                        2'b00: expected = a & b;
                        2'b01: expected = a | b;
                        2'b10: expected = a ^ b;
                        2'b11: expected = a + b;
                    endcase

                    if (y !== expected) begin
                        $display(
                            "FAIL: A=%0d B=%0d OP=%b Y=%0d EXPECTED=%0d",
                            a, b, op, y, expected
                        );
                    end
                    else begin
                        $display(
                            "PASS: A=%0d B=%0d OP=%b Y=%0d",
                            a, b, op, y
                        );
                    end

                end

            end

        end

        $finish;

    end

endmodule
```

---

# 28. How Many Tests?

There are:

```text
A → 16 possibilities
B → 16 possibilities
OP → 4 possibilities
```

Therefore:

$$
16\times16\times4=1024
$$

The testbench checks:

$$
\boxed{1024\text{ combinations}}
$$

This is a complete exhaustive verification for the given input widths.

---

# 29. Setup

Run:

```bash
mkdir -p ~/Verilog_50_Days/Day_14/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_14
```

Put the RTL in:

```text
rtl/alu_continuous.v
```

and testbench in:

```text
tb/tb_alu_continuous.v
```

---

# 30. Compile

```bash
iverilog -o sim/alu_sim \
    rtl/alu_continuous.v \
    tb/tb_alu_continuous.v
```

---

# 31. Run

```bash
vvp sim/alu_sim
```

You should see:

```text
PASS: A=0 B=0 OP=00 Y=0
PASS: A=0 B=1 OP=00 Y=0
...
```

There should be no:

```text
FAIL
```

messages.

---

# 32. View Waveform

Run:

```bash
gtkwave sim/alu_continuous.vcd
```

Add:

```text
a
b
op
y
```

Observe how `y` changes according to `op`.

---

# 33. Day 14 Key Concepts

Remember these five points:

### 1.

```verilog
assign
```

means continuous assignment.

### 2.

A continuous assignment continuously drives a net according to an expression.

### 3.

Traditional Verilog commonly uses:

```verilog
wire
```

with continuous assignment.

### 4.

The conditional operator:

```verilog
?:
```

is very useful for compact combinational RTL.

### 5.

Continuous assignment normally describes combinational behavior.

---

# 34. Placement Questions

### Q1. What is continuous assignment?

A continuous assignment continuously drives a net using the value of an expression.

### Q2. Which keyword is used?

```verilog
assign
```

### Q3. What is the common traditional destination type?

```verilog
wire
```

### Q4. Give an example.

```verilog
assign y = a & b;
```

### Q5. What happens when an input changes?

The expression is reevaluated and the driven net updates accordingly.

### Q6. What is the difference between `assign` and `always`?

`assign` is a continuous assignment mechanism, while `always` creates a procedural block that executes when its sensitivity conditions are triggered.

### Q7. Can continuous assignment describe combinational logic?

Yes.

### Q8. Can it directly implement a flip-flop?

No. A flip-flop requires storage behavior, normally modeled using clocked sequential logic.

### Q9. What does this mean?

```verilog
assign y = sel ? b : a;
```

It describes a 2:1 multiplexer.

### Q10. What is the difference between `&` and `&&`?

```text
&  → bitwise AND
&& → logical AND
```

### Q11. What is the difference between `|` and `||`?

```text
|  → bitwise OR
|| → logical OR
```

### Q12. What is a multiple-driver problem?

It occurs when more than one source drives the same signal, potentially causing contention or unwanted resolved values.

---

# 35. Interview Question

**Q: Why would you use continuous assignment instead of an `always` block?**

Answer:

> Continuous assignment is convenient for expressing direct combinational relationships between signals, especially simple Boolean, arithmetic, and conditional equations. It makes the dataflow relationship explicit.

---

# 36. Interview Question

**Q: Is `wire` combinational and `reg` sequential?**

Answer:

> No. `wire` and `reg` describe Verilog signal/variable types; they do not directly determine the physical hardware. The RTL behavior determines whether synthesis produces combinational logic, a latch, flip-flops, or other hardware.

---

# 37. Interview Question

**Q: Is every `assign` statement combinational?**

For normal synthesizable RTL, continuous assignments are generally used to describe combinational relationships. The important point is that `assign` continuously drives a net from an expression rather than storing a previous value.

---

# 38. Practice Problems

### Practice 1

Implement:

$$
Y=(A\&B)|(C\&D)
$$

using only continuous assignments.

---

### Practice 2

Implement a 4-bit:

```text
A == B
A > B
A < B
```

comparator using continuous assignments.

---

### Practice 3

Implement a 4-bit 2:1 MUX:

```text
Y = A when S=0
Y = B when S=1
```

using:

```verilog
assign
```

---

### Practice 4

Implement a 4-bit half adder/adder section using continuous assignments.

---

### Practice 5

Write a continuous assignment for:

$$
Y=\overline{A}B+AC
$$

Then identify what type of circuit it represents.

---

# 39. Day 14 Checklist

Before moving to Day 15, make sure you can:

* [ ] Explain continuous assignment
* [ ] Use `assign`
* [ ] Explain `wire`
* [ ] Write Boolean equations using `assign`
* [ ] Use vector assignments
* [ ] Distinguish `&` and `&&`
* [ ] Distinguish `|` and `||`
* [ ] Use arithmetic expressions
* [ ] Use comparison expressions
* [ ] Use `?:`
* [ ] Implement a MUX with `assign`
* [ ] Explain continuous vs procedural assignment
* [ ] Understand multiple-driver problems
* [ ] Run Icarus Verilog
* [ ] View the waveform in GTKWave
* [ ] Verify all 1024 ALU combinations

---

# 40. Day 14 Golden Notes

```text
assign y = expression;
```

means:

```text
Continuously drive y from expression.
```

Example:

```verilog
assign y = a & b;
```

MUX:

```verilog
assign y = sel ? b : a;
```

Vector:

```verilog
assign y = a & b;
```

Arithmetic:

```verilog
assign sum = a + b;
```

Comparison:

```verilog
assign greater = (a > b);
```

The central idea:

$$
\boxed{\text{Continuous Assignment = continuously maintained dataflow relationship}}
$$

---

# Day 14 Final Interview Line

If asked **"What is continuous assignment in Verilog?"**, answer:

> **Continuous assignment is a Verilog mechanism used to continuously drive a net from an expression using the `assign` keyword. Whenever a value in the expression changes, the driven net is updated. It is commonly used for combinational/dataflow RTL.**

**Day 14 complete.**

Next in the roadmap: **Day 15 — Blocking Assignment (`=`)**.
