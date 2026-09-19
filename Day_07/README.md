# Day 07 — Verilog `parameter` and `localparam`

## 1. Day 7 Objective

Today we will learn:

* What a `parameter` is
* Why parameters are used in RTL
* Parameter syntax
* Parameterized modules
* How to override a parameter
* What `localparam` is
* Difference between `parameter` and `localparam`
* Parameterized bus widths
* Parameterized counters
* Compile and simulate parameterized RTL
* Placement interview questions

### Day 7 Roadmap Assignment

> **Perform an experiment using `parameter` and `localparam`.**

---

# 2. What is a Parameter?

A `parameter` is a constant value that can be used to make a Verilog module **configurable**.

Instead of hard-coding a value:

```verilog
reg [7:0] data;
```

we can write:

```verilog
parameter WIDTH = 8;

reg [WIDTH-1:0] data;
```

Now the same module can be used with different widths.

For example:

```text
WIDTH = 4
WIDTH = 8
WIDTH = 16
WIDTH = 32
```

without rewriting the RTL.

---

# 3. Why Do We Need Parameters?

Suppose you need:

```text
4-bit adder
8-bit adder
16-bit adder
32-bit adder
```

Without parameters, you might create four separate modules.

With a parameter:

```verilog
parameter WIDTH = 8;
```

one module can implement all of them.

This is one of the most important ideas in reusable RTL design.

---

# 4. Basic Syntax

```verilog
module example #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);

    assign y = a + b;

endmodule
```

The important part is:

```verilog
#(
    parameter WIDTH = 8
)
```

---

# 5. Parameterized 4-bit Adder

First consider a fixed-width design:

```verilog
module adder_4bit (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [3:0] sum
);

    assign sum = a + b;

endmodule
```

This works only for the intended 4-bit interface.

Now parameterize it.

```verilog
module parameterized_adder #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] sum
);

    assign sum = a + b;

endmodule
```

Now:

```text
WIDTH = 4  → 4-bit adder
WIDTH = 8  → 8-bit adder
WIDTH = 16 → 16-bit adder
```

---

# 6. Understanding `[WIDTH-1:0]`

Suppose:

```verilog
parameter WIDTH = 8;
```

Then:

```verilog
[WIDTH-1:0]
```

becomes:

```text
[7:0]
```

So:

```verilog
input wire [WIDTH-1:0] a;
```

becomes:

```verilog
input wire [7:0] a;
```

If:

```verilog
WIDTH = 4;
```

then:

```text
[WIDTH-1:0]
=
[3:0]
```

Therefore the expression automatically adapts to the selected width.

---

# 7. Parameter Override

The default value:

```verilog
parameter WIDTH = 4
```

can be overridden when instantiating the module.

Example:

```verilog
parameterized_adder #(
    .WIDTH(8)
) dut (
    .a(a),
    .b(b),
    .sum(sum)
);
```

Now this particular instance is an 8-bit adder.

---

# 8. Default Parameter

If we instantiate:

```verilog
parameterized_adder dut (
    .a(a),
    .b(b),
    .sum(sum)
);
```

then the default value is used:

```verilog
WIDTH = 4
```

So there is no requirement to override every parameter.

---

# 9. Multiple Instances with Different Widths

This is where parameters become especially useful.

```verilog
parameterized_adder #(
    .WIDTH(4)
) adder4 (
    .a(a4),
    .b(b4),
    .sum(sum4)
);

parameterized_adder #(
    .WIDTH(8)
) adder8 (
    .a(a8),
    .b(b8),
    .sum(sum8)
);
```

The same RTL module is used for both.

Hardware instances have different widths.

---

# 10. What is `localparam`?

A `localparam` is also a constant.

Example:

```verilog
localparam WIDTH = 8;
```

The important difference is that a `localparam` is intended to remain fixed inside the module and is **not meant to be overridden during module instantiation**.

Example:

```verilog
module example #(
    parameter WIDTH = 8
);

    localparam MAX_VALUE = (1 << WIDTH) - 1;

endmodule
```

Here:

```text
WIDTH
```

can be configured.

But:

```text
MAX_VALUE
```

is calculated internally from `WIDTH`.

---

# 11. `parameter` vs `localparam`

| Feature                          | `parameter` | `localparam` |
| -------------------------------- | ----------- | ------------ |
| Constant                         | Yes         | Yes          |
| Can define default configuration | Yes         | No           |
| Intended to be overridden        | Yes         | No           |
| Useful for module configuration  | Yes         | No           |
| Useful for internal constants    | Yes         | Yes          |
| Can depend on another parameter  | Yes         | Yes          |

### Simple rule

Remember:

```text
parameter  → configurable from outside
localparam → fixed inside the module
```

---

# 12. Example of Parameter + Localparam

Consider a counter.

```verilog
module counter #(
    parameter WIDTH = 4
)(
    input wire clk,
    input wire reset,
    output reg [WIDTH-1:0] count
);

    localparam MAX_COUNT = (1 << WIDTH) - 1;

    always @(posedge clk) begin
        if (reset)
            count <= 0;
        else if (count == MAX_COUNT)
            count <= 0;
        else
            count <= count + 1'b1;
    end

endmodule
```

Here:

```verilog
parameter WIDTH = 4;
```

controls the counter width.

And:

```verilog
localparam MAX_COUNT = (1 << WIDTH) - 1;
```

calculates the maximum count internally.

For:

```text
WIDTH = 4
```

we get:

```text
MAX_COUNT = 15
```

For:

```text
WIDTH = 8
```

we get:

```text
MAX_COUNT = 255
```

---

# 13. Main Day 7 Experiment

We will build a **parameterized counter**.

Requirements:

* Configurable width
* Reset
* Counting
* Maximum-count detection
* Internal `localparam`
* Verify two different widths

---

# 14. RTL — Parameterized Counter

Create:

```text
rtl/parameter_counter.v
```

```verilog
module parameter_counter #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             reset,
    output reg [WIDTH-1:0] count
);

    localparam MAX_COUNT = (1 << WIDTH) - 1;

    always @(posedge clk) begin
        if (reset)
            count <= 0;
        else if (count == MAX_COUNT)
            count <= 0;
        else
            count <= count + 1'b1;
    end

endmodule
```

---

# 15. Understand the RTL

### Parameter

```verilog
parameter WIDTH = 4;
```

Default width is 4.

### Output

```verilog
output reg [WIDTH-1:0] count
```

For `WIDTH = 4`:

```text
count[3:0]
```

For `WIDTH = 8`:

```text
count[7:0]
```

### Local parameter

```verilog
localparam MAX_COUNT = (1 << WIDTH) - 1;
```

This calculates the largest value representable by the selected width.

---

# 16. Why `(1 << WIDTH)`?

`<<` is the left-shift operator.

For:

```text
WIDTH = 4
```

we have:

```text
1 << 4
```

which gives:

```text
16
```

Then:

```text
16 - 1 = 15
```

Therefore:

```text
MAX_COUNT = 15
```

For 8 bits:

```text
1 << 8 = 256
256 - 1 = 255
```

---

# 17. Testbench

Create:

```text
tb/tb_parameter_counter.v
```

```verilog
`timescale 1ns/1ps

module tb_parameter_counter;

    reg clk;
    reg reset;

    wire [3:0] count4;
    wire [7:0] count8;

    // 4-bit counter
    parameter_counter #(
        .WIDTH(4)
    ) counter4 (
        .clk   (clk),
        .reset (reset),
        .count (count4)
    );

    // 8-bit counter
    parameter_counter #(
        .WIDTH(8)
    ) counter8 (
        .clk   (clk),
        .reset (reset),
        .count (count8)
    );

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test
    initial begin

        $dumpfile("sim/parameter_counter.vcd");
        $dumpvars(0, tb_parameter_counter);

        reset = 1;

        #12;

        reset = 0;

        #180;

        $finish;

    end

endmodule
```

---

# 18. What Are We Testing?

We have two instances:

### Instance 1

```verilog
.WIDTH(4)
```

Therefore:

```text
count4 = 4 bits
```

and it counts:

```text
0 → 1 → 2 → ... → 15 → 0
```

### Instance 2

```verilog
.WIDTH(8)
```

Therefore:

```text
count8 = 8 bits
```

and it counts:

```text
0 → 1 → 2 → ... → 255 → 0
```

The simulation duration is not long enough to reach 255 for the 8-bit counter, but the 4-bit counter will demonstrate wrapping.

---

# 19. Expected 4-bit Counter

After reset:

| Clock | count4 |
| ----: | -----: |
| Reset |      0 |
|     1 |      1 |
|     2 |      2 |
|     3 |      3 |
|     4 |      4 |
|   ... |    ... |
|    15 |     15 |
|    16 |      0 |
|    17 |      1 |

This demonstrates:

```text
0 → 15 → 0
```

---

# 20. Expected 8-bit Counter

The 8-bit counter has:

$$
2^8 = 256
$$

states.

Therefore:

```text
0 → 1 → 2 → ... → 254 → 255 → 0
```

---

# 21. Directory Structure

Create:

```bash
mkdir -p ~/Verilog_50_Days/Day_07/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_07
```

Directory:

```text
Day_07/
├── rtl/
│   └── parameter_counter.v
├── tb/
│   └── tb_parameter_counter.v
├── sim/
└── wave/
```

---

# 22. Compile

Run:

```bash
iverilog -o sim/parameter_counter_sim \
rtl/parameter_counter.v \
tb/tb_parameter_counter.v
```

If there is no error, compilation succeeded.

---

# 23. Run

```bash
vvp sim/parameter_counter_sim
```

The VCD file will be generated:

```text
sim/parameter_counter.vcd
```

---

# 24. Open GTKWave

```bash
gtkwave sim/parameter_counter.vcd
```

Add:

```text
clk
reset
count4
count8
```

Verify:

```text
count4:
0 → 1 → 2 → ... → 15 → 0
```

and observe that `count8` increments independently.

---

# 25. Parameter Experiment

Now perform an important experiment.

Change:

```verilog
parameter WIDTH = 4
```

to:

```verilog
parameter WIDTH = 6
```

Compile again.

The default counter now becomes:

```text
6-bit
```

Its maximum value is:

$$
2^6-1=63
$$

Therefore:

```text
0 → 1 → 2 → ... → 63 → 0
```

No changes to the counter logic are required.

That is the main advantage of parameterized RTL.

---

# 26. Another Experiment

Change:

```verilog
.WIDTH(4)
```

to:

```verilog
.WIDTH(3)
```

Now:

```text
count3
```

has 3 bits.

Maximum value:

$$
2^3-1=7
$$

Sequence:

```text
0
1
2
3
4
5
6
7
0
```

---

# 27. Why Parameters Are Important in Real RTL

Real chip designs contain many configurable blocks.

Examples:

```text
Data width
Address width
FIFO depth
Number of channels
Counter width
Register width
Number of pipeline stages
Memory size
```

Instead of writing separate modules:

```text
fifo_4bit
fifo_8bit
fifo_16bit
fifo_32bit
```

we can write:

```verilog
fifo #(
    .DATA_WIDTH(32)
)
```

and configure the design.

---

# 28. Parameter Naming

Good parameter names are descriptive:

```verilog
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 10;
parameter DEPTH      = 1024;
parameter CHANNELS   = 4;
```

Avoid meaningless names such as:

```verilog
parameter X = 32;
```

Good naming becomes especially important in large RTL projects.

---

# 29. Parameter vs `localparam` Example

Consider:

```verilog
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

endmodule
```

Here the user can configure:

```text
DATA_WIDTH
DEPTH
```

but:

```text
ADDR_WIDTH
```

is derived internally.

This is a common RTL design pattern.

---

# 30. Common Mistakes

### Mistake 1 — Forgetting `#(...)`

Wrong:

```verilog
module counter (
    parameter WIDTH = 8
);
```

Correct parameterized module syntax:

```verilog
module counter #(
    parameter WIDTH = 8
)(
    ...
);
```

---

### Mistake 2 — Wrong bus width

For width `WIDTH`:

```verilog
[WIDTH-1:0]
```

not:

```verilog
[WIDTH:0]
```

Because `[WIDTH:0]` contains `WIDTH+1` bits.

---

### Mistake 3 — Confusing parameter and localparam

Remember:

```text
parameter  → configurable
localparam → internal constant
```

---

### Mistake 4 — Hard-coding values

Instead of:

```verilog
if (count == 15)
```

for a parameterized 4-bit counter, use:

```verilog
localparam MAX_COUNT = (1 << WIDTH) - 1;
```

Then the RTL automatically adapts to `WIDTH`.

---

### Mistake 5 — Changing width but not testbench

If the DUT becomes:

```text
WIDTH = 8
```

the testbench signal should also be:

```verilog
reg [7:0] / wire [7:0]
```

as appropriate.

---

# 31. Placement Interview Questions

### Q1. What is a parameter in Verilog?

A parameter is a constant used to configure a module without modifying its RTL.

### Q2. Why are parameters useful?

They make RTL reusable and scalable.

### Q3. What is a `localparam`?

A constant intended to be fixed inside the module and not externally overridden.

### Q4. Difference between parameter and localparam?

```text
parameter  → externally configurable
localparam → internally fixed
```

### Q5. How do you override a parameter?

Example:

```verilog
counter #(
    .WIDTH(16)
) dut (...);
```

### Q6. What does `[WIDTH-1:0]` mean?

It creates a bus containing `WIDTH` bits.

### Q7. If WIDTH = 8, what is `[WIDTH-1:0]`?

```text
[7:0]
```

### Q8. If WIDTH = 16?

```text
[15:0]
```

### Q9. What is the maximum unsigned value of an N-bit vector?

$$
2^N-1
$$

### Q10. What is the maximum value of a 4-bit unsigned counter?

```text
15
```

### Q11. What is the purpose of `localparam MAX_COUNT`?

It creates an internal constant based on the selected counter width.

### Q12. Can two instances of the same parameterized module have different widths?

Yes.

Example:

```verilog
counter #(.WIDTH(4)) c4 (...);
counter #(.WIDTH(8)) c8 (...);
```

### Q13. Does changing a parameter dynamically during simulation change hardware width?

No. Parameters are elaboration/configuration constants, not runtime variables.

### Q14. Is a parameter a variable?

No. It is a constant.

### Q15. Why is parameterization important in RTL?

It allows the same RTL module to be reused for different design configurations.

---

# 32. Day 7 Assignment

Complete these before Day 8.

### Assignment 1

Create a parameterized **AND gate**:

```text
WIDTH = 4
WIDTH = 8
WIDTH = 16
```

It should perform:

```text
Y = A & B
```

---

### Assignment 2

Create a parameterized register:

```text
WIDTH = 4
WIDTH = 8
WIDTH = 16
```

Verify all three configurations.

---

### Assignment 3

Create a parameterized counter with:

```text
WIDTH = 3
WIDTH = 4
WIDTH = 8
```

Verify the maximum count for each.

---

### Assignment 4 — Parameter + localparam

Create:

```verilog
parameter WIDTH = 8;
localparam MAX_VALUE = (1 << WIDTH) - 1;
```

Display both values during simulation.

---

# 33. Day 7 Verification Table

| WIDTH | Number of states | Maximum value |
| ----: | ---------------: | ------------: |
|     3 |                8 |             7 |
|     4 |               16 |            15 |
|     5 |               32 |            31 |
|     8 |              256 |           255 |
|    16 |           65,536 |        65,535 |

General formula:

$$
\boxed{\text{Number of states}=2^{WIDTH}}
$$

$$
\boxed{\text{Maximum}=2^{WIDTH}-1}
$$

---

# 34. Day 7 Golden Rule

> **Use `parameter` when a module should be configurable. Use `localparam` for constants that should be derived or fixed internally.**

The key idea:

```text
Hard-coded RTL
      ↓
Parameterized RTL
      ↓
Reusable RTL
      ↓
Scalable hardware design
```

---

# 35. Day 7 Final Checklist

Before moving to Day 8, you should be able to explain:

* [ ] What is a parameter?
* [ ] Why use parameters?
* [ ] Parameter syntax
* [ ] Parameter override
* [ ] What is localparam?
* [ ] Parameter vs localparam
* [ ] `[WIDTH-1:0]`
* [ ] Parameterized counter
* [ ] Maximum value of an N-bit counter
* [ ] Number of states of an N-bit counter
* [ ] Why hard-coded constants should be avoided when configuration is intended
* [ ] How to compile and simulate a parameterized module
* [ ] How to verify it in GTKWave

```
