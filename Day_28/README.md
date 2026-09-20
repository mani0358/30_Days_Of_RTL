# Day 28 — Pipeline in Verilog RTL

## 📌 Topic

**Pipeline**

## 🎯 Objective

Understand how pipelining divides a large combinational operation into multiple stages separated by registers.

### Roadmap Assignment

Implement a pipeline for:

```text
(A + B) * C - D
```

---

# 1. Learning Objectives

By the end of Day 28, you should be able to:

* Understand what a pipeline is.
* Understand pipeline stages.
* Understand pipeline registers.
* Understand latency and throughput.
* Understand pipeline filling and draining.
* Understand critical path reduction.
* Understand data alignment.
* Implement a multi-stage pipeline in Verilog.
* Use nonblocking assignments in sequential pipeline logic.
* Simulate the pipeline using Icarus Verilog.
* Analyze the pipeline using GTKWave.
* Answer basic pipeline interview questions.

---

# 2. What is a Pipeline?

A pipeline divides a large combinational circuit into smaller stages.

Registers are placed between the stages.

```text
Combinational
     ↓
   Register
     ↓
Combinational
     ↓
   Register
     ↓
Combinational
     ↓
   Register
```

For today's assignment:

```text
(A + B) * C - D
```

we divide the operation into three stages.

```text
Stage 1        Stage 2        Stage 3

 A + B          SUM × C        PRODUCT - D
   │               │                │
   ▼               ▼                ▼
 [REG]           [REG]            [REG]
```

---

# 3. Why Pipeline?

Without pipelining:

```text
A + B → × C → - D → RESULT
```

The entire operation forms one long combinational path.

With pipelining:

```text
A + B → REG → × C → REG → - D → REG
```

The long path is divided into smaller paths.

This can allow a higher operating frequency.

---

# 4. Latency

Latency is the number of clock cycles between accepting an input and producing the corresponding output.

Our design contains:

```text
Stage 1
Stage 2
Stage 3
```

Therefore the pipeline has approximately:

```text
3 clock stages
```

of latency from input sampling to the registered result.

---

# 5. Throughput

Throughput is the rate at which results can be produced.

Once the pipeline is full:

```text
Cycle 1 → Input 1
Cycle 2 → Input 2
Cycle 3 → Input 3
Cycle 4 → Input 4
```

Different inputs can occupy different pipeline stages simultaneously.

Therefore a properly designed pipeline can produce:

```text
1 result / clock cycle
```

after the pipeline is filled.

---

# 6. Pipeline Assignment

We implement:

```text
RESULT = (A + B) * C - D
```

with:

```text
A = 8-bit
B = 8-bit
C = 8-bit
D = 8-bit
```

The roadmap does not specify operand widths, so **8-bit unsigned operands are selected for this laboratory implementation**.

---

# 7. Pipeline Architecture

## Stage 1

Calculate:

```text
SUM = A + B
```

Also register `C` and `D` because they are required by later stages.

```text
SUM = A + B
C1  = C
D1  = D
```

---

## Stage 2

Calculate:

```text
PRODUCT = SUM * C1
```

and delay D:

```text
PRODUCT = SUM * C1
D2      = D1
```

---

## Stage 3

Calculate:

```text
RESULT = PRODUCT - D2
```

Complete pipeline:

```text
A ─────┐
       │
B ─────┤
       ▼
     ADD
       │
       ▼
    SUM_REG
       │
       ├────────────── C_REG
       │
       ▼
    MULTIPLY
       │
       ▼
 PRODUCT_REG
       │
       ▼
   SUBTRACT ◄──── D_REG2
       │
       ▼
     RESULT
```

---

# 8. Why Must D Be Delayed?

Consider:

```text
(A + B) * C - D
```

The multiplication takes place in a later pipeline stage.

Therefore D must also be delayed.

Otherwise, the current `D` could be subtracted from an older multiplication result.

This would mix data belonging to different input transactions.

Therefore:

```text
D → D_REG → D_REG2 → subtraction
```

is required.

This is called:

**Data alignment**

---

# 9. Width Calculation

### A + B

Two 8-bit unsigned values can produce:

```text
255 + 255 = 510
```

510 requires 9 bits.

Therefore:

```verilog
reg [8:0] sum_reg;
```

### SUM × C

`SUM` is 9 bits and `C` is 8 bits.

Maximum:

```text
510 × 255 = 130050
```

This requires 17 bits.

Therefore:

```verilog
reg [16:0] product_reg;
```

---

# 10. RTL Code

Create:

```text
pipeline_expression.v
```

```verilog
module pipeline_expression (
    input  wire        clk,
    input  wire        reset,

    input  wire [7:0]  A,
    input  wire [7:0]  B,
    input  wire [7:0]  C,
    input  wire [7:0]  D,

    output reg  [16:0] result
);

    // Stage 1 registers
    reg [8:0] sum_reg;
    reg [7:0] c_reg;
    reg [7:0] d_reg;

    // Stage 2 registers
    reg [16:0] product_reg;
    reg [7:0] d_reg2;

    always @(posedge clk) begin

        if (reset) begin
            sum_reg     <= 9'd0;
            c_reg       <= 8'd0;
            d_reg       <= 8'd0;

            product_reg <= 17'd0;
            d_reg2      <= 8'd0;

            result      <= 17'd0;
        end

        else begin

            // Stage 1
            sum_reg <= {1'b0, A} + {1'b0, B};
            c_reg   <= C;
            d_reg   <= D;

            // Stage 2
            product_reg <= sum_reg * c_reg;
            d_reg2      <= d_reg;

            // Stage 3
            result <= product_reg - d_reg2;

        end
    end

endmodule
```

---

# 11. Why Use `<=`?

Pipeline registers are sequential elements.

Therefore we use:

```verilog
<=
```

instead of:

```verilog
=
```

Example:

```verilog
sum_reg     <= A + B;
product_reg <= sum_reg * c_reg;
result      <= product_reg - d_reg2;
```

Nonblocking assignments allow the registers to update according to the previous pipeline-stage values on the same clock edge.

---

# 12. Testbench

Create:

```text
tb_pipeline_expression.v
```

```verilog
`timescale 1ns/1ps

module tb_pipeline_expression;

    reg clk;
    reg reset;

    reg [7:0] A;
    reg [7:0] B;
    reg [7:0] C;
    reg [7:0] D;

    wire [16:0] result;

    pipeline_expression dut (
        .clk(clk),
        .reset(reset),
        .A(A),
        .B(B),
        .C(C),
        .D(D),
        .result(result)
    );

    // 10 ns clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, tb_pipeline_expression);

        clk   = 1'b0;
        reset = 1'b1;

        A = 0;
        B = 0;
        C = 0;
        D = 0;

        #12;

        reset = 1'b0;

        // Test 1
        A = 8'd5;
        B = 8'd3;
        C = 8'd2;
        D = 8'd4;

        // Test 2
        #10;
        A = 8'd10;
        B = 8'd5;
        C = 8'd3;
        D = 8'd2;

        // Test 3
        #10;
        A = 8'd7;
        B = 8'd1;
        C = 8'd4;
        D = 8'd5;

        // Test 4
        #10;
        A = 8'd20;
        B = 8'd10;
        C = 8'd2;
        D = 8'd6;

        #50;

        $finish;
    end

    initial begin
        $monitor(
            "TIME=%0t A=%0d B=%0d C=%0d D=%0d RESULT=%0d",
            $time, A, B, C, D, result
        );
    end

endmodule
```

---

# 13. Expected Calculations

### Test 1

```text
A = 5
B = 3
C = 2
D = 4

(5 + 3) × 2 - 4

= 8 × 2 - 4
= 16 - 4
= 12
```

Expected:

```text
RESULT = 12
```

### Test 2

```text
(10 + 5) × 3 - 2

= 15 × 3 - 2
= 45 - 2
= 43
```

Expected:

```text
RESULT = 43
```

### Test 3

```text
(7 + 1) × 4 - 5

= 8 × 4 - 5
= 32 - 5
= 27
```

Expected:

```text
RESULT = 27
```

### Test 4

```text
(20 + 10) × 2 - 6

= 30 × 2 - 6
= 60 - 6
= 54
```

Expected:

```text
RESULT = 54
```

---

# 14. Directory Setup

On Ubuntu:

```bash
mkdir -p ~/RTL_50_Days/Day_28_Pipeline
cd ~/RTL_50_Days/Day_28_Pipeline
```

Create the RTL:

```bash
nano pipeline_expression.v
```

Create the testbench:

```bash
nano tb_pipeline_expression.v
```

---

# 15. Compile

Use Icarus Verilog:

```bash
iverilog -o pipeline_sim pipeline_expression.v tb_pipeline_expression.v
```

If there are no errors, run:

```bash
vvp pipeline_sim
```

---

# 16. View Waveform

The testbench creates:

```text
pipeline.vcd
```

Open it:

```bash
gtkwave pipeline.vcd
```

Add:

```text
clk
reset
A
B
C
D
result
```

For deeper analysis, add:

```text
dut.sum_reg
dut.c_reg
dut.d_reg
dut.product_reg
dut.d_reg2
```

You should be able to see the data moving through the pipeline stages.

---

# 17. Pipeline Timing

For four consecutive inputs:

```text
              Cycle
              1   2   3   4   5   6

Input 1       S1  S2  S3
Input 2           S1  S2  S3
Input 3               S1  S2  S3
Input 4                   S1  S2  S3
```

After filling:

```text
One result can be produced per clock.
```

---

# 18. Unpipelined vs Pipelined

| Feature            | Unpipelined       | Pipelined          |
| ------------------ | ----------------- | ------------------ |
| Registers          | Fewer             | More               |
| Latency            | Lower in cycles   | Higher in cycles   |
| Throughput         | Lower             | Higher             |
| Critical path      | Longer            | Shorter            |
| Maximum frequency  | Potentially lower | Potentially higher |
| Area               | Lower             | Higher             |
| Clock power        | Lower             | Higher             |
| Control complexity | Lower             | Higher             |

---

# 19. Critical Path

Without pipeline:

```text
ADD → MULTIPLY → SUBTRACT
```

The entire operation can form the critical combinational path.

With pipeline:

```text
ADD → REG → MULTIPLY → REG → SUBTRACT → REG
```

The combinational path is divided into smaller sections.

---

# 20. Important Interview Questions

### Q1. What is pipelining?

Pipelining divides a large combinational circuit into multiple stages separated by registers.

### Q2. Why is pipelining used?

To reduce the amount of combinational logic in each timing stage and potentially increase the maximum operating frequency and throughput.

### Q3. Does pipelining reduce latency?

Not necessarily. Pipeline latency in clock cycles usually increases with additional stages.

### Q4. What is throughput?

The rate at which completed results are produced.

### Q5. What is a pipeline register?

A register placed between pipeline stages to store intermediate results.

### Q6. Why do we use nonblocking assignment?

Because pipeline registers are sequential elements and `<=` models clocked register behavior correctly.

### Q7. Why is D delayed?

To keep D aligned with the corresponding multiplication result.

### Q8. What is the critical path?

The longest timing path that limits the maximum operating frequency.

### Q9. What happens if pipeline stages are unbalanced?

The slowest stage can become the timing bottleneck.

### Q10. What is pipeline latency?

The number of clock cycles required for an input to reach its corresponding output.

---

# 21. Day 28 Assignment

Implement and verify:

```text
RESULT = (A + B) * C - D
```

Requirements:

```text
A = 8 bits
B = 8 bits
C = 8 bits
D = 8 bits
```

Use three pipeline stages:

```text
Stage 1 → A + B
Stage 2 → SUM × C
Stage 3 → PRODUCT - D
```

Verify:

```text
(5 + 3) × 2 - 4   = 12
(10 + 5) × 3 - 2  = 43
(7 + 1) × 4 - 5   = 27
(20 + 10) × 2 - 6 = 54
```

Also verify the **three-stage pipeline latency** using GTKWave.

---

# 22. Day 28 Key Takeaways

Remember these five points:

```text
1. Pipeline = combinational logic divided into stages.

2. Registers separate pipeline stages.

3. Pipelining can increase throughput and maximum frequency.

4. Pipelining introduces additional latency and register overhead.

5. Related signals must be delayed/aligned through the pipeline.
```

The most important RTL structure for today is:

```text
        ADD
         │
        REG
         │
      MULTIPLY
         │
        REG
         │
      SUBTRACT
         │
        REG
         │
       RESULT
```

**Day 28 complete: PIPELINE.**
