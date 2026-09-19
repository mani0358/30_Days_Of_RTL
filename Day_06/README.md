# Day 06 — Verilog `integer`

## 1. Day 6 Objective

Today we will learn:

* What `integer` means in Verilog
* Syntax and properties of `integer`
* Signed nature of `integer`
* Difference between `integer`, `reg`, and `wire`
* Where `integer` is commonly used
* Why an `integer` is usually not the best choice for RTL counters
* Signed numbers in Verilog
* 3-bit signed number representation
* Design a **signed 3-bit down counter**
* Write its testbench
* Simulate using Icarus Verilog
* Verify the waveform using GTKWave

### Day 6 Roadmap Assignment

> **Design a signed 3-bit down counter.**

---

# 2. What is `integer` in Verilog?

`integer` is a Verilog variable data type used to store **signed integer values**.

Basic syntax:

```verilog
integer count;
```

An `integer` is commonly used for:

* Loop variables
* Testbench calculations
* Counters in simulation
* Temporary calculations
* Indexing

Example:

```verilog
integer i;

initial begin
    for (i = 0; i < 10; i = i + 1) begin
        $display("i = %0d", i);
    end
end
```

---

# 3. Important Property of `integer`

In traditional Verilog, an `integer` is:

* 32 bits wide
* Signed
* A variable
* Procedurally assignable

Example:

```verilog
integer x;

initial begin
    x = -10;
    $display("x = %0d", x);
end
```

Output:

```text
x = -10
```

---

# 4. `integer` vs `reg` vs `wire`

| Feature                                 | `wire`                 | `reg`                  | `integer`          |
| --------------------------------------- | ---------------------- | ---------------------- | ------------------ |
| Type                                    | Net                    | Variable               | Variable           |
| Typical width                           | 1 bit unless specified | 1 bit unless specified | 32 bits            |
| Signed by default                       | No                     | No                     | Yes                |
| Procedural assignment                   | No                     | Yes                    | Yes                |
| Continuous assignment                   | Yes                    | No                     | No                 |
| Typical use                             | Connections            | RTL variables          | Calculations/loops |
| Can represent negative values naturally | Not by default         | With `signed`          | Yes                |

### Important interview point

```verilog
integer count;
```

does **not** mean that the hardware must contain a 32-bit physical register.

What hardware is synthesized depends on **how the variable is used**.

For actual RTL datapaths/counters, explicit-width declarations are generally preferable.

---

# 5. Signed Numbers

A signed number can represent both:

```text
positive numbers
negative numbers
```

For example, a 3-bit signed two's-complement number has the range:

$$
-2^{3-1} \text{ to } 2^{3-1}-1
$$

Therefore:

$$
-4 \text{ to } +3
$$

So a 3-bit signed number can represent:

| Binary | Decimal |
| ------ | ------: |
| `011`  |      +3 |
| `010`  |      +2 |
| `001`  |      +1 |
| `000`  |       0 |
| `111`  |      -1 |
| `110`  |      -2 |
| `101`  |      -3 |
| `100`  |      -4 |

This is **two's-complement representation**.

---

# 6. Why is `100` equal to -4?

For a 3-bit signed number:

```text
100
```

MSB is `1`, so it is negative.

Find its magnitude using two's complement:

```text
100
invert → 011
add 1 → 100
```

Therefore:

```text
100 = -4
```

---

# 7. Signed 3-bit Down Counter

A down counter decreases its value on every active clock edge.

We want the sequence:

```text
 3
 2
 1
 0
-1
-2
-3
-4
 3
 ...
```

Because the counter has only 3 bits, after:

```text
-4
```

the next value wraps around to:

```text
+3
```

This is modulo-8 two's-complement behavior.

---

# 8. Counter State Table

| Current | Binary | Next | Binary |
| ------: | :----: | ---: | :----: |
|      +3 |  `011` |   +2 |  `010` |
|      +2 |  `010` |   +1 |  `001` |
|      +1 |  `001` |    0 |  `000` |
|       0 |  `000` |   -1 |  `111` |
|      -1 |  `111` |   -2 |  `110` |
|      -2 |  `110` |   -3 |  `101` |
|      -3 |  `101` |   -4 |  `100` |
|      -4 |  `100` |   +3 |  `011` |

The important point is:

```text
counter_next = counter - 1
```

---

# 9. RTL Implementation

For an actual 3-bit RTL counter, we will explicitly specify the width and signedness:

```verilog
module signed_down_counter (
    input  wire clk,
    input  wire reset,
    output reg signed [2:0] count
);

    always @(posedge clk) begin
        if (reset)
            count <= 3'sd3;
        else
            count <= count - 3'sd1;
    end

endmodule
```

### Why `reg signed [2:0]`?

```verilog
reg
```

means `count` is a variable that can be assigned inside the `always` block.

```verilog
signed
```

tells Verilog to interpret the value as signed.

```verilog
[2:0]
```

makes it exactly 3 bits wide.

---

# 10. Why not use `integer` for the counter?

We are learning `integer` today, but for an RTL counter we want the hardware width to be explicit.

Using:

```verilog
integer count;
```

would normally give us a 32-bit signed variable.

But our required hardware is:

```text
3-bit signed counter
```

Therefore:

```verilog
reg signed [2:0] count;
```

communicates the intended hardware width much more clearly.

### Placement rule

> Use `integer` mainly for simulation/control calculations and loop variables; use explicitly sized vectors for hardware datapaths and counters when width matters.

---

# 11. Understanding `3'sd3`

Consider:

```verilog
3'sd3
```

Break it down:

```text
3     → width = 3 bits
' s   → signed
d     → decimal
3     → value
```

Therefore:

```verilog
3'sd3
```

means:

```text
3-bit signed decimal 3
```

Similarly:

```verilog
3'sd1
```

means:

```text
3-bit signed decimal 1
```

---

# 12. Testbench

Create:

```text
tb/tb_signed_down_counter.v
```

Code:

```verilog
`timescale 1ns/1ps

module tb_signed_down_counter;

    reg clk;
    reg reset;

    wire signed [2:0] count;

    signed_down_counter dut (
        .clk   (clk),
        .reset (reset),
        .count (count)
    );

    // Clock generation
    initial begin
        clk = 0;

        forever #5 clk = ~clk;
    end

    // Test sequence
    initial begin

        $dumpfile("sim/signed_down_counter.vcd");
        $dumpvars(0, tb_signed_down_counter);

        reset = 1;

        #12;
        reset = 0;

        #90;

        $finish;
    end

endmodule
```

---

# 13. How the Clock Works

We have:

```verilog
forever #5 clk = ~clk;
```

Therefore:

```text
0 → 1 after 5 ns
1 → 0 after 5 ns
0 → 1 after 5 ns
...
```

So the clock period is:

$$
T = 10ns
$$

and frequency is:

$$
f = \frac{1}{T}
$$

$$
f = \frac{1}{10ns}=100MHz
$$

---

# 14. Reset Behavior

Initially:

```verilog
reset = 1;
```

At the first positive clock edge:

```text
reset = 1
```

therefore:

```verilog
count <= 3'sd3;
```

So:

```text
count = +3
```

Then:

```verilog
reset = 0;
```

The counter begins counting down.

---

# 15. Expected Counter Sequence

After reset is released:

```text
+3
+2
+1
 0
-1
-2
-3
-4
+3
...
```

Binary:

```text
011
010
001
000
111
110
101
100
011
...
```

---

# 16. Important Verification

We can verify that the binary sequence correctly represents signed decimal values.

| Count bits | Signed decimal |
| ---------- | -------------: |
| `011`      |             +3 |
| `010`      |             +2 |
| `001`      |             +1 |
| `000`      |              0 |
| `111`      |             -1 |
| `110`      |             -2 |
| `101`      |             -3 |
| `100`      |             -4 |
| `011`      |             +3 |

Therefore the RTL correctly implements a **3-bit signed down counter**.

---

# 17. Directory Structure

Create:

```text
~/Verilog_50_Days/
└── Day_06/
    ├── rtl/
    │   └── signed_down_counter.v
    ├── tb/
    │   └── tb_signed_down_counter.v
    ├── sim/
    └── wave/
```

---

# 18. Create the Directories

Run in Ubuntu:

```bash
mkdir -p ~/Verilog_50_Days/Day_06/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_06
```

Check:

```bash
tree
```

Expected:

```text
.
├── rtl
├── sim
├── tb
└── wave
```

---

# 19. Compile

Run:

```bash
iverilog -o sim/signed_down_counter_sim \
rtl/signed_down_counter.v \
tb/tb_signed_down_counter.v
```

If there are no errors, compilation is successful.

---

# 20. Run Simulation

```bash
vvp sim/signed_down_counter_sim
```

The simulation generates:

```text
sim/signed_down_counter.vcd
```

---

# 21. Open GTKWave

```bash
gtkwave sim/signed_down_counter.vcd
```

Add:

```text
clk
reset
count
```

to the waveform.

You should observe:

```text
count:
3 → 2 → 1 → 0 → -1 → -2 → -3 → -4 → 3 ...
```

---

# 22. Very Important Verilog Concept: Signedness

Compare:

```verilog
reg [2:0] a;
```

with:

```verilog
reg signed [2:0] a;
```

The first is unsigned.

The second is signed.

For example:

```text
111
```

as unsigned:

```text
7
```

but:

```text
111
```

as 3-bit signed two's complement:

```text
-1
```

This difference is extremely important in RTL and interviews.

---

# 23. `integer` Practical Example

Now let's actually use an `integer`.

Create:

```text
integer_example.v
```

```verilog
module integer_example;

    integer i;

    initial begin

        for (i = 0; i < 5; i = i + 1) begin
            $display("i = %0d", i);
        end

    end

endmodule
```

Compile:

```bash
iverilog -o integer_sim integer_example.v
```

Run:

```bash
vvp integer_sim
```

Expected:

```text
i = 0
i = 1
i = 2
i = 3
i = 4
```

This is one of the most common uses of `integer`.

---

# 24. Common Mistakes

### Mistake 1 — Thinking `integer` means a hardware 32-bit counter

Not necessarily.

`integer` is a Verilog variable type. Synthesis depends on how it is used.

---

### Mistake 2 — Forgetting `signed`

```verilog
reg [2:0] count;
```

is unsigned.

For signed operation:

```verilog
reg signed [2:0] count;
```

---

### Mistake 3 — Assuming `111` always means -1

It depends on signedness.

```text
3'b111 = 7 unsigned
3'sb111 = -1 signed
```

---

### Mistake 4 — Using blocking assignment for sequential RTL

For actual clocked RTL, prefer:

```verilog
count <= count - 1;
```

rather than:

```verilog
count = count - 1;
```

We will study **blocking vs nonblocking assignments in detail later in the roadmap**.

---

### Mistake 5 — Using an incorrect width

For a 3-bit counter:

```verilog
reg signed [2:0] count;
```

not:

```verilog
reg signed [3:0] count;
```

The latter is 4 bits.

---

# 25. Placement Interview Questions

### Q1. What is an integer in Verilog?

An `integer` is a signed variable data type, traditionally 32 bits wide, commonly used for loops, calculations, and simulation variables.

### Q2. Is integer signed?

Yes. A Verilog `integer` is signed.

### Q3. What is the difference between `integer` and `reg`?

`integer` is a predefined signed 32-bit variable, while `reg` is a variable type whose width is explicitly specified when needed.

### Q4. Is `reg` necessarily a physical register?

No.

The hardware inferred from a `reg` depends on the procedural logic in which it is used.

### Q5. What is the range of a 3-bit signed number?

```text
-4 to +3
```

### Q6. What is `3'b111`?

Unsigned binary:

```text
7
```

### Q7. What is `3'sb111`?

Signed 3-bit two's-complement value:

```text
-1
```

### Q8. What is the sequence of a 3-bit signed down counter starting at +3?

```text
3, 2, 1, 0, -1, -2, -3, -4, 3...
```

### Q9. Why does -4 go to +3?

Because a 3-bit counter has 8 possible states and wraps around modulo 8.

### Q10. Why use an explicitly sized vector instead of integer for a hardware counter?

It makes the intended hardware width explicit.

---

# 26. Day 6 Assignment

Complete these yourself:

### Assignment 1 — Integer

Write a Verilog program that prints:

```text
10
9
8
7
6
5
4
3
2
1
0
```

using an `integer` and a `for` loop.

---

### Assignment 2 — Signed Counter

Modify the counter so that it starts at:

```text
-4
```

and counts upward:

```text
-4
-3
-2
-1
0
1
2
3
-4
...
```

---

### Assignment 3 — Verify Binary

Make a table showing:

```text
Binary
Signed decimal
Unsigned decimal
```

for all 8 possible 3-bit values.

---

### Assignment 4 — GTKWave

Capture the waveform containing:

```text
clk
reset
count
```

and verify every transition manually.

---

# 27. Day 6 Checklist

Before moving to Day 7, make sure you can explain:

* [ ] What is `integer`?
* [ ] Is `integer` signed?
* [ ] What is the usual width of Verilog `integer`?
* [ ] What is a signed number?
* [ ] What is two's complement?
* [ ] What is the range of a 3-bit signed number?
* [ ] Difference between signed and unsigned vectors
* [ ] Why `111` can mean either 7 or -1
* [ ] What is a signed 3-bit down counter?
* [ ] Why does `-4` wrap to `+3`?
* [ ] Why explicit width is useful in RTL?
* [ ] How to compile using Icarus?
* [ ] How to inspect the waveform using GTKWave?

---

# Day 6 Golden Rule

> **`integer` is a signed variable commonly used for loops and calculations. For hardware whose width matters, use explicitly sized vectors such as `reg signed [2:0]`.**

Day 6 flow:

```text
integer
   ↓
signed numbers
   ↓
two's complement
   ↓
3-bit signed representation
   ↓
signed down counter
   ↓
RTL
   ↓
testbench
   ↓
Icarus simulation
   ↓
GTKWave verification
```
