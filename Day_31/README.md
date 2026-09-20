# Day 31 — Clock Dividers in Verilog RTL

## 📌 Topic

**Clock Dividers**

## 🎯 Roadmap Objective

Learn methods to divide clocks to meet the timing requirements of peripherals.

---

# 1. Learning Objectives

By the end of Day 31, you should understand:

* What a clock divider is.
* Why clock division is required.
* How a counter can divide a clock.
* How to generate a lower-frequency clock from a higher-frequency clock.
* The difference between frequency division and clock enable generation.
* How to calculate the required divider value.
* How to implement an even clock divider.
* How to implement a divide-by-2 clock.
* How to implement a divide-by-N clock.
* How to verify a clock divider using simulation.
* How clock dividers relate to peripheral timing.

---

# 2. What is a Clock Divider?

A **clock divider** is a digital circuit that generates a lower-frequency clock or timing signal from a higher-frequency clock.

For example:

```text
Input clock  = 100 MHz
Output clock = 50 MHz
```

The output frequency is half the input frequency.

```text
          ┌──────────────┐
100 MHz ─►│ Clock Divider│──► 50 MHz
          └──────────────┘
```

---

# 3. Why Do We Need Clock Dividers?

Different digital systems and peripherals may require different timing frequencies.

For example:

```text
System clock
     │
     ├──► CPU logic
     │
     ├──► Peripheral A
     │
     ├──► Peripheral B
     │
     └──► Communication interface
```

A peripheral may need a slower timing signal than the main system clock.

A clock divider can generate a lower-frequency signal.

---

# 4. Basic Frequency Relationship

If:

```text
F_in = input clock frequency
F_out = output clock frequency
```

then the division ratio is:

$$
N=\frac{F_{in}}{F_{out}}
$$

Therefore:

$$
\boxed{F_{out}=\frac{F_{in}}{N}}
$$

For example:

```text
F_in  = 100 MHz
F_out = 10 MHz
```

Then:

$$
N=\frac{100}{10}=10
$$

So we need a:

```text
Divide-by-10
```

relationship.

---

# 5. Divide-by-2 Clock Divider

The simplest clock divider uses a flip-flop that toggles on every rising edge.

```text
          ┌────────────┐
CLK ─────►│ Toggle FF  │───► CLK_DIV2
          └────────────┘
```

The output changes state once per input clock edge.

Because a complete output period requires two input clock cycles:

$$
\boxed{F_{out}=\frac{F_{in}}{2}}
$$

---

# 6. Divide-by-2 RTL

Create:

```text
clock_div2.v
```

```verilog
module clock_div2 (
    input  wire clk,
    input  wire reset,
    output reg  clk_div2
);

    always @(posedge clk) begin
        if (reset)
            clk_div2 <= 1'b0;
        else
            clk_div2 <= ~clk_div2;
    end

endmodule
```

---

# 7. How Divide-by-2 Works

Suppose initially:

```text
clk_div2 = 0
```

At each rising edge:

```text
clk_div2 <= ~clk_div2;
```

Therefore:

| Input clock edge | `clk_div2` |
| ---------------: | ---------: |
|            Reset |          0 |
|                1 |          1 |
|                2 |          0 |
|                3 |          1 |
|                4 |          0 |
|                5 |          1 |
|                6 |          0 |

The output toggles every input clock cycle.

Therefore:

```text
Input:

__|‾|__|‾|__|‾|__|‾|__

Output:

____|‾‾‾|____|‾‾‾|____
```

The output frequency is half the input frequency.

---

# 8. General Divide-by-N Clock Divider

For a larger division ratio, we can use a counter.

Architecture:

```text
             ┌───────────┐
CLK ────────►│  Counter  │
             └─────┬─────┘
                   │
                   ▼
              Compare N
                   │
                   ▼
              Toggle OUT
```

The counter counts input clock edges.

When the terminal count is reached:

```text
output = ~output
```

and the counter starts again.

---

# 9. Important Frequency Formula

Suppose the output toggles after `N` input clock cycles.

A complete output cycle requires **two toggles**.

Therefore:

$$
\boxed{F_{out}=\frac{F_{in}}{2N}}
$$

This is a very important point.

For example, if:

```text
F_in = 100 MHz
N = 5
```

then:

$$
F_{out}=
\frac{100MHz}{2\times5}
$$

$$
\boxed{F_{out}=10MHz}
$$

---

# 10. Divide-by-10 Example

We want:

```text
100 MHz → 10 MHz
```

Using:

$$
F_{out}=\frac{F_{in}}{2N}
$$

we get:

$$
10=\frac{100}{2N}
$$

Therefore:

$$
2N=10
$$

$$
N=5
$$

So the output must toggle every 5 input clock cycles.

---

# 11. Parameterized Clock Divider

Create:

```text
clock_divider.v
```

```verilog
module clock_divider #(
    parameter DIVIDE = 5
)(
    input  wire clk,
    input  wire reset,
    output reg  clk_out
);

    integer count;

    always @(posedge clk) begin

        if (reset) begin
            count   <= 0;
            clk_out <= 1'b0;
        end

        else if (count == DIVIDE-1) begin
            count   <= 0;
            clk_out <= ~clk_out;
        end

        else begin
            count <= count + 1;
        end

    end

endmodule
```

---

# 12. Example: Divide-by-10

Instantiate:

```verilog
clock_divider #(
    .DIVIDE(5)
) divider_inst (
    .clk(clk),
    .reset(reset),
    .clk_out(clk_out)
);
```

Since the output toggles every 5 input clocks:

$$
F_{out}=\frac{F_{in}}{2(5)}
$$

Therefore:

```text
Fout = Fin / 10
```

---

# 13. Example: 100 MHz to 10 MHz

Given:

```text
Input clock = 100 MHz
Required output = 10 MHz
```

Calculate:

$$
N=\frac{F_{in}}{2F_{out}}
$$

$$
N=\frac{100}{2(10)}
$$

$$
\boxed{N=5}
$$

Therefore:

```verilog
parameter DIVIDE = 5;
```

---

# 14. Example: 50 MHz to 5 MHz

Given:

```text
Fin = 50 MHz
Fout = 5 MHz
```

$$
N=\frac{50}{2(5)}
$$

$$
\boxed{N=5}
$$

Therefore the output toggles every 5 input-clock cycles.

---

# 15. Testbench

Create:

```text
tb_clock_divider.v
```

```verilog
`timescale 1ns/1ps

module tb_clock_divider;

    reg clk;
    reg reset;

    wire clk_out;

    clock_divider #(
        .DIVIDE(5)
    ) dut (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_out)
    );

    // 10 ns input clock period
    always #5 clk = ~clk;

    initial begin

        $dumpfile("clock_divider.vcd");
        $dumpvars(0, tb_clock_divider);

        clk   = 1'b0;
        reset = 1'b1;

        #20;

        reset = 1'b0;

        #300;

        $finish;

    end

    initial begin
        $monitor(
            "TIME=%0t CLK=%b COUNT=%0d CLK_OUT=%b",
            $time,
            clk,
            dut.count,
            clk_out
        );
    end

endmodule
```

---

# 16. Ubuntu Directory

Create the Day 31 directory:

```bash
mkdir -p ~/RTL_50_Days/Day_31_Clock_Dividers
cd ~/RTL_50_Days/Day_31_Clock_Dividers
```

Create the RTL:

```bash
nano clock_divider.v
```

Create the testbench:

```bash
nano tb_clock_divider.v
```

---

# 17. Compile

Use Icarus Verilog:

```bash
iverilog -o clock_divider_sim clock_divider.v tb_clock_divider.v
```

Run:

```bash
vvp clock_divider_sim
```

---

# 18. GTKWave

The testbench creates:

```text
clock_divider.vcd
```

Open it:

```bash
gtkwave clock_divider.vcd
```

Add:

```text
clk
reset
clk_out
```

Also add:

```text
dut.count
```

You should see:

```text
Input clock:
_‾_‾_‾_‾_‾_‾_‾_‾_

Output clock:
___‾‾‾‾___‾‾‾‾___
```

The output frequency will be lower than the input frequency.

---

# 19. Verify Divide-by-10

For the testbench:

```text
Input clock period = 10 ns
```

Therefore:

$$
F_{in}=\frac{1}{10ns}
$$

$$
F_{in}=100MHz
$$

With:

```text
DIVIDE = 5
```

the output period is:

$$
T_{out}=10\times10ns
$$

$$
\boxed{T_{out}=100ns}
$$

Therefore:

$$
F_{out}=\frac{1}{100ns}
$$

$$
\boxed{F_{out}=10MHz}
$$

So the simulation should demonstrate:

```text
100 MHz → 10 MHz
```

---

# 20. Truth/Transition Verification

For:

```text
DIVIDE = 5
```

the counter behavior is:

| Input clock | Counter action | Output |
| ----------: | -------------- | -----: |
|       Reset | counter = 0    |      0 |
|           1 | 0 → 1          |      0 |
|           2 | 1 → 2          |      0 |
|           3 | 2 → 3          |      0 |
|           4 | 3 → 4          |      0 |
|           5 | 4 → 0, toggle  |      1 |
|           6 | 0 → 1          |      1 |
|           7 | 1 → 2          |      1 |
|           8 | 2 → 3          |      1 |
|           9 | 3 → 4          |      1 |
|          10 | 4 → 0, toggle  |      0 |

Therefore the output toggles every five input clock cycles.

Two toggles form one complete output cycle.

---

# 21. Clock Divider vs Counter Enable

This is a **very important placement concept**.

A clock divider creates another timing waveform:

```text
clk ──► divider ──► clk_out
```

A clock-enable approach keeps one system clock:

```text
              ┌──────────────┐
clk ─────────►│ Main logic   │
              │              │
enable ──────►│ Enable       │
              └──────────────┘
```

Instead of creating a new clock, the logic only updates when the enable is asserted.

In FPGA RTL design, using a **clock enable** is often preferable to creating arbitrary fabric-generated clocks for ordinary logic.

---

# 22. Why Gated/Generated Clocks Need Care

A clock is a special signal because it controls sequential elements.

An incorrectly generated clock can create:

* glitches
* unexpected clock edges
* timing problems
* skew problems
* difficult timing analysis

Therefore, do not casually create a clock by ordinary combinational logic such as:

```verilog
assign bad_clk = clk & enable;
```

for general-purpose clock distribution.

Clocking resources and proper clock-enable structures should be considered for FPGA designs.

---

# 23. Clock Divider Using a Toggle Flip-Flop

The divide-by-2 design is:

```verilog
always @(posedge clk) begin
    if (reset)
        clk_div2 <= 1'b0;
    else
        clk_div2 <= ~clk_div2;
end
```

Conceptually:

```text
              ┌─────────────┐
              │             │
CLK ─────────►│   DFF       │
              │ D = ~Q      │
              └──────┬──────┘
                     │
                     ▼
                  CLK/2
```

This is one of the simplest frequency dividers.

---

# 24. Even Division

A counter/toggle divider naturally produces an output with a 50% duty cycle when the output is toggled at equal intervals.

For example:

```text
Divide by 2
Divide by 4
Divide by 6
Divide by 8
Divide by 10
```

can be produced with appropriate toggle counts.

---

# 25. Odd Division

Generating an odd divide ratio with a clean 50% duty-cycle clock is more complicated.

For example:

```text
Divide-by-3
Divide-by-5
Divide-by-7
```

cannot simply be obtained by toggling one output after a fixed integer number of input cycles while maintaining a perfect 50% duty cycle.

This is an important limitation of the simple counter/toggle approach.

More advanced clocking techniques may be required when exact frequency and duty-cycle requirements exist.

---

# 26. Integer Divider Limitation

Suppose:

```text
Fin = 50 MHz
Fout = 3 MHz
```

The required division ratio is:

$$
\frac{50}{3}=16.6667
$$

An integer counter cannot produce this exact frequency using a simple fixed integer division ratio.

This motivates more advanced techniques such as:

```text
Fractional clock division
PLL
MMCM
```

which are topics addressed in the following roadmap day(s). The roadmap specifically lists **Day 32: Fractional Clock Dividers**.

---

# 27. Peripheral Timing

Clock division is useful when a peripheral requires a slower timing reference.

Conceptually:

```text
                 System Clock
                     │
                     ▼
              ┌─────────────┐
              │Clock Divider│
              └──────┬──────┘
                     │
             Peripheral Clock
                     │
                     ▼
                Peripheral
```

The exact clocking method depends on the FPGA/device architecture and peripheral requirements.

---

# 28. Placement Interview Questions

## Q1. What is a clock divider?

A circuit that generates a lower-frequency timing signal from a higher-frequency clock.

---

## Q2. What is the simplest divide-by-2 circuit?

A toggle flip-flop.

---

## Q3. What is the output frequency of a divide-by-2 circuit?

$$
\boxed{F_{out}=\frac{F_{in}}{2}}
$$

---

## Q4. Why does a toggle divider divide the frequency by 2?

Because the output must toggle twice to complete one full output period.

---

## Q5. What is the formula for the counter-based divider used today?

If the output toggles every `N` input clock cycles:

$$
\boxed{F_{out}=\frac{F_{in}}{2N}}
$$

---

## Q6. For 100 MHz to 10 MHz, what toggle count is required?

$$
N=\frac{100}{2\times10}=5
$$

Therefore:

```text
N = 5
```

---

## Q7. Why should generated clocks be handled carefully?

Because glitches, skew, and timing-analysis problems can occur if clocks are generated incorrectly.

---

## Q8. What is a clock enable?

A control signal that determines when synchronous logic updates while the main clock remains unchanged.

---

## Q9. What is the difference between clock division and clock enable?

Clock division creates a slower timing waveform, while a clock enable allows logic to update less frequently without necessarily creating a new clock.

---

## Q10. Why can't a simple integer divider generate every arbitrary frequency?

Because the required division ratio may not be an integer.

---

# 29. Practice Problems

### Problem 1

Input:

```text
100 MHz
```

Divide by 2.

Find output frequency.

### Answer

$$
\boxed{50MHz}
$$

---

### Problem 2

Input:

```text
80 MHz
```

Required:

```text
20 MHz
```

Find `N` for the counter/toggle implementation.

$$
N=\frac{80}{2(20)}
$$

$$
\boxed{N=2}
$$

---

### Problem 3

Input:

```text
50 MHz
```

Using:

```text
N = 5
```

calculate output frequency.

$$
F_{out}=\frac{50}{2(5)}
$$

$$
\boxed{5MHz}
$$

---

### Problem 4

Input clock:

```text
100 MHz
```

Required output:

```text
25 MHz
```

Find `N`.

$$
N=\frac{100}{2(25)}
$$

$$
\boxed{N=2}
$$

---

### Problem 5

Input:

```text
50 MHz
```

Required:

```text
3 MHz
```

Can the simple integer divider generate exactly 3 MHz?

### Answer

No.

$$
\frac{50}{3}=16.6667
$$

The required division relationship is not an integer.

This leads to the next topic:

```text
Fractional Clock Dividers
```

---

# 30. Day 31 Assignment

Implement a parameterized clock divider.

### Requirements

Inputs:

```text
clk
reset
```

Output:

```text
clk_out
```

Use a programmable integer divider.

Verify:

```text
100 MHz → 10 MHz
```

using a suitable testbench.

Also verify:

```text
50 MHz → 5 MHz
```

by changing the testbench clock period and divider value.

Observe in GTKWave:

```text
clk
reset
dut.count
clk_out
```

Calculate the input and output periods manually and compare them with the simulation.

---

# 31. Git Repository Structure

Your repository should now look like:

```text
50-Days-of-RTL/
│
├── Day_01_Naming_Convention/
├── Day_02_Text_Based_Design_Flow/
├── ...
├── Day_28_Pipeline/
├── Day_29_Concurrency/
├── Day_30_Recursive_Systems/
│
└── Day_31_Clock_Dividers/
    ├── README.md
    ├── clock_div2.v
    ├── clock_divider.v
    └── tb_clock_divider.v
```

---

# 32. Git Commit

After completing Day 31:

```bash
git add Day_31_Clock_Dividers/
```

```bash
git commit -m "Day 31: Implement programmable clock divider"
```

```bash
git push
```

---

# 33. Day 31 Key Takeaways

Remember:

```text
1. A clock divider generates a lower-frequency timing signal.

2. A toggle flip-flop provides a simple divide-by-2 circuit.

3. Counter-based division can generate integer frequency divisions.

4. If output toggles every N input cycles:

   Fout = Fin / (2N)

5. The counter determines when the output toggles.

6. Generated clocks must be handled carefully.

7. Clock enables are an important alternative to fabric-generated clocks.

8. Simple integer dividers cannot generate every arbitrary frequency.

9. Fractional clock division is required for non-integer division ratios.
```

## ⭐ Most Important Formula

$$
\boxed{F_{out}=\frac{F_{in}}{2N}}
$$

where:

```text
Fin = input clock frequency
N   = number of input clock cycles between output toggles
Fout = output clock frequency
```

### Example

```text
Fin  = 100 MHz
N    = 5

Fout = 100 / (2 × 5)
     = 10 MHz
```

$$
\boxed{100MHz\rightarrow10MHz}
$$

**Day 31 complete — Clock Dividers.**
