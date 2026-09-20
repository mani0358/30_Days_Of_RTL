# Day 44 — 32-bit Slicer with One-Cycle Latency

## 1. Objective

Design a Verilog module that:

* Accepts a **32-bit input**
* Extracts the **least-significant 4 bits**
* Registers the extracted value
* Produces the output with **one clock-cycle latency**
* Verifies the design using Icarus Verilog and GTKWave

Roadmap assignment:

> Design a 32-bit slicer extracting the least-significant 4 bits with one-cycle latency.

---

# 2. What is a Bit Slicer?

A bit slicer extracts a selected portion of a larger vector.

For example:

```text
32-bit input

31                       4 3       0
+--------------------------+---------+
|       upper 28 bits      |  4 bits |
+--------------------------+---------+
                           ^
                           |
                         output
```

We want:

$$
output=input[3:0]
$$

These are the **4 least-significant bits**, also called the **LSBs**.

---

# 3. What Does LSB Mean?

LSB means:

**Least Significant Bit**

For:

```text
1011
```

the rightmost bit is the LSB:

```text
1011
   ^
  LSB
```

For a 32-bit vector:

```text
31                         0
+--------------------------+
|                          |
+--------------------------+
                           ^
                           |
                          LSB
```

The least-significant 4 bits are:

```text
bits [3:0]
```

---

# 4. What Does MSB Mean?

MSB means:

**Most Significant Bit**

For:

```text
1011
```

the leftmost bit is the MSB:

```text
^
MSB
```

For a 32-bit vector:

```text
31                         0
 ^
 MSB
```

Therefore:

```text
input[31] = MSB
input[0]  = LSB
```

---

# 5. Verilog Part-Select

The syntax:

```verilog
input[3:0]
```

means:

```text
bits 3, 2, 1, 0
```

Therefore:

```verilog
assign output = input[3:0];
```

would extract the lower four bits.

However, this would be **combinational**.

The assignment requires:

> one-cycle latency

Therefore we need a register.

---

# 6. Combinational vs Registered Slicer

## Combinational

```verilog
assign sliced = data[3:0];
```

Conceptually:

```text
data changes
     |
     v
sliced changes immediately
```

There is no clock-cycle latency.

---

## Registered

```verilog
always @(posedge clk)
    sliced <= data[3:0];
```

Now:

```text
data
 |
 | clock edge
 v
register
 |
 | one clocked update
 v
sliced
```

Therefore the output is updated on a clock edge.

---

# 7. What Does One-Cycle Latency Mean?

Suppose:

```text
Cycle 1:
data = 32'h12345678
```

At the active clock edge:

```text
data[3:0] = 8
```

The output register captures:

```text
8
```

After that clock edge:

```text
sliced = 4'h8
```

If a new input arrives for the next cycle:

```text
Cycle 2:
data = 32'hABCDEF35
```

then:

```text
sliced = 4'h5
```

The important point is that the output is **registered**, rather than being a direct combinational connection.

---

# 8. Basic RTL

Create:

```text
Day_44/rtl/slicer_32_to_4.v
```

```verilog
module slicer_32_to_4 (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] data_in,
    output reg  [3:0]  data_out
);

    always @(posedge clk) begin

        if (reset)
            data_out <= 4'b0000;

        else
            data_out <= data_in[3:0];

    end

endmodule
```

---

# 9. Understanding the RTL

The input is:

```verilog
input wire [31:0] data_in
```

Therefore:

```text
data_in[31:0]
```

contains 32 bits.

The output is:

```verilog
output reg [3:0] data_out
```

Therefore:

```text
data_out
```

contains 4 bits.

The slicing operation is:

```verilog
data_in[3:0]
```

The register is:

```verilog
always @(posedge clk)
```

Therefore the extracted value is captured on the rising edge.

---

# 10. Why Is `data_out` a `reg`?

Because it is assigned inside:

```verilog
always
```

using a procedural assignment:

```verilog
data_out <= ...
```

In Verilog-2001:

```text
wire → driven by continuous assignment/module output

reg  → procedural assignment
```

Remember:

> `reg` does not automatically mean a physical register.

The synthesis hardware depends on how the signal is described.

Here, because the assignment occurs inside a `posedge clk` block, synthesis infers a flip-flop/register.

---

# 11. Why Do We Use Nonblocking Assignment?

We use:

```verilog
<=
```

rather than:

```verilog
=
```

because this is sequential logic.

Correct:

```verilog
always @(posedge clk)
    data_out <= data_in[3:0];
```

This follows the sequential RTL coding style from Day 16.

---

# 12. Reset

We include:

```verilog
if (reset)
    data_out <= 4'b0000;
```

Therefore after reset:

```text
data_out = 0000
```

This gives the output a known state.

---

# 13. Truth Table / Functional Verification

Although this is not a logic gate circuit, we can verify the slicing operation using representative inputs.

| `data_in[3:0]` | `data_out` after clock edge |
| :------------: | :-------------------------: |
|     `0000`     |            `0000`           |
|     `0001`     |            `0001`           |
|     `0010`     |            `0010`           |
|     `0011`     |            `0011`           |
|     `0101`     |            `0101`           |
|     `1010`     |            `1010`           |
|     `1111`     |            `1111`           |

The upper 28 bits do not affect the result.

For example:

```text
data_in       = 32'h1234567A
data_in[3:0]  = 4'hA
```

Therefore:

```text
data_out = 4'hA
```

after the active clock edge.

---

# 14. Important Observation

Compare:

```text
32'h0000000A
```

and:

```text
32'hFFFFFFFF
```

Their lower four bits are:

```text
000A → A
FFFF → F
```

Now compare:

```text
32'h12345678
32'h87654378
```

Both have:

```text
data_in[3:0] = 8
```

Therefore both produce:

```text
data_out = 8
```

The upper 28 bits are ignored.

---

# 15. Testbench

Create:

```text
Day_44/tb/tb_slicer_32_to_4.v
```

```verilog
`timescale 1ns/1ps

module tb_slicer_32_to_4;

    reg        clk;
    reg        reset;
    reg [31:0] data_in;

    wire [3:0] data_out;

    slicer_32_to_4 uut (
        .clk     (clk),
        .reset   (reset),
        .data_in (data_in),
        .data_out(data_out)
    );

    always #5 clk = ~clk;

    task apply_and_check;
        input [31:0] test_data;
        input [3:0]  expected;

        begin

            @(negedge clk);

            data_in = test_data;

            @(posedge clk);

            #1;

            if (data_out === expected)

                $display(
                    "PASS: data_in = %h | data_out = %h",
                    test_data,
                    data_out
                );

            else

                $display(
                    "ERROR: data_in = %h | data_out = %h | expected = %h",
                    test_data,
                    data_out,
                    expected
                );

        end

    endtask

    initial begin

        $dumpfile("slicer.vcd");
        $dumpvars(0, tb_slicer_32_to_4);

        clk = 1'b0;
        reset = 1'b1;
        data_in = 32'b0;

        #12;

        reset = 1'b0;

        // Test cases

        apply_and_check(32'h00000000, 4'h0);

        apply_and_check(32'h00000001, 4'h1);

        apply_and_check(32'h12345678, 4'h8);

        apply_and_check(32'hABCDEF35, 4'h5);

        apply_and_check(32'hFFFFFFFF, 4'hF);

        apply_and_check(32'h87654320, 4'h0);

        apply_and_check(32'h1234567A, 4'hA);

        apply_and_check(32'h0000000F, 4'hF);

        #20;

        $finish;

    end

endmodule
```

---

# 16. Compile

From the Day 44 directory:

```bash
mkdir -p sim
```

Compile:

```bash
iverilog -o sim/slicer_test \
    rtl/slicer_32_to_4.v \
    tb/tb_slicer_32_to_4.v
```

Run:

```bash
vvp sim/slicer_test
```

---

# 17. Expected Output

You should see results similar to:

```text
PASS: data_in = 00000000 | data_out = 0

PASS: data_in = 00000001 | data_out = 1

PASS: data_in = 12345678 | data_out = 8

PASS: data_in = abcdef35 | data_out = 5

PASS: data_in = ffffffff | data_out = f

PASS: data_in = 87654320 | data_out = 0

PASS: data_in = 1234567a | data_out = a

PASS: data_in = 0000000f | data_out = f
```

---

# 18. GTKWave

Run:

```bash
gtkwave slicer.vcd
```

Add:

```text
clk
reset
data_in
data_out
```

You can also expand:

```text
uut.data_in
uut.data_out
```

---

# 19. What to Observe in GTKWave

Suppose:

```text
data_in = 32'h12345678
```

The lower four bits are:

```text
1000
```

Therefore after the clock edge:

```text
data_out = 8
```

Then:

```text
data_in = 32'hABCDEF35
```

The lower four bits are:

```text
0101
```

After the next clock edge:

```text
data_out = 5
```

---

# 20. Why the Upper 28 Bits Don't Matter

Consider:

```text
data_in = 32'b
1111_1111_1111_1111_1111_1111_1111_1010
```

The slicer sees only:

```text
data_in[3:0]
```

which is:

```text
1010
```

Therefore:

```text
data_out = 1010
```

Changing:

```text
data_in[31:4]
```

does not change the output.

---

# 21. Part-Select vs Bit-Select

### Bit-select

Selects one bit:

```verilog
data_in[3]
```

Result:

```text
1 bit
```

### Part-select

Selects a range:

```verilog
data_in[3:0]
```

Result:

```text
4 bits
```

Another example:

```verilog
data_in[15:8]
```

extracts:

```text
8 bits
```

---

# 22. Other Slicer Examples

### Lowest 8 bits

```verilog
data_in[7:0]
```

### Lowest 16 bits

```verilog
data_in[15:0]
```

### Upper 8 bits

```verilog
data_in[31:24]
```

### Middle 8 bits

```verilog
data_in[15:8]
```

---

# 23. One-Cycle Latency

A registered slicer is:

```text
             Clock
               |
               v
data_in ---> [ REGISTER ] ---> data_out
                |
             data_in[3:0]
```

The register captures the input slice on a rising edge.

Therefore:

```text
Input available
      |
      v
Clock edge
      |
      v
Output register updates
```

---

# 24. Combinational vs Sequential Slicer

| Feature        | Combinational | Registered              |
| -------------- | ------------- | ----------------------- |
| Clock          | No            | Yes                     |
| Register       | No            | Yes                     |
| Latency        | 0 cycles      | Clocked                 |
| Code           | `assign`      | `always @(posedge clk)` |
| Output changes | With input    | At clock edge           |
| Hardware       | Wiring        | Flip-flops + wiring     |

---

# 25. Important Placement Question

### What is the difference between:

```verilog
assign out = in[3:0];
```

and:

```verilog
always @(posedge clk)
    out <= in[3:0];
```

Answer:

The first is combinational and has no clocked storage.

The second is sequential and stores the extracted 4-bit value in a register.

---

# 26. Another Important Question

### Does slicing itself require hardware?

A simple bit slice such as:

```verilog
data_in[3:0]
```

is essentially a selection of wires.

The hardware cost of the slicing itself is normally negligible.

However, if we register it:

```verilog
out <= data_in[3:0];
```

four flip-flops are required for the 4-bit output register.

---

# 27. Hardware Representation

The design can be visualized as:

```text
data_in[31:4]
      |
      | ignored
      X


data_in[3:0]
      |
      v
+-------------+
| 4 D-FFs     |
|             |
| D0 → Q0     |
| D1 → Q1     |
| D2 → Q2     |
| D3 → Q3     |
+-------------+
      |
      v
  data_out[3:0]
```

So the design contains:

```text
4 flip-flops
```

for the output register.

---

# 28. Reset Behavior

During reset:

```verilog
if (reset)
    data_out <= 4'b0000;
```

Therefore:

```text
reset = 1
       ↓
data_out = 0000
```

When reset is released:

```text
reset = 0
```

the next rising clock edge captures:

```text
data_in[3:0]
```

---

# 29. Synchronous Reset

The reset in today's design is:

```verilog
always @(posedge clk)
```

with:

```verilog
if (reset)
```

Therefore this is a:

**Synchronous reset**

The output changes due to reset only on a clock edge.

Compare with an asynchronous reset:

```verilog
always @(posedge clk or posedge reset)
```

which responds to reset independently of the clock.

This connects directly to the reset concepts from the earlier days.

---

# 30. Parameterized Slicer

The same idea can be generalized.

For example, we can extract a configurable number of LSBs:

```verilog
module parameterized_slicer #(
    parameter WIDTH = 4
)(
    input  wire             clk,
    input  wire             reset,
    input  wire [31:0]      data_in,
    output reg  [WIDTH-1:0] data_out
);

    always @(posedge clk) begin
        if (reset)
            data_out <= {WIDTH{1'b0}};
        else
            data_out <= data_in[WIDTH-1:0];
    end

endmodule
```

For:

```text
WIDTH = 4
```

we get:

```text
data_in[3:0]
```

For:

```text
WIDTH = 8
```

we get:

```text
data_in[7:0]
```

---

# 31. Placement Interview Questions

## Q1. What is bit slicing?

Extracting a selected range of bits from a vector.

Example:

```verilog
data[7:4]
```

extracts four bits.

---

## Q2. What are the LSBs of a 32-bit vector?

The bits:

```text
[3:0]
```

are the least-significant four bits.

---

## Q3. What is a part-select?

Selecting a range of bits:

```verilog
data[7:4]
```

---

## Q4. What is a bit-select?

Selecting one bit:

```verilog
data[4]
```

---

## Q5. What hardware does a 4-bit registered slicer require?

Four flip-flops for the four registered output bits, plus the corresponding connections.

---

## Q6. Does `data[3:0]` itself introduce a clock-cycle delay?

No.

The delay comes from registering the selected bits.

---

## Q7. Why is `data_out` declared as `reg`?

Because it is assigned procedurally inside an `always` block in Verilog.

---

## Q8. Why is `<=` used?

Because `data_out` is sequential state updated on a clock edge.

---

## Q9. What is one-cycle latency?

The output corresponding to an input is available after the relevant clocked register update rather than immediately through a combinational path.

---

## Q10. What is the difference between `[31:0]` and `[0:31]`?

Both contain 32 bits, but their index directions differ.

The conventional declaration:

```verilog
[31:0]
```

uses 31 as the MSB and 0 as the LSB.

---

# 32. Placement Practice

### Question 1

Given:

```text
data = 32'h123456AB
```

What is:

```text
data[3:0]
```

Answer:

```text
1011
```

or:

```text
B
```

---

### Question 2

Given:

```text
data = 32'hDEADBEEF
```

What is:

```text
data[3:0]
```

Answer:

```text
F
```

---

### Question 3

Given:

```text
data = 32'h87654320
```

What is:

```text
data[3:0]
```

Answer:

```text
0
```

---

### Question 4

Given:

```text
data = 32'hFFFF1234
```

What is:

```text
data[3:0]
```

Answer:

```text
4
```

---

### Question 5

How many flip-flops are required for:

```verilog
reg [3:0] data_out;
```

when updated on `posedge clk`?

Answer:

```text
4 flip-flops
```

---

# 33. Practice Questions

## Basic

1. What is an LSB?
2. What is an MSB?
3. What is a bit-select?
4. What is a part-select?
5. What does `[3:0]` mean?
6. What is one-cycle latency?

## RTL

7. Write a 32-to-4 LSB slicer.
8. Add synchronous reset.
9. Add a valid signal.
10. Make the slicer parameterized.
11. Extract `[7:4]` instead of `[3:0]`.

## Placement

12. How many flip-flops are needed for an 8-bit registered slicer?
13. Does a combinational slicer need a clock?
14. What is the difference between a registered and combinational slicer?
15. Why is `<=` preferred in the clocked block?

---

# 34. Day 44 Assignment

Design a:

```text
32-bit → 4-bit
```

registered slicer.

Requirements:

```text
Input:
    clk
    reset
    data_in[31:0]

Output:
    data_out[3:0]
```

Behavior:

```text
data_out <= data_in[3:0]
```

on each rising edge.

Verify at least:

```text
32'h00000000 → 0
32'h00000001 → 1
32'h12345678 → 8
32'hABCDEF35 → 5
32'hFFFFFFFF → F
32'h87654320 → 0
32'h1234567A → A
32'h0000000F → F
```

---

# 35. Git Structure

```text
RTL_50_Days/
│
├── Day_41/
│
├── Day_42/
│
├── Day_43/
│
├── Day_44/
│   ├── README.md
│   │
│   ├── rtl/
│   │   └── slicer_32_to_4.v
│   │
│   ├── tb/
│   │   └── tb_slicer_32_to_4.v
│   │
│   └── sim/
│
└── ...
```

Commit:

```bash
git add Day_44/
git commit -m "Day 44: 32-bit LSB slicer with one-cycle latency"
git push
```

---

# 36. Day 44 Key Takeaways

### LSB

```text
Least Significant Bit
```

For a 32-bit vector:

```text
data_in[0]
```

is the LSB.

### Four LSBs

```verilog
data_in[3:0]
```

### Registered extraction

```verilog
always @(posedge clk)
    data_out <= data_in[3:0];
```

### Output width

```text
4 bits
```

### Register size

```text
4 flip-flops
```

### Important distinction

```text
data_in[3:0]
```

is only a bit selection.

```verilog
data_out <= data_in[3:0];
```

inside a clocked block creates registered storage and therefore clocked latency.

---

# 37. Final Mental Model

```text
                 32-bit input
                     |
                     |
       +-------------+-------------+
       |                           |
    bits [31:4]                 bits [3:0]
       |                           |
     ignored                       |
                                   v
                            +-------------+
             clk ---------->| 4-bit REG  |
                            +-------------+
                                   |
                                   v
                             4-bit output
```

The complete RTL idea is simply:

```verilog
always @(posedge clk) begin
    if (reset)
        data_out <= 4'b0000;
    else
        data_out <= data_in[3:0];
end
```

**Day 44 complete.**

Next roadmap topic:

# Day 45 — High Cohesion

We will move from individual RTL blocks to **good RTL architecture and coding principles**, starting with **high cohesion**—keeping closely related functionality together so modules are easier to understand, verify, reuse, and maintain.
