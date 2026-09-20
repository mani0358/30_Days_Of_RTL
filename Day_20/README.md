# Day 20 — Asynchronous Reset in Verilog RTL

## 1. Day 20 Objective

Today you will learn:

* What reset means in sequential logic
* Why reset is required
* Asynchronous reset
* `posedge reset`
* Active-high asynchronous reset
* Active-low asynchronous reset
* Sensitivity lists
* DFF with asynchronous reset
* Reset behavior independent of clock
* Reset assertion and deassertion
* Asynchronous reset vs normal DFF
* Testbench verification
* GTKWave observation
* Placement interview questions

---

# 2. What Is Reset?

A reset forces a sequential circuit into a known state.

For example, a flip-flop may normally store:

```text
Q = D
```

at a clock edge.

With reset:

```text
reset = 1
    ↓
Q = 0
```

The purpose is to make sure the circuit starts from a known state.

---

# 3. Why Is Reset Important?

Without reset, a register may start with an unknown value in simulation.

For example:

```verilog
reg [3:0] count;
```

Initially:

```text
count = XXXX
```

If the circuit depends on this register, the unknown value can propagate through the design.

Reset gives:

```text
count = 0000
```

or whatever known state is required.

---

# 4. What Is an Asynchronous Reset?

An asynchronous reset can change the flip-flop output **without waiting for the clock edge**.

Consider:

```text
reset = 1
```

The flip-flop is immediately forced into its reset state.

It does not matter whether:

```text
clk = 0
```

or:

```text
clk = 1
```

at the instant reset is asserted.

Conceptually:

```text
              ┌─────────┐
D ───────────►│         │
CLK ─────────►│   DFF   ├──► Q
RESET ───────►│         │
              └─────────┘
```

The reset has direct control over the storage element.

---

# 5. Synchronous vs Asynchronous Reset

This distinction is extremely important.

## Synchronous reset

Reset is checked only at the active clock edge.

```verilog
always @(posedge clk) begin

    if (reset)
        q <= 1'b0;
    else
        q <= d;

end
```

If reset changes between clock edges, `q` does not immediately change.

---

## Asynchronous reset

Reset is included in the sensitivity list.

```verilog
always @(posedge clk or posedge reset) begin

    if (reset)
        q <= 1'b0;
    else
        q <= d;

end
```

Now reset can immediately affect `q`.

---

# 6. Key Difference

### Synchronous reset

```text
reset changes
     ↓
wait for clock edge
     ↓
Q changes
```

### Asynchronous reset

```text
reset changes
     ↓
Q changes immediately
```

This is the central concept of Day 20.

---

# 7. Active-High Asynchronous Reset

An active-high reset means:

```text
reset = 1 → reset is active
reset = 0 → normal operation
```

Typical RTL:

```verilog
always @(posedge clk or posedge reset) begin

    if (reset)
        q <= 1'b0;
    else
        q <= d;

end
```

The important part is:

```verilog
posedge reset
```

---

# 8. Why `posedge reset`?

The sensitivity list is:

```verilog
@(posedge clk or posedge reset)
```

This means the procedural block executes when either:

```text
1. clk changes 0 → 1
```

or:

```text
2. reset changes 0 → 1
```

Therefore:

```text
clock rising edge → normal DFF operation
reset rising edge → immediate reset
```

---

# 9. DFF With Asynchronous Reset

The basic circuit:

```verilog
module dff_async_reset (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);

    always @(posedge clk or posedge reset) begin

        if (reset)
            q <= 1'b0;
        else
            q <= d;

    end

endmodule
```

This is one of the most important RTL templates to memorize.

---

# 10. Behavioral Table

For an active-high asynchronous reset:

| Reset | Clock   |  D | Q behavior    |
| ----: | ------- | -: | ------------- |
|     1 | X       |  X | 0 immediately |
|     0 | ↑       |  0 | 0             |
|     0 | ↑       |  1 | 1             |
|     0 | no edge |  X | Hold          |

The `X` for clock when reset is active means the clock is irrelevant to the reset action.

---

# 11. Important Observation

Suppose:

```text
D = 1
Q = 0
CLK = 0
RESET = 0
```

Now:

```text
RESET: 0 → 1
```

Immediately:

```text
Q = 0
```

No clock edge is required.

Now:

```text
RESET: 1 → 0
```

Does Q immediately become D?

**No.**

After reset is released, the flip-flop returns to normal operation, and Q updates on the next active clock edge.

This distinction is extremely important.

---

# 12. Reset Assertion vs Reset Deassertion

### Reset assertion

For active-high reset:

```text
reset: 0 → 1
```

The flip-flop is immediately reset.

### Reset deassertion

```text
reset: 1 → 0
```

The reset is released.

The flip-flop normally waits for the next clock edge to capture D.

So:

```text
Assertion:
immediate

Deassertion:
normal clocked operation resumes
```

---

# 13. Timing Example

Consider:

```text
D = 1
```

Initially:

```text
reset = 1
Q = 0
```

Then:

```text
reset = 0
```

but no clock edge occurs.

Therefore:

```text
Q = 0
```

Then at the next:

```text
posedge clk
```

the flip-flop captures:

```text
D = 1
```

and:

```text
Q = 1
```

---

# 14. Asynchronous Reset Waveform Concept

```text
CLK
    ↑       ↑       ↑       ↑
____|_______|_______|_______|____

RESET
___________|‾‾‾‾‾‾‾|____________

Q
???????????|_______|____1_______
            reset
```

When reset goes high:

```text
Q → 0
```

without waiting for the next clock edge.

---

# 15. Day 20 Assignment — DFF With Asynchronous Reset

Create:

```text
Day_20/rtl/dff_async_reset.v
```

```verilog
module dff_async_reset (
    input  wire clk,
    input  wire reset,
    input  wire d,
    output reg  q
);

    always @(posedge clk or posedge reset) begin

        if (reset)
            q <= 1'b0;
        else
            q <= d;

    end

endmodule
```

---

# 16. Testbench

Create:

```text
Day_20/tb/tb_dff_async_reset.v
```

```verilog
`timescale 1ns/1ps

module tb_dff_async_reset;

    reg clk;
    reg reset;
    reg d;

    wire q;

    dff_async_reset dut (
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/dff_async_reset.vcd");
        $dumpvars(0, tb_dff_async_reset);

        clk   = 1'b0;
        reset = 1'b1;
        d     = 1'b0;

        // Reset active
        #7;

        // Release reset
        reset = 1'b0;

        // D = 1
        d = 1'b1;

        #8;

        // D = 0
        d = 1'b0;

        #10;

        // Assert reset asynchronously
        reset = 1'b1;

        #3;

        // Release reset
        reset = 1'b0;

        d = 1'b1;

        #10;

        $finish;

    end

endmodule
```

---

# 17. Create Day 20 Directory

On Ubuntu:

```bash
mkdir -p ~/Verilog_50_Days/Day_20/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_20
```

Your structure should be:

```text
Day_20/
├── README.md
├── rtl/
│   └── dff_async_reset.v
├── tb/
│   └── tb_dff_async_reset.v
├── sim/
└── wave/
```

---

# 18. Compile

Run:

```bash
iverilog -o sim/day20 \
rtl/dff_async_reset.v \
tb/tb_dff_async_reset.v
```

If compilation succeeds:

```bash
vvp sim/day20
```

This testbench does not print PASS/FAIL because the primary goal is to observe the timing behavior.

---

# 19. Open GTKWave

Run:

```bash
gtkwave sim/dff_async_reset.vcd
```

Add:

```text
clk
reset
d
q
```

The most important waveform event is the asynchronous reset assertion.

---

# 20. What You Should Observe

Suppose:

```text
reset = 0
d = 1
```

At a rising clock edge:

```text
Q → 1
```

Now suppose:

```text
clk = 0
d = 1
q = 1
```

and:

```text
reset: 0 → 1
```

Immediately:

```text
q → 0
```

even though:

```text
clk did NOT rise
```

This proves that the reset is asynchronous.

---

# 21. The Most Important Experiment

This experiment is extremely important for your understanding.

Set:

```text
clk = 0
reset = 0
d = 1
```

Then:

```text
reset = 1
```

Observe:

```text
q = 0
```

without a clock edge.

Now:

```text
reset = 0
```

Observe that Q remains:

```text
q = 0
```

until:

```text
posedge clk
```

Then:

```text
q = 1
```

---

# 22. Active-Low Asynchronous Reset

Sometimes reset is active-low.

For example:

```text
reset_n
```

where:

```text
reset_n = 0 → reset active
reset_n = 1 → normal operation
```

The RTL becomes:

```verilog
module dff_async_reset_n (
    input  wire clk,
    input  wire reset_n,
    input  wire d,
    output reg  q
);

    always @(posedge clk or negedge reset_n) begin

        if (!reset_n)
            q <= 1'b0;
        else
            q <= d;

    end

endmodule
```

Notice:

```text
active-high:
posedge reset

active-low:
negedge reset_n
```

---

# 23. Active-High vs Active-Low

| Reset type  | Active state | Sensitivity       |
| ----------- | -----------: | ----------------- |
| Active-high |            1 | `posedge reset`   |
| Active-low  |            0 | `negedge reset_n` |

Common naming convention:

```text
reset
rst
reset_n
rst_n
```

The `_n` suffix commonly indicates active-low.

---

# 24. 4-bit Register With Async Reset

The same concept applies to multiple flip-flops.

```verilog
module register_4bit_async_reset (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] d,
    output reg  [3:0] q
);

    always @(posedge clk or posedge reset) begin

        if (reset)
            q <= 4'b0000;
        else
            q <= d;

    end

endmodule
```

Hardware conceptually represents:

```text
4 DFFs
+
common asynchronous reset
```

---

# 25. Counter With Asynchronous Reset

A very common real RTL pattern:

```verilog
module counter_4bit_async_reset (
    input  wire       clk,
    input  wire       reset,
    output reg  [3:0] count
);

    always @(posedge clk or posedge reset) begin

        if (reset)
            count <= 4'b0000;
        else
            count <= count + 1'b1;

    end

endmodule
```

Behavior:

```text
reset = 1
    ↓
count = 0000 immediately

reset = 0
    ↓
normal operation

each rising clock
    ↓
count = count + 1
```

---

# 26. Why `<=`?

This is sequential logic.

Therefore:

```verilog
count <= count + 1'b1;
```

is used.

Remember Day 16:

```text
Clocked sequential logic
        ↓
nonblocking assignment
        ↓
<=
```

---

# 27. Multiple Registers With One Async Reset

Example:

```verilog
always @(posedge clk or posedge reset) begin

    if (reset) begin
        q1 <= 4'b0000;
        q2 <= 4'b0000;
        q3 <= 4'b0000;
    end
    else begin
        q1 <= d1;
        q2 <= d2;
        q3 <= d3;
    end

end
```

All three registers are reset asynchronously.

---

# 28. Why Reset Is Placed First

Correct pattern:

```verilog
always @(posedge clk or posedge reset) begin

    if (reset)
        q <= 0;
    else
        q <= d;

end
```

The priority is:

```text
RESET
  ↓
CLOCK
```

If reset is active, reset behavior wins.

Conceptually:

```text
if reset:
    reset Q
else:
    process clocked data
```

---

# 29. Common Mistake

Incorrect:

```verilog
always @(posedge clk) begin

    if (reset)
        q <= 0;
    else
        q <= d;

end
```

This is **synchronous reset**, not asynchronous reset.

Why?

Because the sensitivity list contains only:

```text
posedge clk
```

Reset cannot trigger the block.

---

# 30. Correct Asynchronous Version

```verilog
always @(posedge clk or posedge reset) begin

    if (reset)
        q <= 0;
    else
        q <= d;

end
```

The critical difference is:

```text
+ posedge reset
```

---

# 31. Another Common Mistake

Do not write:

```verilog
always @(posedge clk or reset)
```

for a normal edge-triggered asynchronous reset.

The reset event should normally be represented by its active transition:

```verilog
posedge reset
```

for active-high reset.

Or:

```verilog
negedge reset_n
```

for active-low reset.

---

# 32. Asynchronous Reset Timing

Consider:

```text
CLK       ↑       ↑       ↑
          |       |       |
RESET ____|‾‾‾‾‾‾|________
```

When reset asserts between clock edges:

```text
RESET ↑
```

the Q output can reset immediately.

This is the defining property of asynchronous reset.

---

# 33. Reset Deassertion

Reset deassertion is different from assertion.

For:

```text
reset = 1
```

the circuit is held in reset.

When:

```text
reset: 1 → 0
```

normal operation is enabled again.

But Q does not automatically capture D at that instant.

It waits for:

```text
posedge clk
```

---

# 34. Why Reset Release Matters

In physical designs, reset deassertion must be handled carefully because different flip-flops may not see the exact same physical reset timing.

This can lead to reset-release timing concerns.

At RTL level, the important concept for today is:

```text
assertion → asynchronous
deassertion → normal clocked behavior
```

Detailed reset synchronization techniques come later when discussing robust RTL/design methodology.

---

# 35. Asynchronous Reset vs Initialization

Do not confuse:

```verilog
initial
```

with:

```verilog
reset
```

An `initial` block is a simulation initialization mechanism.

An asynchronous reset is an explicit hardware control signal in the RTL description.

For example:

```verilog
initial
    q = 0;
```

is fundamentally different from:

```verilog
always @(posedge clk or posedge reset)
```

with:

```verilog
if (reset)
    q <= 0;
```

---

# 36. Day 20 Practical Verification Table

For:

```verilog
always @(posedge clk or posedge reset)
```

verify these cases:

| Reset | Clock event |      D | Expected Q |
| ----: | ----------- | -----: | ---------: |
|     1 | none        |      X |          0 |
|     1 | ↑           |      X |          0 |
|     0 | ↑           |      0 |          0 |
|     0 | ↑           |      1 |          1 |
|     0 | no edge     | change |       Hold |
|     0 | no edge     |   same |       Hold |

The most important row is:

```text
reset = 1
clock = no edge
Q = 0
```

That proves asynchronous behavior.

---

# 37. Placement Interview Questions

### Q1. What is an asynchronous reset?

A reset that can force a sequential element into its reset state independently of the clock.

### Q2. How do you code an active-high asynchronous reset?

```verilog
always @(posedge clk or posedge reset)
```

with:

```verilog
if (reset)
    q <= 0;
```

### Q3. How do you code an active-low asynchronous reset?

```verilog
always @(posedge clk or negedge reset_n)
```

with:

```verilog
if (!reset_n)
    q <= 0;
```

### Q4. What is the difference between synchronous and asynchronous reset?

Synchronous reset is sampled at the clock edge; asynchronous reset can affect the register independently of the clock.

### Q5. Does asynchronous reset assertion require a clock?

No.

### Q6. Does reset deassertion immediately load D?

Normally no. After reset is released, the register captures D on the next active clock edge.

### Q7. Why is `<=` used?

Because the reset-controlled flip-flop is sequential logic.

### Q8. What does `posedge reset` mean?

It means the block is triggered when reset transitions:

```text
0 → 1
```

### Q9. What does `negedge reset_n` mean?

It means the block is triggered when the active-low reset transitions:

```text
1 → 0
```

### Q10. Can an asynchronous reset be used for a counter?

Yes.

Example:

```verilog
always @(posedge clk or posedge reset)
```

### Q11. What happens if reset and clock change at approximately the same physical time?

Reset/clock interaction is a timing-sensitive issue in real hardware. At RTL, the reset branch has priority when the reset event activates the block.

### Q12. What is the main disadvantage of asynchronous reset?

Although it can reset storage elements immediately, reset distribution and especially reset release require careful physical/timing treatment in real designs.

---

# 38. Day 20 Practice Problems

## Practice 1 — Async DFF

Implement:

```text
DFF
+
active-high asynchronous reset
```

Verify that Q resets without a clock edge.

---

## Practice 2 — Async Counter

Implement a:

```text
4-bit up counter
```

with:

```text
active-high asynchronous reset
```

Sequence after reset:

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

## Practice 3 — Async Register

Create an 8-bit register:

```text
reset = 1 → 00000000
reset = 0 → capture D on rising clock
```

---

## Practice 4 — Active-Low Reset

Rewrite the DFF using:

```text
reset_n
```

and verify:

```text
reset_n = 0 → Q = 0
reset_n = 1 → normal operation
```

---

# 39. Day 20 Final Assignment

Implement:

## 4-bit Counter With Asynchronous Reset

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
    ↓
count = 0000 immediately
```

Then:

```text
reset = 0
```

At every:

```text
posedge clk
```

increment:

```text
count <= count + 1
```

RTL template:

```verilog
always @(posedge clk or posedge reset) begin

    if (reset)
        count <= 4'b0000;
    else
        count <= count + 1'b1;

end
```

Verify:

```text
1. Reset assertion without clock
2. Reset release
3. Normal counting
4. Roll-over from 1111 to 0000
5. Reset during counting
```

---

# 40. Day 20 Golden Rules

```text
Synchronous reset
    ↓
reset checked at clock edge
```

```text
Asynchronous reset
    ↓
reset can act without clock edge
```

Active-high:

```verilog
@(posedge clk or posedge reset)
```

Active-low:

```verilog
@(posedge clk or negedge reset_n)
```

Sequential assignment:

```verilog
<=
```

Most important template:

```verilog
always @(posedge clk or posedge reset) begin

    if (reset)
        q <= 1'b0;
    else
        q <= d;

end
```

---

# 41. Day 20 Checklist

Before moving to Day 21, you should be able to explain:

* [ ] Why reset is required
* [ ] What asynchronous reset means
* [ ] Synchronous vs asynchronous reset
* [ ] Active-high reset
* [ ] Active-low reset
* [ ] `posedge reset`
* [ ] `negedge reset_n`
* [ ] DFF with asynchronous reset
* [ ] Asynchronous reset assertion
* [ ] Reset deassertion
* [ ] Why Q does not immediately capture D after reset release
* [ ] Async-reset counter
* [ ] Async-reset register
* [ ] Why `<=` is used
* [ ] How to verify asynchronous reset in GTKWave
* [ ] Common reset-coding mistakes

---

# 42. Placement Memory Trick

Memorize this:

```text
                 RESET
                   |
                   v
            +-------------+
D ---------->     DFF      |----> Q
            |             |
CLK -------->             |
            +-------------+
```

### Synchronous

```verilog
@(posedge clk)
```

### Asynchronous active-high

```verilog
@(posedge clk or posedge reset)
```

### Asynchronous active-low

```verilog
@(posedge clk or negedge reset_n)
```

And always remember:

```text
RESET ASSERTION
      ↓
does NOT need clock

RESET RELEASE
      ↓
normal operation resumes
      ↓
next active clock captures D
```
