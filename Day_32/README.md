# Day 32 — Fractional Clock Dividers

## 📌 Topic

**Fractional Clock Dividers**

## 🎯 Roadmap Objective

Understand the role of **PLLs and MMCMs** in generating clocks and managing phase and frequency.

> **Important:** Day 31 dealt with integer clock division using counters. Day 32 moves toward frequency relationships that cannot be produced by a simple integer counter divider and introduces the concept of PLL/MMCM-based clock management.

---

# 1. Learning Objectives

By the end of Day 32, you should understand:

* Why integer clock dividers are limited.
* What fractional clock division means.
* Why some required output frequencies cannot be generated using a simple counter.
* The basic idea of a fractional divider.
* The difference between integer and fractional division.
* The basic purpose of a PLL.
* The basic purpose of an MMCM.
* How multiplication and division can be combined to obtain a required frequency.
* Why PLL/MMCM clock generation is preferred over arbitrary fabric-generated clocks in FPGA designs.
* The difference between simulation of RTL logic and actual FPGA clock-management resources.

---

# 2. Revision of Day 31

In Day 31 we used:

$$
F_{out}=\frac{F_{in}}{2N}
$$

where `N` is an integer.

For example:

```text
Input  = 100 MHz
N      = 5

Output = 100 / (2 × 5)
       = 10 MHz
```

So:

```text
100 MHz → 10 MHz
```

works perfectly.

But what happens if we want:

```text
50 MHz → 3 MHz
```

?

The required ratio is:

$$
\frac{50}{3}=16.6667
$$

That is not an integer.

A simple fixed integer counter divider cannot generate exactly 3 MHz.

---

# 3. What is Fractional Clock Division?

A **fractional clock divider** produces a clock or timing signal whose effective frequency corresponds to a non-integer division ratio.

For example:

```text
100 MHz → 6.25 MHz
```

The division ratio is:

$$
\frac{100}{6.25}=16
$$

This one is actually an integer ratio.

But consider:

```text
100 MHz → 7 MHz
```

Then:

$$
\frac{100}{7}=14.2857...
$$

The required ratio is fractional.

A simple integer counter cannot directly implement that exact relationship.

---

# 4. Integer vs Fractional Division

## Integer division

Example:

```text
100 MHz → 10 MHz
```

$$
100/10=10
$$

Integer ratio.

A counter-based divider can implement it.

---

## Fractional relationship

Example:

```text
100 MHz → 7 MHz
```

$$
100/7=14.2857...
$$

Non-integer ratio.

A simple fixed integer counter is insufficient.

This is where more advanced clock-generation techniques become useful.

---

# 5. Basic Concept of a Fractional Divider

A conceptual fractional divider can alternate between different integer division values.

For example, suppose the desired average division ratio is:

```text
4.5
```

A conceptual divider could alternate:

```text
4
5
4
5
4
5
...
```

The average is:

$$
\frac{4+5}{2}=4.5
$$

Therefore the **average** division ratio can be fractional.

However, this does **not** mean that the resulting signal has the same properties as a clean clock produced by a dedicated clock-management resource.

The instantaneous periods vary.

This is an important hardware-design distinction.

---

# 6. Why Period Variation Matters

Suppose a divider alternates between:

```text
4 input cycles
5 input cycles
4 input cycles
5 input cycles
```

The output periods are not identical.

Conceptually:

```text
Output period:

4 cycles
    ↓
|--------|

5 cycles
    ↓
|----------|

4 cycles
    ↓
|--------|
```

Therefore the output contains timing variation.

For ordinary data enables this may sometimes be acceptable.

For a true clock, however, phase, jitter, duty cycle, and timing characteristics matter.

---

# 7. Fractional Division Using an Accumulator

A useful conceptual technique is a **phase accumulator**.

Suppose:

```text
phase_accumulator
```

is incremented every input clock.

Conceptually:

```text
             ┌────────────────┐
CLK ────────►│ Phase          │
             │ Accumulator    │
             └───────┬────────┘
                     │
                     ▼
                 MSB / Carry
                     │
                     ▼
                Output signal
```

The accumulator repeatedly wraps around.

This can create a programmable average frequency.

---

# 8. Simple Fractional Frequency Generator

For learning purposes, we can implement a phase accumulator.

Create:

```text
fractional_divider.v
```

```verilog
module fractional_divider #(
    parameter WIDTH = 32,
    parameter [WIDTH-1:0] PHASE_INC = 32'd1
)(
    input  wire clk,
    input  wire reset,
    output wire clk_out
);

    reg [WIDTH-1:0] phase_acc;

    always @(posedge clk) begin
        if (reset)
            phase_acc <= {WIDTH{1'b0}};
        else
            phase_acc <= phase_acc + PHASE_INC;
    end

    assign clk_out = phase_acc[WIDTH-1];

endmodule
```

---

# 9. How the Phase Accumulator Works

The accumulator performs:

$$
Phase_{next}=Phase+Phase\_INC
$$

Because the register has a finite width, it eventually wraps around.

The MSB changes state periodically.

Therefore the MSB becomes a programmable frequency output.

---

# 10. Important Formula

For a `WIDTH`-bit phase accumulator:

$$
\boxed{
F_{out}\approx
F_{clk}
\frac{PHASE\_INC}{2^{WIDTH}}
}
$$

Therefore:

$$
\boxed{
PHASE\_INC\approx
\frac{F_{out}}{F_{clk}}
2^{WIDTH}
}
$$

This is an important formula for understanding fractional frequency generation.

---

# 11. Example

Suppose:

```text
Input clock = 100 MHz
WIDTH       = 16
Required    = 25 MHz
```

Then:

$$
PHASE\_INC=
\frac{25}{100}\times2^{16}
$$

$$
PHASE\_INC=
0.25\times65536
$$

$$
\boxed{PHASE\_INC=16384}
$$

So:

```verilog
parameter PHASE_INC = 16'd16384;
```

would produce an approximately 25 MHz output from the phase accumulator.

---

# 12. Important Difference: Frequency Generator vs Clock Divider

This distinction is very important.

The phase accumulator is useful for understanding **fractional frequency generation**.

It does not automatically mean that the resulting signal is suitable as a global FPGA clock.

For FPGA design, dedicated clock-management resources should be considered when an actual clock is required.

Conceptually:

```text
                 ┌────────────────┐
                 │ Phase          │
                 │ Accumulator     │
                 └───────┬────────┘
                         │
                         ▼
                    Frequency
                    generation
```

versus:

```text
Input Clock
     │
     ▼
┌─────────────┐
│ PLL / MMCM  │
└──────┬──────┘
       │
       ▼
Managed FPGA Clock
```

---

# 13. What is a PLL?

**PLL** stands for:

> **Phase-Locked Loop**

A PLL is a feedback-based clock-management circuit.

Conceptually:

```text
                 ┌─────────────┐
Reference ──────►│             │
Clock            │     PLL     │────► Output Clock
                 │             │
                 └──────▲──────┘
                        │
                        └── Feedback
```

A PLL can be used for clock generation and management.

The roadmap specifically introduces PLLs in the context of generating clocks and managing phase/frequency.

---

# 14. Basic PLL Concept

A simplified PLL contains:

```text
Reference Clock
       │
       ▼
┌──────────────┐
│ Phase/Freq   │
│ Detector     │
└──────┬───────┘
       │
       ▼
     Filter
       │
       ▼
      VCO
       │
       ▼
 Output Clock
       │
       ▼
    Divider
       │
       └──────────► Feedback
```

The feedback path allows the PLL to lock the generated clock relationship to the reference.

---

# 15. What is an MMCM?

**MMCM** stands for:

> **Mixed-Mode Clock Manager**

An MMCM is a dedicated FPGA clock-management resource.

It can be used for clock generation and management, including frequency and phase relationships.

Conceptually:

```text
Input Clock
     │
     ▼
   MMCM
     │
 ┌───┼────────┐
 ▼   ▼        ▼
CLK0 CLK1    CLK2
```

Different clock outputs can be configured for different requirements depending on the FPGA architecture.

---

# 16. PLL vs MMCM

At a high level:

| Feature                | PLL               | MMCM                     |
| ---------------------- | ----------------- | ------------------------ |
| Full form              | Phase-Locked Loop | Mixed-Mode Clock Manager |
| Clock generation       | Yes               | Yes                      |
| Frequency management   | Yes               | Yes                      |
| Phase management       | Yes               | Yes                      |
| FPGA-specific resource | Depends on device | FPGA-specific            |
| Configuration          | Device dependent  | Device dependent         |

**Important:** Exact capabilities and limits depend on the FPGA family.

Therefore, when using Vivado, always use the clocking resources supported by your specific FPGA.

---

# 17. Frequency Relationship

A simplified clock-management relationship can be represented as:

$$
\boxed{
F_{out}=F_{in}\times\frac{M}{D\times O}
}
$$

where:

```text
M = multiplication factor
D = input division factor
O = output division factor
```

This is a conceptual relationship.

The actual legal values and architecture-specific constraints depend on the FPGA's PLL/MMCM resources.

---

# 18. Example

Suppose:

```text
Fin = 100 MHz
M   = 3
D   = 1
O   = 6
```

Then:

$$
F_{out}
=
100\times\frac{3}{1\times6}
$$

$$
F_{out}=50MHz
$$

So:

```text
100 MHz → 50 MHz
```

---

# 19. Another Example

Suppose:

```text
Fin = 50 MHz
M   = 8
D   = 1
O   = 10
```

Then:

$$
F_{out}
=
50\times\frac{8}{10}
$$

$$
\boxed{F_{out}=40MHz}
$$

Again, this is a simplified conceptual calculation. Actual FPGA configuration must satisfy the device-specific clocking constraints.

---

# 20. Why Not Always Use a Counter?

A counter divider is useful when:

* the required ratio is an integer,
* a slower enable is sufficient,
* the signal does not need to be treated as a dedicated clock.

But dedicated clock-management resources are appropriate when clock quality and clock-network behavior matter.

The key idea is:

```text
Counter divider
     ↓
Simple digital frequency division

PLL/MMCM
     ↓
Dedicated clock generation/management
```

---

# 21. Fractional Divider vs PLL/MMCM

| Property                       | Counter Divider | Fractional Accumulator | PLL/MMCM                             |
| ------------------------------ | --------------- | ---------------------- | ------------------------------------ |
| Integer division               | Yes             | Yes                    | Yes                                  |
| Fractional average frequency   | No              | Yes                    | Yes, subject to device configuration |
| Simple RTL                     | Yes             | Yes                    | Usually IP/tool configured           |
| Dedicated clock resource       | No              | No                     | Yes                                  |
| Phase management               | Limited         | Conceptual/digital     | Yes                                  |
| FPGA clock-network integration | Not inherently  | Not inherently         | Yes                                  |
| Main use                       | Simple division | Frequency generation   | Clock management                     |

---

# 22. RTL Simulation Assignment

Create:

```text
tb_fractional_divider.v
```

```verilog
`timescale 1ns/1ps

module tb_fractional_divider;

    reg clk;
    reg reset;

    wire clk_out;

    fractional_divider #(
        .WIDTH(16),
        .PHASE_INC(16'd16384)
    ) dut (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_out)
    );

    // 100 MHz clock
    // Period = 10 ns
    always #5 clk = ~clk;

    initial begin

        $dumpfile("fractional_divider.vcd");
        $dumpvars(0, tb_fractional_divider);

        clk   = 1'b0;
        reset = 1'b1;

        #20;

        reset = 1'b0;

        #1000;

        $finish;

    end

    initial begin
        $monitor(
            "TIME=%0t CLK=%b PHASE=%0d OUT=%b",
            $time,
            clk,
            dut.phase_acc,
            clk_out
        );
    end

endmodule
```

---

# 23. Compile

From Ubuntu:

```bash
iverilog -o fractional_divider_sim \
    fractional_divider.v \
    tb_fractional_divider.v
```

Run:

```bash
vvp fractional_divider_sim
```

Open waveform:

```bash
gtkwave fractional_divider.vcd
```

Observe:

```text
clk
reset
dut.phase_acc
clk_out
```

---

# 24. Directory Structure

Create:

```bash
mkdir -p ~/RTL_50_Days/Day_32_Fractional_Clock_Dividers
cd ~/RTL_50_Days/Day_32_Fractional_Clock_Dividers
```

Files:

```text
Day_32_Fractional_Clock_Dividers/
│
├── README.md
├── fractional_divider.v
└── tb_fractional_divider.v
```

---

# 25. Important Simulation Observation

With:

```text
WIDTH = 16
PHASE_INC = 16384
```

we calculated:

$$
F_{out}
=
100MHz
\times
\frac{16384}{65536}
$$

$$
F_{out}
=
100MHz\times0.25
$$

$$
\boxed{F_{out}=25MHz}
$$

So the phase accumulator produces an approximately 25 MHz output.

---

# 26. Clocking Architecture

Understand this hierarchy:

```text
                    System Clock
                         │
             ┌───────────┴───────────┐
             │                       │
             ▼                       ▼
       Integer Divider        Fractional Generator
             │                       │
             ▼                       ▼
        Slow Enable             Digital Output
             
                         OR

                    System Clock
                         │
                         ▼
                    PLL / MMCM
                         │
             ┌───────────┼───────────┐
             ▼           ▼           ▼
           CLK0        CLK1        CLK2
```

---

# 27. Placement Interview Questions

## Q1. What is fractional clock division?

It is a method of obtaining a frequency relationship corresponding to a non-integer division ratio, rather than only an integer divide.

---

## Q2. Why can't a simple counter generate every frequency?

Because a fixed counter divider uses an integer number of input clock cycles between transitions.

---

## Q3. What is PLL?

PLL means:

$$
\boxed{\text{Phase-Locked Loop}}
$$

It is a feedback-based clock-management circuit.

---

## Q4. What is MMCM?

MMCM means:

$$
\boxed{\text{Mixed-Mode Clock Manager}}
$$

It is a dedicated FPGA clock-management resource.

---

## Q5. What is the basic phase-accumulator equation?

$$
\boxed{
Phase_{next}=Phase+PHASE\_INC
}
$$

---

## Q6. What is the phase-accumulator frequency equation?

$$
\boxed{
F_{out}\approx
F_{clk}
\frac{PHASE\_INC}{2^{WIDTH}}
}
$$

---

## Q7. What happens when the accumulator overflows?

It wraps around because the accumulator has a fixed number of bits.

---

## Q8. Why is a digital fractional divider not automatically a good clock source?

Because its output can have timing variation and it is not automatically connected to the FPGA's dedicated clock network.

---

## Q9. What is the difference between PLL and a counter divider?

A counter divider is ordinary digital logic, whereas a PLL is a dedicated clock-management mechanism based on phase/frequency feedback.

---

## Q10. Why are PLL/MMCM resources important in FPGA design?

They provide dedicated mechanisms for clock generation and management rather than relying only on ordinary fabric logic.

---

# 28. Practice Questions

### Practice 1

Input:

```text
100 MHz
```

Required:

```text
25 MHz
```

Using a 16-bit phase accumulator, calculate `PHASE_INC`.

$$
PHASE\_INC=
\frac{25}{100}\times65536
$$

Answer:

$$
\boxed{16384}
$$

---

### Practice 2

Input:

```text
80 MHz
```

Required:

```text
20 MHz
```

For a 16-bit accumulator:

$$
PHASE\_INC=
\frac{20}{80}\times65536
$$

$$
\boxed{16384}
$$

---

### Practice 3

Input:

```text
100 MHz
```

Required:

```text
10 MHz
```

For a 16-bit accumulator:

$$
PHASE\_INC=
\frac{10}{100}\times65536
$$

$$
PHASE\_INC=6553.6
$$

Because the accumulator increment is an integer, the actual frequency is an approximation.

This demonstrates why fractional frequency generation has finite resolution.

---

# 29. Day 32 Assignment

Implement a **parameterized fractional frequency generator** using a phase accumulator.

### Requirements

Inputs:

```text
clk
reset
```

Parameters:

```text
WIDTH
PHASE_INC
```

Output:

```text
clk_out
```

Test:

```text
100 MHz → approximately 25 MHz
```

using:

```text
WIDTH = 16
PHASE_INC = 16384
```

Then calculate a `PHASE_INC` value for:

```text
100 MHz → approximately 10 MHz
```

and verify it in simulation.

Also document why a digital fractional generator and a dedicated FPGA PLL/MMCM are not interchangeable concepts.

---

# 30. Git Repository Structure

Your repository should now look like:

```text
50-Days-of-RTL/
│
├── Day_01_Naming_Convention/
├── ...
├── Day_29_Concurrency/
├── Day_30_Recursive_Systems/
├── Day_31_Clock_Dividers/
│
└── Day_32_Fractional_Clock_Dividers/
    ├── README.md
    ├── fractional_divider.v
    └── tb_fractional_divider.v
```

---

# 31. Git Commit

```bash
git add Day_32_Fractional_Clock_Dividers/
```

```bash
git commit -m "Day 32: Implement fractional clock divider"
```

```bash
git push
```

---

# 32. Day 32 Key Takeaways

Remember these points for placement:

```text
1. Integer counter dividers cannot generate every arbitrary frequency.

2. Fractional frequency generation can use a phase accumulator.

3. Phase accumulator:
   
   Phase_next = Phase + PHASE_INC

4. Frequency:

   Fout ≈ Fclk × PHASE_INC / 2^WIDTH

5. PLL = Phase-Locked Loop.

6. MMCM = Mixed-Mode Clock Manager.

7. PLL/MMCM are dedicated clock-management resources.

8. A digital fractional generator is not automatically a suitable
   global FPGA clock.

9. Clock frequency, phase, duty cycle, jitter and clock-network
   behavior are important when designing real clocking systems.

10. Day 31 → integer clock division.
    Day 32 → fractional frequency generation + PLL/MMCM concepts.
```

---

# ⭐ Most Important Interview Formula

$$
\boxed{
F_{out}\approx
F_{clk}
\frac{PHASE\_INC}{2^{WIDTH}}
}
$$

And remember:

```text
Day 31:
Counter-based integer division

Day 32:
Fractional frequency generation
        +
PLL/MMCM clock-management concepts
```

**Day 32 complete — Fractional Clock Dividers.**
