# Day 26 — Edge Detectors in Verilog RTL

## 1. Today's Objective

Today you will learn:

* What an edge is in a digital signal
* Rising edge and falling edge
* Rising-edge detector
* Falling-edge detector
* Both-edge detector
* Why a previous-value register is required
* How an edge detector works clock-by-clock
* Verilog implementation
* Reset behavior
* Testbench verification
* Truth/transition-table verification
* Important placement interview questions

---

# 2. What Is an Edge?

A digital signal can transition between two logic levels:

```text
0 → 1
1 → 0
```

These transitions are called **edges**.

There are two basic types.

### Rising Edge

```text
0 → 1
```

Also called:

```text
Positive Edge
```

### Falling Edge

```text
1 → 0
```

Also called:

```text
Negative Edge
```

---

# 3. Visual Representation

A signal might look like:

```text
Signal

1       ┌───────┐       ┌───────
        │       │       │
0 ──────┘       └───────┘
        ↑       ↑       ↑
      rising  falling  rising
```

Therefore:

```text
Rising edge  = 0 → 1
Falling edge = 1 → 0
```

---

# 4. What Is an Edge Detector?

An edge detector generates a pulse when a particular transition occurs.

For example, a rising-edge detector:

```text
Input:  0 0 0 1 1 1 0 0
             ↑
             |
Output: 0 0 0 1 0 0 0 0
```

The output becomes `1` for one clock cycle when the input changes:

```text
0 → 1
```

---

# 5. Why Do We Need a Previous Value?

Suppose we have:

```text
current_input
```

How can we know whether it just changed?

We need to compare:

```text
Current Input
```

with:

```text
Previous Input
```

Therefore we store the previous input in a flip-flop.

Conceptually:

```text
             +----------------+
Input ------>| Previous Value |
             |    Register    |
             +-------+--------+
                     |
                     v
             Previous Input
                     |
                     v
Input ----------> Comparison
                     |
                     v
               Edge Detected
```

This is the key idea of today's topic.

---

# 6. Rising-Edge Detection

A rising edge occurs when:

```text
Previous = 0
Current  = 1
```

Therefore:

```text
rising_edge = current & ~previous
```

Mathematically:

```text
R = Current × Previous'
```

---

# 7. Rising-Edge Truth Table

| Previous | Current | Rising Edge |
| :------: | :-----: | :---------: |
|     0    |    0    |      0      |
|     0    |    1    |      1      |
|     1    |    0    |      0      |
|     1    |    1    |      0      |

Only this condition generates `1`:

```text
Previous = 0
Current  = 1
```

Therefore:

```verilog
rising_edge = signal & ~signal_d;
```

where:

```text
signal_d = delayed/previous signal
```

---

# 8. Falling-Edge Detection

A falling edge occurs when:

```text
Previous = 1
Current  = 0
```

Therefore:

```text
falling_edge = ~current & previous
```

or:

```verilog
falling_edge = ~signal & signal_d;
```

---

# 9. Falling-Edge Truth Table

| Previous | Current | Falling Edge |
| :------: | :-----: | :----------: |
|     0    |    0    |       0      |
|     0    |    1    |       0      |
|     1    |    0    |       1      |
|     1    |    1    |       0      |

Only:

```text
1 → 0
```

produces a pulse.

---

# 10. Both-Edge Detection

Sometimes we want to detect both:

```text
0 → 1
```

and:

```text
1 → 0
```

The condition is:

```text
Current != Previous
```

Therefore:

```verilog
edge = signal ^ signal_d;
```

Truth table:

| Previous | Current | Both-Edge Output |
| :------: | :-----: | :--------------: |
|     0    |    0    |         0        |
|     0    |    1    |         1        |
|     1    |    0    |         1        |
|     1    |    1    |         0        |

So:

```text
XOR = 1
```

whenever the signal changes.

---

# 11. Why Does the Previous Value Need a Register?

Suppose:

```verilog
always @(posedge clk)
```

At each clock edge, we capture:

```verilog
signal_d <= signal;
```

Therefore:

```text
signal_d
```

contains the previous sampled value.

Then we compare:

```verilog
signal
```

against:

```verilog
signal_d
```

The important point is that because `signal_d` is updated using nonblocking assignment, the comparison uses the **old** value of `signal_d` during that clock event.

---

# 12. Rising-Edge Detector RTL

Create:

```bash
mkdir -p ~/Verilog_50_Days/Day_26/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_26
```

Create:

```bash
nano rtl/rising_edge_detector.v
```

Use:

```verilog
module rising_edge_detector (
    input  wire clk,
    input  wire reset,
    input  wire signal_in,
    output wire rising_edge
);

    reg signal_d;

    always @(posedge clk) begin
        if (reset)
            signal_d <= 1'b0;
        else
            signal_d <= signal_in;
    end

    assign rising_edge = signal_in & ~signal_d;

endmodule
```

---

# 13. Understand the RTL

The previous-value register is:

```verilog
reg signal_d;
```

At every clock:

```verilog
signal_d <= signal_in;
```

Therefore:

```text
signal_d = previous sampled value
```

The rising-edge equation is:

```verilog
assign rising_edge = signal_in & ~signal_d;
```

So:

```text
Current = 1
Previous = 0
```

produces:

```text
rising_edge = 1
```

---

# 14. Example

Suppose sampled values are:

```text
signal:

0
0
1
1
1
0
0
1
```

The previous value is:

```text
previous:

0
0
0
1
1
1
0
0
```

Therefore:

```text
Current   Previous   Rising
   0         0         0
   0         0         0
   1         0         1
   1         1         0
   1         1         0
   0         1         0
   0         0         0
   1         0         1
```

So the detector generates:

```text
0 0 1 0 0 0 0 1
```

---

# 15. Falling-Edge Detector RTL

Create:

```bash
nano rtl/falling_edge_detector.v
```

```verilog
module falling_edge_detector (
    input  wire clk,
    input  wire reset,
    input  wire signal_in,
    output wire falling_edge
);

    reg signal_d;

    always @(posedge clk) begin
        if (reset)
            signal_d <= 1'b0;
        else
            signal_d <= signal_in;
    end

    assign falling_edge = ~signal_in & signal_d;

endmodule
```

The equation is:

```text
Falling = Current' × Previous
```

---

# 16. Both-Edge Detector RTL

Create:

```bash
nano rtl/both_edge_detector.v
```

```verilog
module both_edge_detector (
    input  wire clk,
    input  wire reset,
    input  wire signal_in,
    output wire edge_detected
);

    reg signal_d;

    always @(posedge clk) begin
        if (reset)
            signal_d <= 1'b0;
        else
            signal_d <= signal_in;
    end

    assign edge_detected = signal_in ^ signal_d;

endmodule
```

The XOR detects either transition.

---

# 17. One Module with All Three Outputs

For learning and verification, it is useful to combine them:

```verilog
module edge_detector (
    input  wire clk,
    input  wire reset,
    input  wire signal_in,
    output wire rising_edge,
    output wire falling_edge,
    output wire both_edge
);

    reg signal_d;

    always @(posedge clk) begin
        if (reset)
            signal_d <= 1'b0;
        else
            signal_d <= signal_in;
    end

    assign rising_edge  =  signal_in & ~signal_d;
    assign falling_edge = ~signal_in &  signal_d;
    assign both_edge    =  signal_in ^  signal_d;

endmodule
```

This is the main practical design for today.

---

# 18. Testbench

Create:

```bash
nano tb/tb_edge_detector.v
```

Use:

```verilog
`timescale 1ns/1ps

module tb_edge_detector;

    reg clk;
    reg reset;
    reg signal_in;

    wire rising_edge;
    wire falling_edge;
    wire both_edge;

    edge_detector dut (
        .clk         (clk),
        .reset       (reset),
        .signal_in   (signal_in),
        .rising_edge (rising_edge),
        .falling_edge(falling_edge),
        .both_edge   (both_edge)
    );

    always #5 clk = ~clk;

    task sample_signal;
        input value;
        begin
            signal_in = value;
            @(posedge clk);
            #1;

            $display(
                "Time=%0t  Signal=%b  Rising=%b  Falling=%b  Both=%b",
                $time,
                signal_in,
                rising_edge,
                falling_edge,
                both_edge
            );
        end
    endtask

    initial begin

        $dumpfile("sim/edge_detector.vcd");
        $dumpvars(0, tb_edge_detector);

        clk       = 1'b0;
        reset     = 1'b1;
        signal_in = 1'b0;

        #12;

        reset = 1'b0;

        // 0 -> 1 : rising edge
        sample_signal(1'b1);

        // 1 -> 1 : no edge
        sample_signal(1'b1);

        // 1 -> 0 : falling edge
        sample_signal(1'b0);

        // 0 -> 0 : no edge
        sample_signal(1'b0);

        // 0 -> 1 : rising edge
        sample_signal(1'b1);

        // 1 -> 0 : falling edge
        sample_signal(1'b0);

        #10;

        $finish;

    end

endmodule
```

---

# 19. Compile

Run:

```bash
iverilog -o sim/day26 rtl/edge_detector.v tb/tb_edge_detector.v
```

Then:

```bash
vvp sim/day26
```

---

# 20. Expected Behavior

After reset, consider these transitions:

| Previous | Current | Rising | Falling | Both |
| :------: | :-----: | :----: | :-----: | :--: |
|     0    |    1    |    1   |    0    |   1  |
|     1    |    1    |    0   |    0    |   0  |
|     1    |    0    |    0   |    1    |   1  |
|     0    |    0    |    0   |    0    |   0  |
|     0    |    1    |    1   |    0    |   1  |
|     1    |    0    |    0   |    1    |   1  |

This table is your primary functional verification.

---

# 21. GTKWave

Run:

```bash
gtkwave sim/edge_detector.vcd
```

Add:

```text
clk
reset
signal_in
dut.signal_d
rising_edge
falling_edge
both_edge
```

Observe:

### Rising edge

```text
signal_in:    0 ────┌────
                    │
rising_edge:  0 ────┌─
```

### Falling edge

```text
signal_in:    1 ────┐
                    │
falling_edge: 0 ────┌─
```

The output pulse corresponds to the detected transition.

---

# 22. Important Timing Concept

There is an important distinction:

The circuit above detects an edge of `signal_in` **with respect to the sampling clock**.

It does not create a completely asynchronous edge detector merely because the input changes physically between clock edges.

For synchronous RTL:

```text
External/Input Signal
          ↓
     Sampled by clk
          ↓
Previous-value register
          ↓
      Comparison
          ↓
     Edge pulse
```

This distinction is important in real hardware.

---

# 23. Edge Detector as a One-Cycle Pulse Generator

A rising-edge detector is commonly used to turn a level into a pulse.

Suppose:

```text
signal_in = 111111
```

A level detector would remain high.

But a rising-edge detector gives:

```text
signal_in  = 0 1 1 1 1 1
rising     = 0 1 0 0 0 0
```

Therefore:

> A rising-edge detector converts the beginning of a sampled HIGH interval into a one-clock pulse.

---

# 24. Why This Is Useful

Suppose a button, interrupt, request, or control signal stays high for several clock cycles.

You may want to perform an operation **only once** when it becomes active.

Instead of:

```text
request = 111111
```

you can generate:

```text
request_pulse = 010000
```

Then downstream logic can react once.

---

# 25. Edge Detector Using XOR

For both-edge detection:

```verilog
assign both_edge = signal_in ^ signal_d;
```

Why?

XOR truth table:

|  A |  B | A XOR B |
| -: | -: | ------: |
|  0 |  0 |       0 |
|  0 |  1 |       1 |
|  1 |  0 |       1 |
|  1 |  1 |       0 |

Therefore XOR is `1` exactly when the current and previous values are different.

So:

```text
Current != Previous
```

means:

```text
The signal changed.
```

---

# 26. Alternative Both-Edge Equation

Both-edge detection can also be expressed as:

```text
Rising OR Falling
```

Therefore:

```verilog
both_edge = rising_edge | falling_edge;
```

Since rising and falling conditions cannot both be true for the same pair of binary values:

```verilog
both_edge = rising_edge | falling_edge;
```

is equivalent to:

```verilog
both_edge = signal_in ^ signal_d;
```

This gives us a useful verification method.

---

# 27. Verify Mathematically

Rising:

```text
R = C & ~P
```

Falling:

```text
F = ~C & P
```

Both:

```text
B = R | F
```

Therefore:

```text
B = C~P + ~CP
```

This is exactly:

```text
C XOR P
```

Therefore:

```text
B = C ^ P
```

So we have independently verified the XOR implementation.

---

# 28. Common Mistake #1 — No Previous Register

Incorrect thinking:

```verilog
assign rising_edge = signal_in;
```

This is NOT edge detection.

It simply detects the signal level.

If:

```text
signal_in = 111111
```

then:

```text
rising_edge = 111111
```

That is not a one-cycle edge pulse.

Correct:

```verilog
assign rising_edge = signal_in & ~signal_d;
```

---

# 29. Common Mistake #2 — Using Blocking Assignment

For the previous-value register:

```verilog
always @(posedge clk) begin
    signal_d = signal_in;
end
```

Using blocking assignment can cause the subsequent combinational comparison to see the updated value in simulation.

For a clocked register, use:

```verilog
always @(posedge clk) begin
    signal_d <= signal_in;
end
```

This preserves the intended old/new-value relationship.

---

# 30. Common Mistake #3 — Forgetting Reset

Without reset, the initial value of:

```text
signal_d
```

can be unknown in simulation.

Then:

```text
signal_in & ~signal_d
```

may produce:

```text
X
```

during the initial period.

Reset establishes a known previous state.

---

# 31. Reset Polarity

Our design uses:

```verilog
if (reset)
    signal_d <= 1'b0;
```

This is an **active-high synchronous reset**.

Why synchronous?

Because reset is evaluated inside:

```verilog
always @(posedge clk)
```

So the register changes because of reset only at a clock edge.

---

# 32. Asynchronous Reset Version

An asynchronous reset would instead use:

```verilog
always @(posedge clk or posedge reset)
```

Example:

```verilog
always @(posedge clk or posedge reset) begin
    if (reset)
        signal_d <= 1'b0;
    else
        signal_d <= signal_in;
end
```

The difference:

### Synchronous reset

```text
reset + clock edge
        ↓
      reset
```

### Asynchronous reset

```text
reset changes
      ↓
register can reset immediately
```

This connects directly to the reset topics you learned earlier.

---

# 33. Edge Detector vs Clock Edge

This is a common interview trap.

When we write:

```verilog
always @(posedge clk)
```

`posedge clk` means the **clock** has a rising edge.

When we write:

```verilog
rising_edge = signal_in & ~signal_d;
```

we are detecting a rising transition of **signal_in**.

These are different concepts.

```text
posedge clk
    ↓
event that triggers sequential RTL

rising_edge of signal_in
    ↓
condition detected by the RTL
```

---

# 34. Placement Interview Questions

### Q1. What is a rising edge?

A transition from:

```text
0 → 1
```

### Q2. What is a falling edge?

A transition from:

```text
1 → 0
```

### Q3. How do you detect a rising edge?

```verilog
signal_in & ~signal_d
```

### Q4. How do you detect a falling edge?

```verilog
~signal_in & signal_d
```

### Q5. How do you detect both edges?

```verilog
signal_in ^ signal_d
```

### Q6. Why do we need `signal_d`?

It stores the previous sampled value of the input.

### Q7. What hardware stores `signal_d`?

A flip-flop/register.

### Q8. Why use nonblocking assignment?

Because `signal_d` is sequential state.

### Q9. What happens if current and previous values are equal?

No edge is detected.

### Q10. What does XOR do in a both-edge detector?

It produces `1` whenever the current and previous values differ.

### Q11. Is an edge detector combinational or sequential?

The complete sampled edge detector is sequential because it requires a previous-value register.

### Q12. Does `posedge clk` detect the input signal's rising edge?

No. It triggers the sequential block on the **clock's** rising edge.

---

# 35. Placement Problem

Given:

```text
Current signal:

0 0 1 1 1 0 0 1 1
```

Assume the previous sampled value starts at `0`.

Find the rising-edge detector output.

Compare:

| Previous | Current | Rising |
| :------: | :-----: | :----: |
|     0    |    0    |    0   |
|     0    |    0    |    0   |
|     0    |    1    |    1   |
|     1    |    1    |    0   |
|     1    |    1    |    0   |
|     1    |    0    |    0   |
|     0    |    0    |    0   |
|     0    |    1    |    1   |
|     1    |    1    |    0   |

Answer:

```text
0 0 1 0 0 0 0 1 0
```

---

# 36. Day 26 Assignment

Implement a parameterized edge detector:

```verilog
module edge_detector (
    input  wire clk,
    input  wire reset,
    input  wire signal_in,
    output wire rising_edge,
    output wire falling_edge
);
```

Requirements:

1. Detect rising edges.
2. Detect falling edges.
3. Store previous input.
4. Use synchronous reset.
5. Use nonblocking assignment.
6. Verify:

   * `0 → 0`
   * `0 → 1`
   * `1 → 0`
   * `1 → 1`
7. Verify at least 10 input samples.
8. View the result in GTKWave.

---

# 37. Challenge

Design a circuit that generates:

```text
one-clock pulse
```

when `req` changes from:

```text
0 → 1
```

but ignores the signal remaining high.

For:

```text
req = 000111100011
```

the expected pulse should occur at each rising transition.

Determine the output manually before coding.

---

# 38. Day 26 Checklist

Before moving to Day 27, make sure you can explain:

* [ ] What is a rising edge?
* [ ] What is a falling edge?
* [ ] What is a both-edge detector?
* [ ] Why is a previous-value register required?
* [ ] Rising-edge equation
* [ ] Falling-edge equation
* [ ] Both-edge equation
* [ ] Why XOR detects both edges
* [ ] Why `<=` is used
* [ ] Synchronous reset
* [ ] Asynchronous reset
* [ ] Difference between `posedge clk` and input edge detection
* [ ] How to verify an edge detector
* [ ] How to identify edge detection from a waveform

---

# 39. Golden Rules

```text
Rising edge:
0 → 1

Falling edge:
1 → 0

Rising detector:
current & ~previous

Falling detector:
~current & previous

Both-edge detector:
current ^ previous
```

The fundamental RTL pattern is:

```verilog
reg signal_d;

always @(posedge clk) begin
    if (reset)
        signal_d <= 1'b0;
    else
        signal_d <= signal_in;
end

assign rising_edge  = signal_in & ~signal_d;
assign falling_edge = ~signal_in & signal_d;
assign both_edge    = signal_in ^ signal_d;
```

## Day 26 takeaway

> **An edge detector compares the current sampled value with the previous sampled value. A change from 0→1 detects a rising edge, 1→0 detects a falling edge, and XOR detects either transition.**
