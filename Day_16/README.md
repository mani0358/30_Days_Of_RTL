# Day 16 — Nonblocking Assignment (`<=`)

## 1. Day 16 Objective

Today you will learn:

* What a nonblocking assignment is
* Syntax of `<=`
* How nonblocking assignments execute
* Why `<=` is used for sequential RTL
* Difference between blocking `=` and nonblocking `<=`
* The difference between RHS evaluation and LHS update
* Flip-flop modeling
* Register modeling
* Pipeline modeling
* Shift-register example
* Counter example
* Race-condition problems
* Common mistakes
* Complete RTL + testbench
* Placement/interview questions

### Roadmap Topic

**Nonblocking Assignment**

---

# 2. What Is a Nonblocking Assignment?

A nonblocking assignment uses:

```verilog
<=
```

Example:

```verilog
always @(posedge clk) begin
    q <= d;
end
```

The key idea is:

> The right-hand side is evaluated when the statement executes, but the left-hand side update is scheduled to occur later in the current simulation time step.

This behavior is particularly useful for modeling clocked storage elements.

---

# 3. Basic Syntax

```verilog
always @(posedge clk) begin
    q <= d;
end
```

Conceptually:

```text
Clock edge
    │
    ├── Evaluate d
    │
    └── Schedule q update
```

This allows multiple registers to update as if they respond to the same clock edge.

---

# 4. Why Do We Need Nonblocking Assignment?

Consider two registers:

```text
D → FF1 → FF2
```

Suppose:

```text
FF1 = 0
FF2 = 0
D   = 1
```

At the clock edge, the desired behavior is:

```text
FF1 gets 1
FF2 gets old FF1 = 0
```

After the clock:

```text
FF1 = 1
FF2 = 0
```

On the next clock:

```text
FF1 = next D
FF2 = 1
```

This is exactly the behavior modeled naturally with:

```verilog
q1 <= d;
q2 <= q1;
```

---

# 5. The Most Important Concept

For:

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
end
```

the RHS values are evaluated using the values that existed before the scheduled updates take effect.

So:

```text
Before clock:

d  = 1
q1 = 0
q2 = 0
```

After clock:

```text
q1 = 1
q2 = 0
```

The new value of `q1` does **not** immediately become visible to the `q2 <= q1` statement during that same update.

---

# 6. Blocking vs Nonblocking

This is the most important comparison from Days 15 and 16.

### Blocking

```verilog
q1 = d;
q2 = q1;
```

The second statement sees the updated `q1`.

### Nonblocking

```verilog
q1 <= d;
q2 <= q1;
```

Both RHS expressions use the old values before the updates are applied.

---

# 7. Example

Initial state:

```text
q1 = 0
q2 = 0
d  = 1
```

## Blocking

```verilog
always @(posedge clk) begin
    q1 = d;
    q2 = q1;
end
```

Execution:

```text
q1 = 1
q2 = 1
```

Final:

```text
q1 = 1
q2 = 1
```

---

## Nonblocking

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
end
```

RHS values:

```text
d  = 1
q1 = 0
```

Scheduled updates:

```text
q1 ← 1
q2 ← 0
```

Final:

```text
q1 = 1
q2 = 0
```

This is the behavior expected from two cascaded flip-flops.

---

# 8. Hardware Interpretation

The nonblocking version:

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
end
```

models:

```text
       ┌───────┐       ┌───────┐
D ────►│  FF1  │──────►│  FF2  │───► Q2
       └───┬───┘       └───┬───┘
           │               │
           └──── CLK ──────┘
```

Both flip-flops receive the same clock.

---

# 9. Why Blocking Is Problematic Here

Suppose:

```verilog
always @(posedge clk) begin
    q1 = d;
    q2 = q1;
end
```

Simulation can make `q2` see the newly assigned `q1` in the same procedural execution.

That does not model the intended independent clocked updates of two cascaded registers.

Therefore:

> For ordinary clocked sequential RTL, use nonblocking assignment.

---

# 10. Standard RTL Guideline

Memorize this:

```text
Combinational procedural logic
          ↓
       blocking
          =
```

and:

```text
Clocked sequential logic
          ↓
     nonblocking
          <=
```

So:

```verilog
always @(*) begin
    y = expression;
end
```

and:

```verilog
always @(posedge clk) begin
    q <= d;
end
```

---

# 11. D Flip-Flop Using Nonblocking Assignment

The simplest example is a DFF.

```verilog
module dff (
    input  wire clk,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule
```

Operation:

| Clock edge |  D | Q after edge |
| ---------- | -: | -----------: |
| ↑          |  0 |            0 |
| ↑          |  1 |            1 |

The flip-flop samples `D` at the active clock edge.

---

# 12. DFF Truth Table

For a positive-edge triggered DFF:

| Rising Clock Edge | D | Q(next) |
| ----------------- | - | ------- |
| ↑                 | 0 | 0       |
| ↑                 | 1 | 1       |

Therefore:

$$
\boxed{Q_{next}=D}
$$

The output holds its value between active clock edges.

---

# 13. Register Using Nonblocking Assignment

A 4-bit register:

```verilog
module register_4bit (
    input  wire       clk,
    input  wire [3:0] d,
    output reg  [3:0] q
);

    always @(posedge clk) begin
        q <= d;
    end

endmodule
```

Hardware concept:

```text
D[3:0]
  │
  ▼
┌───────────┐
│  4-bit FF │
└─────┬─────┘
      │
      ▼
    Q[3:0]
```

---

# 14. Register With Enable

A very common RTL pattern:

```verilog
module register_enable (
    input  wire       clk,
    input  wire       enable,
    input  wire [3:0] d,
    output reg  [3:0] q
);

    always @(posedge clk) begin
        if (enable)
            q <= d;
    end

endmodule
```

When:

```text
enable = 1
```

the register captures `d`.

When:

```text
enable = 0
```

there is no new assignment, so the flip-flop retains its stored value.

This is intentional sequential behavior.

---

# 15. Register With Reset

```verilog
module register_reset (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] d,
    output reg  [3:0] q
);

    always @(posedge clk) begin
        if (reset)
            q <= 4'b0000;
        else
            q <= d;
    end

endmodule
```

This is a **synchronous reset** because reset is checked only at the rising clock edge.

You will study reset types in later days.

---

# 16. Nonblocking Assignment and Counters

Counters are sequential circuits.

Therefore:

```verilog
module counter_4bit (
    input  wire       clk,
    input  wire       reset,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b0000;
        else
            count <= count + 1'b1;

    end

endmodule
```

The key statement is:

```verilog
count <= count + 1'b1;
```

The updated count becomes visible after the clocked update.

---

# 17. Why `<=` Is Important for Counters

Suppose:

```text
count = 3
```

At the clock edge:

```verilog
count <= count + 1;
```

The RHS is evaluated:

```text
3 + 1 = 4
```

Then the new value is scheduled:

```text
count ← 4
```

The next clock uses the new stored value.

---

# 18. Shift Register

A shift register is another important sequential circuit.

4-bit shift register:

```verilog
module shift_register (
    input  wire       clk,
    input  wire       serial_in,
    output reg  [3:0] q
);

    always @(posedge clk) begin
        q <= {q[2:0], serial_in};
    end

endmodule
```

Suppose:

```text
q = 1010
serial_in = 1
```

After the clock:

```text
q = 0101
```

Wait carefully: the expression:

```verilog
{q[2:0], serial_in}
```

means:

```text
q[2:0] = 010
serial_in = 1

new q = 0101
```

So the old MSB is discarded and the new serial bit enters at bit 0.

---

# 19. Pipeline Example

A two-stage pipeline:

```verilog
module pipeline (
    input  wire       clk,
    input  wire [7:0] d,
    output reg  [7:0] q1,
    output reg  [7:0] q2
);

    always @(posedge clk) begin
        q1 <= d;
        q2 <= q1;
    end

endmodule
```

Suppose initially:

```text
d  = 8'hAA
q1 = 8'h00
q2 = 8'h00
```

At first clock:

```text
q1 = AA
q2 = 00
```

At next clock, if `d` remains `AA`:

```text
q1 = AA
q2 = AA
```

The data takes two register stages to reach `q2`.

---

# 20. Practical Day 16 Assignment

We will build and verify a **4-bit two-stage pipeline**.

Specification:

```text
Input → Register 1 → Register 2 → Output
```

Inputs:

```text
D[3:0]
CLK
RESET
```

Outputs:

```text
Q1[3:0]
Q2[3:0]
```

---

# 21. RTL

Create:

```text
~/Verilog_50_Days/Day_16/rtl/two_stage_pipeline.v
```

```verilog
module two_stage_pipeline (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] d,
    output reg  [3:0] q1,
    output reg  [3:0] q2
);

    always @(posedge clk) begin

        if (reset) begin
            q1 <= 4'b0000;
            q2 <= 4'b0000;
        end
        else begin
            q1 <= d;
            q2 <= q1;
        end

    end

endmodule
```

---

# 22. Expected Behavior

After reset:

```text
q1 = 0000
q2 = 0000
```

Suppose:

```text
d = 1010
```

First rising edge:

```text
q1 = 1010
q2 = 0000
```

Second rising edge:

```text
q1 = 1010
q2 = 1010
```

This demonstrates the essential effect of nonblocking assignment.

---

# 23. Testbench

Create:

```text
~/Verilog_50_Days/Day_16/tb/tb_two_stage_pipeline.v
```

```verilog
`timescale 1ns/1ps

module tb_two_stage_pipeline;

    reg       clk;
    reg       reset;
    reg [3:0] d;

    wire [3:0] q1;
    wire [3:0] q2;

    two_stage_pipeline dut (
        .clk   (clk),
        .reset (reset),
        .d     (d),
        .q1    (q1),
        .q2    (q2)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/two_stage_pipeline.vcd");
        $dumpvars(0, tb_two_stage_pipeline);

        clk   = 1'b0;
        reset = 1'b1;
        d     = 4'b0000;

        // Hold reset for two clock cycles
        #12;

        reset = 1'b0;

        // First data
        d = 4'b1010;

        @(posedge clk);
        #1;

        if ((q1 !== 4'b1010) || (q2 !== 4'b0000))
            $display("FAIL: First pipeline stage");

        else
            $display("PASS: First pipeline stage");

        // Second data
        d = 4'b1100;

        @(posedge clk);
        #1;

        if ((q1 !== 4'b1100) || (q2 !== 4'b1010))
            $display("FAIL: Second pipeline stage");

        else
            $display("PASS: Second pipeline stage");

        // Third data
        d = 4'b0011;

        @(posedge clk);
        #1;

        if ((q1 !== 4'b0011) || (q2 !== 4'b1100))
            $display("FAIL: Third pipeline stage");

        else
            $display("PASS: Third pipeline stage");

        $finish;

    end

endmodule
```

---

# 24. Important Testbench Detail

Notice:

```verilog
@(posedge clk);
#1;
```

The `#1` lets the testbench check the values after the nonblocking updates have occurred in simulation.

This is useful when observing clocked state changes.

---

# 25. Create Directories

Run:

```bash
mkdir -p ~/Verilog_50_Days/Day_16/{rtl,tb,sim,wave}
```

Then:

```bash
cd ~/Verilog_50_Days/Day_16
```

Your directory should be:

```text
Day_16/
├── rtl/
│   └── two_stage_pipeline.v
├── tb/
│   └── tb_two_stage_pipeline.v
├── sim/
└── wave/
```

---

# 26. Compile

```bash
iverilog -o sim/pipeline_sim \
    rtl/two_stage_pipeline.v \
    tb/tb_two_stage_pipeline.v
```

---

# 27. Run

```bash
vvp sim/pipeline_sim
```

Expected:

```text
PASS: First pipeline stage
PASS: Second pipeline stage
PASS: Third pipeline stage
```

There should be no:

```text
FAIL
```

---

# 28. View Waveform

Run:

```bash
gtkwave sim/two_stage_pipeline.vcd
```

Add:

```text
clk
reset
d
q1
q2
```

You should clearly see:

```text
D → Q1 → Q2
```

with one clock-cycle delay between the stages.

---

# 29. Blocking vs Nonblocking Practical Experiment

This is one experiment you should actually run.

Create a blocking version:

```verilog
module blocking_pipeline (
    input  wire       clk,
    input  wire [3:0] d,
    output reg  [3:0] q1,
    output reg  [3:0] q2
);

    always @(posedge clk) begin
        q1 = d;
        q2 = q1;
    end

endmodule
```

Compare it with:

```verilog
module nonblocking_pipeline (
    input  wire       clk,
    input  wire [3:0] d,
    output reg  [3:0] q1,
    output reg  [3:0] q2
);

    always @(posedge clk) begin
        q1 <= d;
        q2 <= q1;
    end

endmodule
```

---

# 30. Expected Difference

Suppose before the clock:

```text
d  = 1010
q1 = 0000
q2 = 0000
```

### Blocking version

```text
q1 = d
```

gives:

```text
q1 = 1010
```

Then:

```text
q2 = q1
```

uses the new `q1`:

```text
q2 = 1010
```

### Nonblocking version

```text
q1 <= d
q2 <= q1
```

uses old values for RHS evaluation:

```text
q1 ← 1010
q2 ← 0000
```

Therefore:

```text
Blocking:
q1 = 1010
q2 = 1010

Nonblocking:
q1 = 1010
q2 = 0000
```

This experiment is extremely important.

---

# 31. Nonblocking Assignment and Race Conditions

One major reason nonblocking assignment is preferred for clocked RTL is to reduce simulation-order dependencies between separate clocked processes.

Example:

```verilog
always @(posedge clk)
    q1 <= d;

always @(posedge clk)
    q2 <= q1;
```

Both blocks respond to the same clock edge.

With nonblocking assignments, the old state is used consistently for RHS evaluation.

This gives predictable register-to-register behavior.

---

# 32. Multiple Nonblocking Assignments

Consider:

```verilog
always @(posedge clk) begin
    a <= b;
    b <= c;
    c <= d;
end
```

All RHS expressions are evaluated based on the pre-clock state.

So conceptually:

```text
new a = old b
new b = old c
new c = old d
```

This is exactly what you expect from a chain of flip-flops.

---

# 33. Shift Register Example

Consider:

```verilog
always @(posedge clk) begin
    q[3] <= q[2];
    q[2] <= q[1];
    q[1] <= q[0];
    q[0] <= serial_in;
end
```

Because all assignments are nonblocking:

```text
new q3 = old q2
new q2 = old q1
new q1 = old q0
new q0 = serial_in
```

This correctly models a shift register.

---

# 34. Counter Example

```verilog
always @(posedge clk) begin
    count <= count + 1'b1;
end
```

Suppose:

```text
count = 5
```

At the clock:

```text
RHS = 5 + 1 = 6
```

Then:

```text
count ← 6
```

Next clock:

```text
RHS = 6 + 1 = 7
```

So:

```text
5 → 6 → 7 → 8 → ...
```

---

# 35. Nonblocking Assignment Does Not Mean "No Delay"

This is an important misconception.

Writing:

```verilog
q <= d;
```

does not mean that the hardware has some fixed physical delay inserted.

The `<=` operator specifies **simulation scheduling semantics**.

Synthesis interprets the behavior and creates the corresponding hardware.

---

# 36. Nonblocking Assignment Does Not Mean "Always Sequential"

The operator itself does not magically create a flip-flop.

The surrounding procedural structure matters.

For example, the standard and intended use is:

```verilog
always @(posedge clk)
    q <= d;
```

which describes a flip-flop.

The hardware is determined by the complete RTL behavior, not just by seeing `<=`.

---

# 37. Common Mistakes

## Mistake 1 — Using `=` for a pipeline

Avoid:

```verilog
always @(posedge clk) begin
    q1 = d;
    q2 = q1;
end
```

when the intent is two independent register stages.

Use:

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
end
```

---

## Mistake 2 — Thinking `<=` means less-than-or-equal

Inside Verilog procedural assignment:

```verilog
q <= d;
```

is the **nonblocking assignment operator**.

It is not the relational operator.

---

## Mistake 3 — Mixing styles without understanding scheduling

For example:

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 = q1;
end
```

Mixing blocking and nonblocking assignments in the same clocked block can make reasoning difficult and can introduce simulation-order issues.

For ordinary sequential RTL, keep the clocked state updates consistently nonblocking.

---

# 38. Placement Interview Questions

### Q1. What is nonblocking assignment?

A procedural assignment using `<=` where the RHS is evaluated when the statement executes and the LHS update is scheduled for later in the current simulation time step.

### Q2. Which operator represents nonblocking assignment?

```verilog
<=
```

### Q3. Where is nonblocking assignment commonly used?

Clocked sequential RTL.

### Q4. Why use nonblocking for flip-flops?

It models simultaneous state updates at a clock edge and prevents one register's update from immediately affecting another register's RHS evaluation in the same clock event.

### Q5. What is the recommended assignment for combinational logic?

```verilog
=
```

### Q6. What is the recommended assignment for clocked sequential logic?

```verilog
<=
```

### Q7. What is the difference between:

```verilog
q1 = d;
q2 = q1;
```

and:

```verilog
q1 <= d;
q2 <= q1;
```

The blocking version allows `q2` to see the updated `q1` during procedural execution. The nonblocking version makes both RHS evaluations use the pre-update values.

### Q8. What does a two-stage pipeline look like?

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
end
```

### Q9. What is a race condition?

A situation where simulation behavior depends on the relative ordering of events/processes, potentially producing unintended or nondeterministic results.

### Q10. Does `<=` physically create a delay?

No. It specifies Verilog simulation scheduling semantics; synthesis determines the hardware.

---

# 39. Important Interview Problem

Initial:

```text
A = 0
B = 1
```

Code:

```verilog
always @(posedge clk) begin
    A <= B;
    B <= A;
end
```

After the first clock:

```text
A = 1
B = 0
```

After the second clock:

```text
A = 0
B = 1
```

Therefore the values swap every clock.

This is a classic nonblocking-assignment interview question.

---

# 40. Another Interview Problem

Initial:

```text
q1 = 0
q2 = 0
d  = 1
```

Code:

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
end
```

After first clock:

```text
q1 = 1
q2 = 0
```

After second clock, assuming `d` remains `1`:

```text
q1 = 1
q2 = 1
```

Therefore:

$$
\boxed{\text{Data takes two register stages to reach }q2}
$$

---

# 41. Practice Problems

## Practice 1 — Three-Stage Pipeline

Implement:

```text
D → Q1 → Q2 → Q3
```

using nonblocking assignments.

Expected:

```verilog
always @(posedge clk) begin
    q1 <= d;
    q2 <= q1;
    q3 <= q2;
end
```

---

## Practice 2 — 4-bit Register

Implement a 4-bit register with:

* clock
* enable
* synchronous reset

Use nonblocking assignment.

---

## Practice 3 — Shift Register

Implement a 4-bit shift register:

```text
serial_in → Q0 → Q1 → Q2 → Q3
```

Use nonblocking assignments.

---

## Practice 4 — Counter

Implement a 4-bit up counter:

```text
0 → 1 → 2 → ... → 15 → 0
```

using:

```verilog
<=
```

---

## Practice 5 — Swap Registers

Implement:

```text
A ↔ B
```

on every rising clock edge.

Use:

```verilog
always @(posedge clk) begin
    a <= b;
    b <= a;
end
```

Explain why this works correctly with nonblocking assignments.

---

# 42. Day 16 Golden Rules

### Rule 1

```text
Combinational procedural logic
        ↓
       =
```

### Rule 2

```text
Clocked sequential logic
        ↓
       <=
```

### Rule 3

With:

```verilog
q1 <= d;
q2 <= q1;
```

think:

```text
new q1 = old d
new q2 = old q1
```

### Rule 4

For:

```verilog
a <= b;
b <= a;
```

think:

```text
new a = old b
new b = old a
```

### Rule 5

Nonblocking assignment models simultaneous state updates much more naturally than blocking assignment for clocked RTL.

---

# 43. Day 16 Checklist

Before moving to Day 17:

* [ ] Understand `<=`
* [ ] Understand RHS evaluation
* [ ] Understand scheduled LHS update
* [ ] Understand why `<=` is used for sequential RTL
* [ ] Know blocking vs nonblocking
* [ ] Understand two-stage pipeline behavior
* [ ] Implement a DFF using `<=`
* [ ] Implement a register using `<=`
* [ ] Implement a counter using `<=`
* [ ] Implement a shift register using `<=`
* [ ] Understand race-condition concerns
* [ ] Run the pipeline simulation
* [ ] View `D → Q1 → Q2` in GTKWave
* [ ] Solve the swap-register interview problem

---

# 44. Day 16 Final Interview Answer

If the interviewer asks:

**"Why do we use nonblocking assignment in sequential logic?"**

Answer:

> **Nonblocking assignment `<=` evaluates the right-hand sides using the pre-update values and schedules the left-hand-side updates for later in the same simulation time step. This models the simultaneous behavior of flip-flops at a clock edge and prevents one register's update from immediately affecting another register's calculation in the same clock event. Therefore it is the standard choice for clocked sequential RTL.**

## One-line memory rule

$$
\boxed{\text{Combinational → blocking }(=)}
$$

$$
\boxed{\text{Sequential → nonblocking }(\leq)}
$$

**Day 16 complete.**

Next: **Day 17 — `if/else` in Verilog RTL.**
