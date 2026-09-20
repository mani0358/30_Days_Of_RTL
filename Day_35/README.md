# Day 35 — Waveform Generators

## 📌 Topic

**Waveform Generators**

## 🎯 Roadmap Objective

Learn how digital RTL can generate mathematical waveforms.

### Day 35 Assignment

> Generate a **Sinc waveform** using Verilog RTL.

The main goal is to understand the connection between:

```text
Mathematical function
        ↓
Discrete samples
        ↓
Digital representation
        ↓
RTL waveform generator
        ↓
DAC / simulation
```

---

# 1. Learning Objectives

By the end of Day 35, you should understand:

* What a waveform generator is.
* Continuous vs discrete-time waveforms.
* Sampling.
* Digital waveform generation.
* What a Sinc function is.
* Why a Sinc waveform is useful.
* How to represent waveform samples digitally.
* ROM/LUT-based waveform generation.
* How to generate waveform samples using a counter.
* How to simulate a waveform in Verilog.
* How to inspect the generated waveform using GTKWave.
* Why LUT-based waveform generation is common in FPGA designs.

---

# 2. What is a Waveform Generator?

A waveform generator produces a sequence of values representing a desired waveform.

For example:

```text
Sine wave
Triangle wave
Square wave
Sawtooth wave
Sinc wave
```

In digital hardware, the waveform is normally represented as a sequence of samples.

```text
        Waveform
           │
           ▼
    Sample generation
           │
           ▼
       Digital data
           │
           ▼
          DAC
           │
           ▼
     Analog waveform
```

For today's simulation, we will stop at the digital samples.

---

# 3. Continuous vs Discrete Waveform

A mathematical waveform may be continuous:

```text
Amplitude
   │
   │      /\
   │     /  \
   │____/    \____
   │
   └──────────────────► time
```

A digital circuit cannot directly represent every continuous point.

Instead, it uses samples:

```text
Amplitude
   │
   │       ●
   │      ● ●
   │     ●   ●
   │  ● ●     ● ●
   │ ●           ●
   └──────────────────► sample number
```

Each sample is represented by a binary number.

---

# 4. What is a Sinc Function?

The normalized Sinc function is commonly defined as:

$$
\boxed{
sinc(x)=\frac{\sin(\pi x)}{\pi x}
}
$$

At:

$$
x=0
$$

the expression appears to contain:

$$
\frac{0}{0}
$$

but its limiting value is:

$$
\boxed{sinc(0)=1}
$$

Therefore:

```text
sinc(0) = 1
```

---

# 5. Shape of Sinc

The Sinc function has a central peak and oscillating side lobes.

Conceptually:

```text
Amplitude

  1.0              ●
                    │
                   / \
                  /   \
─────────────────●─────●──────────────────
              /           \
             /             \
            ●               ●
                 \       /
                  \_____/

                 time →
```

More accurately, it has zeros at non-zero integer values:

$$
x=\pm1,\pm2,\pm3,\ldots
$$

because:

$$
\sin(\pi n)=0
$$

for integer `n`.

---

# 6. Important Sinc Properties

For:

$$
sinc(x)=\frac{\sin(\pi x)}{\pi x}
$$

we have:

### At zero

$$
sinc(0)=1
$$

### At integer values

$$
sinc(n)=0
$$

for non-zero integer `n`.

Examples:

```text
sinc(1) = 0
sinc(2) = 0
sinc(3) = 0
```

and because Sinc is an even function:

$$
sinc(-x)=sinc(x)
$$

---

# 7. Why is Sinc Important?

The Sinc function is strongly associated with sampling and signal processing.

It appears in:

* interpolation
* reconstruction theory
* digital signal processing
* filtering
* communication systems
* signal analysis

For an ideal low-pass filter, the impulse response has a Sinc-shaped form.

---

# 8. Important RTL Point

Verilog hardware does not naturally perform floating-point:

```text
sin()
division
π
```

as simple synthesizable operations.

Therefore, FPGA designs commonly use:

```text
Mathematical waveform
        ↓
Calculate samples offline
        ↓
Quantize samples
        ↓
Store in LUT/ROM
        ↓
Counter/address
        ↓
Waveform samples
```

This is the approach we will use.

---

# 9. LUT-Based Waveform Generator

LUT means:

**Look-Up Table**

The idea is:

```text
Address
   │
   ▼
┌──────────────┐
│     ROM      │
│              │
│ sample 0     │
│ sample 1     │
│ sample 2     │
│ ...          │
│ sample N     │
└──────┬───────┘
       │
       ▼
 waveform sample
```

A counter generates addresses.

```text
Counter
   │
   ▼
ROM address
   │
   ▼
Sinc sample
```

---

# 10. Digital Sinc Samples

For a simple demonstration, we can use a small set of quantized Sinc samples.

For example, using a symmetric sequence:

```text
        central peak
             ↓
...  -2  -1   0   1   2  ...
      │   │   │   │   │
      ▼   ▼   ▼   ▼   ▼

     small values
           ↓
          peak
           ↓
     small values
```

Because Sinc is symmetric:

$$
sinc(-x)=sinc(x)
$$

our LUT can also be symmetric.

---

# 11. 8-bit Signed Samples

We will represent the waveform using:

```text
8-bit signed
```

Therefore:

```text
Minimum = -128
Maximum = +127
```

The zero-centered waveform can be represented using signed two's-complement values.

Example:

```text
Amplitude
 +127 ────────●
              │
    0 ───●────┼────●────────
              │
 -128 ────────┴────────────
```

---

# 12. Simple Sinc LUT

For learning purposes, use the following 16 samples:

```text
Address    Sample
0          -10
1          -12
2          -8
3           0
4          12
5          32
6          64
7          96
8         127
9          96
10         64
11         32
12         12
13          0
14         -8
15        -12
```

These values provide a **discrete Sinc-like symmetric waveform** suitable for learning the RTL waveform-generator architecture.

Important:

> These are quantized demonstration samples, not an exact mathematical Sinc sampled at a specified continuous-time grid.

---

# 13. Why Use a LUT?

Instead of trying to calculate:

$$
\frac{\sin(\pi x)}{\pi x}
$$

inside every clock cycle, we store precomputed values.

Advantages:

* Simple hardware.
* Fast output.
* Predictable timing.
* Easy FPGA implementation.
* ROM inference is possible.
* No expensive real-number division required.

---

# 14. Basic Sinc Generator RTL

Create:

```text
sinc_generator.v
```

```verilog
module sinc_generator (
    input  wire       clk,
    input  wire       reset,
    output reg signed [7:0] sample
);

    reg [3:0] address;

    always @(posedge clk) begin
        if (reset)
            address <= 4'd0;
        else
            address <= address + 1'b1;
    end

    always @(*) begin

        case (address)

            4'd0:  sample = -8'sd10;
            4'd1:  sample = -8'sd12;
            4'd2:  sample = -8'sd8;
            4'd3:  sample =  8'sd0;
            4'd4:  sample =  8'sd12;
            4'd5:  sample =  8'sd32;
            4'd6:  sample =  8'sd64;
            4'd7:  sample =  8'sd96;
            4'd8:  sample =  8'sd127;
            4'd9:  sample =  8'sd96;
            4'd10: sample =  8'sd64;
            4'd11: sample =  8'sd32;
            4'd12: sample =  8'sd12;
            4'd13: sample =  8'sd0;
            4'd14: sample = -8'sd8;
            4'd15: sample = -8'sd12;

            default:
                sample = 8'sd0;

        endcase

    end

endmodule
```

---

# 15. How the RTL Works

There are two main parts.

### Part 1 — Address Counter

```verilog
always @(posedge clk)
```

increments:

```text
0 → 1 → 2 → ... → 15 → 0 → ...
```

Because the address is 4 bits:

```text
1111 + 1 = 0000
```

so the waveform automatically repeats.

---

# 16. Part 2 — LUT

The `case` statement behaves like a ROM/LUT:

```text
address → sample
```

For example:

```text
address = 8
```

gives:

```text
sample = 127
```

which is the center peak.

---

# 17. Address-to-Sample Table

| Address | Signed Sample |
| ------: | ------------: |
|       0 |           -10 |
|       1 |           -12 |
|       2 |            -8 |
|       3 |             0 |
|       4 |            12 |
|       5 |            32 |
|       6 |            64 |
|       7 |            96 |
|       8 |           127 |
|       9 |            96 |
|      10 |            64 |
|      11 |            32 |
|      12 |            12 |
|      13 |             0 |
|      14 |            -8 |
|      15 |           -12 |

This table is the digital waveform.

---

# 18. Testbench

Create:

```text
tb_sinc_generator.v
```

```verilog
`timescale 1ns/1ps

module tb_sinc_generator;

    reg clk;
    reg reset;

    wire signed [7:0] sample;

    sinc_generator dut (
        .clk    (clk),
        .reset  (reset),
        .sample (sample)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sinc_generator.vcd");
        $dumpvars(0, tb_sinc_generator);

        clk   = 1'b0;
        reset = 1'b1;

        #20;

        reset = 1'b0;

        #200;

        $finish;

    end

    always @(posedge clk) begin
        $display(
            "TIME=%0t ADDRESS=%0d SAMPLE=%0d",
            $time,
            dut.address,
            sample
        );
    end

endmodule
```

---

# 19. Ubuntu Setup

Create the directory:

```bash
mkdir -p ~/RTL_50_Days/Day_35_Waveform_Generators
cd ~/RTL_50_Days/Day_35_Waveform_Generators
```

Create:

```text
sinc_generator.v
tb_sinc_generator.v
README.md
```

---

# 20. Compile

Use Icarus Verilog:

```bash
iverilog -o sinc_sim \
    sinc_generator.v \
    tb_sinc_generator.v
```

If there are no errors, run:

```bash
vvp sinc_sim
```

---

# 21. Expected Terminal Behavior

You should see addresses and samples changing:

```text
TIME=...
ADDRESS=0 SAMPLE=-10
ADDRESS=1 SAMPLE=-12
ADDRESS=2 SAMPLE=-8
ADDRESS=3 SAMPLE=0
ADDRESS=4 SAMPLE=12
ADDRESS=5 SAMPLE=32
ADDRESS=6 SAMPLE=64
ADDRESS=7 SAMPLE=96
ADDRESS=8 SAMPLE=127
...
```

The exact first displayed sample depends on the clock/reset event at which the monitor executes.

The important sequence is:

```text
-10
-12
-8
0
12
32
64
96
127
96
64
32
12
0
-8
-12
```

and then it repeats.

---

# 22. GTKWave

Open the VCD:

```bash
gtkwave sinc_generator.vcd
```

Add:

```text
clk
reset
dut.address
sample
```

You should see the sample value changing according to the LUT.

---

# 23. Expected Waveform

Conceptually:

```text
Sample

 127                         ●
                            / \
  96                       ●   ●
                           │   │
  64                     ●       ●
                         │       │
  32                   ●           ●
                       │           │
   0 ───────────────●───────────────●────
                   /                 \
 -10             ●                     ●
                 \_____________________/

                 sample number →
```

The central sample is the largest positive value.

---

# 24. Truth/Sequence Verification

This is not a Boolean logic circuit, so a conventional truth table is not applicable.

Instead, verify the LUT sequence:

| Address | Expected Sample |
| ------: | --------------: |
|       0 |             -10 |
|       1 |             -12 |
|       2 |              -8 |
|       3 |               0 |
|       4 |              12 |
|       5 |              32 |
|       6 |              64 |
|       7 |              96 |
|       8 |             127 |
|       9 |              96 |
|      10 |              64 |
|      11 |              32 |
|      12 |              12 |
|      13 |               0 |
|      14 |              -8 |
|      15 |             -12 |

Important symmetry check:

```text
sample[7] = sample[9]
sample[6] = sample[10]
sample[5] = sample[11]
sample[4] = sample[12]
sample[3] = sample[13]
sample[2] = sample[14]
sample[1] = sample[15]
```

This verifies the intended symmetric LUT.

---

# 25. Better Verification

A good RTL testbench should automatically check the samples.

Example:

```verilog
integer errors;

initial begin

    errors = 0;

    #20;
    reset = 1'b0;

    #10;
    if (sample !== -8'sd10)
        errors = errors + 1;

    #10;
    if (sample !== -8'sd12)
        errors = errors + 1;

    #10;
    if (sample !== -8'sd8)
        errors = errors + 1;

    if (errors == 0)
        $display("PASS: Sinc LUT verification successful");
    else
        $display("FAIL: %0d errors detected", errors);

end
```

For a larger project, a complete self-checking testbench is preferable.

---

# 26. Why Not Calculate Sinc Directly in Verilog?

You might think of writing:

```verilog
sample = sin(pi*x)/(pi*x);
```

This is not a good synthesizable FPGA implementation.

Problems include:

* real-number arithmetic
* sine calculation
* division
* hardware cost
* timing complexity
* synthesis support limitations

Instead:

```text
Mathematical function
        ↓
Offline calculation
        ↓
Quantization
        ↓
LUT / ROM
        ↓
RTL
```

is usually much more practical.

---

# 27. LUT vs Algorithmic Waveform Generation

| Method                   | Advantage                           | Disadvantage        |
| ------------------------ | ----------------------------------- | ------------------- |
| LUT                      | Fast and simple                     | Uses memory         |
| Direct calculation       | Flexible                            | Expensive hardware  |
| CORDIC                   | Computes trig functions efficiently | More logic/latency  |
| Polynomial approximation | Can reduce memory                   | Approximation error |

For today's beginner RTL implementation:

$$
\boxed{\text{LUT is the simplest approach}}
$$

---

# 28. Waveform Generator Architecture

A practical FPGA waveform generator can look like:

```text
             Clock
               │
               ▼
        ┌─────────────┐
        │ Phase/Addr  │
        │  Accumulator│
        └──────┬──────┘
               │
               ▼
        ┌─────────────┐
        │   Waveform  │
        │    LUT/ROM  │
        └──────┬──────┘
               │
               ▼
          Digital Sample
               │
               ▼
              DAC
               │
               ▼
       Analog Waveform
```

---

# 29. Relationship to Day 32

Day 32 covered:

**Fractional Clock Dividers**

One important concept was the phase accumulator.

A phase accumulator can also be used to generate a waveform address.

For example:

```text
Phase accumulator
       │
       ▼
Address
       │
       ▼
     LUT
       │
       ▼
 Waveform
```

This is a major FPGA/DSP concept.

---

# 30. Frequency Control

Suppose the LUT contains one complete waveform cycle.

If the address increments by:

```text
1
```

every clock:

```text
0 → 1 → 2 → ... → 15 → 0
```

The waveform frequency is determined by:

$$
F_{wave}=\frac{F_{clk}}{N}
$$

where:

* `Fclk` = sample/update clock
* `N` = number of LUT samples per cycle

For a 16-sample LUT:

$$
F_{wave}=\frac{F_{clk}}{16}
$$

when one sample is output every clock and the complete 16-entry LUT represents one cycle.

---

# 31. DDS Connection

This architecture is closely related to:

**DDS — Direct Digital Synthesis**

Basic DDS:

```text
          Frequency Control Word
                    │
                    ▼
             Phase Accumulator
                    │
                    ▼
              Phase → Address
                    │
                    ▼
                  ROM
                    │
                    ▼
               Waveform
```

DDS is widely used for:

* RF signal generation
* waveform generation
* communications
* function generators
* SDR systems

This is especially relevant to FPGA/RF design.

---

# 32. Placement Interview Questions

### Q1. What is a waveform generator?

A digital circuit that produces a sequence of values representing a desired waveform.

---

### Q2. What is a LUT?

A Look-Up Table stores precomputed values that can be selected using an address.

---

### Q3. Why use a LUT for waveform generation?

It avoids expensive real-time mathematical calculations and provides predictable hardware timing.

---

### Q4. What is a Sinc function?

For normalized Sinc:

$$
sinc(x)=\frac{\sin(\pi x)}{\pi x}
$$

with:

$$
sinc(0)=1
$$

by the limiting definition.

---

### Q5. Why is Sinc important in DSP?

It is closely related to ideal band-limited interpolation and the impulse response of an ideal low-pass filter.

---

### Q6. What happens to the address counter after 15 in a 4-bit LUT?

It wraps around:

```text
1111 + 1 = 0000
```

---

### Q7. Why are signed samples useful?

Because the waveform contains both positive and negative amplitudes.

---

### Q8. What is quantization?

Converting a continuous or high-precision numerical value into one of a finite set of digital values.

---

### Q9. What is DDS?

Direct Digital Synthesis is a technique that uses digital phase accumulation and waveform lookup to generate periodic waveforms.

---

### Q10. How can waveform frequency be controlled?

By controlling the rate at which the waveform address/phase advances.

---

# 33. Practice Questions

### Practice 1

What is:

$$
sinc(0)
$$

?

---

### Practice 2

What is:

$$
sinc(1)
$$

?

---

### Practice 3

What is the normalized Sinc equation?

---

### Practice 4

Why does the Sinc LUT contain both positive and negative values?

---

### Practice 5

Why is a LUT preferred over calculating `sin()` and division every clock cycle?

---

### Practice 6

If a LUT has 32 samples per waveform cycle and the update clock is 32 MHz, what is the waveform frequency?

$$
F_{wave}=\frac{32MHz}{32}
$$

---

### Practice 7

What happens when a 4-bit address counter reaches:

```text
1111
```

and increments?

---

### Practice 8

What is DDS?

---

# 34. Day 35 Assignment

Implement a complete digital Sinc waveform generator.

### Requirements

1. Use a LUT.
2. Use at least 16 samples.
3. Use signed samples.
4. Generate one repeating waveform cycle.
5. Use a counter or phase accumulator for addressing.
6. Simulate using Icarus Verilog.
7. Generate a VCD file.
8. View the waveform in GTKWave.
9. Verify the sample sequence automatically.
10. Explain how the architecture could connect to a DAC.

### Advanced Extension

Replace the simple counter with a phase accumulator:

```text
phase_accumulator
        │
        ▼
   LUT address
        │
        ▼
    Sinc sample
```

Then change the phase increment and observe the change in waveform frequency.

---

# 35. Repository Structure

```text
50-Days-of-RTL/
│
├── Day_33_Glue_Logic/
├── Day_34_Error_Detection_Correction/
│
└── Day_35_Waveform_Generators/
    │
    ├── README.md
    ├── sinc_generator.v
    ├── tb_sinc_generator.v
    └── sinc_generator.vcd
```

---

# 36. Git Commands

```bash
cd ~/RTL_50_Days
```

```bash
git add Day_35_Waveform_Generators/
```

```bash
git commit -m "Day 35: Implement Sinc waveform generator"
```

```bash
git push
```

---

# 37. Day 35 Key Takeaways

```text
1. Digital waveform generators output discrete samples.

2. Sinc(x) = sin(πx)/(πx).

3. sinc(0) = 1.

4. Sinc is an even function:
   sinc(-x) = sinc(x).

5. A LUT can store precomputed waveform samples.

6. A counter can generate sequential LUT addresses.

7. Signed samples allow positive and negative amplitudes.

8. LUT-based generation is much simpler than implementing
   real-number mathematical calculations directly in RTL.

9. A phase accumulator can control waveform frequency.

10. LUT + phase accumulator is the basic idea behind DDS.

11. Waveform samples can ultimately be sent to a DAC.

12. GTKWave can be used to verify the generated digital waveform.
```

## ⭐ Most Important Concepts

### Sinc

$$
\boxed{sinc(x)=\frac{\sin(\pi x)}{\pi x}}
$$

### Special case

$$
\boxed{sinc(0)=1}
$$

### Symmetry

$$
\boxed{sinc(-x)=sinc(x)}
$$

### LUT waveform frequency

For one complete cycle stored in `N` samples and one sample generated per clock:

$$
\boxed{F_{wave}=\frac{F_{clk}}{N}}
$$

### DDS architecture

```text
Clock
  │
  ▼
Phase Accumulator
  │
  ▼
LUT Address
  │
  ▼
Waveform LUT
  │
  ▼
Digital Sample
  │
  ▼
DAC
```

**Day 35 complete — Waveform Generators → Sinc → LUT → RTL implementation → simulation → GTKWave → DDS fundamentals → placement preparation.**
