# Day 34 — Error Detection & Correction

## 📌 Topic

**Error Detection & Correction**

## 🎯 Roadmap Objective

Learn techniques used to detect and correct errors in digital data.

Day 34 focuses on:

* Parity
* Error detection
* CRC
* Hamming-code concept
* Practical Verilog implementation of CRC

The main Day 34 assignment is:

> Design a CRC system for an 8-bit message using a 4-bit generator polynomial.

---

# 1. Learning Objectives

By the end of Day 34, you should understand:

* Why errors occur during digital communication.
* Error detection vs error correction.
* Single-bit parity.
* Even and odd parity.
* Limitations of parity.
* CRC fundamentals.
* Generator polynomial.
* XOR-based CRC division.
* How CRC detects errors.
* How to implement CRC in Verilog.
* How to verify CRC using a testbench.
* Basic Hamming-code concepts.

---

# 2. Why Error Detection is Required

Digital data may be transmitted through a noisy channel.

For example:

```text
Transmitter                 Receiver

10110010  ───────────────►  10111010
                              ↑
                           Error
```

The transmitted data was:

```text
10110010
```

but the received data became:

```text
10111010
```

A bit changed during transmission.

Therefore, communication systems use error-detection or error-correction techniques.

---

# 3. Error Detection vs Error Correction

## Error Detection

Determines whether an error has occurred.

Examples:

* Parity
* CRC
* Checksum

```text
Data ──► Error Detection ──► ERROR / NO ERROR
```

---

## Error Correction

Determines that an error occurred and can also identify/correct the erroneous bit under the scheme's supported conditions.

Examples:

* Hamming code
* Reed-Solomon
* BCH
* LDPC

Basic idea:

```text
Data + Redundancy
        │
        ▼
 Error Correction
        │
        ▼
 Corrected Data
```

---

# 4. Redundancy

To detect errors, additional bits are transmitted along with the original data.

These additional bits are called:

**Redundant bits**

Example:

```text
Original data:

1011001

Parity bit:

0

Transmitted:

10110010
```

The receiver uses the redundancy to determine whether the data is valid.

---

# 5. Parity Bit

The simplest error-detection technique is parity.

There are two common types:

1. Even parity
2. Odd parity

---

# 6. Even Parity

The parity bit is selected so that the total number of `1`s becomes even.

Example:

```text
Data = 1011001
```

Number of ones:

```text
1 + 0 + 1 + 1 + 0 + 0 + 1
= 4
```

There are already 4 ones.

Therefore:

```text
Parity = 0
```

Transmitted data:

```text
10110010
```

---

# 7. Odd Parity

The parity bit is selected so that the total number of `1`s becomes odd.

For:

```text
Data = 1011001
```

There are 4 ones.

Therefore:

```text
Parity = 1
```

because:

```text
4 + 1 = 5
```

which is odd.

---

# 8. XOR and Parity

XOR is extremely useful for parity generation.

For data:

```text
A B C D
```

even parity can be generated as:

```verilog
assign parity = A ^ B ^ C ^ D;
```

For a vector:

```verilog
assign parity = ^data;
```

The `^` here is the **reduction XOR operator**.

---

# 9. Parity Generator

Example:

```verilog
module parity_generator (
    input  wire [7:0] data,
    output wire       parity
);

    assign parity = ^data;

endmodule
```

This produces the XOR of all eight bits.

---

# 10. Parity Checker

At the receiver:

```verilog
module parity_checker (
    input  wire [7:0] data,
    input  wire       parity,
    output wire       error
);

    assign error = ^{data, parity};

endmodule
```

For even parity:

```text
error = 0 → no parity error
error = 1 → parity error
```

---

# 11. Limitation of Parity

Parity is simple, but it has an important limitation.

Suppose two bits change:

```text
Original:

10110010

Received:

10000110
```

Two bits may have changed.

The parity can remain unchanged because the number of changed `1`s can preserve the overall parity.

Therefore:

> Simple parity is effective for detecting many odd-number-of-bit errors, but it cannot reliably detect every multi-bit error.

This is one reason CRC is widely used.

---

# 12. What is CRC?

CRC means:

**Cyclic Redundancy Check**

CRC is an error-detection technique based on polynomial division.

The sender calculates a CRC value and appends it to the message.

```text
             CRC
              │
              ▼
DATA ───────► CRC GENERATOR ─────► DATA + CRC
```

At the receiver:

```text
DATA + CRC
    │
    ▼
CRC CHECKER
    │
    ├── Remainder = 0 → No detected error
    │
    └── Remainder ≠ 0 → Error detected
```

---

# 13. Generator Polynomial

CRC uses a generator polynomial.

For this day's assignment, use a **4-bit generator**.

Example:

```text
1101
```

This corresponds to:

$$
G(x)=x^3+x^2+1
$$

because:

```text
1 1 0 1
│ │ │ │
x³ x² x 1
```

The highest degree is 3.

Therefore the CRC remainder contains:

```text
3 bits
```

---

# 14. Why XOR is Used Instead of Subtraction

Binary polynomial division uses XOR rather than normal arithmetic subtraction.

Important XOR rules:

```text
0 XOR 0 = 0
0 XOR 1 = 1
1 XOR 0 = 1
1 XOR 1 = 0
```

Notice:

```text
1 XOR 1 = 0
```

There is no borrow.

---

# 15. CRC Calculation Concept

Suppose:

```text
DATA = 10110010
GENERATOR = 1101
```

Generator degree:

```text
3
```

Therefore append three zeros:

```text
10110010 000
```

Then perform modulo-2 division using XOR.

The final remainder is the CRC.

```text
10110010 000
       │
       ▼
  XOR division
       │
       ▼
   remainder
```

The transmitted frame becomes:

```text
DATA + CRC
```

---

# 16. CRC Example

Let's demonstrate the XOR division.

```text
Data:

10110010
```

Append three zeros:

```text
10110010000
```

Generator:

```text
1101
```

The division repeatedly XORs the generator with the current portion whenever the leading bit is `1`.

Conceptually:

```text
10110010000
1101
----
...
```

Continue until fewer than four bits remain.

The remaining bits form the CRC remainder.

---

# 17. CRC Hardware Concept

CRC can be implemented using a Linear Feedback Shift Register (LFSR).

Conceptually:

```text
          ┌──── XOR ───────────────┐
          │                         │
          ▼                         │
      ┌───────┐   ┌───────┐   ┌───────┐
DATA ─►  FF2  ├──►│  FF1  ├──►│  FF0  │
      └───────┘   └───────┘   └───────┘
          ▲                         │
          └──────── XOR ────────────┘
```

The exact feedback taps depend on the generator polynomial.

---

# 18. Day 34 Practical RTL

We will implement a simple combinational CRC calculator for:

```text
Message = 8 bits
Generator = 1101
CRC = 3 bits
```

Create:

```text
crc8_4bit_generator.v
```

```verilog
module crc8_4bit_generator (
    input  wire [7:0] data,
    output reg  [2:0] crc
);

    reg [10:0] work;
    integer i;

    always @(*) begin

        // Append three zeros because generator degree = 3
        work = {data, 3'b000};

        // Modulo-2 division by 1101
        for (i = 10; i >= 3; i = i - 1) begin

            if (work[i]) begin
                work[i]   = work[i]   ^ 1'b1;
                work[i-1] = work[i-1] ^ 1'b1;
                work[i-2] = work[i-2] ^ 1'b0;
                work[i-3] = work[i-3] ^ 1'b1;
            end

        end

        crc = work[2:0];

    end

endmodule
```

The XOR operation above corresponds to:

```text
1101
```

with the three polynomial positions:

```text
1 1 0 1
```

---

# 19. Cleaner XOR Implementation

The same operation can be written more clearly using a temporary generator.

```verilog
module crc8_4bit_generator (
    input  wire [7:0] data,
    output reg  [2:0] crc
);

    reg [10:0] work;
    reg [3:0]  generator;
    integer i;

    always @(*) begin

        generator = 4'b1101;
        work      = {data, 3'b000};

        for (i = 10; i >= 3; i = i - 1) begin

            if (work[i])
                work[i -: 4] = work[i -: 4] ^ generator;

        end

        crc = work[2:0];

    end

endmodule
```

The expression:

```verilog
work[i -: 4]
```

means:

> Take 4 bits starting from bit `i` downward.

For example:

```text
i = 10

work[10 -: 4]

= work[10:7]
```

---

# 20. Testbench

Create:

```text
tb_crc8_4bit_generator.v
```

```verilog
`timescale 1ns/1ps

module tb_crc8_4bit_generator;

    reg  [7:0] data;
    wire [2:0] crc;

    crc8_4bit_generator dut (
        .data(data),
        .crc(crc)
    );

    initial begin

        $dumpfile("crc8.vcd");
        $dumpvars(0, tb_crc8_4bit_generator);

        $display("DATA       CRC");
        $display("----------------");

        data = 8'b00000000;
        #10;
        $display("%b     %b", data, crc);

        data = 8'b00000001;
        #10;
        $display("%b     %b", data, crc);

        data = 8'b10110010;
        #10;
        $display("%b     %b", data, crc);

        data = 8'b11111111;
        #10;
        $display("%b     %b", data, crc);

        data = 8'b11001010;
        #10;
        $display("%b     %b", data, crc);

        $finish;

    end

endmodule
```

---

# 21. Compile

Create your Day 34 directory:

```bash
mkdir -p ~/RTL_50_Days/Day_34_Error_Detection_Correction
cd ~/RTL_50_Days/Day_34_Error_Detection_Correction
```

Create:

```text
crc8_4bit_generator.v
tb_crc8_4bit_generator.v
```

Compile:

```bash
iverilog -o crc_sim \
    crc8_4bit_generator.v \
    tb_crc8_4bit_generator.v
```

Run:

```bash
vvp crc_sim
```

---

# 22. GTKWave

The testbench generates:

```text
crc8.vcd
```

Open it:

```bash
gtkwave crc8.vcd
```

Add:

```text
data
crc
```

to the waveform window.

---

# 23. Self-Checking Testbench

For placement-level verification, a self-checking testbench is better than only using `$display`.

You can calculate the expected CRC independently and compare it with the DUT output.

Basic structure:

```verilog
if (crc !== expected_crc)
    $display("ERROR");
else
    $display("PASS");
```

This is an important verification habit.

---

# 24. CRC Verification Principle

The fundamental property is:

```text
TRANSMITTED DATA + CRC
             │
             ▼
       CRC CHECKER
             │
             ▼
         REMAINDER
```

If the CRC was generated correctly:

```text
remainder = 0
```

for the corresponding codeword under the same CRC convention.

If an error changes the transmitted bits:

```text
remainder != 0
```

for errors that the selected CRC polynomial detects.

---

# 25. Error Injection

Suppose the original frame is:

```text
DATA + CRC
```

At the receiver, intentionally change one bit:

```text
Original:
10110010xxx

Received:
10110011xxx
         ↑
       error
```

The CRC checker should produce a non-zero remainder for this detected error.

This is a very useful experiment.

---

# 26. CRC vs Parity

| Feature                    | Parity        | CRC                                        |
| -------------------------- | ------------- | ------------------------------------------ |
| Complexity                 | Very low      | Higher                                     |
| Hardware                   | Simple XOR    | XOR/LFSR logic                             |
| Redundancy                 | Usually 1 bit | Multiple bits                              |
| Error detection capability | Limited       | Much stronger                              |
| Common use                 | Simple links  | Communication/storage systems              |
| Detects all errors?        | No            | No single CRC detects every possible error |

The exact error-detection guarantees depend on the selected CRC polynomial and frame length.

---

# 27. Hamming Code

Hamming code is an **error-correcting code**.

Unlike simple parity, Hamming coding can provide information about the location of certain errors.

For example, Hamming code can be used for:

```text
Data
  +
Parity bits
  ↓
Hamming encoded word
```

At the receiver:

```text
Received word
      │
      ▼
 Syndrome calculation
      │
      ▼
 Error location
```

---

# 28. Hamming Parity Positions

For a Hamming code, parity bits are commonly placed at positions:

```text
1, 2, 4, 8, ...
```

because these are powers of two.

Example:

```text
Position:

1 2 3 4 5 6 7

P P D P D D D
```

For a 7-bit Hamming code:

```text
P1 P2 D1 P4 D2 D3 D4
```

The parity bits examine different groups of positions.

---

# 29. Syndrome

The receiver calculates parity-check results.

These results form the:

**syndrome**

For a single-bit error, the syndrome can identify the erroneous bit position under the Hamming scheme.

Conceptually:

```text
Received data
     │
     ▼
Parity checks
     │
     ▼
 Syndrome
     │
     ▼
Error position
```

---

# 30. Error Detection vs Correction Summary

```text
PARITY
   │
   └── Detects certain errors

CRC
   │
   └── Strong error detection

HAMMING
   │
   └── Error detection + correction
       for supported error patterns
```

---

# 31. Placement Interview Questions

## Q1. What is CRC?

CRC stands for **Cyclic Redundancy Check** and is an error-detection technique based on modulo-2 polynomial division.

---

## Q2. Why is XOR used in CRC?

CRC uses modulo-2 arithmetic, where subtraction and addition are equivalent to XOR.

---

## Q3. What is a generator polynomial?

It is the polynomial used as the divisor during CRC calculation.

---

## Q4. If the generator has degree 3, how many CRC bits are generated?

```text
3 bits
```

---

## Q5. Why are zeros appended to the data?

For a generator of degree `r`, `r` zero bits are appended before calculating the remainder.

---

## Q6. What is the difference between CRC and parity?

Parity uses very little redundancy and has limited error-detection capability. CRC uses a polynomial-based remainder and generally provides much stronger error detection.

---

## Q7. What is Hamming code?

An error-correcting code that uses strategically placed parity bits to detect and, under its supported conditions, locate/correct errors.

---

## Q8. What is a syndrome?

A set of parity-check results used in error detection/correction. In Hamming coding, the syndrome can indicate the position of a single-bit error.

---

## Q9. What is an LFSR?

A **Linear Feedback Shift Register** is a shift register whose input is generated using XOR feedback. LFSR structures are commonly used to implement CRC-related hardware.

---

## Q10. Does CRC correct errors?

Normally, CRC is used for **error detection**, not direct correction.

A system can then request retransmission or use another mechanism to recover the correct data.

---

# 32. Practice Questions

### Question 1

For:

```text
Data = 1011001
```

How many `1`s are present?

---

### Question 2

For the same data, determine the even-parity bit.

---

### Question 3

What is:

```text
1011 XOR 1101
```

---

### Question 4

For generator:

```text
1101
```

what is its polynomial?

Answer:

$$
x^3+x^2+1
$$

---

### Question 5

How many zeros are appended before CRC division for generator `1101`?

Answer:

```text
3
```

because the polynomial degree is 3.

---

### Question 6

Why is CRC generally stronger than a single parity bit?

---

### Question 7

Where are Hamming parity bits normally placed?

Answer:

```text
1, 2, 4, 8, ...
```

---

# 33. Day 34 Assignment

## Main Assignment

Design an **8-bit CRC generator using a 4-bit generator polynomial**.

Use:

```text
Message = 8 bits
Generator = 1101
CRC = 3 bits
```

Your design should:

1. Accept an 8-bit message.
2. Append three zeros.
3. Perform modulo-2 division.
4. Generate the 3-bit remainder.
5. Output the CRC.
6. Verify multiple messages.
7. Create a CRC checker.
8. Inject an error into a transmitted frame.
9. Verify that the checker detects the error.

---

# 34. Recommended Repository Structure

```text
50-Days-of-RTL/
│
├── Day_31_Clock_Dividers/
├── Day_32_Fractional_Clock_Dividers/
├── Day_33_Glue_Logic/
│
└── Day_34_Error_Detection_Correction/
    │
    ├── README.md
    │
    ├── parity_generator.v
    ├── parity_checker.v
    │
    ├── crc8_4bit_generator.v
    ├── tb_crc8_4bit_generator.v
    │
    ├── crc_checker.v
    ├── tb_crc_checker.v
    │
    └── simulation/
```

---

# 35. Git Commit

```bash
git add Day_34_Error_Detection_Correction/
```

```bash
git commit -m "Day 34: Implement CRC error detection"
```

```bash
git push
```

---

# 36. Day 34 Key Takeaways

Remember these points for placement:

```text
1. Error detection determines whether data was corrupted.

2. Error correction can additionally recover/correct supported errors.

3. Parity is the simplest error-detection method.

4. CRC stands for Cyclic Redundancy Check.

5. CRC uses modulo-2 polynomial division.

6. XOR performs the modulo-2 arithmetic.

7. Generator polynomial determines the CRC.

8. For a degree-r generator, the CRC has r bits.

9. CRC is primarily an error-detection technique.

10. LFSRs are commonly used for efficient CRC hardware.

11. Hamming code uses parity bits for error detection/correction.

12. Hamming parity positions are powers of two:
    1, 2, 4, 8, ...

13. Hamming syndrome can identify the position of a
    single-bit error under the appropriate code.
```

## ⭐ Most Important Formulas

### Parity

$$
\boxed{Parity = \bigoplus Data}
$$

### CRC

$$
\boxed{CRC = Data\cdot x^r \bmod G(x)}
$$

where:

* `r` = degree of generator polynomial
* `G(x)` = generator polynomial

### CRC Generator

```text
1101
```

corresponds to:

$$
\boxed{G(x)=x^3+x^2+1}
$$

### Hamming parity positions

$$
\boxed{1,2,4,8,\ldots}
$$

**Day 34 complete: Error Detection & Correction → Parity → CRC → Hamming fundamentals → Verilog implementation → simulation → placement preparation.**
