# Day 09 — Dataflow Modeling

## 1. Day 9 Objective

Today we will learn:

* What dataflow modeling means
* Continuous assignment using `assign`
* How data flows through RTL
* Difference between dataflow and behavioral modeling
* Bitwise operators
* XOR operation
* Vector operations
* Binary-to-Gray code conversion
* Truth-table verification
* RTL implementation
* Testbench
* Icarus Verilog simulation
* GTKWave verification
* Placement interview questions

### Day 9 Assignment

> **Design a Binary-to-Gray code converter.**

---

# 2. What is Dataflow Modeling?

Dataflow modeling describes **how data moves through the logic** of a digital circuit.

The primary construct used is:

```verilog
assign
```

Example:

```verilog
assign y = a & b;
```

This means:

```text
y continuously follows the value of a AND b
```

When `a` or `b` changes, `y` automatically updates.

---

# 3. Basic Dataflow Syntax

```verilog
module example (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a & b;

endmodule
```

The relationship is:

$$
Y=A\cdot B
$$

No clock is required.

No `always` block is required.

---

# 4. Continuous Assignment

Consider:

```verilog
assign y = a ^ b;
```

This is called a **continuous assignment**.

It continuously drives `y` based on the current value of `a` and `b`.

For example:

```text
a = 0, b = 0 → y = 0
a = 0, b = 1 → y = 1
a = 1, b = 0 → y = 1
a = 1, b = 1 → y = 0
```

---

# 5. Dataflow Modeling = Combinational Relationship

A simple dataflow equation:

```verilog
assign y = a & b;
```

represents combinational logic.

There is no memory.

There is no clock.

The output depends on the current inputs.

Conceptually:

```text
Inputs
  ↓
Boolean expression
  ↓
Output
```

---

# 6. Common Dataflow Operators

### AND

```verilog
assign y = a & b;
```

### OR

```verilog
assign y = a | b;
```

### XOR

```verilog
assign y = a ^ b;
```

### NOT

```verilog
assign y = ~a;
```

### NAND

```verilog
assign y = ~(a & b);
```

### NOR

```verilog
assign y = ~(a | b);
```

### XNOR

```verilog
assign y = ~(a ^ b);
```

---

# 7. Bitwise vs Logical Operators

This is an important placement topic.

### Bitwise AND

```verilog
&
```

### Logical AND

```verilog
&&
```

For vector operations, bitwise operators operate bit-by-bit.

Example:

```verilog
4'b1010 & 4'b1100
```

gives:

```text
1010
1100
----
1000
```

Therefore:

```verilog
assign y = a & b;
```

is a bitwise operation when `a` and `b` are vectors.

---

# 8. What is Gray Code?

Gray code is a binary numbering system in which **adjacent code words differ in only one bit**.

For 3 bits:

| Decimal | Binary |  Gray |
| ------: | :----: | :---: |
|       0 |  `000` | `000` |
|       1 |  `001` | `001` |
|       2 |  `010` | `011` |
|       3 |  `011` | `010` |
|       4 |  `100` | `110` |
|       5 |  `101` | `111` |
|       6 |  `110` | `101` |
|       7 |  `111` | `100` |

Observe the Gray sequence:

```text
000
001
011
010
110
111
101
100
```

Each adjacent pair differs by one bit.

---

# 9. Why Gray Code is Useful

Gray coding is useful in situations where changing multiple bits simultaneously can create ambiguity.

A major RTL application is **asynchronous FIFO pointer synchronization**, where Gray-coded pointers are commonly used to reduce ambiguity when transferring a multi-bit pointer between clock domains.

For Day 9, our focus is the **Binary-to-Gray conversion logic**.

---

# 10. Binary-to-Gray Conversion Formula

For an N-bit binary number:

```text
Binary:
B[N-1] ... B[2] B[1] B[0]
```

Gray code is:

```text
G[N-1] = B[N-1]

G[N-2] = B[N-1] XOR B[N-2]

G[N-3] = B[N-2] XOR B[N-3]

...

G[0] = B[1] XOR B[0]
```

The MSB is copied directly.

---

# 11. 4-bit Binary-to-Gray Formula

For:

```text
Binary = B3 B2 B1 B0
```

the Gray output is:

```text
G3 = B3
G2 = B3 ^ B2
G1 = B2 ^ B1
G0 = B1 ^ B0
```

Therefore:

$$
\boxed{G_3=B_3}
$$

$$
\boxed{G_2=B_3\oplus B_2}
$$

$$
\boxed{G_1=B_2\oplus B_1}
$$

$$
\boxed{G_0=B_1\oplus B_0}
$$

---

# 12. Why Does This Work?

Take:

```text
Binary = 1011
```

Calculate:

```text
G3 = B3
   = 1

G2 = B3 XOR B2
   = 1 XOR 0
   = 1

G1 = B2 XOR B1
   = 0 XOR 1
   = 1

G0 = B1 XOR B0
   = 1 XOR 1
   = 0
```

Therefore:

```text
Binary = 1011
Gray   = 1110
```

---

# 13. 4-bit Binary-to-Gray Truth Table

There are 16 possible inputs.

| Decimal | Binary |  Gray  |
| ------: | :----: | :----: |
|       0 | `0000` | `0000` |
|       1 | `0001` | `0001` |
|       2 | `0010` | `0011` |
|       3 | `0011` | `0010` |
|       4 | `0100` | `0110` |
|       5 | `0101` | `0111` |
|       6 | `0110` | `0101` |
|       7 | `0111` | `0100` |
|       8 | `1000` | `1100` |
|       9 | `1001` | `1101` |
|      10 | `1010` | `1111` |
|      11 | `1011` | `1110` |
|      12 | `1100` | `1010` |
|      13 | `1101` | `1011` |
|      14 | `1110` | `1001` |
|      15 | `1111` | `1000` |

This table should be your reference when verifying the RTL.

---

# 14. Dataflow RTL

Create:

```text
rtl/binary_to_gray.v
```

Code:

```verilog
module binary_to_gray (
    input  wire [3:0] binary,
    output wire [3:0] gray
);

    assign gray[3] = binary[3];
    assign gray[2] = binary[3] ^ binary[2];
    assign gray[1] = binary[2] ^ binary[1];
    assign gray[0] = binary[1] ^ binary[0];

endmodule
```

This is pure **dataflow modeling**.

There is:

```text
No always block
No clock
No register
No reset
```

It is combinational logic.

---

# 15. Compact Dataflow Version

The same logic can be written more compactly:

```verilog
module binary_to_gray (
    input  wire [3:0] binary,
    output wire [3:0] gray
);

    assign gray = binary ^ (binary >> 1);

endmodule
```

This is the standard general binary-to-Gray relationship:

$$
\boxed{Gray = Binary \oplus (Binary >> 1)}
$$

For example:

```text
Binary        = 1011
Binary >> 1   = 0101
                 ----
XOR           = 1110
```

Therefore:

```text
1011 → 1110
```

---

# 16. Which Version Should You Learn?

For placement preparation, understand **both**.

### Bit-by-bit version

```verilog
assign gray[3] = binary[3];
assign gray[2] = binary[3] ^ binary[2];
assign gray[1] = binary[2] ^ binary[1];
assign gray[0] = binary[1] ^ binary[0];
```

This makes the actual logic very clear.

### Compact version

```verilog
assign gray = binary ^ (binary >> 1);
```

This demonstrates that you understand the generalized formula.

---

# 17. Testbench

Create:

```text
tb/tb_binary_to_gray.v
```

```verilog
`timescale 1ns/1ps

module tb_binary_to_gray;

    reg  [3:0] binary;
    wire [3:0] gray;

    binary_to_gray dut (
        .binary (binary),
        .gray   (gray)
    );

    initial begin

        $dumpfile("sim/binary_to_gray.vcd");
        $dumpvars(0, tb_binary_to_gray);

        binary = 4'b0000; #10;
        binary = 4'b0001; #10;
        binary = 4'b0010; #10;
        binary = 4'b0011; #10;
        binary = 4'b0100; #10;
        binary = 4'b0101; #10;
        binary = 4'b0110; #10;
        binary = 4'b0111; #10;
        binary = 4'b1000; #10;
        binary = 4'b1001; #10;
        binary = 4'b1010; #10;
        binary = 4'b1011; #10;
        binary = 4'b1100; #10;
        binary = 4'b1101; #10;
        binary = 4'b1110; #10;
        binary = 4'b1111; #10;

        $finish;

    end

endmodule
```

---

# 18. Directory Structure

Create:

```bash
mkdir -p ~/Verilog_50_Days/Day_09/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_09
```

You should have:

```text
Day_09/
├── rtl/
│   └── binary_to_gray.v
├── tb/
│   └── tb_binary_to_gray.v
├── sim/
└── wave/
```

---

# 19. Compile

Run:

```bash
iverilog -o sim/binary_to_gray_sim \
rtl/binary_to_gray.v \
tb/tb_binary_to_gray.v
```

---

# 20. Run Simulation

```bash
vvp sim/binary_to_gray_sim
```

The simulation creates:

```text
sim/binary_to_gray.vcd
```

---

# 21. Open GTKWave

```bash
gtkwave sim/binary_to_gray.vcd
```

Add:

```text
binary
gray
```

There is no clock because this is a combinational circuit.

You should observe:

```text
binary    gray
0000      0000
0001      0001
0010      0011
0011      0010
0100      0110
...
1011      1110
...
1111      1000
```

---

# 22. Verify One Important Example

Take:

```text
binary = 1101
```

Calculate:

```text
G3 = B3 = 1

G2 = B3 ^ B2
   = 1 ^ 1
   = 0

G1 = B2 ^ B1
   = 1 ^ 0
   = 1

G0 = B1 ^ B0
   = 0 ^ 1
   = 1
```

Therefore:

```text
Binary = 1101
Gray   = 1011
```

The waveform should show:

```text
1101 → 1011
```

---

# 23. Why No Clock?

Binary-to-Gray conversion is a combinational operation.

The output is determined directly from the current input.

Therefore:

```text
Binary input
     ↓
XOR logic
     ↓
Gray output
```

There is no need for:

```text
clk
reset
flip-flop
register
```

---

# 24. Dataflow vs Behavioral Modeling

You will study behavioral modeling more formally on **Day 10**.

For now, understand this basic distinction.

### Dataflow

Describes the logic relationship using expressions:

```verilog
assign y = a & b;
```

### Behavioral

Describes behavior using procedural constructs:

```verilog
always @(*) begin
    y = a & b;
end
```

Both can describe combinational hardware, but they use different Verilog modeling styles.

---

# 25. Dataflow vs Structural Modeling

### Dataflow

```verilog
assign y = a ^ b;
```

Describes the relationship mathematically.

### Structural

```verilog
xor x1(y, a, b);
```

Describes the circuit using gate/module instances.

You will study structural modeling in more detail on Day 11.

---

# 26. Dataflow Design Pattern

A typical dataflow design looks like:

```text
Inputs
  ↓
Operators
  ↓
Intermediate expressions
  ↓
Output
```

Example:

```verilog
assign w1 = a & b;
assign w2 = c | d;
assign y  = w1 ^ w2;
```

This represents:

$$
Y=(A\cdot B)\oplus(C+D)
$$

---

# 27. Internal Wires in Dataflow

You can use intermediate wires:

```verilog
module example (
    input  wire a,
    input  wire b,
    input  wire c,
    output wire y
);

    wire w1;
    wire w2;

    assign w1 = a & b;
    assign w2 = b | c;
    assign y  = w1 ^ w2;

endmodule
```

This is still dataflow modeling.

---

# 28. Important Rule About `assign`

For traditional Verilog:

```verilog
assign
```

is a **continuous assignment** and is normally used to drive nets such as `wire`.

Example:

```verilog
wire y;

assign y = a & b;
```

Do not confuse this with procedural assignment inside an `always` block.

---

# 29. Common Mistakes

### Mistake 1 — Wrong Gray formula

Wrong:

```verilog
assign gray = binary ^ 1;
```

Correct:

```verilog
assign gray = binary ^ (binary >> 1);
```

---

### Mistake 2 — Forgetting the MSB

For:

```text
B3 B2 B1 B0
```

we need:

```text
G3 = B3
```

not:

```text
G3 = B3 ^ B2
```

---

### Mistake 3 — Using arithmetic `+` instead of XOR

Gray conversion uses XOR:

```verilog
^
```

not:

```verilog
+
```

---

### Mistake 4 — Adding a clock unnecessarily

Binary-to-Gray conversion is combinational.

No clock is required.

---

### Mistake 5 — Confusing bitwise XOR and reduction XOR

These are different.

```verilog
a ^ b
```

with vectors performs bitwise XOR.

But:

```verilog
^a
```

is a reduction XOR.

This distinction is important.

---

# 30. Bitwise XOR Example

Consider:

```text
A = 1010
B = 1100
```

Bitwise XOR:

```text
  1010
^ 1100
------
  0110
```

Therefore:

```verilog
assign y = a ^ b;
```

produces:

```text
y = 0110
```

---

# 31. Reduction XOR

If:

```verilog
a = 4'b1011;
```

then:

```verilog
^a
```

means:

```text
1 ^ 0 ^ 1 ^ 1
```

which gives:

```text
1
```

So:

```text
a ^ b
```

and:

```text
^a
```

are not the same operation.

---

# 32. Placement Interview Questions

### Q1. What is dataflow modeling?

A Verilog modeling style that describes data relationships using continuous assignments and expressions.

### Q2. Which keyword is primarily used?

```text
assign
```

### Q3. What is continuous assignment?

An assignment in which the output continuously follows changes in the right-hand-side expression.

### Q4. Is Binary-to-Gray conversion combinational or sequential?

Combinational.

### Q5. What is the binary-to-Gray formula?

$$
\boxed{Gray = Binary \oplus (Binary >> 1)}
$$

### Q6. What happens to the MSB during conversion?

The Gray MSB is equal to the Binary MSB.

### Q7. Convert `1011` to Gray.

```text
Binary = 1011
Gray   = 1110
```

### Q8. Convert `1101` to Gray.

```text
Binary = 1101
Gray   = 1011
```

### Q9. Why is Gray code useful?

Adjacent Gray-code values differ by one bit, which can reduce ambiguity when transitioning between adjacent states. It is commonly used in asynchronous FIFO pointer logic.

### Q10. Difference between `^` and `^` as a reduction operator?

```verilog
a ^ b
```

is bitwise XOR for vectors.

```verilog
^a
```

is reduction XOR.

### Q11. Does dataflow modeling require a clock?

No.

### Q12. What is the difference between dataflow and behavioral modeling?

Dataflow describes relationships using continuous assignments and expressions; behavioral modeling uses procedural constructs such as `always`.

### Q13. What is the difference between dataflow and structural modeling?

Dataflow describes logic relationships through expressions, while structural modeling describes interconnection of gates/modules.

### Q14. What type of signal is traditionally driven by `assign`?

A net such as `wire`.

### Q15. Is a Binary-to-Gray converter sequential?

No. It is combinational.

---

# 33. Day 9 Assignment

## Assignment 1 — 4-bit Binary-to-Gray

Implement:

```text
Binary → Gray
```

using individual equations.

Verify all 16 combinations.

---

## Assignment 2 — Compact Formula

Implement the same circuit using:

```verilog
assign gray = binary ^ (binary >> 1);
```

Compare the output with Assignment 1.

Both should produce exactly the same result.

---

## Assignment 3 — 8-bit Converter

Create an:

```text
8-bit Binary-to-Gray converter
```

using a parameter:

```verilog
parameter WIDTH = 8;
```

and implement:

```verilog
assign gray = binary ^ (binary >> 1);
```

Test several values.

---

## Assignment 4 — Reverse Conversion

Study and implement:

```text
Gray → Binary
```

For a 4-bit Gray number:

```text
B3 = G3
B2 = B3 ^ G2
B1 = B2 ^ G1
B0 = B1 ^ G0
```

Verify the conversion against the original binary values.

---

# 34. Day 9 Verification Table

Use these important test cases:

| Binary | Expected Gray |
| :----: | :-----------: |
| `0000` |     `0000`    |
| `0001` |     `0001`    |
| `0010` |     `0011`    |
| `0011` |     `0010`    |
| `0100` |     `0110`    |
| `0101` |     `0111`    |
| `0110` |     `0101`    |
| `0111` |     `0100`    |
| `1000` |     `1100`    |
| `1001` |     `1101`    |
| `1010` |     `1111`    |
| `1011` |     `1110`    |
| `1100` |     `1010`    |
| `1101` |     `1011`    |
| `1110` |     `1001`    |
| `1111` |     `1000`    |

Your RTL should match this table for **all 16 inputs**.

---

# 35. Day 9 Final Checklist

Before moving to Day 10, make sure you can explain:

* [ ] What is dataflow modeling?
* [ ] What is continuous assignment?
* [ ] What does `assign` do?
* [ ] Difference between `wire` and `reg`
* [ ] Bitwise AND/OR/XOR
* [ ] Reduction XOR
* [ ] What is Gray code?
* [ ] Why Gray code is useful
* [ ] Binary-to-Gray equation
* [ ] 4-bit Binary-to-Gray truth table
* [ ] Why the MSB is copied
* [ ] Why no clock is needed
* [ ] How to simulate with Icarus
* [ ] How to verify with GTKWave
* [ ] Difference between dataflow and behavioral modeling

---

# 36. Day 9 Golden Rule

> **Dataflow modeling describes combinational relationships using continuous assignments such as `assign`.**

For Binary-to-Gray:

$$
\boxed{G=B\oplus(B>>1)}
$$

Remember this pattern:

```text
Binary
  ↓
Right shift by 1
  ↓
XOR
  ↓
Gray
```

And the RTL:

```verilog
assign gray = binary ^ (binary >> 1);
```

This is one of the formulas worth memorizing for campus-placement interviews.

### Day 9 Flow

```text
Dataflow Modeling
       ↓
Continuous Assignment
       ↓
Bitwise Operators
       ↓
XOR
       ↓
Gray Code
       ↓
Binary → Gray
       ↓
Dataflow RTL
       ↓
Testbench
       ↓
Icarus Simulation
       ↓
GTKWave Verification
```
