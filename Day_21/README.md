# Day 21 — Synchronous Reset in Verilog RTL

## 1. Day 21 Objective

Today you will learn:

* What synchronous reset is
* How synchronous reset differs from asynchronous reset
* How to code a synchronous-reset DFF
* Reset behavior with respect to the clock
* Active-high synchronous reset
* Active-low synchronous reset
* Synchronous-reset registers
* Synchronous-reset counters
* Testbench verification
* Waveform analysis in GTKWave
* Common coding mistakes
* Placement interview questions

The most important concept today is:

> **A synchronous reset only affects the sequential element at the active clock edge.**

---

# 2. Quick Revision — Day 20

Yesterday we studied asynchronous reset.

The basic asynchronous-reset DFF was:

```verilog
always @(posedge clk or posedge reset) begin
    if (reset)
        q <= 1'b0;
    else
        q <= d;
end
```

The important part was:

```verilog
posedge reset
```

Therefore reset itself could trigger the `always` block.

---

# 3. What Is Synchronous Reset?

A synchronous reset is a reset that is checked **only at the active clock edge**.

For a positive-edge-triggered DFF:

```verilog
always @(posedge clk) begin
    if (reset)
        q <= 1'b0;
    else
        q <= d;
end
```

Notice:

```text
Only clk is in the sensitivity list.
```

There is no:

```verilog
or posedge reset
```

Therefore changing reset by itself does not immediately change Q.

---

# 4. Fundamental Difference

### Asynchronous reset

```verilog
always @(posedge clk or posedge reset)
```

### Synchronous reset

```verilog
always @(posedge clk)
```

This one-line difference is extremely important.

---

# 5. Synchronous Reset Operation

Consider:

```text
reset = 1
```

but:

```text
clk = 0
```

For synchronous reset:

```text
Q does NOT immediately change.
```

The circuit waits for:

```text
posedge clk
```

At the rising edge:

```text
reset = 1
```

so:

```text
Q = 0
```

---

# 6. Timing Concept

Suppose:

```text
CLK

____/‾‾\____/‾‾\____/‾‾\____


RESET

________‾‾‾‾‾‾‾‾‾________


Q

___________0______________
```

When reset goes high between clock edges:

```text
Q does not necessarily change immediately.
```

At the next rising clock edge:

```text
Q → 0
```

This is what makes the reset synchronous.

---

# 7. Synchronous DFF

The basic RTL is:

```verilog
module dff_sync_reset (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin
        if (reset)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule
```

Memorize this structure.

---

# 8. Synchronous Reset Truth Table

For a positive-edge-triggered DFF:

| Reset | Clock   |  D | Q after active edge |
| ----: | ------- | -: | ------------------: |
|     0 | ↑       |  0 |                   0 |
|     0 | ↑       |  1 |                   1 |
|     1 | ↑       |  0 |                   0 |
|     1 | ↑       |  1 |                   0 |
|     0 | no edge |  X |                Hold |
|     1 | no edge |  X |                Hold |

The key point:

```text
Reset = 1
+
No clock edge
=
Q does not change
```

---

# 9. Compare With Asynchronous Reset

## Asynchronous

```verilog
always @(posedge clk or posedge reset)
```

If:

```text
reset: 0 → 1
```

then:

```text
Q → 0
```

without waiting for a clock.

---

## Synchronous

```verilog
always @(posedge clk)
```

If:

```text
reset: 0 → 1
```

then:

```text
Q remains unchanged
```

until:

```text
posedge clk
```

---

# 10. Side-by-Side Comparison

| Feature                 | Synchronous Reset | Asynchronous Reset                |
| ----------------------- | ----------------- | --------------------------------- |
| Reset sensitivity       | Clock only        | Clock + reset                     |
| Reset acts immediately? | No                | Yes                               |
| Requires clock edge?    | Yes               | No for assertion                  |
| RTL                     | `@(posedge clk)`  | `@(posedge clk or posedge reset)` |
| Reset checked           | At clock edge     | Whenever reset asserts            |
| Typical assignment      | `<=`              | `<=`                              |

---

# 11. Active-High Synchronous Reset

Active-high means:

```text
reset = 1 → reset active
reset = 0 → normal operation
```

RTL:

```verilog
always @(posedge clk) begin

    if (reset)
        q <= 1'b0;
    else
        q <= d;

end
```

---

# 12. Why Is It Called Synchronous?

Because the reset operation is synchronized with the clock.

Suppose:

```text
reset = 1
```

At:

```text
clk = 0
```

nothing happens.

At:

```text
posedge clk
```

the reset is sampled.

Then:

```text
Q = 0
```

So:

```text
RESET + CLOCK EDGE
        ↓
     RESET Q
```

---

# 13. Reset Deassertion

Suppose:

```text
reset = 1
```

and:

```text
Q = 0
```

Now:

```text
reset: 1 → 0
```

For a synchronous reset:

```text
Q remains unchanged.
```

At the next rising clock edge:

```text
Q captures D.
```

So both reset assertion and release are governed by the clock.

---

# 14. Example

Suppose:

```text
D = 1
Q = 0
reset = 1
```

Now reset changes:

```text
reset: 1 → 0
```

but there is no clock edge.

Then:

```text
Q = 0
```

Still.

Now:

```text
posedge clk
```

Since:

```text
reset = 0
D = 1
```

the result becomes:

```text
Q = 1
```

---

# 15. Main Practical — Synchronous Reset DFF

Create:

```text
~/Verilog_50_Days/Day_21/
```

with:

```text
Day_21/
├── rtl/
├── tb/
├── sim/
└── wave/
```

Run:

```bash
mkdir -p ~/Verilog_50_Days/Day_21/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_21
```

---

# 16. RTL

Create:

```text
rtl/dff_sync_reset.v
```

```verilog
module dff_sync_reset (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin

        if (reset)
            q <= 1'b0;
        else
            q <= d;

    end

endmodule
```

---

# 17. Testbench

Create:

```text
tb/tb_dff_sync_reset.v
```

```verilog
`timescale 1ns/1ps

module tb_dff_sync_reset;

    reg clk;
    reg reset;
    reg d;

    wire q;

    dff_sync_reset dut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/dff_sync_reset.vcd");
        $dumpvars(0, tb_dff_sync_reset);

        clk   = 1'b0;
        reset = 1'b1;
        d     = 1'b0;

        // Reset is active.
        // It will take effect at the next rising edge.
        #7;

        // Release reset between clock edges.
        reset = 1'b0;
        d     = 1'b1;

        #6;

        // Change D.
        d = 1'b0;

        #8;

        // Assert reset between clock edges.
        reset = 1'b1;

        #3;

        // Reset is still active.
        d = 1'b1;

        #7;

        // Release reset.
        reset = 1'b0;

        #10;

        $finish;

    end

endmodule
```

---

# 18. Compile

Run:

```bash
iverilog -o sim/day21 \
rtl/dff_sync_reset.v \
tb/tb_dff_sync_reset.v
```

Then:

```bash
vvp sim/day21
```

Open the waveform:

```bash
gtkwave sim/dff_sync_reset.vcd
```

Add:

```text
clk
reset
d
q
```

---

# 19. What To Observe in GTKWave

Pay special attention when:

```text
reset
```

changes from:

```text
0 → 1
```

between clock edges.

You should see:

```text
reset = 1
```

but:

```text
q = previous value
```

until the next rising clock edge.

At:

```text
posedge clk
```

Q becomes:

```text
0
```

because reset is active.

---

# 20. Critical Experiment

This experiment distinguishes Day 20 and Day 21.

Set:

```text
D = 1
Q = 1
reset = 0
```

Now change:

```text
reset = 1
```

while:

```text
CLK = 0
```

### Synchronous reset

Q:

```text
1
```

remains unchanged until the next rising clock.

### Asynchronous reset

Q:

```text
1 → 0
```

immediately.

This is the most important Day 21 experiment.

---

# 21. Synchronous Reset Counter

Synchronous reset is also commonly used in counters.

```verilog
module counter_4bit_sync_reset (
    input  wire       clk,
    input  wire       reset,
    output reg [3:0]  count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b0000;
        else
            count <= count + 1'b1;

    end

endmodule
```

---

# 22. Counter Operation

When:

```text
reset = 1
```

the counter is reset at the next clock edge:

```text
0000
```

When:

```text
reset = 0
```

the counter increments:

```text
0000
0001
0010
0011
0100
...
1111
0000
```

---

# 23. Important Difference During Counting

Suppose:

```text
count = 0101
reset = 0
```

Then reset becomes:

```text
reset = 1
```

between clock edges.

For a synchronous reset:

```text
count = 0101
```

still.

At the next:

```text
posedge clk
```

then:

```text
count = 0000
```

---

# 24. 4-bit Register With Synchronous Reset

```verilog
module register_4bit_sync_reset (
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

The reset behavior is exactly the same concept as the single DFF.

---

# 25. Active-Low Synchronous Reset

An active-low synchronous reset uses:

```text
reset_n = 0
```

as the active state.

RTL:

```verilog
module dff_sync_reset_n (
    input  wire clk,
    input  wire reset_n,
    input  wire d,
    output reg  q
);

    always @(posedge clk) begin

        if (!reset_n)
            q <= 1'b0;
        else
            q <= d;

    end

endmodule
```

Notice something important:

There is **no**:

```verilog
negedge reset_n
```

because the reset is synchronous.

The sensitivity list is still:

```verilog
@(posedge clk)
```

---

# 26. Active-Low Comparison

### Synchronous active-low

```verilog
always @(posedge clk) begin
    if (!reset_n)
        q <= 0;
    else
        q <= d;
end
```

### Asynchronous active-low

```verilog
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        q <= 0;
    else
        q <= d;
end
```

The difference is:

```text
synchronous:
@(posedge clk)

asynchronous:
@(posedge clk or negedge reset_n)
```

---

# 27. Common Mistake #1

Do not write:

```verilog
always @(posedge clk or posedge reset)
```

if the requirement is a **synchronous** reset.

That describes asynchronous reset behavior.

Correct:

```verilog
always @(posedge clk)
```

---

# 28. Common Mistake #2

Do not write:

```verilog
always @(*) begin
    if (reset)
        q = 0;
end
```

for a synchronous-reset DFF.

That describes combinational behavior and is missing the clocked storage behavior.

---

# 29. Common Mistake #3 — Missing Else

For a combinational block, incomplete assignments can infer a latch.

For a clocked block, however:

```verilog
always @(posedge clk) begin
    if (reset)
        q <= 0;
end
```

means Q retains its value when reset is not active.

That is valid sequential behavior.

Do not confuse this with incomplete combinational logic.

---

# 30. Why `<=`?

The DFF is sequential logic.

Therefore:

```verilog
q <= d;
```

is the standard nonblocking assignment.

Similarly:

```verilog
q <= 0;
```

is used for reset.

Remember:

```text
Combinational procedural logic → =
Clocked sequential logic       → <=
```

---

# 31. Truth-Table Verification

For the synchronous-reset DFF, at a rising clock edge:

| Reset |  D | Q(next) |
| ----: | -: | ------: |
|     0 |  0 |       0 |
|     0 |  1 |       1 |
|     1 |  0 |       0 |
|     1 |  1 |       0 |

The Boolean relationship at the active clock edge is:

```text
Q(next) = 0    when reset = 1
Q(next) = D    when reset = 0
```

Equivalently:

```text
Q(next) = ~reset & D
```

But remember: this equation describes the **next-state decision at the clock edge**. The output Q itself is still stored in a flip-flop.

---

# 32. Synchronous Reset DFF as a Next-State Function

We can think of the DFF as:

```text
D ───────┐
         │
         ▼
      ┌───────┐
      │ MUX   │────► DFF ───► Q
      └───────┘
         ▲
         │
       reset
```

When:

```text
reset = 1
```

the DFF receives:

```text
0
```

When:

```text
reset = 0
```

the DFF receives:

```text
D
```

At the active clock edge, that selected value is stored.

---

# 33. Synchronous Reset in an FSM

Synchronous reset is frequently used in state machines.

Example:

```verilog
always @(posedge clk) begin

    if (reset)
        state <= IDLE;
    else
        state <= next_state;

end
```

This means:

```text
reset active
    ↓
wait for clock
    ↓
state = IDLE
```

This is an important pattern you will use when studying FSMs.

---

# 34. Synchronous Reset in a Pipeline

Example:

```verilog
always @(posedge clk) begin

    if (reset) begin
        q1 <= 0;
        q2 <= 0;
    end
    else begin
        q1 <= d;
        q2 <= q1;
    end

end
```

Both pipeline registers are reset at the clock edge.

---

# 35. Day 20 vs Day 21

This is the comparison you should memorize.

| Property                      | Day 20: Async               | Day 21: Sync                |
| ----------------------------- | --------------------------- | --------------------------- |
| Sensitivity                   | `clk + reset`               | `clk`                       |
| Reset assertion               | Immediate                   | At clock edge               |
| Clock needed to assert reset? | No                          | Yes                         |
| Reset release                 | Returns to normal operation | Returns to normal operation |
| Main RTL difference           | `or posedge reset`          | No reset edge               |
| Sequential assignment         | `<=`                        | `<=`                        |

---

# 36. Interview Scenario

### Question

You have:

```verilog
always @(posedge clk) begin
    if (reset)
        q <= 0;
    else
        q <= d;
end
```

If:

```text
reset = 1
```

and the clock does not change, what happens to Q?

### Answer

Q does not immediately change.

The reset is synchronous, so Q becomes `0` only at the next active clock edge.

---

# 37. Another Interview Scenario

### Question

What changes if we write:

```verilog
always @(posedge clk or posedge reset)
```

instead?

### Answer

The reset becomes asynchronous.

When reset transitions from `0` to `1`, the block executes immediately, independently of the clock.

---

# 38. Placement Interview Questions

### Q1. What is synchronous reset?

A reset whose effect on a sequential element occurs only at the active clock edge.

### Q2. What is the sensitivity list of a positive-edge DFF with synchronous reset?

```verilog
@(posedge clk)
```

### Q3. Does synchronous reset require a clock?

Yes.

### Q4. Can synchronous reset change Q between clock edges?

No.

### Q5. What is the main RTL difference between synchronous and asynchronous reset?

Asynchronous reset appears in the sensitivity list; synchronous reset does not.

### Q6. How do you code active-low synchronous reset?

```verilog
always @(posedge clk) begin
    if (!reset_n)
        q <= 0;
    else
        q <= d;
end
```

### Q7. Why use nonblocking assignment?

Because the target is sequential clocked logic.

### Q8. Can counters use synchronous reset?

Yes.

### Q9. Can FSMs use synchronous reset?

Yes.

### Q10. Can pipeline registers use synchronous reset?

Yes.

---

# 39. Day 21 Practice Problems

## Practice 1

Design a:

```text
8-bit register
```

with:

```text
clk
synchronous reset
enable
data[7:0]
```

Priority:

```text
reset > enable > hold
```

---

## Practice 2

Design a:

```text
4-bit synchronous-reset down counter
```

Sequence:

```text
1111
1110
1101
...
0000
1111
```

---

## Practice 3

Design a:

```text
4-bit register
```

with active-low synchronous reset:

```text
reset_n = 0 → clear at next clock
reset_n = 1 → normal operation
```

---

## Practice 4

Take your Day 20 asynchronous-reset DFF and Day 21 synchronous-reset DFF.

Use exactly the same input sequence and compare both waveforms in GTKWave.

Identify the moment when:

```text
reset = 1
```

between two clock edges.

Explain why Q behaves differently.

---

# 40. Day 21 Final Assignment

Implement:

## 4-bit Synchronous Reset Up Counter

Inputs:

```text
clk
reset
```

Output:

```text
count[3:0]
```

Requirements:

```text
reset = 1
```

must cause:

```text
count = 0000
```

at the **next rising edge of clk**.

When:

```text
reset = 0
```

the counter increments every rising edge.

RTL:

```verilog
module counter_4bit_sync_reset (
    input  wire      clk,
    input  wire      reset,
    output reg [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b0000;
        else
            count <= count + 1'b1;

    end

endmodule
```

---

# 41. Verification Requirements

Your testbench must verify:

```text
1. Initial reset
2. Reset assertion between clock edges
3. Reset remains active
4. Reset release between clock edges
5. Counting
6. Reset during counting
7. Reset taking effect only at the next rising edge
8. Counter rollover
```

The most important check:

```text
reset changes
       ↓
NO clock edge
       ↓
count must NOT reset immediately
```

Then:

```text
posedge clk
       ↓
count resets to 0000
```

---

# 42. Golden Rule

Memorize:

```text
SYNCHRONOUS RESET

always @(posedge clk)
begin
    if (reset)
        q <= 0;
    else
        q <= d;
end
```

Versus:

```text
ASYNCHRONOUS RESET

always @(posedge clk or posedge reset)
begin
    if (reset)
        q <= 0;
    else
        q <= d;
end
```

The easiest placement trick:

> **If reset is in the sensitivity list, it is asynchronous. If only the clock is in the sensitivity list, the reset is synchronous.**

---

# 43. Day 21 Checklist

Before moving ahead, you should be able to explain:

* [ ] What synchronous reset means
* [ ] Why synchronous reset needs a clock edge
* [ ] Active-high synchronous reset
* [ ] Active-low synchronous reset
* [ ] Synchronous-reset DFF
* [ ] Synchronous-reset register
* [ ] Synchronous-reset counter
* [ ] Synchronous reset in an FSM
* [ ] Synchronous reset in a pipeline
* [ ] Difference between synchronous and asynchronous reset
* [ ] Why reset is absent from the sensitivity list
* [ ] Why `<=` is used
* [ ] How to verify the difference in GTKWave
* [ ] Common synchronous-reset coding mistakes

---

# 44. One-Line Placement Summary

```text
ASYNC RESET:
@(posedge clk or posedge reset)
→ reset can act without clock

SYNC RESET:
@(posedge clk)
→ reset acts only at clock edge
```

**Day 20 = Asynchronous Reset**

**Day 21 = Synchronous Reset**

**Day 22 = Asynchronous vs Synchronous Counters**
