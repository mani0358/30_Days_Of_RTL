# Day 22 — Asynchronous vs Synchronous Counters

## 1. Day 22 Objective

Today you will learn:

* What a counter is
* Up counter and down counter
* Asynchronous/ripple counter
* Synchronous counter
* Difference between ripple and synchronous counters
* Clock propagation through flip-flops
* Counter timing
* RTL implementation
* Reset in counters
* Testbench verification
* Why synchronous counters are faster
* Placement interview questions

---

# 2. What Is a Counter?

A counter is a sequential circuit that moves through a predefined sequence of states according to clock pulses.

For a 4-bit binary up counter:

```text
0000
0001
0010
0011
0100
0101
0110
0111
1000
1001
1010
1011
1100
1101
1110
1111
0000
...
```

Each clock event advances the count.

---

# 3. Up Counter

An up counter increments its value.

For a 3-bit counter:

```text
000
001
010
011
100
101
110
111
000
...
```

Mathematically:

```text
count_next = count + 1
```

---

# 4. Down Counter

A down counter decrements its value.

For a 3-bit counter:

```text
111
110
101
100
011
010
001
000
111
...
```

Mathematically:

```text
count_next = count - 1
```

---

# 5. Why Do We Need Counters?

Counters are used in:

* Frequency division
* Timers
* Clock generation/control
* Event counting
* Address generation
* Digital clocks
* Communication systems
* Memory addressing
* FSM sequencing
* PWM
* Protocol timing

Counters are one of the most common sequential circuits in RTL design.

---

# 6. Two Important Counter Architectures

There are two fundamental architectures:

### 1. Asynchronous counter

Also called:

```text
Ripple counter
```

### 2. Synchronous counter

All flip-flops receive the same clock.

This distinction is extremely important for digital-design interviews.

---

# 7. Asynchronous / Ripple Counter

In an asynchronous counter, the first flip-flop receives the external clock.

The next flip-flop receives its clock from the output of the previous flip-flop.

Conceptually:

```text
        ┌─────┐
CLK ───►│ FF0 │──Q0──► CLK of FF1
        └─────┘          │
                         ▼
                     ┌─────┐
                     │ FF1 │──Q1──► CLK of FF2
                     └─────┘          │
                                      ▼
                                  ┌─────┐
                                  │ FF2 │
                                  └─────┘
```

Therefore the clock effectively **ripples** through the flip-flops.

---

# 8. Why Is It Called Ripple Counter?

Suppose the counter changes:

```text
0111 → 1000
```

Several bits must change.

The transitions occur sequentially because each flip-flop waits for the transition from the preceding stage.

Conceptually:

```text
Q0 changes
   ↓
Q1 changes
   ↓
Q2 changes
   ↓
Q3 changes
```

The transition propagates through the chain.

Hence:

```text
Ripple counter
```

---

# 9. Propagation Delay

Every real flip-flop has propagation delay.

Suppose:

```text
t_pd = propagation delay of one flip-flop
```

For four cascaded flip-flops, the worst-case ripple delay can be approximately related to:

```text
4 × t_pd
```

The exact timing depends on the implementation and what delay is being measured.

The important concept is:

> **The delay accumulates through the ripple chain.**

---

# 10. Problem With Ripple Counters

The main issue is speed.

Because one flip-flop's output drives the clock of the next flip-flop:

```text
FF0
 ↓
FF1
 ↓
FF2
 ↓
FF3
```

the final output cannot respond until the transition propagates through the chain.

This creates propagation delay.

---

# 11. Synchronous Counter

In a synchronous counter, all flip-flops receive the same clock.

Conceptually:

```text
                 ┌─────┐
CLK ────────────►│ FF0 │──Q0
      │          └─────┘
      │
      │          ┌─────┐
      ├─────────►│ FF1 │──Q1
      │          └─────┘
      │
      │          ┌─────┐
      ├─────────►│ FF2 │──Q2
      │          └─────┘
      │
      │          ┌─────┐
      └─────────►│ FF3 │──Q3
                 └─────┘
```

All flip-flops are triggered by the same clock edge.

---

# 12. How Does a Synchronous Counter Count?

The combinational logic determines which flip-flops should toggle.

For a binary up counter:

```text
Q0 toggles every clock
Q1 toggles when Q0 = 1
Q2 toggles when Q1Q0 = 11
Q3 toggles when Q2Q1Q0 = 111
```

Therefore:

```text
Q0_next = ~Q0
```

```text
Q1 toggles when Q0 = 1
```

```text
Q2 toggles when Q1Q0 = 11
```

```text
Q3 toggles when Q2Q1Q0 = 111
```

---

# 13. 4-bit Synchronous Up Counter Using T Flip-Flops

For T flip-flops:

```text
T = 0 → hold
T = 1 → toggle
```

Therefore:

```text
T0 = 1
```

```text
T1 = Q0
```

```text
T2 = Q0 & Q1
```

```text
T3 = Q0 & Q1 & Q2
```

All four flip-flops use the same clock.

---

# 14. Why Does This Work?

Consider:

```text
Q = 0000
```

At the next clock:

```text
T0 = 1
```

so Q0 toggles:

```text
0000 → 0001
```

Next:

```text
Q = 0001
```

Now:

```text
T0 = 1
T1 = Q0 = 1
```

so:

```text
0001 → 0010
```

Next:

```text
0010 → 0011
```

Then:

```text
0011 → 0100
```

and so on.

---

# 15. Synchronous Counter Using D Flip-Flops

The same counter can be designed with DFFs.

For a binary incrementer:

```text
D = Q + 1
```

So a simple RTL implementation is:

```verilog id="qjv7j2"
module sync_counter_4bit (
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

This describes a synchronous counter.

---

# 16. Why Is This a Synchronous Counter?

Look at the clock:

```verilog id="p9z4xq"
always @(posedge clk)
```

Only one clock is used.

There is no:

```verilog id="z4v7yr"
Q0 → clock of FF1
```

or:

```verilog id="7v2qhe"
Q1 → clock of FF2
```

All state updates happen with respect to the same `clk`.

---

# 17. Truth Table — 3-bit Up Counter

The state sequence is:

| Current State | Next State |
| ------------- | ---------- |
| 000           | 001        |
| 001           | 010        |
| 010           | 011        |
| 011           | 100        |
| 100           | 101        |
| 101           | 110        |
| 110           | 111        |
| 111           | 000        |

This is the state-transition behavior of a modulo-8 counter.

---

# 18. Modulus of a Counter

The modulus, or MOD number, is the number of unique states through which a counter cycles.

For an N-bit binary counter:

```text
MOD = 2^N
```

Examples:

```text
1-bit → MOD-2
2-bit → MOD-4
3-bit → MOD-8
4-bit → MOD-16
8-bit → MOD-256
```

For a 4-bit counter:

```text
0000 → 0001 → ... → 1111 → 0000
```

There are:

```text
16
```

states.

Therefore:

```text
MOD-16
```

---

# 19. Asynchronous Counter vs Synchronous Counter

| Feature           | Asynchronous/Ripple       | Synchronous              |
| ----------------- | ------------------------- | ------------------------ |
| Clock             | Cascaded                  | Common clock             |
| FF0 clock         | External clock            | Common clock             |
| FF1 clock         | Previous FF output        | Common clock             |
| FF2 clock         | Previous FF output        | Common clock             |
| Propagation       | Ripple                    | Parallel clocking        |
| Speed             | Lower                     | Generally higher         |
| Design complexity | Simple                    | More combinational logic |
| Timing            | Accumulated ripple delay  | More controlled          |
| Typical use       | Simple low-speed counters | High-speed RTL           |

---

# 20. Important Interview Point

Do not say:

> "Asynchronous counter has no clock."

That is incorrect.

An asynchronous counter **does have a clock**, but the flip-flops do not all receive the same external clock.

Instead:

```text
External CLK
    ↓
   FF0
    ↓
   FF1
    ↓
   FF2
    ↓
   FF3
```

The clocking ripples through the chain.

---

# 21. Ripple Counter Timing

Suppose:

```text
CLK = 0 → 1
```

FF0 responds.

After its propagation delay:

```text
Q0 changes
```

That transition can trigger FF1.

After another delay:

```text
Q1 changes
```

Then:

```text
Q2
```

and:

```text
Q3
```

Therefore the outputs do not necessarily change simultaneously.

---

# 22. Synchronous Counter Timing

For a synchronous counter:

```text
CLK ↑
 │
 ├──► FF0
 ├──► FF1
 ├──► FF2
 └──► FF3
```

All flip-flops see the same clock edge.

The combinational logic determines their next states.

Therefore there is no ripple clock chain.

---

# 23. Important: RTL Simulation vs Physical Hardware

At RTL:

```verilog id="s5f3f2"
count <= count + 1'b1;
```

looks extremely simple.

But synthesis can implement it using:

```text
Flip-flops
+
combinational incrementer
+
clock/reset logic
```

The RTL is an abstraction of the hardware.

For a placement interview, understand both:

```text
RTL description
        ↓
Synthesis
        ↓
Flip-flops + combinational logic
```

---

# 24. Synchronous Counter With Enable

A very common practical counter has:

```text
reset
enable
```

Example:

```verilog id="e0d6m8"
module counter_4bit_enable (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b0000;

        else if (enable)
            count <= count + 1'b1;

        else
            count <= count;

    end

endmodule
```

The explicit:

```verilog
count <= count;
```

is not necessary in this clocked block, but it makes the hold behavior obvious.

A cleaner version is:

```verilog id="xwgjfj"
always @(posedge clk) begin

    if (reset)
        count <= 4'b0000;
    else if (enable)
        count <= count + 1'b1;

end
```

When neither condition is true, the register naturally holds its value.

---

# 25. Synchronous Down Counter

```verilog id="n3j5n7"
module down_counter_4bit (
    input  wire       clk,
    input  wire       reset,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b1111;
        else
            count <= count - 1'b1;

    end

endmodule
```

Sequence:

```text
1111
1110
1101
1100
...
0010
0001
0000
1111
```

This is a modulo-16 down counter.

---

# 26. Reset and Counter Architecture

You can combine today's topic with Days 20 and 21.

### Asynchronous reset counter

```verilog id="8uv3go"
always @(posedge clk or posedge reset)
```

### Synchronous reset counter

```verilog id="1qg8qj"
always @(posedge clk)
```

Both are counters.

The difference is how reset is handled.

---

# 27. Day 22 Practical Assignment

Implement a:

## 4-bit Synchronous Up Counter

Inputs:

```text id="h0b2u9"
clk
reset
enable
```

Output:

```text id="0v7o7m"
count[3:0]
```

Priority:

```text id="09a99x"
reset > enable > hold
```

Expected behavior:

```text id="hup4q1"
reset = 1
    ↓
0000 at next clock edge
```

Then:

```text id="l1c6ly"
reset = 0
enable = 1
```

count:

```text id="st1hby"
0000
0001
0010
0011
...
1111
0000
```

When:

```text id="m83zq5"
enable = 0
```

the count holds.

---

# 28. RTL

Create:

```text id="u6v8uc"
~/Verilog_50_Days/Day_22/rtl/counter_4bit.v
```

```verilog id="6e4n2p"
module counter_4bit (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b0000;

        else if (enable)
            count <= count + 1'b1;

    end

endmodule
```

---

# 29. Testbench

Create:

```text id="lqgz1g"
~/Verilog_50_Days/Day_22/tb/tb_counter_4bit.v
```

```verilog id="w3k3n8"
`timescale 1ns/1ps

module tb_counter_4bit;

    reg clk;
    reg reset;
    reg enable;

    wire [3:0] count;

    counter_4bit dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/counter_4bit.vcd");
        $dumpvars(0, tb_counter_4bit);

        clk    = 1'b0;
        reset  = 1'b1;
        enable = 1'b0;

        // Reset
        #12;

        // Enable counting
        reset  = 1'b0;
        enable = 1'b1;

        #80;

        // Hold count
        enable = 1'b0;

        #20;

        // Count again
        enable = 1'b1;

        #30;

        // Reset while counting
        reset = 1'b1;

        #10;

        reset = 1'b0;

        #20;

        $finish;

    end

endmodule
```

---

# 30. Run the Simulation

Create the directories:

```bash id="v6vry7"
mkdir -p ~/Verilog_50_Days/Day_22/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_22
```

Compile:

```bash id="i9gc8q"
iverilog -o sim/day22 \
rtl/counter_4bit.v \
tb/tb_counter_4bit.v
```

Run:

```bash id="9y0b4e"
vvp sim/day22
```

Open:

```bash id="j6e7e1"
gtkwave sim/counter_4bit.vcd
```

Add:

```text id="eq0w8k"
clk
reset
enable
count
```

---

# 31. Expected Waveform

During:

```text id="m9xkps"
reset = 1
```

at the rising edge:

```text id="m0w9yv"
count = 0000
```

Then:

```text id="43xk6u"
enable = 1
```

At successive rising edges:

```text id="n98f0r"
0000
0001
0010
0011
0100
0101
...
```

When:

```text id="44x5rh"
enable = 0
```

the counter stops changing.

When:

```text id="1z3r1e"
reset = 1
```

the counter becomes zero at the next rising edge.

---

# 32. Automatic Testbench Verification

For placement-level RTL practice, don't only look at the waveform.

You should also learn to automatically verify the design.

A more robust testbench can maintain an expected count:

```verilog id="3j9x74"
reg [3:0] expected;

always @(posedge clk) begin

    #1;

    if (reset)
        expected = 4'b0000;
    else if (enable)
        expected = expected + 1'b1;

    if (count !== expected)
        $display("ERROR: expected=%b actual=%b",
                 expected, count);
    else
        $display("PASS: count=%b", count);

end
```

For a complete self-checking testbench, initialize `expected` consistently with the DUT's reset behavior and avoid race conditions by sampling after the nonblocking updates.

---

# 33. Counter Truth-Table Concept

For a 1-bit increment stage:

| Current Q |  T | Next Q |
| --------: | -: | -----: |
|         0 |  0 |      0 |
|         0 |  1 |      1 |
|         1 |  0 |      1 |
|         1 |  1 |      0 |

This is exactly the T flip-flop behavior.

For the synchronous binary counter:

```text
T0 = 1
T1 = Q0
T2 = Q0Q1
T3 = Q0Q1Q2
```

This gives the binary counting sequence.

---

# 34. Ripple Counter Concept With T Flip-Flops

A classic asynchronous counter can be built using T flip-flops with:

```text
T = 1
```

for every stage.

Conceptually:

```text
CLK ──► FF0 ─Q0─► FF1 ─Q1─► FF2 ─Q2─► FF3
          T=1       T=1       T=1       T=1
```

Each stage toggles when its clock input receives the appropriate transition.

This is the hardware idea behind a ripple counter.

---

# 35. Synchronous Counter Concept

For the same 4-bit counter:

```text
                 ┌─────┐
CLK ────────────►│ FF0 │
                 └─────┘
                    │Q0

                 ┌─────┐
CLK ────────────►│ FF1 │
                 └─────┘
                    │Q1

                 ┌─────┐
CLK ────────────►│ FF2 │
                 └─────┘
                    │Q2

                 ┌─────┐
CLK ────────────►│ FF3 │
                 └─────┘
```

All clock inputs are common.

Combinational logic generates the T/D inputs.

---

# 36. Why Synchronous Counters Are Generally Faster

### Ripple counter

The state transition propagates:

```text
FF0 → FF1 → FF2 → FF3
```

Therefore delay accumulates.

### Synchronous counter

All flip-flops receive:

```text
same clock edge
```

The main timing path is through the combinational next-state logic and flip-flop timing, rather than a chain of clock transitions.

Therefore synchronous counters are generally more suitable for high-speed designs.

---

# 37. Important Trade-Off

Synchronous counters are not automatically "free."

They generally require more combinational logic.

So there is a trade-off:

```text
Ripple:
simple hardware
but larger accumulated ripple timing

Synchronous:
more logic
but better timing/control
```

The actual implementation depends on the target technology and design requirements.

---

# 38. Placement Interview Questions

### Q1. What is an asynchronous counter?

A counter in which the clocking of successive flip-flops is derived from preceding flip-flop outputs rather than a common clock.

### Q2. What is another name for an asynchronous counter?

Ripple counter.

### Q3. Why is it called a ripple counter?

Because state transitions propagate from one flip-flop to the next.

### Q4. Do all flip-flops in a ripple counter receive the same external clock?

No.

### Q5. Do all flip-flops in a synchronous counter receive the same clock?

Yes.

### Q6. Which counter generally has less ripple propagation delay?

The synchronous counter.

### Q7. Why?

Because the flip-flops are clocked together rather than using cascaded clock transitions.

### Q8. What is MOD-16?

A counter with 16 unique states.

### Q9. How many states does an N-bit binary counter have?

```text
2^N
```

### Q10. How many flip-flops are required for MOD-16 binary counting?

Four.

Because:

```text
2^4 = 16
```

### Q11. What is the sequence of a 4-bit up counter?

```text
0000 → 0001 → ... → 1111 → 0000
```

### Q12. What happens when a binary counter reaches its maximum value?

It wraps around to zero.

For 4 bits:

```text
1111 → 0000
```

---

# 39. Very Important Interview Question

### Why can a ripple counter produce temporary incorrect output combinations?

Because the flip-flops do not switch simultaneously.

For example, during:

```text
0111 → 1000
```

different bits may change at slightly different times.

There can therefore be short-lived intermediate combinations before the final state settles.

This is one reason synchronous designs are preferred when tightly controlled timing is required.

---

# 40. Example of Ripple Transition

Ideal transition:

```text
0111
 ↓
1000
```

Physical transition can conceptually pass through temporary states such as:

```text
0111
0110
0100
0000
1000
```

The exact intermediate sequence depends on the flip-flop polarity, architecture, and propagation behavior.

The important point is:

> **Intermediate states can exist because the outputs do not change simultaneously.**

---

# 41. Frequency Division

Counters can also divide frequency.

For a binary counter:

```text
Q0
```

toggles every input clock cycle, so its frequency is approximately:

```text
f_clk / 2
```

Similarly:

```text
Q1 → f_clk / 4
Q2 → f_clk / 8
Q3 → f_clk / 16
```

Therefore a binary counter can act as a frequency divider.

This concept becomes important later when you study clock dividers.

---

# 42. Day 22 Final Assignment

Implement **both**:

### A. 4-bit synchronous counter

```text
CLK
RESET
ENABLE
COUNT[3:0]
```

### B. Conceptual 4-bit ripple counter

Draw the architecture:

```text
CLK → FF0 → FF1 → FF2 → FF3
```

For each design, explain:

1. Clock connection
2. Reset behavior
3. Counting sequence
4. Propagation delay
5. Why the two architectures differ

---

# 43. Day 22 Practice

## Problem 1

Design a 3-bit synchronous up counter.

Expected:

```text
000
001
010
011
100
101
110
111
000
```

---

## Problem 2

Design a 3-bit synchronous down counter.

Expected:

```text
111
110
101
100
011
010
001
000
111
```

---

## Problem 3

Design a MOD-10 synchronous counter.

Expected:

```text
0000
0001
0010
0011
0100
0101
0110
0111
1000
1001
0000
```

---

## Problem 4

Explain why a 4-bit ripple counter has more accumulated propagation delay than a 4-bit synchronous counter.

---

## Problem 5

Calculate the number of states in:

```text
5-bit counter
8-bit counter
10-bit counter
```

Use:

```text
2^N
```

---

# 44. Day 22 Golden Rules

Remember:

```text
ASYNC / RIPPLE COUNTER

CLK
 ↓
FF0
 ↓
FF1
 ↓
FF2
 ↓
FF3
```

versus:

```text
SYNCHRONOUS COUNTER

          ┌─► FF0
CLK ──────┼─► FF1
          ├─► FF2
          └─► FF3
```

And:

```text
N-bit binary counter
        ↓
    2^N states
```

For RTL:

```verilog
always @(posedge clk)
```

describes synchronous state updates.

---

# 45. Day 22 Checklist

Before moving to Day 23, make sure you can answer:

* [ ] What is a counter?
* [ ] What is an up counter?
* [ ] What is a down counter?
* [ ] What is an asynchronous/ripple counter?
* [ ] What is a synchronous counter?
* [ ] Why is a ripple counter called a ripple counter?
* [ ] Do all ripple-counter flip-flops use the same external clock?
* [ ] Do all synchronous-counter flip-flops use the same clock?
* [ ] What is propagation delay?
* [ ] Why does ripple delay accumulate?
* [ ] Why are synchronous counters generally faster?
* [ ] What is MOD-2^N?
* [ ] How many states does a 4-bit counter have?
* [ ] How can a counter divide frequency?
* [ ] How does a synchronous counter use T flip-flops?
* [ ] How do you code a synchronous counter in Verilog?
* [ ] How do reset and enable interact in a counter?

---

# 46. Placement Memory Trick

### Ripple counter

> **Previous flip-flop output becomes the next clock.**

### Synchronous counter

> **All flip-flops share the same clock.**

### Binary counter

> **N bits → 2^N states.**

### 4-bit counter

```text
0000 → ... → 1111 → 0000
```

### Frequency division

```text
Q0 → /2
Q1 → /4
Q2 → /8
Q3 → /16
```

---

## Day 22 Summary

You have now connected the previous three days:

```text
Day 20
Asynchronous Reset
        ↓
Day 21
Synchronous Reset
        ↓
Day 22
Asynchronous vs Synchronous Counters
```

The key distinction to remember is:

```text
RIPPLE COUNTER
Different FFs see clock transitions at different times.

SYNCHRONOUS COUNTER
All FFs receive the same clock edge.
```

**Next: Day 23 — Full Range vs Partial Range Counters.**
