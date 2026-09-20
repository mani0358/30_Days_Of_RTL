# Day 45 — High Cohesion in RTL Design

## 1. Objective

Learn the RTL design principle of **High Cohesion**.

By the end of Day 45, you should understand:

* What cohesion means
* What high cohesion means
* Why high cohesion is important in RTL
* How to identify a poorly cohesive module
* How to split a large module into focused modules
* How high cohesion improves verification and reuse
* How to apply the principle to Verilog RTL
* How high cohesion relates to **low coupling**, which is the next major design principle

---

# 2. Roadmap Topic

The final section of the 50-day RTL roadmap focuses on writing RTL that is:

* maintainable
* reusable
* readable
* robust
* easy to verify
* easy to modify

Day 45 introduces:

> **High Cohesion**

The basic principle is:

```text
One module
      ↓
One closely related responsibility
```

---

# 3. What is Cohesion?

**Cohesion** describes how closely related the responsibilities of a module are.

In simple words:

> Cohesion tells us how well the contents of a module belong together.

For example, consider a module that only performs addition:

```text
adder
 |
 +-- addition
 +-- addition-related logic
 +-- addition-related outputs
```

This has a clear responsibility.

Now consider a single module containing:

```text
adder
UART
FIFO
PWM
counter
traffic light
CRC
```

These functions are unrelated.

That module has poor cohesion.

---

# 4. High Cohesion

A module has **high cohesion** when its internal logic is strongly related to one specific purpose.

Example:

```text
+----------------------+
|      FIFO Module     |
|                      |
| write logic          |
| read logic           |
| pointers             |
| full/empty           |
+----------------------+
```

All of these pieces belong to the FIFO's responsibility.

Therefore the module is highly cohesive.

---

# 5. Low Cohesion

A module with unrelated responsibilities has low cohesion.

For example:

```text
+--------------------------------+
|       EVERYTHING MODULE        |
|                                |
| UART                           |
| FIFO                           |
| PWM                            |
| CRC                            |
| ALU                            |
| Counter                        |
| Traffic light                  |
+--------------------------------+
```

This makes the RTL harder to:

* understand
* test
* debug
* reuse
* modify

---

# 6. Simple Real-World Analogy

Think about a toolbox.

A screwdriver box containing:

```text
screwdrivers
screwdriver bits
screwdriver accessories
```

has a clear purpose.

But imagine one box containing:

```text
screwdrivers
rice
books
keyboard
shoes
resistors
```

Everything is in one place, but the contents are unrelated.

The same idea applies to RTL modules.

---

# 7. High Cohesion in RTL

Suppose we are designing a communication system:

```text
+----------------+
| Communication  |
| System         |
+----------------+
       |
       +------ UART
       |
       +------ FIFO
       |
       +------ CRC
       |
       +------ Controller
```

Instead of putting everything inside one module:

```text
communication_system.v
```

we can create:

```text
uart.v
fifo.v
crc.v
controller.v
```

Each module has a focused responsibility.

The top-level module connects them.

---

# 8. Poorly Cohesive RTL Example

Consider:

```verilog
module bad_design (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] data,
    output reg  [7:0] result,
    output reg        pwm,
    output reg        crc_error
);

    reg [7:0] counter;
    reg [7:0] fifo_memory [0:15];
    reg [3:0] wr_ptr;

    always @(posedge clk) begin

        // Counter
        if (reset)
            counter <= 8'd0;
        else
            counter <= counter + 1'b1;

        // Arithmetic
        result <= data + 8'd10;

        // PWM
        if (counter < 8'd128)
            pwm <= 1'b1;
        else
            pwm <= 1'b0;

        // FIFO write
        if (data != 8'd0) begin
            fifo_memory[wr_ptr] <= data;
            wr_ptr <= wr_ptr + 1'b1;
        end

        // Some unrelated error logic
        crc_error <= ^data;

    end

endmodule
```

This module contains:

```text
counter
arithmetic
PWM
FIFO
CRC/parity-like logic
```

These functions are unrelated.

This is a poor architectural organization.

---

# 9. Why Is This a Problem?

Suppose you need to modify the FIFO.

You now have to work inside a module containing:

```text
counter
PWM
arithmetic
error logic
FIFO
```

The module becomes harder to understand.

Verification also becomes more complicated.

Instead of testing:

```text
FIFO
```

you potentially need to deal with the entire module.

---

# 10. High-Cohesion Version

Split the design into focused modules:

```text
project/
│
├── counter.v
├── pwm.v
├── fifo.v
├── arithmetic.v
├── crc.v
└── top.v
```

Now:

```text
counter.v
    ↓
counter responsibility

pwm.v
    ↓
PWM responsibility

fifo.v
    ↓
FIFO responsibility

crc.v
    ↓
CRC responsibility
```

Each module has a clear purpose.

---

# 11. Example: High-Cohesion Counter

Create:

```text
rtl/counter.v
```

```verilog
module counter #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,
    output reg [WIDTH-1:0] count
);

    always @(posedge clk) begin
        if (reset)
            count <= {WIDTH{1'b0}};
        else
            count <= count + 1'b1;
    end

endmodule
```

This module has one primary responsibility:

> Count clock cycles.

That is high cohesion.

---

# 12. Example: High-Cohesion PWM

Create:

```text
rtl/pwm.v
```

```verilog
module pwm #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,
    input  wire [WIDTH-1:0] duty,
    output reg              pwm_out
);

    reg [WIDTH-1:0] counter;

    always @(posedge clk) begin
        if (reset) begin
            counter <= {WIDTH{1'b0}};
            pwm_out <= 1'b0;
        end
        else begin

            counter <= counter + 1'b1;

            if (counter < duty)
                pwm_out <= 1'b1;
            else
                pwm_out <= 1'b0;

        end
    end

endmodule
```

Everything inside this module is related to PWM generation.

Therefore it has high cohesion.

---

# 13. Example: High-Cohesion FIFO

From Day 41, we already created a FIFO containing:

```text
memory
write pointer
read pointer
count
full
empty
read/write control
```

These are strongly related.

Therefore:

```text
FIFO module
```

is naturally a highly cohesive module.

---

# 14. Top-Level Integration

Now create:

```text
rtl/top.v
```

The top module connects the focused modules.

Conceptually:

```text
                 +-------------+
                 |   Counter   |
                 +-------------+
                        |
                        |
                        v
                  control logic


                 +-------------+
 data ---------->|     PWM     |----> pwm_out
                 +-------------+


 data ---------->+-------------+
                 |    FIFO     |----> fifo_data
                 +-------------+
```

The top-level module is responsible for **integration**, while individual modules are responsible for their own functions.

---

# 15. Top-Level Example

```verilog
module top (
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] duty,
    output wire       pwm_out,
    output wire [7:0] count
);

    counter #(
        .WIDTH(8)
    ) counter_inst (
        .clk   (clk),
        .reset (reset),
        .count (count)
    );

    pwm #(
        .WIDTH(8)
    ) pwm_inst (
        .clk     (clk),
        .reset   (reset),
        .duty    (duty),
        .pwm_out (pwm_out)
    );

endmodule
```

Notice that the top module doesn't implement the internal counter or PWM algorithm.

It connects modules.

---

# 16. High Cohesion Diagram

```text
                 TOP MODULE
                     |
          +----------+----------+
          |          |          |
          v          v          v
      +-------+  +-------+  +-------+
      |Counter|  |  PWM  |  | FIFO  |
      +-------+  +-------+  +-------+
          |          |          |
       count       pwm_out    data
```

Each block has a clear purpose.

---

# 17. Why High Cohesion Matters in RTL

## 1. Easier verification

You can test each module independently.

For example:

```text
tb_counter.v
tb_pwm.v
tb_fifo.v
```

Instead of one huge testbench.

---

## 2. Easier debugging

If the FIFO fails:

```text
FIFO
 ↓
fifo.v
```

You can focus on the FIFO module.

---

## 3. Reusability

A highly cohesive module can be reused elsewhere.

For example:

```text
fifo.v
```

can potentially be used in:

```text
UART
SPI
DMA
network interface
processor subsystem
```

without taking unrelated logic with it.

---

## 4. Easier modification

Suppose you want to change the PWM implementation.

You modify:

```text
pwm.v
```

instead of searching through a huge system module.

---

## 5. Easier synthesis/debugging

Clear module boundaries make RTL structure easier to inspect during:

* synthesis
* simulation
* timing analysis
* debugging
* code review

---

# 18. High Cohesion vs Low Cohesion

| High Cohesion        | Low Cohesion           |
| -------------------- | ---------------------- |
| Focused module       | Mixed responsibilities |
| Easier to understand | Harder to understand   |
| Easier verification  | Complex verification   |
| Better reuse         | Poor reuse             |
| Easier debugging     | Harder debugging       |
| Easier maintenance   | Harder maintenance     |
| Clear responsibility | Unclear responsibility |

---

# 19. Important: High Cohesion Does NOT Mean One Module Must Contain One Line of Logic

This is a common misunderstanding.

High cohesion does **not** mean:

```text
one module = one statement
```

Instead:

```text
one module = one closely related responsibility
```

A FIFO may contain hundreds of lines of RTL and still have high cohesion.

For example:

```text
FIFO
├── memory
├── write pointer
├── read pointer
├── full logic
├── empty logic
└── count
```

All of these belong to the FIFO.

---

# 20. Cohesion Boundary

A useful design question is:

> "Do these pieces of logic naturally belong together?"

If yes:

```text
keep them together
```

If no:

```text
consider separating them
```

Example:

```text
FIFO memory
FIFO pointer
FIFO full/empty
```

should stay together.

But:

```text
FIFO
+
UART transmitter
+
PWM generator
```

should normally be separate modules.

---

# 21. High Cohesion and Verification

Consider a FIFO.

A dedicated FIFO testbench can verify:

```text
write
read
full
empty
overflow protection
underflow protection
ordering
```

without needing to understand unrelated PWM or UART logic.

This is one of the biggest practical benefits of high cohesion.

---

# 22. High Cohesion and Reuse

Suppose we have:

```text
fifo.v
```

with a parameter:

```verilog
parameter DATA_WIDTH = 8;
parameter DEPTH = 16;
```

It can potentially be instantiated multiple times:

```text
UART FIFO
    |
    +---- fifo.v

SPI FIFO
    |
    +---- fifo.v

DMA FIFO
    |
    +---- fifo.v
```

The module's focused responsibility makes reuse easier.

---

# 23. High Cohesion and Parameters

Parameters can help maintain cohesion without duplicating modules.

For example:

```verilog
module counter #(
    parameter WIDTH = 8
)
```

The same counter can be used as:

```text
8-bit counter
16-bit counter
32-bit counter
```

without adding unrelated functionality.

---

# 24. Bad Design vs Better Design

### Bad

```text
system.v
│
├── UART
├── FIFO
├── PWM
├── CRC
├── Counter
├── ALU
└── Traffic Light
```

### Better

```text
system.v
│
├── uart.v
├── fifo.v
├── pwm.v
├── crc.v
├── counter.v
├── alu.v
└── traffic_light.v
```

The top-level module integrates the blocks.

---

# 25. Cohesion Is About Responsibility

When designing an RTL module, ask:

```text
What is this module responsible for?
```

A good answer should be concise.

Examples:

```text
FIFO:
"Stores and retrieves data in FIFO order."

PWM:
"Generates a pulse-width-modulated output."

UART TX:
"Serializes parallel data according to UART protocol."

CRC:
"Generates/checks CRC."

Counter:
"Maintains a count according to its control conditions."
```

These are clear responsibilities.

---

# 26. Practical Example

Suppose you are designing a sensor interface:

```text
Sensor
  |
  v
+-------------+
| Sensor Ctrl |
+-------------+
      |
      v
+-------------+
|    FIFO     |
+-------------+
      |
      v
+-------------+
|    CRC      |
+-------------+
      |
      v
+-------------+
| UART TX     |
+-------------+
```

Each module performs a focused task.

This is much easier to understand than:

```text
sensor_uart_crc_fifo_everything.v
```

---

# 27. Testbench Strategy

High cohesion naturally supports modular verification.

Directory:

```text
Day_45/
│
├── rtl/
│   ├── counter.v
│   ├── pwm.v
│   └── top.v
│
├── tb/
│   └── tb_top.v
│
└── sim/
```

You can also test each module independently:

```text
tb_counter.v
tb_pwm.v
```

---

# 28. Day 45 Demonstration

We will verify two focused modules:

```text
counter
PWM
```

using one top-level design.

The counter:

```text
0 → 1 → 2 → 3 → ...
```

The PWM:

```text
counter < duty
```

produces:

```text
PWM = 1
```

otherwise:

```text
PWM = 0
```

---

# 29. Testbench

Create:

```text
tb/tb_top.v
```

```verilog
`timescale 1ns/1ps

module tb_top;

    reg clk;
    reg reset;
    reg [7:0] duty;

    wire [7:0] count;
    wire pwm_out;

    top uut (
        .clk     (clk),
        .reset   (reset),
        .duty    (duty),
        .pwm_out (pwm_out),
        .count   (count)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("day45.vcd");
        $dumpvars(0, tb_top);

        clk   = 1'b0;
        reset = 1'b1;
        duty  = 8'd64;

        #20;

        reset = 1'b0;

        #300;

        duty = 8'd128;

        #300;

        $finish;

    end

    always @(posedge clk) begin
        $display(
            "TIME=%0t | RESET=%b | COUNT=%0d | DUTY=%0d | PWM=%b",
            $time,
            reset,
            count,
            duty,
            pwm_out
        );
    end

endmodule
```

---

# 30. Compile

From the Day 45 directory:

```bash
mkdir -p sim
```

Compile:

```bash
iverilog -o sim/day45_test \
    rtl/counter.v \
    rtl/pwm.v \
    rtl/top.v \
    tb/tb_top.v
```

Run:

```bash
vvp sim/day45_test
```

---

# 31. View Waveform

```bash
gtkwave day45.vcd
```

Add:

```text
clk
reset
count
duty
pwm_out
```

Observe that:

```text
counter
```

and:

```text
PWM
```

are independent focused blocks connected through the top-level design.

---

# 32. Truth/Functional Verification

This topic is architectural rather than a Boolean-gate problem, so there is no single truth table for "high cohesion."

However, we can verify the functional behavior of the example modules.

## Counter

| Reset | Clock edge | Next count |
| ----: | ---------- | ---------: |
|     1 | ↑          |          0 |
|     0 | ↑          |  count + 1 |

## PWM

For the simplified PWM comparison:

$$
PWM = (counter < duty)
$$

| `counter < duty` | PWM |
| ---------------: | --: |
|                0 |   0 |
|                1 |   1 |

This confirms the example's functional behavior.

---

# 33. Interview Question — What is Cohesion?

**Answer:**

Cohesion measures how strongly the responsibilities and functionality within a module are related.

High cohesion means a module contains closely related functionality focused on a clear responsibility.

---

# 34. Interview Question — What is High Cohesion?

**Answer:**

High cohesion means that a module performs a focused, closely related set of functions rather than combining unrelated functionality.

---

# 35. Interview Question — Why is High Cohesion Important?

**Answer:**

It improves:

* readability
* verification
* debugging
* reuse
* maintenance
* modularity

---

# 36. Interview Question — Give an RTL Example

A FIFO containing:

```text
memory
read pointer
write pointer
full logic
empty logic
```

has high cohesion because all of these functions implement FIFO behavior.

---

# 37. Interview Question — Does High Cohesion Mean One Module Can Only Have One Always Block?

No.

A module can have multiple:

```verilog
always
```

blocks and still have high cohesion.

For example, an FSM may have:

```text
state register
next-state logic
output logic
```

while still being one cohesive FSM module.

---

# 38. Interview Question — Is High Cohesion the Same as Low Coupling?

No.

They are related but different concepts.

### Cohesion

Looks **inside a module**.

```text
How related are the responsibilities inside this module?
```

### Coupling

Looks at **relationships between modules**.

```text
How dependent are modules on each other?
```

Day 45:

```text
HIGH COHESION
```

Later:

```text
LOW COUPLING
```

Together they produce cleaner RTL architecture.

---

# 39. Placement Scenario

Suppose an interviewer gives you:

```text
module system;
```

containing:

```text
UART
SPI
FIFO
PWM
CRC
Counter
```

and asks:

> What architectural problem do you see?

A strong answer is:

> The module has multiple unrelated responsibilities, resulting in poor cohesion. I would separate the functionality into focused modules and use a top-level integration module to connect them.

---

# 40. Placement Question

### Which design has higher cohesion?

### Design A

```text
fifo.v
├── write pointer
├── read pointer
├── memory
├── full
└── empty
```

### Design B

```text
system.v
├── FIFO
├── UART
├── PWM
├── CRC
└── ALU
```

Answer:

**Design A**, because its internal functionality is strongly related to one responsibility: FIFO operation.

---

# 41. Assignment

Create a small RTL system with at least **three highly cohesive modules**:

```text
counter.v
pwm.v
fifo.v
```

Then create:

```text
top.v
```

that integrates them.

Requirements:

### Counter

8-bit counter.

### PWM

8-bit duty-cycle input.

### FIFO

8-bit data.

### Top

Connect the modules without moving their internal functionality into the top module.

---

# 42. Advanced Assignment

Create:

```text
sensor_system/
│
├── sensor_controller.v
├── fifo.v
├── crc.v
├── uart_tx.v
└── top.v
```

Give each module exactly one clear responsibility.

Write one sentence describing the responsibility of every module.

Example:

```text
fifo.v:
Stores incoming sensor samples in FIFO order.
```

---

# 43. Day 45 Checklist

Before moving to Day 46, make sure you can answer:

```text
[ ] What is cohesion?
[ ] What is high cohesion?
[ ] What is low cohesion?
[ ] Why is high cohesion useful?
[ ] How do you recognize poor cohesion?
[ ] How do you split a large RTL module?
[ ] Why does high cohesion help verification?
[ ] Why does high cohesion improve reuse?
[ ] Difference between cohesion and coupling?
[ ] Can a cohesive module contain multiple always blocks?
```

---

# 44. Git Structure

```text
RTL_50_Days/
│
├── Day_44/
│
├── Day_45/
│   ├── README.md
│   │
│   ├── rtl/
│   │   ├── counter.v
│   │   ├── pwm.v
│   │   └── top.v
│   │
│   ├── tb/
│   │   └── tb_top.v
│   │
│   └── sim/
│
└── ...
```

Commit:

```bash
git add Day_45/
git commit -m "Day 45: High cohesion in RTL design"
git push
```

---

# 45. Key Takeaways

Remember these five points:

### 1. Cohesion

How closely related the functionality inside a module is.

### 2. High cohesion

A module has a focused responsibility.

### 3. Avoid unrelated functionality

Don't combine:

```text
UART + FIFO + PWM + CRC + ALU
```

just because they are part of the same system.

### 4. Use top-level integration

```text
        TOP
     /   |   \
    /    |    \
 FIFO   PWM  UART
```

### 5. High cohesion improves RTL quality

It makes designs:

```text
easier to understand
easier to verify
easier to debug
easier to reuse
easier to maintain
```

---

# 46. Final Mental Model

```text
             SYSTEM
                |
       +--------+--------+
       |        |        |
       v        v        v
     FIFO      PWM      UART
       |        |        |
   FIFO logic  PWM     UART
              logic    logic
```

The most important rule for Day 45 is:

> **Keep closely related RTL functionality together, and separate unrelated responsibilities into separate modules.**

This is **High Cohesion**.
