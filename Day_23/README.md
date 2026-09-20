# Day 23 — Full Range vs Partial Range Counters

## 1. Day 23 Objective

Today you will learn:

* What a full-range counter is
* What a partial-range counter is
* MOD-2ⁿ counters
* MOD-N counters
* Why partial-range counters are required
* How to design a MOD-10 counter using 4 flip-flops
* State transitions
* Terminal-count detection
* Counter rollover
* Synchronous reset
* Enable control
* Verilog implementation
* Testbench verification
* Placement interview questions

---

# 2. Quick Revision — Day 22

Yesterday we studied counters and compared:

```text
Asynchronous / Ripple Counter
```

with:

```text
Synchronous Counter
```

We learned:

```text
N-bit binary counter
        ↓
2^N possible states
```

For example:

```text
4-bit → 2^4 = 16 states
```

So a normal 4-bit binary counter is:

```text
MOD-16
```

Today we will see how to use the same 4 flip-flops to create fewer than 16 states.

---

# 3. What Is a Full-Range Counter?

A full-range binary counter uses **all possible states** available for its number of bits.

For an N-bit counter:

```text
Number of states = 2^N
```

Therefore:

```text
1-bit  → 2 states
2-bit  → 4 states
3-bit  → 8 states
4-bit  → 16 states
5-bit  → 32 states
```

---

# 4. Example — 4-bit Full-Range Counter

A 4-bit full-range counter goes through:

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
```

There are:

```text
16
```

unique states.

Therefore:

```text
MOD-16
```

---

# 5. What Is a Partial-Range Counter?

A partial-range counter does **not use all 2ⁿ possible states**.

It uses only a selected number of states.

For example, a 4-bit counter could count:

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

Only:

```text
10
```

states are used.

Therefore this is:

```text
MOD-10
```

counter.

---

# 6. Full Range vs Partial Range

| Feature          | Full Range              | Partial Range       |
| ---------------- | ----------------------- | ------------------- |
| Number of states | All 2ⁿ                  | Fewer than 2ⁿ       |
| Example          | 4-bit MOD-16            | 4-bit MOD-10        |
| Unused states    | None                    | Some                |
| Rollover         | Natural binary overflow | Explicitly designed |
| State detection  | Usually unnecessary     | Usually required    |

---

# 7. Why Do We Need Partial-Range Counters?

Real systems often require a specific number of states.

Examples:

```text
MOD-10 → decimal digit counter
MOD-12 → clock/timer applications
MOD-60 → seconds/minutes
MOD-24 → hours
MOD-100 → event/timer applications
```

A binary counter naturally gives powers of two:

```text
2, 4, 8, 16, 32, ...
```

But many systems need:

```text
10
12
24
60
100
```

Therefore we need partial-range counters.

---

# 8. Determining Number of Flip-Flops

To design a counter with N states, choose the smallest number of flip-flops such that:

```text
2^number_of_FF ≥ N
```

For MOD-10:

```text
2^3 = 8
```

Not enough.

```text
2^4 = 16
```

Enough.

Therefore:

```text
MOD-10
requires 4 flip-flops
```

---

# 9. Examples

## MOD-5

Need:

```text
2^2 = 4
```

not enough.

```text
2^3 = 8
```

Therefore:

```text
3 flip-flops
```

---

## MOD-10

```text
2^3 = 8  → insufficient
2^4 = 16 → sufficient
```

Therefore:

```text
4 flip-flops
```

---

## MOD-16

```text
2^4 = 16
```

Therefore:

```text
4 flip-flops
```

---

## MOD-20

```text
2^4 = 16 → insufficient
2^5 = 32 → sufficient
```

Therefore:

```text
5 flip-flops
```

---

# 10. General Formula

For a MOD-N counter:

```text
Number of flip-flops = ceil(log2(N))
```

Equivalent design rule:

```text
2^M ≥ N
```

where M is the number of flip-flops.

---

# 11. MOD-10 Counter

Let's design a MOD-10 counter.

Required states:

```text
0000 → 0001 → 0010 → 0011 → 0100
0101 → 0110 → 0111 → 1000 → 1001
```

Then:

```text
1001 → 0000
```

So the sequence is:

```text
0
1
2
3
4
5
6
7
8
9
0
```

This is exactly a decimal digit counter.

---

# 12. Why Is It Partial Range?

A 4-bit binary counter can represent:

```text
0000 to 1111
```

which is:

```text
0 to 15
```

But our MOD-10 counter uses only:

```text
0 to 9
```

Therefore these states are unused:

```text
1010 = 10
1011 = 11
1100 = 12
1101 = 13
1110 = 14
1111 = 15
```

These are the six unused states.

---

# 13. Terminal Count

For a MOD-10 counter, the maximum valid state is:

```text
1001
```

which represents decimal 9.

We can detect:

```verilog
count == 4'b1001
```

and then return to zero.

Conceptually:

```text
count = 9
   ↓
terminal count
   ↓
next count = 0
```

---

# 14. Simple MOD-10 Counter RTL

```verilog id="0z4a4g"
module mod10_counter (
    input  wire       clk,
    input  wire       reset,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b0000;

        else if (count == 4'b1001)
            count <= 4'b0000;

        else
            count <= count + 1'b1;

    end

endmodule
```

---

# 15. Understanding the RTL

The first condition:

```verilog id="5z6g3g"
if (reset)
    count <= 4'b0000;
```

means reset has highest priority.

Next:

```verilog id="d7v4tv"
else if (count == 4'b1001)
```

detects decimal 9.

Then:

```verilog id="v7j9l7"
count <= 4'b0000;
```

causes rollover.

Otherwise:

```verilog id="n8x1zy"
count <= count + 1'b1;
```

increments normally.

---

# 16. State Transition Table

For MOD-10:

| Current | Decimal | Next |
| ------- | ------: | ---- |
| 0000    |       0 | 0001 |
| 0001    |       1 | 0010 |
| 0010    |       2 | 0011 |
| 0011    |       3 | 0100 |
| 0100    |       4 | 0101 |
| 0101    |       5 | 0110 |
| 0110    |       6 | 0111 |
| 0111    |       7 | 1000 |
| 1000    |       8 | 1001 |
| 1001    |       9 | 0000 |

This is the complete valid state sequence.

---

# 17. Truth-Table Verification

For a counter, the useful truth table is the **state-transition table** rather than a conventional combinational truth table.

For example:

```text
Current count → Next count
```

The important transition is:

```text
1001 → 0000
```

instead of:

```text
1001 → 1010
```

That is what makes the counter MOD-10.

---

# 18. What About Unused States?

This is a very important design question.

Suppose due to:

* power-up behavior
* reset problems
* noise
* upset
* simulation initialization
* another bug

the counter enters:

```text
1010
```

Our basic RTL does not explicitly specify what happens there.

For example:

```verilog
else
    count <= count + 1'b1;
```

would produce:

```text
1010 → 1011
```

and eventually:

```text
1111 → 0000
```

So the counter eventually returns to the valid range.

But we can explicitly design recovery from invalid states.

---

# 19. Self-Correcting MOD-10 Counter

A more robust version can explicitly detect invalid states:

```verilog id="pjxv1g"
module mod10_counter_safe (
    input  wire       clk,
    input  wire       reset,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'b0000;

        else if (count >= 4'b1001)
            count <= 4'b0000;

        else
            count <= count + 1'b1;

    end

endmodule
```

Now:

```text
1010
1011
1100
1101
1110
1111
```

all return to:

```text
0000
```

at the next clock edge.

---

# 20. Why `>= 9`?

The valid maximum is:

```text
1001 = 9
```

So:

```verilog
count >= 4'b1001
```

detects:

```text
9
10
11
12
13
14
15
```

and forces the counter to zero.

However, notice that this also detects 9, which is exactly the intended terminal count.

---

# 21. Alternative Invalid-State Handling

You can explicitly write:

```verilog id="wzgg4u"
case (count)

    4'd0: count <= 4'd1;
    4'd1: count <= 4'd2;
    4'd2: count <= 4'd3;
    4'd3: count <= 4'd4;
    4'd4: count <= 4'd5;
    4'd5: count <= 4'd6;
    4'd6: count <= 4'd7;
    4'd7: count <= 4'd8;
    4'd8: count <= 4'd9;
    4'd9: count <= 4'd0;

    default: count <= 4'd0;

endcase
```

This explicitly defines recovery from every unused state.

---

# 22. Which Style Should You Understand?

You should understand both:

### Arithmetic style

```verilog id="9q4nvo"
if (count == 9)
    count <= 0;
else
    count <= count + 1;
```

Simple and compact.

### State-explicit style

```verilog id="m5un98"
case (count)
    ...
    default: count <= 0;
endcase
```

Makes every state transition explicit.

Both can describe synthesizable sequential logic.

---

# 23. MOD-5 Counter

A MOD-5 counter needs:

```text
3 flip-flops
```

because:

```text
2^2 = 4 < 5
2^3 = 8 ≥ 5
```

Valid sequence:

```text
000
001
010
011
100
000
```

RTL:

```verilog id="20k4gq"
module mod5_counter (
    input  wire      clk,
    input  wire      reset,
    output reg [2:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 3'd0;

        else if (count == 3'd4)
            count <= 3'd0;

        else
            count <= count + 1'b1;

    end

endmodule
```

---

# 24. MOD-12 Counter

A MOD-12 counter needs:

```text
4 flip-flops
```

because:

```text
2^3 = 8 < 12
2^4 = 16 ≥ 12
```

Valid states:

```text
0 → 1 → 2 → ... → 10 → 11 → 0
```

Terminal state:

```text
1011
```

because:

```text
1011 = 11
```

---

# 25. MOD-16 Counter

A MOD-16 counter uses all states of a 4-bit counter:

```text
0 → 1 → ... → 15 → 0
```

No explicit partial-range rollover is necessary because normal 4-bit arithmetic naturally wraps:

```text
1111 + 1 = 0000
```

Therefore it is a full-range counter.

---

# 26. MOD-10 vs MOD-16

| Property            |        MOD-10 |     MOD-16 |
| ------------------- | ------------: | ---------: |
| Flip-flops          |             4 |          4 |
| Valid states        |            10 |         16 |
| Unused states       |             6 |          0 |
| Maximum valid count |             9 |         15 |
| Rollover            |         9 → 0 |     15 → 0 |
| Type                | Partial range | Full range |

This is one of the most important comparisons from today.

---

# 27. MOD-10 With Enable

A practical counter often needs an enable.

```verilog id="ww3ps9"
module mod10_counter_enable (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'd0;

        else if (enable) begin

            if (count == 4'd9)
                count <= 4'd0;
            else
                count <= count + 1'b1;

        end

    end

endmodule
```

Priority:

```text
reset
  ↓
enable
  ↓
terminal count
  ↓
increment
```

---

# 28. Day 23 Practical Setup

Create:

```bash id="x7qymc"
mkdir -p ~/Verilog_50_Days/Day_23/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_23
```

Directory:

```text id="1i8h0r"
Day_23/
├── rtl/
├── tb/
├── sim/
└── wave/
```

---

# 29. Main Assignment — MOD-10 Counter

Create:

```text id="zq3j5e"
rtl/mod10_counter.v
```

```verilog id="o0t6e5"
module mod10_counter (
    input  wire       clk,
    input  wire       reset,
    output reg  [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'd0;

        else if (count == 4'd9)
            count <= 4'd0;

        else
            count <= count + 1'b1;

    end

endmodule
```

---

# 30. Testbench

Create:

```text id="s5u7d6"
tb/tb_mod10_counter.v
```

```verilog id="2e5w70"
`timescale 1ns/1ps

module tb_mod10_counter;

    reg clk;
    reg reset;

    wire [3:0] count;

    mod10_counter dut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/mod10_counter.vcd");
        $dumpvars(0, tb_mod10_counter);

        clk   = 1'b0;
        reset = 1'b1;

        // Reset
        #12;

        reset = 1'b0;

        // Allow the counter to run
        #100;

        // Reset again
        reset = 1'b1;

        #10;

        reset = 1'b0;

        #30;

        $finish;

    end

endmodule
```

---

# 31. Compile and Run

Compile:

```bash id="g05mgn"
iverilog -o sim/day23 \
rtl/mod10_counter.v \
tb/tb_mod10_counter.v
```

Run:

```bash id="6d1m1x"
vvp sim/day23
```

Open:

```bash id="u4jj58"
gtkwave sim/mod10_counter.vcd
```

Add:

```text id="q07v2n"
clk
reset
count
```

---

# 32. Expected Waveform Sequence

After reset:

```text id="q5e0gq"
0000
```

Then:

```text id="4qphw6"
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

Then it repeats.

You must **never see a valid-state transition to `1010`** during normal operation.

---

# 33. Automatic Verification

A better testbench can check the expected sequence.

Example:

```verilog id="x5blxw"
integer i;
reg [3:0] expected;

initial begin

    expected = 4'd0;

    // Apply reset
    reset = 1'b1;

    repeat (2)
        @(posedge clk);

    #1;

    reset = 1'b0;

    for (i = 0; i < 25; i = i + 1) begin

        @(posedge clk);
        #1;

        if (count !== expected)
            $display("ERROR: expected=%0d actual=%0d",
                     expected, count);
        else
            $display("PASS: count=%0d", count);

        if (expected == 4'd9)
            expected = 4'd0;
        else
            expected = expected + 1'b1;

    end

end
```

The exact expected-value timing should be aligned with the reset and clock sequence in your complete testbench.

---

# 34. Important Simulation Detail

Because the DUT uses:

```verilog
<=
```

the counter update is a nonblocking assignment.

Therefore, in a testbench, it is useful to sample after the NBA update:

```verilog
@(posedge clk);
#1;
```

rather than immediately assuming the new value has already appeared.

This connects directly to **Day 16 — Nonblocking Assignment**.

---

# 35. Full-Range Counter Example

```verilog id="i7j25k"
module full_range_counter (
    input wire       clk,
    input wire       reset,
    output reg [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'd0;
        else
            count <= count + 1'b1;

    end

endmodule
```

This naturally produces:

```text
0 → 1 → ... → 15 → 0
```

Therefore:

```text
MOD-16
```

---

# 36. Partial-Range Counter Example

```verilog id="j4m1kl"
module partial_range_counter (
    input wire       clk,
    input wire       reset,
    output reg [3:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= 4'd0;

        else if (count == 4'd9)
            count <= 4'd0;

        else
            count <= count + 1'b1;

    end

endmodule
```

Sequence:

```text
0 → 1 → ... → 9 → 0
```

Therefore:

```text
MOD-10
```

---

# 37. Why Not Use 3 Bits for MOD-10?

Because 3 bits have only:

```text
2^3 = 8
```

states:

```text
0 to 7
```

But MOD-10 requires:

```text
0 to 9
```

Therefore 3 bits cannot represent all ten required states.

You need:

```text
4 bits
```

---

# 38. Why Are Six States Unused?

A 4-bit register can represent:

```text
16 states
```

MOD-10 needs:

```text
10 states
```

Therefore:

```text
16 - 10 = 6
```

unused states.

Those are:

```text
10
11
12
13
14
15
```

or:

```text
1010
1011
1100
1101
1110
1111
```

---

# 39. Invalid-State Recovery

A robust partial-range counter should consider what happens if it enters an unused state.

For MOD-10:

```text
1010–1111
```

are invalid states.

One strategy is:

```text
invalid state
     ↓
0000
```

at the next clock edge.

This creates a self-recovery mechanism.

Example:

```verilog id="s8u7yw"
if (count >= 4'd10)
    count <= 4'd0;
```

---

# 40. Why Invalid-State Handling Matters

At RTL, reset may establish the correct initial state.

But in real systems, designers also think about:

* power-up behavior
* reset reliability
* unexpected state entry
* robustness
* state-machine recovery

Therefore, defining behavior for unused states can improve robustness.

---

# 41. Common Mistake #1

Incorrect assumption:

```text id="c4v06s"
4-bit counter = always MOD-10
```

Wrong.

A normal 4-bit binary counter is:

```text id="0q7jpj"
MOD-16
```

It becomes MOD-10 only if you deliberately restrict its state sequence.

---

# 42. Common Mistake #2

Writing:

```verilog id="9o5f5n"
if (count == 4'd10)
    count <= 0;
```

for a normal incrementing MOD-10 counter.

This is too late.

The valid maximum is:

```text id="c3dj3t"
9
```

So you normally detect:

```verilog id="s2r35c"
count == 4'd9
```

and make the next state zero.

---

# 43. Common Mistake #3

Using too few flip-flops.

For MOD-10:

```text id="pbb0mj"
3 FFs → 8 states
```

which is insufficient.

You need:

```text id="h2ckak"
4 FFs → 16 states
```

---

# 44. Common Mistake #4

Forgetting the rollover.

If you simply write:

```verilog id="s3c9jw"
count <= count + 1'b1;
```

with 4 bits, you get:

```text id="d2qf0g"
9 → 10
```

which violates MOD-10.

You need terminal-count handling.

---

# 45. Placement Interview Questions

### Q1. What is a full-range counter?

A counter that uses all possible states of its N-bit representation.

### Q2. What is a partial-range counter?

A counter that uses fewer than the 2ⁿ possible states.

### Q3. What is the modulus of a 4-bit binary counter?

```text
16
```

So it is MOD-16.

### Q4. How many flip-flops are required for MOD-10?

Four.

### Q5. Why?

Because:

```text
2^3 < 10
```

but:

```text
2^4 ≥ 10
```

### Q6. What is the sequence of a MOD-10 counter?

```text
0 → 1 → 2 → ... → 9 → 0
```

### Q7. What are the unused states of a 4-bit MOD-10 counter?

```text
10, 11, 12, 13, 14, 15
```

### Q8. What is terminal count?

The final valid count before rollover.

For MOD-10:

```text
9
```

### Q9. Why do we need terminal-count detection?

To force the counter back to the beginning of its desired range.

### Q10. What is the general number of flip-flops for MOD-N?

```text
ceil(log2(N))
```

### Q11. Is MOD-16 a partial-range counter when implemented with four bits?

No. It uses all 16 possible 4-bit states.

### Q12. Is MOD-10 a partial-range counter with four bits?

Yes. It uses 10 of 16 possible states.

---

# 46. Interview Problem

### Question

Design a MOD-6 counter.

### Step 1 — Number of flip-flops

```text
2^2 = 4 < 6
2^3 = 8 ≥ 6
```

Therefore:

```text
3 flip-flops
```

### Step 2 — Sequence

```text
000
001
010
011
100
101
000
```

### Step 3 — Terminal state

```text
101 = 5
```

Therefore:

```text
if count == 5
    count <= 0;
```

---

# 47. Another Interview Problem

### Design a MOD-12 counter.

Number of flip-flops:

```text
2^3 = 8 < 12
2^4 = 16 ≥ 12
```

Therefore:

```text
4 flip-flops
```

Sequence:

```text
0 → 1 → 2 → ... → 11 → 0
```

Terminal count:

```text
11 = 4'b1011
```

---

# 48. Day 23 Practice Problems

## Problem 1

Design a MOD-6 counter.

Determine:

```text
1. Number of flip-flops
2. Valid states
3. Terminal count
4. RTL
5. Testbench
```

---

## Problem 2

Design a MOD-12 counter.

Determine:

```text
1. Number of flip-flops
2. Unused states
3. Terminal count
```

---

## Problem 3

Design a MOD-20 counter.

Determine:

```text
1. Number of flip-flops
2. Valid range
3. Terminal count
4. Number of unused states
```

---

## Problem 4

Design a MOD-100 counter.

Determine:

```text
1. Number of flip-flops
2. Valid states
3. Unused states
```

---

# 49. Day 23 Final Assignment

Build and verify:

## MOD-10 Synchronous Counter

### Inputs

```text
clk
reset
enable
```

### Output

```text
count[3:0]
```

### Requirements

```text
reset = 1
    ↓
count = 0 at next rising edge
```

When:

```text
reset = 0
enable = 1
```

sequence:

```text
0
1
2
3
4
5
6
7
8
9
0
...
```

When:

```text
enable = 0
```

the counter holds its current value.

### Verify:

* Reset
* Enable
* Hold
* Count 0→9
* Rollover 9→0
* Reset during counting
* At least 25 consecutive count cycles
* No `10–15` states during normal operation

---

# 50. Day 23 Golden Rules

### Full-range counter

```text
N bits
 ↓
2^N states
 ↓
all states used
```

Example:

```text
4-bit → MOD-16
```

### Partial-range counter

```text
N bits
 ↓
fewer than 2^N states
 ↓
unused states exist
```

Example:

```text
4-bit → MOD-10
```

### Flip-flop calculation

```text
2^M ≥ MOD
```

### Terminal count

```text
MOD-N up counter
      ↓
terminal count = N-1
      ↓
next state = 0
```

---

# 51. Day 23 Checklist

Before moving to Day 24, you should be able to explain:

* [ ] Full-range counter
* [ ] Partial-range counter
* [ ] MOD-N counter
* [ ] MOD-2ⁿ counter
* [ ] Number of flip-flops required for MOD-N
* [ ] Terminal count
* [ ] Rollover
* [ ] Unused states
* [ ] Invalid-state recovery
* [ ] MOD-5
* [ ] MOD-6
* [ ] MOD-10
* [ ] MOD-12
* [ ] MOD-16
* [ ] MOD-20
* [ ] Why MOD-10 requires four flip-flops
* [ ] How to code a partial-range counter
* [ ] How to verify it in GTKWave

---

# 52. Placement Memory Trick

Remember these four formulas:

```text
N-bit full-range counter
        ↓
      2^N states
```

```text
MOD-N counter
        ↓
N valid states
```

```text
Required FFs
        ↓
ceil(log2(N))
```

```text
MOD-N up counter
        ↓
terminal count = N-1
```

For example:

```text
MOD-10
 ↓
4 FFs
 ↓
0 → 1 → ... → 9 → 0
 ↓
6 unused 4-bit states
```

---

## Day 23 Summary

You have now progressed:

```text
Day 20
Asynchronous Reset
        ↓
Day 21
Synchronous Reset
        ↓
Day 22
Asynchronous vs Synchronous Counters
        ↓
Day 23
Full Range vs Partial Range Counters
```

The central concept is:

> **A full-range N-bit counter uses all 2ⁿ states; a partial-range counter deliberately uses fewer states and therefore needs explicit state-range control.**

**Next: Day 24 — Shift Registers.**
