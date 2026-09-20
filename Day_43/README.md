# Day 43 — Booth Multiplier

## 1. Objective

Learn and implement a **4-bit signed Booth multiplier** in Verilog.

Today we will learn:

* Signed binary multiplication
* Why ordinary multiplication hardware can be expensive
* Booth's algorithm
* 2's-complement signed numbers
* `Q0` and `Q-1`
* Add/subtract/no-operation conditions
* Arithmetic right shift
* 4-bit signed multiplication
* Sequential Booth multiplier RTL
* Exhaustive verification
* Icarus Verilog + GTKWave
* Placement interview questions

---

# 2. What is Booth Multiplication?

**Booth's algorithm** is an algorithm used for multiplication of signed binary numbers.

Instead of directly generating a partial product for every multiplier bit, Booth encoding examines pairs of bits:

```text
Q0
Q-1
```

and determines whether to:

```text
ADD
SUBTRACT
NOTHING
```

This can reduce the number of arithmetic operations, especially when the multiplier contains consecutive 1s.

---

# 3. Why Do We Need Booth's Algorithm?

Suppose a multiplier contains:

```text
11110000
```

A simple shift-and-add multiplier may generate several partial products.

Booth's algorithm recognizes runs of `1`s and can replace them with a combination of:

```text
addition
+
subtraction
```

This can reduce the number of partial-product operations.

---

# 4. Signed Numbers

For today's design we use:

```text
4-bit signed numbers
```

A 4-bit 2's-complement number has the range:

$$
-2^{3}\leq N\leq2^{3}-1
$$

Therefore:

$$
\boxed{-8\leq N\leq7}
$$

---

# 5. 4-bit Signed Number Table

| Decimal | 4-bit 2's complement |
| ------: | :------------------: |
|      -8 |        `1000`        |
|      -7 |        `1001`        |
|      -6 |        `1010`        |
|      -5 |        `1011`        |
|      -4 |        `1100`        |
|      -3 |        `1101`        |
|      -2 |        `1110`        |
|      -1 |        `1111`        |
|       0 |        `0000`        |
|       1 |        `0001`        |
|       2 |        `0010`        |
|       3 |        `0011`        |
|       4 |        `0100`        |
|       5 |        `0101`        |
|       6 |        `0110`        |
|       7 |        `0111`        |

---

# 6. Why Is the Product 8 Bits?

Each operand is 4 bits.

The multiplication result requires up to:

$$
4+4=8\ bits
$$

Therefore:

```text
Multiplicand = 4 bits
Multiplier   = 4 bits
Product      = 8 bits
```

Example:

$$
7\times7=49
$$

49 in 8-bit binary:

```text
00110001
```

---

# 7. Booth Registers

The basic Booth multiplier uses:

```text
M       → Multiplicand
Q       → Multiplier
A       → Accumulator
Q-1     → Extra bit
```

For a 4-bit multiplier:

```text
A  = 4 bits
Q  = 4 bits
M  = 4 bits
Q-1 = 1 bit
```

Conceptually:

```text
       A              Q        Q-1
   +--------+      +------+      +
   | 4 bits |      |4 bits|      |
   +--------+      +------+      +
          \          /
           \        /
          9-bit shift register
```

---

# 8. Initial State

Before multiplication:

```text
A   = 0000
Q   = multiplier
M   = multiplicand
Q-1 = 0
```

Example:

Multiply:

$$
3\times2
$$

Then:

```text
M = 0011
Q = 0010
A = 0000
Q-1 = 0
```

---

# 9. Booth Decision Table

This is the most important table for Booth's algorithm.

Look at:

```text
Q0 Q-1
```

| Q0 | Q-1 | Operation    |
| -: | --: | ------------ |
|  0 |   0 | No operation |
|  0 |   1 | `A = A + M`  |
|  1 |   0 | `A = A - M`  |
|  1 |   1 | No operation |

Memorize:

```text
00 → nothing
01 → ADD M
10 → SUBTRACT M
11 → nothing
```

---

# 10. Why Q0 and Q-1?

`Q0` is the current least-significant bit of the multiplier.

`Q-1` stores the previous value of that bit.

Therefore Booth examines the transition:

```text
Q-1 → Q0
```

The transitions:

```text
01
10
```

indicate boundaries of runs of 1s.

---

# 11. Arithmetic Right Shift

After the ADD/SUBTRACT operation, we perform:

```text
Arithmetic Right Shift
```

on:

```text
A Q Q-1
```

The important difference is that an arithmetic right shift preserves the sign bit.

Example:

```text
Positive:

001100
   ↓
000110
```

For a negative number:

```text
110100
   ↓
111010
```

The leftmost `1` is preserved.

---

# 12. Arithmetic vs Logical Right Shift

### Logical right shift

Zeros enter from the left.

```text
1100 >> 1

0110
```

### Arithmetic right shift

The sign bit is replicated.

```text
1100 >>> 1

1110
```

For signed Booth multiplication:

$$
\boxed{\text{Arithmetic right shift is required}}
$$

---

# 13. Booth Algorithm

For an N-bit multiplier:

### Step 1

Initialize:

```text
A = 0
Q = multiplier
M = multiplicand
Q-1 = 0
```

### Step 2

Examine:

```text
Q0 Q-1
```

### Step 3

Perform:

```text
01 → A = A + M
10 → A = A - M
00 → nothing
11 → nothing
```

### Step 4

Arithmetic right shift:

```text
A Q Q-1
```

### Step 5

Repeat N times.

For 4-bit operands:

```text
4 iterations
```

### Step 6

Final product:

```text
A Q
```

---

# 14. Worked Example — 3 × 2

Let's multiply:

$$
3\times2
$$

Binary:

```text
M = 0011
Q = 0010
```

Initial:

```text
A   = 0000
Q   = 0010
Q-1 = 0
```

---

## Iteration 1

Q0:

```text
Q = 0010
     ^
     0
```

Therefore:

```text
Q0 Q-1 = 00
```

Operation:

```text
Nothing
```

Now arithmetic right shift:

```text
A Q Q-1

0000 0010 0
        ↓
0000 0001 0
```

---

## Iteration 2

Now:

```text
Q = 0001
Q0 = 1
Q-1 = 0
```

Therefore:

```text
10
```

Operation:

```text
A = A - M
```

So:

```text
A = 0000 - 0011
```

$$
A=-3
$$

4-bit representation:

```text
1101
```

Then arithmetic right shift.

---

## Iteration 3

Examine the new:

```text
Q0 Q-1
```

Perform the corresponding Booth operation and arithmetic shift.

---

## Iteration 4

Again examine:

```text
Q0 Q-1
```

perform the operation and shift.

After four iterations, the final:

```text
A Q
```

represents:

```text
00000110
```

which is:

$$
6
$$

Therefore:

$$
\boxed{3\times2=6}
$$

---

# 15. Important Point About Manual Booth Calculations

When solving Booth multiplication by hand, always write the complete state:

```text
Iteration
A
Q
Q-1
Q0 Q-1
Operation
After shift
```

Do not try to mentally skip the shifts.

That prevents most Booth-algorithm mistakes.

---

# 16. Another Example — Negative Numbers

Suppose:

$$
(-3)\times2
$$

4-bit representation:

```text
-3 = 1101
 2 = 0010
```

Therefore:

```text
M = 1101
Q = 0010
```

The final 8-bit result should be:

$$
-6
$$

8-bit 2's complement:

```text
00000110
```

Invert:

```text
11111001
```

Add 1:

```text
11111010
```

Therefore:

```text
-6 = 11111010
```

So the Booth multiplier must produce:

```text
11111010
```

---

# 17. Important Signed Multiplication Examples

You should know these:

|  A |  B | Product |
| -: | -: | ------: |
|  3 |  2 |       6 |
|  3 | -2 |      -6 |
| -3 |  2 |      -6 |
| -3 | -2 |       6 |
|  7 |  7 |      49 |
| -8 |  1 |      -8 |
| -8 | -1 |       8 |
| -8 |  7 |     -56 |

The last result is within the 8-bit signed range:

$$
-128\leq Product\leq127
$$

---

# 18. 8-bit Signed Product Range

For two 4-bit signed operands:

$$
-8\leq A\leq7
$$

and:

$$
-8\leq B\leq7
$$

The minimum product is:

$$
-8\times7=-56
$$

The maximum product is:

$$
(-8)\times(-8)=64
$$

or:

$$
7\times7=49
$$

Therefore the overall product range is:

$$
\boxed{-56\leq Product\leq64}
$$

An 8-bit signed result is therefore sufficient.

---

# 19. Booth Multiplier RTL

Create:

```text
Day_43/
├── rtl/
│   └── booth_multiplier_4bit.v
├── tb/
│   └── tb_booth_multiplier_4bit.v
└── sim/
```

Use this sequential implementation.

```verilog
module booth_multiplier_4bit (
    input  wire              clk,
    input  wire              reset,
    input  wire              start,

    input  wire signed [3:0] multiplicand,
    input  wire signed [3:0] multiplier,

    output reg  signed [7:0] product,
    output reg               busy,
    output reg               done
);

    reg signed [3:0] A;
    reg signed [3:0] M;
    reg        [3:0] Q;
    reg               Q_minus_1;

    reg [2:0] count;

    // Temporary variables used during one Booth iteration
    reg signed [3:0] A_temp;
    reg        [3:0] Q_temp;
    reg               Q_minus_1_temp;
    reg signed [8:0] shift_temp;

    always @(posedge clk) begin

        if (reset) begin

            A          <= 4'b0000;
            M          <= 4'b0000;
            Q          <= 4'b0000;
            Q_minus_1  <= 1'b0;

            count      <= 3'd0;

            product    <= 8'b0;

            busy       <= 1'b0;
            done       <= 1'b0;

        end

        else begin

            done <= 1'b0;

            // Start a new multiplication
            if (start && !busy) begin

                A         <= 4'b0000;
                M         <= multiplicand;
                Q         <= multiplier;
                Q_minus_1 <= 1'b0;

                count     <= 3'd0;

                busy      <= 1'b1;

            end

            // Perform one Booth iteration
            else if (busy) begin

                // Copy current values
                A_temp         = A;
                Q_temp         = Q;
                Q_minus_1_temp = Q_minus_1;

                // Booth decision
                case ({Q[0], Q_minus_1})

                    2'b01:
                        A_temp = A + M;

                    2'b10:
                        A_temp = A - M;

                    2'b00,
                    2'b11:
                        A_temp = A;

                    default:
                        A_temp = A;

                endcase

                // Arithmetic right shift of A,Q,Q-1
                shift_temp = {A_temp, Q_temp, Q_minus_1_temp};

                shift_temp = shift_temp >>> 1;

                A_temp         = shift_temp[8:5];
                Q_temp         = shift_temp[4:1];
                Q_minus_1_temp = shift_temp[0];

                // Update state
                A         <= A_temp;
                Q         <= Q_temp;
                Q_minus_1 <= Q_minus_1_temp;

                // Four iterations completed
                if (count == 3) begin

                    product <= {A_temp, Q_temp};

                    busy    <= 1'b0;
                    done    <= 1'b1;

                end

                else begin

                    count <= count + 1'b1;

                end

            end

        end

    end

endmodule
```

---

# 20. Understanding the RTL

The main Booth decision is:

```verilog
case ({Q[0], Q_minus_1})

    2'b01:
        A_temp = A + M;

    2'b10:
        A_temp = A - M;

    2'b00,
    2'b11:
        A_temp = A;

endcase
```

This directly implements:

```text
00 → nothing
01 → ADD
10 → SUBTRACT
11 → nothing
```

---

# 21. Why `busy` Is Used

Multiplication requires:

```text
4 iterations
```

Therefore the multiplier cannot finish in a single clock.

`busy` indicates:

```text
busy = 1
```

while Booth iterations are occurring.

When all four iterations finish:

```text
busy = 0
done = 1
```

Conceptually:

```text
START
  |
  v
BUSY
  |
  | 4 iterations
  v
DONE
```

---

# 22. Why `done` Is Used

The output product should be considered valid when:

```text
done = 1
```

Therefore the external logic can use:

```text
if (done)
    use(product);
```

This is a common RTL handshake style.

---

# 23. Testbench

Create:

```text
Day_43/tb/tb_booth_multiplier_4bit.v
```

```verilog
`timescale 1ns/1ps

module tb_booth_multiplier_4bit;

    reg clk;
    reg reset;
    reg start;

    reg signed [3:0] multiplicand;
    reg signed [3:0] multiplier;

    wire signed [7:0] product;
    wire busy;
    wire done;

    integer i;
    integer j;
    integer expected;
    integer errors;

    booth_multiplier_4bit uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product),
        .busy(busy),
        .done(done)
    );

    always #5 clk = ~clk;

    task multiply_and_check;

        input signed [3:0] a;
        input signed [3:0] b;

        begin

            @(negedge clk);

            multiplicand = a;
            multiplier   = b;
            start        = 1'b1;

            @(negedge clk);

            start = 1'b0;

            wait(done);

            expected = a * b;

            if (product !== expected) begin

                $display(
                    "ERROR: %0d * %0d = DUT %0d, EXPECTED %0d",
                    a,
                    b,
                    product,
                    expected
                );

                errors = errors + 1;

            end

            else begin

                $display(
                    "PASS: %0d * %0d = %0d",
                    a,
                    b,
                    product
                );

            end

        end

    endtask

    initial begin

        $dumpfile("booth.vcd");
        $dumpvars(0, tb_booth_multiplier_4bit);

        clk = 1'b0;

        reset = 1'b1;
        start = 1'b0;

        multiplicand = 0;
        multiplier   = 0;

        errors = 0;

        #12;

        reset = 1'b0;

        // Basic tests
        multiply_and_check(3, 2);
        multiply_and_check(3, -2);
        multiply_and_check(-3, 2);
        multiply_and_check(-3, -2);

        multiply_and_check(7, 7);
        multiply_and_check(-8, 1);
        multiply_and_check(-8, -1);
        multiply_and_check(-8, 7);

        // Exhaustive verification
        for (i = -8; i <= 7; i = i + 1) begin

            for (j = -8; j <= 7; j = j + 1) begin

                multiply_and_check(i, j);

            end

        end

        if (errors == 0)
            $display("================================");
            $display("ALL BOOTH TESTS PASSED");
            $display("================================");

        else
            $display(
                "FAILED TESTS = %0d",
                errors
            );

        #20;

        $finish;

    end

endmodule
```

---

# 24. Important Testbench Point

The exhaustive test checks:

$$
16\times16=256
$$

possible combinations.

Because a 4-bit signed number has 16 possible values:

```text
-8 through +7
```

Therefore:

```text
16 × 16 = 256
```

tests are possible.

This is much stronger than testing only a few examples.

---

# 25. Compile

From the Day 43 directory:

```bash
mkdir -p sim
```

Compile:

```bash
iverilog -o sim/booth_test \
    rtl/booth_multiplier_4bit.v \
    tb/tb_booth_multiplier_4bit.v
```

Run:

```bash
vvp sim/booth_test
```

---

# 26. Open Waveform

Run:

```bash
gtkwave booth.vcd
```

Add:

```text
clk
reset
start
multiplicand
multiplier
busy
done
product
```

For internal debugging, also add:

```text
uut.A
uut.M
uut.Q
uut.Q_minus_1
uut.count
```

These internal signals are extremely useful for understanding Booth's algorithm.

---

# 27. Expected Basic Results

You should see:

```text
PASS: 3 * 2 = 6

PASS: 3 * -2 = -6

PASS: -3 * 2 = -6

PASS: -3 * -2 = 6

PASS: 7 * 7 = 49

PASS: -8 * 1 = -8

PASS: -8 * -1 = 8

PASS: -8 * 7 = -56
```

And finally:

```text
================================
ALL BOOTH TESTS PASSED
================================
```

---

# 28. Booth Truth/Decision Verification

The fundamental Booth table is:

| `Q0` | `Q-1` | Action  | Verification |
| ---: | ----: | ------- | ------------ |
|    0 |     0 | Nothing | A unchanged  |
|    0 |     1 | `A + M` | Add          |
|    1 |     0 | `A - M` | Subtract     |
|    1 |     1 | Nothing | A unchanged  |

This table must be correct for the algorithm to work.

---

# 29. Booth vs Ordinary Shift-and-Add

## Ordinary shift-and-add

A basic multiplier examines multiplier bits and adds shifted versions of the multiplicand.

For example:

```text
Multiplier bit = 1
        ↓
Add shifted M
```

---

## Booth

Booth examines:

```text
Q0 Q-1
```

and performs:

```text
ADD
SUBTRACT
NOTHING
```

This can reduce the number of arithmetic operations for certain multiplier patterns.

---

# 30. Example of a Run of Ones

Consider:

```text
011110
```

There is a long run of `1`s.

A basic multiplier may generate multiple partial products.

Booth can identify the boundaries of the run and represent the operation using addition and subtraction.

This is one of the main reasons Booth's algorithm is useful.

---

# 31. Hardware View

A Booth multiplier can be viewed as:

```text
                 +----------------+
Multiplicand --->|                |
                 |   ADD/SUB      |
                 |                |
                 +-------+--------+
                         |
                         v
                       +---+
                       | A |
                       +---+
                         |
                         v
                    Arithmetic
                    Right Shift
                         |
                +--------+--------+
                |                 |
                v                 v
              A register       Q register
                                  |
                                  v
                                Q0
                                  |
                                  v
                                Q-1
```

The control logic examines:

```text
Q0 Q-1
```

and selects:

```text
ADD
SUBTRACT
NONE
```

---

# 32. Why 4 Iterations?

The multiplier is:

```text
4 bits
```

Therefore Booth processes:

```text
one multiplier bit per iteration
```

So:

$$
\boxed{4\ iterations}
$$

For an N-bit Booth multiplier:

$$
\boxed{N\ iterations}
$$

in the basic radix-2 implementation.

---

# 33. Latency

For the RTL above:

```text
Start
 ↓
4 Booth iterations
 ↓
Done
```

Therefore the multiplication itself requires four processing iterations after the operation begins.

The exact externally observed latency also depends on how `start`, `done`, and the clock edges are defined in the surrounding interface.

---

# 34. Why We Use Nonblocking Assignment

The Booth registers are sequential state:

```verilog
A
Q
Q_minus_1
count
product
busy
```

Therefore the state updates use:

```verilog
<=
```

For example:

```verilog
A <= A_temp;
Q <= Q_temp;
```

This follows proper sequential RTL coding style.

The temporary variables calculate the next state during the current clock event.

---

# 35. Important Verilog Point — Signed Signals

We declare:

```verilog
reg signed [3:0] M;
reg signed [3:0] A;
```

and:

```verilog
output reg signed [7:0] product;
```

The `signed` keyword is important because Booth multiplication works with signed 2's-complement numbers.

Do not accidentally change these to unsigned when testing negative operands.

---

# 36. 2's Complement Reminder

To find the negative representation:

Example:

$$
-5
$$

Positive:

```text
0101
```

Invert:

```text
1010
```

Add 1:

```text
1011
```

Therefore:

```text
-5 = 1011
```

---

# 37. Placement Interview Questions

## Q1. What is Booth's algorithm?

Booth's algorithm is a signed binary multiplication algorithm that examines adjacent multiplier bits and performs addition, subtraction, or no operation followed by an arithmetic right shift.

---

## Q2. What is the Booth decision table?

```text
00 → nothing
01 → A + M
10 → A - M
11 → nothing
```

---

## Q3. What is `Q-1`?

`Q-1` is an additional bit storing the previous least-significant multiplier bit used with `Q0` for Booth encoding.

---

## Q4. Why is arithmetic right shift used?

Because signed 2's-complement values must preserve their sign during the shift.

---

## Q5. How many iterations are required for an N-bit radix-2 Booth multiplier?

```text
N iterations
```

---

## Q6. What is the range of a 4-bit signed number?

$$
-8\text{ to }+7
$$

---

## Q7. What is the product width of two 4-bit operands?

Normally:

```text
8 bits
```

are used for the product.

---

## Q8. Why can Booth multiplication reduce hardware operations?

Because runs of consecutive 1s can be represented using transitions requiring addition and subtraction rather than generating a separate partial product for every 1.

---

## Q9. What is the difference between logical and arithmetic right shift?

Logical shift inserts zeros.

Arithmetic shift replicates the sign bit.

---

## Q10. Why do we use `signed` in Verilog?

To tell Verilog that the bit vector should be interpreted as a signed 2's-complement value in arithmetic operations and comparisons where signed interpretation applies.

---

# 38. Placement Calculation Questions

### Question 1

What is the range of a 5-bit signed number?

$$
-2^4\leq N\leq2^4-1
$$

Therefore:

$$
\boxed{-16\text{ to }15}
$$

---

### Question 2

How many Booth iterations are required for a 16-bit multiplier?

$$
\boxed{16}
$$

---

### Question 3

What is the maximum positive 4-bit signed number?

```text
0111
```

Therefore:

$$
\boxed{7}
$$

---

### Question 4

What is the minimum 4-bit signed number?

```text
1000
```

Therefore:

$$
\boxed{-8}
$$

---

### Question 5

Represent `-6` using 4-bit 2's complement.

```text
6  = 0110
NOT = 1001
+1  = 1010
```

Therefore:

$$
\boxed{-6=1010}
$$

---

# 39. Practice Questions

## Basic

1. What is Booth multiplication?
2. Why is Booth useful for signed multiplication?
3. What is `Q-1`?
4. What is `Q0`?
5. Explain the four Booth cases.
6. Why is arithmetic right shift required?

## Manual calculation

7. Perform `3 × 2` using Booth's algorithm.
8. Perform `3 × -2`.
9. Perform `-3 × 2`.
10. Perform `-3 × -2`.
11. Perform `7 × 7`.
12. Perform `-8 × 7`.

## RTL

13. Design a 4-bit signed Booth multiplier.
14. Add `start`.
15. Add `busy`.
16. Add `done`.
17. Create an exhaustive self-checking testbench.

---

# 40. Day 43 Assignment

Build and verify:

```text
4-bit signed Booth multiplier
```

Required inputs:

```text
clk
reset
start
multiplicand[3:0]
multiplier[3:0]
```

Required outputs:

```text
product[7:0]
busy
done
```

Verification must include:

```text
3 × 2
3 × -2
-3 × 2
-3 × -2
7 × 7
-8 × 1
-8 × -1
-8 × 7
```

Then perform **exhaustive testing of all 256 signed combinations**.

Your testbench should report:

```text
PASS
```

or:

```text
ERROR
```

for every combination.

---

# 41. Git Structure

```text
RTL_50_Days/
│
├── Day_41/
│
├── Day_42/
│
├── Day_43/
│   ├── README.md
│   │
│   ├── rtl/
│   │   └── booth_multiplier_4bit.v
│   │
│   ├── tb/
│   │   └── tb_booth_multiplier_4bit.v
│   │
│   └── sim/
│
└── ...
```

Commit:

```bash
git add Day_43/
git commit -m "Day 43: 4-bit signed Booth multiplier"
git push
```

---

# 42. Day 43 Key Takeaways

Remember these five things:

### 1. Signed range

For N bits:

$$
\boxed{-2^{N-1}\text{ to }2^{N-1}-1}
$$

For 4 bits:

$$
\boxed{-8\text{ to }7}
$$

### 2. Booth table

```text
Q0 Q-1

00 → NOTHING
01 → ADD M
10 → SUBTRACT M
11 → NOTHING
```

### 3. Shift

After every operation:

```text
Arithmetic Right Shift
```

### 4. Number of iterations

For an N-bit multiplier:

$$
\boxed{N}
$$

### 5. Final product

After the final iteration:

```text
A Q
```

contains the product.

---

# 43. Final Mental Model

```text
                  START
                    |
                    v
        +-----------------------+
        | A=0, Q=Multiplier     |
        | M=Multiplicand        |
        | Q-1=0                 |
        +-----------+-----------+
                    |
                    v
              Examine Q0,Q-1
                    |
          +---------+---------+
          |         |         |
         00/11      01        10
          |         |         |
        NOTHING    A+M       A-M
          |         |         |
          +---------+---------+
                    |
                    v
          Arithmetic Right Shift
                    |
                    v
             Repeat N times
                    |
                    v
                  A Q
                    |
                    v
                 PRODUCT
```

## One-line interview answer

> **Booth multiplication is a signed binary multiplication technique that examines `Q0` and `Q-1`, performs ADD, SUBTRACT, or NO-OP, and then performs an arithmetic right shift for each multiplier bit.**

**Day 43 complete.**

Next roadmap topic:

# Day 44 — 32-bit Slicer

The assignment is to design a **32-bit input slicer that extracts the least-significant 4 bits with one-cycle latency**, which will reinforce **bit slicing, registers, latency, and sequential RTL**.
