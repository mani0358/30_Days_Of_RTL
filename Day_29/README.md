# Day 29 — Concurrency in Verilog RTL

## 📌 Topic

**Concurrency in Verilog**

## 🎯 Roadmap Objective

Understand how Verilog's inherently parallel nature can be leveraged for efficient hardware design.

---

# 1. Learning Objectives

By the end of Day 29, you should understand:

* What concurrency means in Verilog.
* Why Verilog describes hardware differently from software.
* Concurrent statements vs procedural statements.
* How multiple `assign` statements operate simultaneously.
* How multiple `always` blocks operate concurrently.
* How independent hardware blocks work in parallel.
* The difference between sequential software execution and parallel hardware execution.
* How concurrency affects RTL design.
* How to design a PWM generator using concurrent hardware behavior.
* How to simulate and verify a PWM signal.
* How duty cycle and frequency are controlled.

---

# 2. What is Concurrency?

**Concurrency** means that multiple hardware operations can exist and operate at the same time.

This is one of the most important differences between Verilog and conventional software programming.

For example:

```verilog
assign y1 = a & b;
assign y2 = c | d;
assign y3 = e ^ f;
```

These three statements represent three pieces of hardware.

Conceptually:

```text
             ┌──────────┐
A ──────────►│   AND    │───► Y1
B ──────────►│          │
             └──────────┘

             ┌──────────┐
C ──────────►│    OR    │───► Y2
D ──────────►│          │
             └──────────┘

             ┌──────────┐
E ──────────►│   XOR    │───► Y3
F ──────────►│          │
             └──────────┘
```

All three hardware functions can operate concurrently.

---

# 3. Software vs Hardware

## Software

A processor generally executes instructions according to a sequence:

```text
Instruction 1
     ↓
Instruction 2
     ↓
Instruction 3
```

## Hardware

Hardware can perform independent operations simultaneously:

```text
             ┌── Operation A ──┐
Input ───────┼── Operation B ──┼── Output
             └── Operation C ──┘
```

This is why Verilog is called a **Hardware Description Language (HDL)**.

We are describing hardware behavior and structure rather than writing a normal sequential software program.

---

# 4. Concurrent Statements

Statements outside procedural blocks such as:

```verilog
assign
```

are concurrent.

Example:

```verilog
assign y1 = a & b;
assign y2 = c & d;
assign y3 = e | f;
```

They represent independent combinational logic.

---

# 5. Multiple `always` Blocks

Multiple `always` blocks are also conceptually concurrent.

Example:

```verilog
always @(posedge clk)
    counter <= counter + 1;

always @(posedge clk)
    register_a <= data_a;

always @(posedge clk)
    register_b <= data_b;
```

At a clock edge, all three pieces of sequential hardware respond to the same clock.

Conceptually:

```text
                 CLOCK
                   │
        ┌──────────┼──────────┐
        │          │          │
        ▼          ▼          ▼
     Counter    Register A  Register B
```

---

# 6. Important Point About `always`

Consider:

```verilog
always @(posedge clk) begin
    a <= b;
    c <= d;
end
```

The statements inside one procedural block execute according to Verilog's procedural semantics.

But:

```verilog
always @(posedge clk)
    a <= b;

always @(posedge clk)
    c <= d;
```

represent separate concurrent processes.

This distinction is important when designing RTL.

---

# 7. Example of Concurrency

Consider:

```verilog
module concurrent_example (
    input  wire clk,
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    output wire y1,
    output wire y2,
    output reg  q1,
    output reg  q2
);

    assign y1 = a & b;
    assign y2 = c | d;

    always @(posedge clk)
        q1 <= y1;

    always @(posedge clk)
        q2 <= y2;

endmodule
```

There are four different hardware behaviors:

```text
1. AND logic
2. OR logic
3. q1 register
4. q2 register
```

They operate as independent hardware structures.

---

# 8. Concurrency and Clocked Logic

Suppose:

```verilog
always @(posedge clk)
    q1 <= d1;

always @(posedge clk)
    q2 <= d2;

always @(posedge clk)
    q3 <= d3;
```

At the same clock edge:

```text
        ┌───────────┐
CLK ───►│           │
        ├───────────┤
        │           │
        ├───────────┤
        │           │
        └───────────┘
             │
       ┌─────┼─────┐
       ▼     ▼     ▼
      Q1    Q2    Q3
```

All three registers can capture their inputs on the same clock edge.

---

# 9. Concurrency Does NOT Mean Every Line Executes Physically at Exactly the Same Time

This is an important distinction.

Verilog simulation has a defined event scheduling model.

At the hardware level, synthesis converts the RTL into actual hardware.

Therefore:

```text
RTL
 ↓
Synthesis
 ↓
Hardware
```

The important idea is that independent hardware structures can operate simultaneously.

---

# 10. Day 29 Assignment — PWM Generator

The roadmap assignment is:

> Design a PWM (Pulse Width Modulation) signal generator with adjustable duty cycle and frequency.

PWM is a good example of concurrent digital hardware.

---

# 11. What is PWM?

PWM stands for:

**Pulse Width Modulation**

A PWM signal repeatedly switches between:

```text
HIGH
LOW
HIGH
LOW
...
```

The percentage of time that the signal remains HIGH is called the:

**Duty Cycle**

---

# 12. PWM Waveform

For 50% duty cycle:

```text
       ┌───────┐       ┌───────┐
       │       │       │       │
───────┘       └───────┘       └──────
       <------ Period ------->
```

For 25% duty cycle:

```text
       ┌───┐           ┌───┐
       │   │           │   │
───────┘   └───────────┘   └────────
```

For 75% duty cycle:

```text
       ┌─────────────┐       ┌─────────────┐
       │             │       │             │
───────┘             └───────┘
```

---

# 13. Duty Cycle Formula

The duty cycle is:

$$
Duty\ Cycle =
\frac{T_{HIGH}}{T_{PERIOD}}\times100
$$

For example:

```text
Period = 100 units
HIGH   = 50 units
```

Then:

$$
Duty=\frac{50}{100}\times100
$$

$$
\boxed{Duty=50\%}
$$

---

# 14. PWM Using a Counter

A simple digital PWM generator can use:

```text
Counter
   │
   ▼
Compare with duty cycle
   │
   ▼
PWM output
```

Architecture:

```text
              ┌─────────────┐
CLOCK ────────►   COUNTER   │
              └──────┬──────┘
                     │
                     ▼
               ┌───────────┐
Duty Cycle ───►│ Comparator│
               └─────┬─────┘
                     │
                     ▼
                   PWM
```

---

# 15. PWM Logic

Suppose the counter ranges from:

```text
0 → 99
```

for one PWM period.

For 50% duty cycle:

```text
counter < 50
```

produces:

```text
PWM = 1
```

while:

```text
counter >= 50
```

produces:

```text
PWM = 0
```

Therefore:

```verilog
assign pwm = (counter < duty_cycle);
```

This is a concurrent continuous assignment.

It is an excellent example of today's concurrency topic.

---

# 16. PWM RTL

Create:

```text
pwm_generator.v
```

```verilog
module pwm_generator #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,
    input  wire [WIDTH-1:0] duty_cycle,
    output wire             pwm
);

    reg [WIDTH-1:0] counter;

    always @(posedge clk) begin
        if (reset)
            counter <= {WIDTH{1'b0}};
        else
            counter <= counter + 1'b1;
    end

    assign pwm = (counter < duty_cycle);

endmodule
```

---

# 17. How This Design Works

For:

```text
WIDTH = 8
```

the counter ranges:

```text
0 → 255
```

Therefore the PWM period is:

```text
256 clock cycles
```

approximately.

If:

```text
duty_cycle = 128
```

then:

```text
counter = 0 ... 127
```

produces:

```text
PWM = 1
```

and:

```text
counter = 128 ... 255
```

produces:

```text
PWM = 0
```

This gives approximately:

```text
50% duty cycle
```

---

# 18. Duty Cycle Examples

For an 8-bit counter:

### 25%

```text
duty_cycle = 64
```

because:

$$
\frac{64}{256}\times100=25\%
$$

### 50%

```text
duty_cycle = 128
```

because:

$$
\frac{128}{256}\times100=50\%
$$

### 75%

```text
duty_cycle = 192
```

because:

$$
\frac{192}{256}\times100=75\%
$$

---

# 19. Important Limitation of This Simple PWM

The above implementation provides an adjustable duty cycle.

The PWM frequency is determined by the clock frequency and counter width.

For an N-bit counter:

$$
F_{PWM}=\frac{F_{CLK}}{2^N}
$$

For example, if:

```text
FCLK = 100 MHz
WIDTH = 8
```

then:

$$
F_{PWM}=
\frac{100\,MHz}{256}
$$

$$
F_{PWM}\approx390.625\,kHz
$$

So this basic implementation does **not independently control arbitrary PWM frequency and duty cycle**.

To independently control both, we need additional frequency/period control logic.

---

# 20. Adjustable Frequency and Duty Cycle

A more flexible PWM design uses a programmable period:

```text
Counter
   │
   ├──── counter < high_time ──► PWM
   │
   └──── counter == period ────► reset counter
```

Architecture:

```text
                 ┌─────────────┐
                 │   Counter   │
                 └──────┬──────┘
                        │
             ┌──────────┴──────────┐
             ▼                     ▼
       Compare HIGH          Compare PERIOD
             │                     │
             └──────────┬──────────┘
                        ▼
                       PWM
```

We can define:

```text
period_count
high_count
```

where:

```text
high_count < period_count
```

controls the duty cycle.

---

# 21. Programmable PWM RTL

Create:

```text
pwm_variable.v
```

```verilog
module pwm_variable #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,
    input  wire [WIDTH-1:0] period_count,
    input  wire [WIDTH-1:0] high_count,
    output wire             pwm
);

    reg [WIDTH-1:0] counter;

    always @(posedge clk) begin

        if (reset) begin
            counter <= {WIDTH{1'b0}};
        end

        else if (counter >= period_count - 1'b1) begin
            counter <= {WIDTH{1'b0}};
        end

        else begin
            counter <= counter + 1'b1;
        end

    end

    assign pwm = (counter < high_count);

endmodule
```

---

# 22. Frequency Formula

For this implementation:

$$
F_{PWM}=\frac{F_{CLK}}{Period}
$$

Example:

```text
Clock = 100 MHz
Period = 100
```

Then:

$$
F_{PWM}=
\frac{100MHz}{100}
$$

$$
\boxed{F_{PWM}=1MHz}
$$

---

# 23. Duty Cycle Formula

If:

```text
period = 100
high_count = 25
```

then:

$$
Duty=\frac{25}{100}\times100
$$

$$
\boxed{Duty=25\%}
$$

Therefore:

```text
period_count
```

controls frequency while:

```text
high_count
```

controls duty cycle.

---

# 24. Testbench

Create:

```text
tb_pwm_variable.v
```

```verilog
`timescale 1ns/1ps

module tb_pwm_variable;

    reg clk;
    reg reset;

    reg [7:0] period_count;
    reg [7:0] high_count;

    wire pwm;

    pwm_variable #(
        .WIDTH(8)
    ) dut (
        .clk(clk),
        .reset(reset),
        .period_count(period_count),
        .high_count(high_count),
        .pwm(pwm)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("pwm.vcd");
        $dumpvars(0, tb_pwm_variable);

        clk = 1'b0;
        reset = 1'b1;

        period_count = 8'd20;
        high_count   = 8'd10;

        #20;

        reset = 1'b0;

        // 50% duty cycle
        #300;

        // Change to 25%
        high_count = 8'd5;

        #300;

        // Change to 75%
        high_count = 8'd15;

        #300;

        $finish;
    end

    initial begin
        $monitor(
            "TIME=%0t COUNTER=%0d PERIOD=%0d HIGH=%0d PWM=%b",
            $time,
            dut.counter,
            period_count,
            high_count,
            pwm
        );
    end

endmodule
```

---

# 25. Ubuntu Setup

Create the Day 29 directory:

```bash
mkdir -p ~/RTL_50_Days/Day_29_Concurrency
cd ~/RTL_50_Days/Day_29_Concurrency
```

Create:

```bash
nano pwm_variable.v
```

Then:

```bash
nano tb_pwm_variable.v
```

---

# 26. Compile

```bash
iverilog -o pwm_sim pwm_variable.v tb_pwm_variable.v
```

Run:

```bash
vvp pwm_sim
```

---

# 27. GTKWave

The testbench generates:

```text
pwm.vcd
```

Open:

```bash
gtkwave pwm.vcd
```

Add:

```text
clk
reset
period_count
high_count
pwm
```

Also add:

```text
dut.counter
```

You should observe:

```text
counter → repeatedly counts
pwm     → changes according to high_count
```

---

# 28. Concurrency in Our PWM Design

Notice that these are separate hardware behaviors:

```verilog
always @(posedge clk)
    counter <= ...;
```

and:

```verilog
assign pwm = (counter < high_count);
```

The counter is sequential hardware.

The comparison is combinational hardware.

Conceptually:

```text
              CLOCK
                │
                ▼
          ┌───────────┐
          │  COUNTER  │
          └─────┬─────┘
                │
                ▼
          ┌───────────┐
HIGH ────►│ COMPARE   │
          └─────┬─────┘
                │
                ▼
               PWM
```

The two descriptions together describe interconnected hardware that operates concurrently.

---

# 29. Truth/Behavior Verification

For a simple comparator:

```text
counter < high_count
```

the behavior is:

| counter | high_count | PWM |
| ------: | ---------: | --: |
|       0 |         10 |   1 |
|       1 |         10 |   1 |
|       2 |         10 |   1 |
|       3 |         10 |   1 |
|       4 |         10 |   1 |
|       5 |         10 |   1 |
|       6 |         10 |   1 |
|       7 |         10 |   1 |
|       8 |         10 |   1 |
|       9 |         10 |   1 |
|      10 |         10 |   0 |
|      11 |         10 |   0 |
|     ... |         10 |   0 |

Therefore:

```text
counter = 0 to 9
PWM = 1

counter = 10 onward
PWM = 0
```

For:

```text
period = 20
high_count = 10
```

we get:

```text
10 cycles HIGH
10 cycles LOW
```

giving:

$$
Duty=50\%
$$

---

# 30. Placement Interview Questions

## Q1. What is concurrency in Verilog?

Concurrency means that independent Verilog statements and hardware structures can represent operations occurring in parallel.

---

## Q2. Are Verilog statements always executed sequentially?

No.

Concurrent Verilog constructs describe hardware that can operate simultaneously.

Statements inside a procedural block have procedural execution semantics, but the resulting hardware may operate in parallel with hardware described elsewhere.

---

## Q3. Give an example of concurrent statements.

```verilog
assign y1 = a & b;
assign y2 = c | d;
assign y3 = e ^ f;
```

These describe independent combinational logic.

---

## Q4. Can multiple `always` blocks operate concurrently?

Yes.

For example:

```verilog
always @(posedge clk)
    q1 <= d1;

always @(posedge clk)
    q2 <= d2;
```

Both respond to the same clock edge.

---

## Q5. What is PWM?

PWM is Pulse Width Modulation, where the width of the HIGH portion of a periodic signal is varied to control its average behavior.

---

## Q6. What is duty cycle?

$$
Duty\ Cycle=
\frac{T_{HIGH}}{T_{PERIOD}}\times100
$$

---

## Q7. How can a counter generate PWM?

Compare a counter against a programmable threshold:

```verilog
assign pwm = (counter < high_count);
```

---

## Q8. What controls PWM frequency?

In the programmable-period implementation, the period count controls PWM frequency:

$$
F_{PWM}=\frac{F_{CLK}}{Period}
$$

---

## Q9. What controls PWM duty cycle?

The HIGH count:

$$
Duty=\frac{High\ Count}{Period}\times100
$$

---

## Q10. Why is PWM a good example of concurrency?

Because the counter is sequential logic while the comparison generating PWM is combinational logic, and they form simultaneously operating hardware.

---

# 31. Common Mistakes

### Mistake 1 — Using blocking assignment for a clocked register

Incorrect style:

```verilog
always @(posedge clk)
    counter = counter + 1;
```

For normal sequential RTL, use:

```verilog
always @(posedge clk)
    counter <= counter + 1;
```

---

### Mistake 2 — Forgetting reset

Without proper reset, the counter can begin in an unknown state in simulation.

---

### Mistake 3 — `high_count > period_count`

For the intended PWM interpretation:

```text
high_count <= period_count
```

should be enforced or documented.

---

### Mistake 4 — Confusing frequency with duty cycle

Remember:

```text
Period → Frequency
HIGH time → Duty cycle
```

---

# 32. Practice Problems

### Problem 1

For:

```text
period = 100
high_count = 20
```

calculate the duty cycle.

**Answer:**

$$
20\%
$$

---

### Problem 2

For:

```text
FCLK = 50 MHz
period = 100
```

calculate PWM frequency.

**Answer:**

$$
F_{PWM}=\frac{50MHz}{100}=500kHz
$$

---

### Problem 3

For:

```text
period = 200
high_count = 150
```

calculate duty cycle.

**Answer:**

$$
75\%
$$

---

### Problem 4

If two independent `always @(posedge clk)` blocks update two different registers, can both registers update on the same clock edge?

**Answer:**

Yes.

---

# 33. Day 29 Assignment

Implement a **programmable PWM generator** with:

```text
Input:
    clk
    reset
    period_count
    high_count

Output:
    pwm
```

Requirements:

```text
PWM frequency controlled by period_count
PWM duty cycle controlled by high_count
```

Verify at least:

```text
50% duty cycle
25% duty cycle
75% duty cycle
```

using GTKWave.

Also explain how the design demonstrates **concurrency in Verilog**.

---

# 34. Git Repository Structure

Your repository should now look like:

```text
50-Days-of-RTL/
│
├── Day_01_Naming_Convention/
├── Day_02_Text_Based_Design_Flow/
├── Day_03_Graphic_Based_Design_Flow/
├── ...
├── Day_27_Arbiters/
│
└── Day_29_Concurrency/
    ├── README.md
    ├── pwm_generator.v
    ├── pwm_variable.v
    └── tb_pwm_variable.v
```

---

# 35. Git Commit

After completing the lab:

```bash
git add Day_29_Concurrency/
git commit -m "Day 29: Learn Verilog concurrency and implement PWM"
git push
```

---

# 36. Day 29 Key Takeaways

Remember:

```text
1. Verilog describes hardware, not ordinary sequential software.

2. Independent hardware structures can operate concurrently.

3. Continuous assignments are concurrent.

4. Multiple always blocks represent concurrent hardware processes.

5. PWM can be implemented using a counter and comparator.

6. Period controls PWM frequency.

7. HIGH time controls duty cycle.

8. Nonblocking assignment is used for sequential registers.
```

### Most important concept

```text
        Sequential Logic
              │
              ▼
          COUNTER
              │
              ▼
        Combinational
          Comparison
              │
              ▼
             PWM
```

This is **Day 29 — Concurrency**.
