# Day 15 — Blocking Assignment (`=`)

## 1. Day 15 Objective

Today you will learn:

* What a blocking assignment is
* Syntax of `=`
* How blocking assignments execute
* Sequential execution inside an `always` block
* Blocking assignment in combinational logic
* Blocking assignment in testbenches
* Difference between blocking and continuous assignment
* Difference between blocking `=` and nonblocking `<=`
* Common RTL mistakes
* Race-condition problems
* Practical RTL + testbench
* Placement/interview questions

### Roadmap Topic

**Blocking Assignment**

---

# 2. What Is a Blocking Assignment?

A blocking assignment uses:

```verilog
=
```

Example:

```verilog
a = b;
```

The important idea is:

> **The next statement waits until the blocking assignment has executed.**

Consider:

```verilog
always @(*) begin
    a = b;
    c = a;
end
```

The execution is:

```text
1. a gets b
2. c gets the new value of a
```

Therefore:

```text
c = b
```

---

# 3. Basic Syntax

```verilog
always @(*) begin

    variable = expression;

end
```

Example:

```verilog
always @(*) begin
    y = a & b;
end
```

Here:

```text
a & b
   ↓
 y
```

is calculated immediately within the procedural execution.

---

# 4. Why Is It Called "Blocking"?

Consider:

```verilog
always @(*) begin

    x = a;
    y = x;
    z = y;

end
```

The execution behaves conceptually as:

```text
x = a
 ↓
wait for this statement to execute
 ↓
y = x
 ↓
wait
 ↓
z = y
```

So each statement blocks the execution of the next statement until it has executed.

---

# 5. Simple Example

```verilog
module blocking_example (
    input  wire a,
    input  wire b,
    output reg  y
);

    always @(*) begin
        y = a & b;
    end

endmodule
```

Truth table:

| A | B | Y |
| - | - | - |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

This is combinational logic.

---

# 6. Blocking Assignment Is Procedural

Compare:

### Continuous assignment

```verilog
assign y = a & b;
```

### Blocking procedural assignment

```verilog
always @(*) begin
    y = a & b;
end
```

Both can describe the same combinational function.

But they are different Verilog constructs.

```text
assign
   ↓
continuous assignment

always + =
   ↓
procedural assignment
```

---

# 7. Blocking Assignment and `reg`

In traditional Verilog, a variable assigned inside a procedural block is commonly declared as:

```verilog
reg
```

Example:

```verilog
reg y;

always @(*) begin
    y = a & b;
end
```

Remember:

> `reg` does not necessarily mean that synthesis creates a physical register.

The behavior determines the hardware.

---

# 8. The Most Important Example

Consider:

```verilog
always @(*) begin

    a = b;
    c = a;

end
```

Suppose initially:

```text
b = 1
```

Execution:

```text
a = b
```

therefore:

```text
a = 1
```

Then:

```text
c = a
```

so:

```text
c = 1
```

Therefore:

```text
c = b
```

---

# 9. Blocking vs Nonblocking

This is one of the most important Verilog interview topics.

### Blocking

```verilog
=
```

### Nonblocking

```verilog
<=
```

Example:

```verilog
a = b;
```

versus:

```verilog
a <= b;
```

They have different simulation scheduling behavior.

---

# 10. Blocking Assignment

Example:

```verilog
always @(posedge clk) begin

    q = d;

end
```

At the clock edge:

```text
d → q
```

using a blocking assignment.

However, for normal synthesizable clocked sequential RTL, **nonblocking assignment (`<=`) is the recommended style**.

We will study this more deeply in the next day.

---

# 11. Why Blocking Is Commonly Used for Combinational Logic

Consider:

```verilog
always @(*) begin

    temp = a & b;
    y    = temp | c;

end
```

The intended dataflow is:

```text
a,b
 │
AND
 │
temp
 │
OR ◄── c
 │
 y
```

Blocking assignment naturally allows the statements to execute in that order.

---

# 12. Example — Two Intermediate Signals

```verilog
module blocking_logic (
    input  wire a,
    input  wire b,
    input  wire c,
    output reg  y
);

    reg temp;

    always @(*) begin
        temp = a & b;
        y    = temp | c;
    end

endmodule
```

Equation:

$$
temp=A\cdot B
$$

$$
Y=temp+C
$$

Therefore:

$$
\boxed{Y=AB+C}
$$

---

# 13. Truth Table Verification

For:

$$
Y=AB+C
$$

| A | B | C | AB | Y |
| - | - | - | -- | - |
| 0 | 0 | 0 | 0  | 0 |
| 0 | 0 | 1 | 0  | 1 |
| 0 | 1 | 0 | 0  | 0 |
| 0 | 1 | 1 | 0  | 1 |
| 1 | 0 | 0 | 0  | 0 |
| 1 | 0 | 1 | 0  | 1 |
| 1 | 1 | 0 | 1  | 1 |
| 1 | 1 | 1 | 1  | 1 |

The RTL should produce exactly these results.

---

# 14. Important Rule for Combinational Blocks

When using:

```verilog
always @(*)
```

with blocking assignments, make sure every output gets assigned for every possible condition.

Good:

```verilog
always @(*) begin

    y = 1'b0;

    if (sel)
        y = a;

end
```

The default assignment ensures `y` always receives a value.

---

# 15. Bad Example — Possible Latch

```verilog
always @(*) begin

    if (sel)
        y = a;

end
```

When:

```text
sel = 0
```

there is no assignment to `y`.

The previous value can therefore be retained, leading to latch inference during synthesis.

Better:

```verilog
always @(*) begin

    y = 1'b0;

    if (sel)
        y = a;

end
```

---

# 16. Blocking Assignment and Order

Consider:

```verilog
always @(*) begin

    x = a;
    y = x;
    z = y;

end
```

The intended result is:

```text
x = a
y = a
z = a
```

because the assignments execute procedurally in order.

This makes blocking assignment useful for intermediate calculations.

---

# 17. Example — Combinational ALU

Let's build a small ALU using blocking assignments.

Operations:

```text
00 → AND
01 → OR
10 → XOR
11 → ADD
```

---

# 18. RTL

Create:

```text
~/Verilog_50_Days/Day_15/rtl/alu_blocking.v
```

```verilog
module alu_blocking (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [1:0] op,
    output reg  [3:0] y
);

    always @(*) begin

        y = 4'b0000;

        case (op)

            2'b00:
                y = a & b;

            2'b01:
                y = a | b;

            2'b10:
                y = a ^ b;

            2'b11:
                y = a + b;

            default:
                y = 4'b0000;

        endcase

    end

endmodule
```

This uses:

```text
always @(*)
blocking assignment
case
```

and describes combinational logic.

---

# 19. ALU Truth Table

The operation selection is:

| `op` | Operation |
| ---- | --------- |
| `00` | `A & B`   |
| `01` | `A \| B`  |
| `10` | `A ^ B`   |
| `11` | `A + B`   |

For example:

```text
A = 1010
B = 1100
```

### AND

```text
1010
1100
----
1000
```

### OR

```text
1010
1100
----
1110
```

### XOR

```text
1010
1100
----
0110
```

### ADD

```text
1010
1100
----
1 0110
```

Since `y` is 4 bits:

```text
y = 0110
```

The carry is discarded.

---

# 20. Testbench

Create:

```text
~/Verilog_50_Days/Day_15/tb/tb_alu_blocking.v
```

```verilog
`timescale 1ns/1ps

module tb_alu_blocking;

    reg [3:0] a;
    reg [3:0] b;
    reg [1:0] op;

    wire [3:0] y;

    reg [3:0] expected;

    integer i;
    integer j;
    integer k;

    alu_blocking dut (
        .a(a),
        .b(b),
        .op(op),
        .y(y)
    );

    initial begin

        $dumpfile("sim/alu_blocking.vcd");
        $dumpvars(0, tb_alu_blocking);

        for (k = 0; k < 4; k = k + 1) begin

            for (i = 0; i < 16; i = i + 1) begin

                for (j = 0; j < 16; j = j + 1) begin

                    a  = i;
                    b  = j;
                    op = k;

                    #1;

                    case (op)

                        2'b00:
                            expected = a & b;

                        2'b01:
                            expected = a | b;

                        2'b10:
                            expected = a ^ b;

                        2'b11:
                            expected = a + b;

                        default:
                            expected = 4'b0000;

                    endcase

                    if (y !== expected) begin

                        $display(
                            "FAIL: A=%0d B=%0d OP=%b Y=%0d Expected=%0d",
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

# 21. Number of Tests

There are:

```text
A → 16 combinations
B → 16 combinations
OP → 4 combinations
```

Therefore:

$$
16\times16\times4=1024
$$

So the testbench exhaustively checks:

$$
\boxed{1024\text{ combinations}}
$$

---

# 22. Run the Experiment

Create directories:

```bash
mkdir -p ~/Verilog_50_Days/Day_15/{rtl,tb,sim,wave}
```

Go there:

```bash
cd ~/Verilog_50_Days/Day_15
```

Compile:

```bash
iverilog -o sim/alu_blocking_sim \
    rtl/alu_blocking.v \
    tb/tb_alu_blocking.v
```

Run:

```bash
vvp sim/alu_blocking_sim
```

You should get:

```text
PASS: A=0 B=0 OP=00 Y=0
PASS: A=0 B=1 OP=00 Y=0
...
```

There should be no:

```text
FAIL
```

---

# 23. GTKWave

Run:

```bash
gtkwave sim/alu_blocking.vcd
```

Add:

```text
a
b
op
y
```

Observe that `y` follows the selected operation.

---

# 24. Very Important: `=` Does NOT Mean "Instant Hardware"

This is a common beginner misunderstanding.

When we write:

```verilog
y = a & b;
```

inside:

```verilog
always @(*)
```

the `=` describes **simulation/procedural assignment semantics**.

It does not mean the synthesized hardware literally contains a special "blocking assignment component."

Synthesis interprets the RTL behavior and produces hardware.

---

# 25. Blocking Assignment Execution Model

Suppose:

```verilog
always @(*) begin

    x = a;
    y = x;
    z = y;

end
```

Conceptually:

```text
Start
  │
  ▼
x = a
  │
  ▼
y = x
  │
  ▼
z = y
  │
  ▼
End
```

The statements execute in procedural order.

---

# 26. Blocking Assignment vs Continuous Assignment

### Continuous

```verilog
assign y = a & b;
```

### Blocking

```verilog
always @(*) begin
    y = a & b;
end
```

Both can represent:

$$
Y=A\cdot B
$$

But their modeling mechanisms differ.

---

# 27. Blocking Assignment vs Nonblocking Assignment

This is the most important comparison.

| Feature            | Blocking `=`                   | Nonblocking `<=`                 |
| ------------------ | ------------------------------ | -------------------------------- |
| Symbol             | `=`                            | `<=`                             |
| Execution style    | Blocking/procedural            | Scheduled update                 |
| Common use         | Combinational procedural logic | Clocked sequential logic         |
| Statements execute | In procedural order            | RHS evaluated, updates scheduled |
| Typical RTL        | `always @(*)`                  | `always @(posedge clk)`          |

A common coding guideline is:

```text
Combinational → blocking =
Sequential    → nonblocking <=
```

This is the rule you should remember for placement preparation.

---

# 28. Why Blocking Can Be Dangerous in Sequential Logic

Consider:

```verilog
always @(posedge clk) begin

    q1 = d;
    q2 = q1;

end
```

With blocking assignment, after:

```text
q1 = d
```

`q1` immediately has the new value during the procedural execution.

Then:

```text
q2 = q1
```

uses that new value.

So the simulation behaves like:

```text
q2 gets new d
```

This may not represent the intended two-register pipeline behavior.

---

# 29. Intended Two-Register Pipeline

If the intention is:

```text
D → FF1 → FF2
```

then normally write:

```verilog
always @(posedge clk) begin

    q1 <= d;
    q2 <= q1;

end
```

Now both right-hand sides are evaluated from the old state before the scheduled updates take effect.

This is why `<=` is normally used for clocked sequential logic.

You will study this much more deeply in **Day 16 — Nonblocking Assignment**.

---

# 30. A Critical Interview Example

Suppose initially:

```text
a = 0
b = 1
```

Code:

```verilog
always @(posedge clk) begin

    a = b;
    b = a;

end
```

Using blocking assignments:

```text
a = 1
b = 1
```

because after:

```text
a = b
```

`a` has already changed.

With nonblocking:

```verilog
always @(posedge clk) begin

    a <= b;
    b <= a;

end
```

the old values are used for both RHS expressions.

Initial:

```text
a = 0
b = 1
```

After the clock edge:

```text
a = 1
b = 0
```

This is a very common interview question.

---

# 31. Hardware Interpretation

The nonblocking version:

```verilog
always @(posedge clk) begin
    a <= b;
    b <= a;
end
```

represents two registers exchanging values:

```text
        ┌──────┐
   ┌───►│  A   │
   │    └──────┘
   │       │
   │       ▼
   │    ┌──────┐
   └────│  B   │
        └──────┘
```

Both registers update together at the clock edge.

---

# 32. Important Rule for Placement

Memorize:

```text
Combinational procedural logic
        ↓
       =
    blocking
```

and:

```text
Clocked sequential logic
        ↓
       <=
    nonblocking
```

This is a coding guideline, not merely a syntax preference.

---

# 33. Common Mistakes

## Mistake 1

Using:

```verilog
<=
```

for ordinary combinational procedural calculations without understanding the scheduling implications.

---

## Mistake 2

Using:

```verilog
=
```

for clocked pipeline/register logic.

This can produce simulation behavior different from the intended register-to-register behavior.

---

## Mistake 3

Forgetting a combinational assignment:

```verilog
always @(*) begin

    if (sel)
        y = a;

end
```

Potential latch.

---

## Mistake 4

Thinking:

```text
reg = physical register
```

Incorrect.

The behavior determines the synthesized hardware.

---

# 34. When Should You Use Blocking Assignment?

For your placement preparation, the standard guideline is:

### Use blocking `=` for:

* Combinational `always @(*)` blocks
* Intermediate combinational calculations
* Testbench procedural code

Example:

```verilog
always @(*) begin
    temp = a & b;
    y = temp | c;
end
```

---

# 35. When Should You Use Nonblocking?

For your placement preparation:

### Use nonblocking `<=` for:

* Flip-flops
* Registers
* Counters
* Shift registers
* Clocked FSM state
* Sequential pipelines

Example:

```verilog
always @(posedge clk) begin
    q <= d;
end
```

We will cover this properly in Day 16.

---

# 36. Placement Viva Questions

### Q1. What is blocking assignment?

A procedural assignment using `=` in which the statement completes before the next procedural statement executes.

### Q2. What symbol represents blocking assignment?

```verilog
=
```

### Q3. Where is blocking assignment commonly used?

Combinational procedural logic and testbenches.

### Q4. What is the difference between `=` and `<=`?

`=` is blocking procedural assignment, while `<=` is nonblocking assignment with different event-scheduling behavior.

### Q5. Which is generally preferred for combinational RTL?

```verilog
=
```

### Q6. Which is generally preferred for clocked sequential RTL?

```verilog
<=
```

### Q7. Why?

Blocking assignments update variables during procedural execution, while nonblocking assignments model simultaneous state updates at clocked boundaries more naturally.

### Q8. Does `reg` always mean a hardware register?

No.

### Q9. Can blocking assignment describe combinational hardware?

Yes.

### Q10. Can blocking assignment be synthesized in sequential logic?

It can be synthesized, but using blocking assignments in clocked sequential RTL can create simulation/order issues and is generally discouraged when modeling ordinary flip-flop-based state.

---

# 37. Practice Problems

## Practice 1

Implement:

$$
Y=AB+C
$$

using:

```verilog
always @(*)
```

and blocking assignment.

Verify the complete 8-row truth table.

---

## Practice 2

Implement a 4-bit comparator using:

```verilog
always @(*)
```

and blocking assignment.

Outputs:

```text
greater
equal
less
```

Verify all:

$$
16\times16=256
$$

input combinations.

---

## Practice 3

Write:

```verilog
always @(*) begin
    x = a;
    y = x;
end
```

Determine the relationship between `a`, `x`, and `y`.

---

## Practice 4

Predict the result.

Initially:

```text
a = 0
b = 1
```

Then:

```verilog
always @(posedge clk) begin
    a = b;
    b = a;
end
```

What are `a` and `b` after the clock?

---

## Practice 5

Now replace `=` with `<=`:

```verilog
always @(posedge clk) begin
    a <= b;
    b <= a;
end
```

Predict the result.

This is an important interview exercise.

---

# 38. Day 15 Golden Notes

### Blocking operator

```verilog
=
```

### Typical combinational block

```verilog
always @(*) begin
    y = expression;
end
```

### Typical sequential block

```verilog
always @(posedge clk) begin
    q <= d;
end
```

### Main guideline

```text
Combinational → blocking =
Sequential    → nonblocking <=
```

### Critical concept

With blocking:

```verilog
a = b;
c = a;
```

the second statement sees the updated `a`.

With nonblocking:

```verilog
a <= b;
c <= a;
```

the RHS values are evaluated before the scheduled updates take effect.

---

# 39. Day 15 Checklist

Before moving to Day 16:

* [ ] Understand blocking assignment
* [ ] Know the `=` operator
* [ ] Understand procedural execution order
* [ ] Know why blocking is useful for combinational logic
* [ ] Understand complete combinational assignments
* [ ] Understand latch inference
* [ ] Know blocking vs continuous assignment
* [ ] Know blocking vs nonblocking assignment
* [ ] Understand the `a=b; b=a;` interview example
* [ ] Implement the blocking ALU
* [ ] Verify all 1024 combinations
* [ ] Run Icarus Verilog
* [ ] View GTKWave
* [ ] Know when `=` is normally used

---

# 40. Final Day 15 Interview Answer

If the interviewer asks:

**"What is blocking assignment in Verilog?"**

Answer:

> **Blocking assignment is a procedural assignment represented by `=`. The assignment executes in procedural order, so the next statement observes the updated value. It is commonly used for combinational logic and testbench code, while nonblocking `<=` is generally preferred for clocked sequential RTL.**

### The one-line memory rule:

$$
\boxed{\text{Combinational → }=\qquad\text{Sequential → }\leq}
$$

**Day 15 complete.**

Next: **Day 16 — Nonblocking Assignment (`<=`)**.
