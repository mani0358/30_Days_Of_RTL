# Day 47 — Avoid Magic Numbers in RTL Design

## 1. Objective

Learn how to avoid **magic numbers** in Verilog RTL.

By the end of Day 47, you should understand:

* What a magic number is
* Why magic numbers are dangerous
* How to replace them with parameters
* How to use `localparam`
* How named constants improve RTL readability
* How magic numbers affect maintainability
* How to write configurable RTL
* How this connects with high cohesion and low coupling

---

# 2. Roadmap Topic

The final section of the 50-day RTL roadmap focuses on improving RTL quality.

The sequence is:

```text
Day 45 → High Cohesion
Day 46 → Low Coupling
Day 47 → Avoid Magic Numbers
Day 48 → Robustness
Day 49 → Readability
Day 50 → DRY
```

Day 47 focuses on:

> **Avoid Magic Numbers**

---

# 3. What is a Magic Number?

A **magic number** is a hard-coded numeric value whose meaning is not obvious from the code.

Example:

```verilog
if (count == 255)
```

What does `255` mean?

Possibilities:

```text
maximum count?
FIFO depth?
timeout?
PWM period?
address limit?
```

The code does not tell us.

That is a magic number.

---

# 4. Simple Example

Bad:

```verilog
if (counter == 999)
    counter <= 0;
```

A reader has to figure out why:

```text
999
```

is used.

Better:

```verilog
parameter PERIOD = 1000;

if (counter == PERIOD-1)
    counter <= 0;
```

Now the intent is obvious.

---

# 5. Why Magic Numbers Are a Problem

Magic numbers can cause:

* poor readability
* difficult maintenance
* accidental inconsistencies
* difficult parameterization
* increased chance of errors
* difficult debugging
* repeated modifications

Suppose:

```verilog
if (count == 999)
```

appears in 10 different places.

If the required period changes from:

```text
1000
```

to:

```text
2000
```

you may need to search and modify many locations.

---

# 6. Better Approach

Define a meaningful constant:

```verilog
localparam PERIOD = 1000;
```

Then use:

```verilog
if (count == PERIOD-1)
```

Now the code communicates the design intent.

---

# 7. Parameter vs localparam

Two important tools are:

```verilog
parameter
```

and:

```verilog
localparam
```

---

## `parameter`

A parameter can normally be overridden when the module is instantiated.

Example:

```verilog
module counter #(
    parameter WIDTH = 8
);
```

Another module can instantiate:

```verilog
counter #(
    .WIDTH(16)
) counter_inst (...);
```

Therefore:

```text
parameter
=
configurable constant
```

---

## `localparam`

A `localparam` is intended to be an internal constant.

Example:

```verilog
localparam IDLE  = 2'b00;
localparam RUN   = 2'b01;
localparam DONE  = 2'b10;
```

The values define internal states.

The outside module should not normally override them.

Therefore:

```text
parameter
→ external configuration

localparam
→ internal design constant
```

---

# 8. Bad Counter Example

Create:

```text
rtl/bad_counter.v
```

```verilog
module bad_counter (
    input  wire       clk,
    input  wire       reset,
    output reg [7:0]  count
);

    always @(posedge clk) begin

        if (reset)
            count <= 8'd0;

        else if (count == 8'd99)
            count <= 8'd0;

        else
            count <= count + 8'd1;

    end

endmodule
```

Here:

```text
99
```

is a magic number.

Why 99?

The code does not explain it.

---

# 9. Better Counter

```verilog
module counter #(
    parameter WIDTH = 8,
    parameter MAX_COUNT = 100
)(
    input  wire             clk,
    input  wire             reset,
    output reg [WIDTH-1:0] count
);

    always @(posedge clk) begin

        if (reset)
            count <= {WIDTH{1'b0}};

        else if (count == MAX_COUNT-1)
            count <= {WIDTH{1'b0}};

        else
            count <= count + 1'b1;

    end

endmodule
```

Now:

```text
MAX_COUNT
```

clearly describes the purpose.

---

# 10. Why `MAX_COUNT-1`?

If:

```text
MAX_COUNT = 100
```

the counter values are:

```text
0
1
2
...
98
99
```

At:

```text
count = 99
```

we reset to:

```text
0
```

Therefore:

$$
MAX\_COUNT-1=99
$$

This gives exactly 100 count states:

```text
0 → 99
```

---

# 11. Another Example — FIFO

Bad:

```verilog
reg [7:0] memory [0:15];
```

The reader must figure out:

```text
Why 16?
```

Better:

```verilog
parameter DEPTH = 16;
parameter DATA_WIDTH = 8;

reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
```

Now the design tells us:

```text
DATA_WIDTH = 8
DEPTH = 16
```

This is much clearer.

---

# 12. FIFO Example

```verilog
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input wire                   clk,
    input wire                   reset,
    input wire                   wr_en,
    input wire [DATA_WIDTH-1:0]  wr_data,
    input wire                   rd_en,
    output reg [DATA_WIDTH-1:0]  rd_data
);

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    // FIFO implementation

endmodule
```

Compare:

```verilog
reg [7:0] memory [0:15];
```

with:

```verilog
reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
```

The second version communicates intent and is reusable.

---

# 13. State Machine Example

Magic numbers are especially undesirable in FSMs.

Bad:

```verilog
case (state)

    2'b00:
        ...

    2'b01:
        ...

    2'b10:
        ...

endcase
```

What do these values mean?

A reader must remember:

```text
00 = IDLE
01 = RUN
10 = DONE
```

---

# 14. Better FSM

Use `localparam`.

```verilog
localparam IDLE = 2'b00;
localparam RUN  = 2'b01;
localparam DONE = 2'b10;
```

Then:

```verilog
case (state)

    IDLE:
        ...

    RUN:
        ...

    DONE:
        ...

endcase
```

Now the RTL is self-explanatory.

---

# 15. Day 36 Connection

Our Day 36 sequence detector used:

```verilog
localparam S0 = 2'b00;
localparam S1 = 2'b01;
localparam S2 = 2'b10;
```

This is a good example of avoiding magic numbers.

Instead of:

```verilog
case (state)

    2'b00:
        ...

    2'b01:
        ...

    2'b10:
        ...

endcase
```

we use:

```verilog
case (state)

    S0:
        ...

    S1:
        ...

    S2:
        ...

endcase
```

---

# 16. Why Named States Are Better

Compare:

```verilog
if (state == 2'b01)
```

with:

```verilog
if (state == RUN)
```

The second immediately communicates the meaning.

This improves:

```text
readability
debugging
maintenance
code review
```

---

# 17. Clock Divider Example

Bad:

```verilog
if (count == 24)
```

Why 24?

Not obvious.

Better:

```verilog
parameter DIVIDE = 25;

if (count == DIVIDE-1)
```

Now:

```text
DIVIDE = 25
```

communicates the intended division parameter.

---

# 18. Day 31 Connection

Our clock divider used:

```verilog
parameter DIVIDE = 5;
```

and:

```verilog
if (count == DIVIDE-1)
```

This is preferable to:

```verilog
if (count == 4)
```

because the design intent is clear.

---

# 19. PWM Example

Bad:

```verilog
if (counter < 128)
    pwm_out <= 1'b1;
else
    pwm_out <= 1'b0;
```

What does:

```text
128
```

mean?

It might represent:

```text
50% duty cycle
```

but that isn't obvious.

Better:

```verilog
parameter PWM_PERIOD = 256;
parameter DUTY_CYCLE = 128;
```

Then:

```verilog
if (counter < DUTY_CYCLE)
    pwm_out <= 1'b1;
else
    pwm_out <= 1'b0;
```

---

# 20. Example: Timing Constant

Bad:

```verilog
if (counter == 999999)
```

Better:

```verilog
localparam TIMEOUT_CYCLES = 1_000_000;

if (counter == TIMEOUT_CYCLES-1)
```

Now anyone reading the code knows:

```text
This is a timeout measured in clock cycles.
```

---

# 21. Numeric Separators

Verilog allows underscores in numeric constants to improve readability.

Instead of:

```verilog
1000000
```

you can write:

```verilog
1_000_000
```

Similarly:

```verilog
32'b11111111111111111111111111111111
```

can be written as:

```verilog
32'hFFFF_FFFF
```

The underscores do not change the value.

---

# 22. Good Numeric Formatting

Prefer:

```verilog
8'hFF
```

over:

```verilog
8'b11111111
```

when hexadecimal representation communicates the value better.

Prefer:

```verilog
32'd1000
```

when the value is naturally decimal.

Prefer:

```verilog
4'b1010
```

when the bit pattern itself matters.

---

# 23. Magic Numbers in Widths

Consider:

```verilog
reg [31:0] data;
```

This is not automatically a bad magic number.

The width may be part of the intended interface.

But if the design is supposed to be configurable, use:

```verilog
parameter DATA_WIDTH = 32;

reg [DATA_WIDTH-1:0] data;
```

The important question is:

> Does this numeric value represent a configurable design property?

If yes, consider making it a parameter.

---

# 24. When a Number Is NOT a Problem

Not every number is a magic number.

For example:

```verilog
if (reset)
    count <= 0;
```

The:

```text
0
```

has an obvious meaning.

Likewise:

```verilog
data[3:0]
```

may simply describe a fixed interface requirement.

The goal is not:

> Remove every number.

The goal is:

> Give important design constants meaningful names.

---

# 25. Magic Number Decision Rule

When you see:

```verilog
if (count == 999)
```

ask:

> What does 999 represent?

If it represents:

```text
timeout
period
depth
width
state
address limit
protocol value
```

give it a meaningful name.

---

# 26. Example — Protocol Value

Bad:

```verilog
if (opcode == 8'hA5)
```

Better:

```verilog
localparam OPCODE_WRITE = 8'hA5;

if (opcode == OPCODE_WRITE)
```

Now the meaning is clear.

---

# 27. Example — Error Code

Bad:

```verilog
if (error_code == 3)
```

Better:

```verilog
localparam ERROR_NONE    = 3'd0;
localparam ERROR_TIMEOUT = 3'd1;
localparam ERROR_CRC     = 3'd2;
localparam ERROR_OVERFLOW = 3'd3;

if (error_code == ERROR_OVERFLOW)
```

The RTL becomes much easier to understand.

---

# 28. Example — FSM

```verilog
localparam STATE_WIDTH = 2;

localparam IDLE  = 2'b00;
localparam LOAD  = 2'b01;
localparam RUN   = 2'b10;
localparam DONE  = 2'b11;
```

Then:

```verilog
case (state)

    IDLE:
        ...

    LOAD:
        ...

    RUN:
        ...

    DONE:
        ...

    default:
        ...

endcase
```

This is much better than unexplained binary values.

---

# 29. Complete RTL Example

Create:

```text
rtl/parameterized_counter.v
```

```verilog
module parameterized_counter #(
    parameter WIDTH     = 8,
    parameter MAX_COUNT = 100
)(
    input  wire             clk,
    input  wire             reset,
    input  wire             enable,
    output reg [WIDTH-1:0]  count
);

    always @(posedge clk) begin

        if (reset) begin
            count <= {WIDTH{1'b0}};
        end

        else if (enable) begin

            if (count == MAX_COUNT-1)
                count <= {WIDTH{1'b0}};

            else
                count <= count + 1'b1;

        end

    end

endmodule
```

---

# 30. What Have We Improved?

Instead of:

```verilog
8-bit
100
```

we use:

```text
WIDTH
MAX_COUNT
```

The module can now be configured.

Example:

```verilog
parameterized_counter #(
    .WIDTH(8),
    .MAX_COUNT(100)
)
```

or:

```verilog
parameterized_counter #(
    .WIDTH(16),
    .MAX_COUNT(1000)
)
```

Same RTL.

Different configuration.

---

# 31. Testbench

Create:

```text
tb/tb_parameterized_counter.v
```

```verilog
`timescale 1ns/1ps

module tb_parameterized_counter;

    reg clk;
    reg reset;
    reg enable;

    wire [7:0] count;

    parameterized_counter #(
        .WIDTH(8),
        .MAX_COUNT(10)
    ) uut (
        .clk   (clk),
        .reset (reset),
        .enable (enable),
        .count (count)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("day47.vcd");
        $dumpvars(0, tb_parameterized_counter);

        clk    = 1'b0;
        reset  = 1'b1;
        enable = 1'b0;

        #12;

        reset  = 1'b0;
        enable = 1'b1;

        #120;

        enable = 1'b0;

        #30;

        $finish;

    end

    always @(posedge clk) begin

        $display(
            "TIME=%0t | RESET=%b | ENABLE=%b | COUNT=%0d",
            $time,
            reset,
            enable,
            count
        );

    end

endmodule
```

---

# 32. Expected Counter Behavior

We configured:

```verilog
.MAX_COUNT(10)
```

Therefore:

```text
0
1
2
3
4
5
6
7
8
9
0
1
...
```

The important point is that the RTL does not contain:

```verilog
if (count == 9)
```

Instead:

```verilog
if (count == MAX_COUNT-1)
```

---

# 33. Compile

From the Day 47 directory:

```bash
mkdir -p sim
```

Compile:

```bash
iverilog -o sim/day47_test \
    rtl/parameterized_counter.v \
    tb/tb_parameterized_counter.v
```

Run:

```bash
vvp sim/day47_test
```

View waveform:

```bash
gtkwave day47.vcd
```

---

# 34. Functional Verification

For:

```text
MAX_COUNT = 4
```

the expected sequence is:

| Current count | Next count |
| ------------: | ---------: |
|             0 |          1 |
|             1 |          2 |
|             2 |          3 |
|             3 |          0 |

The terminal count is:

$$
MAX\_COUNT-1
$$

Therefore:

$$
4-1=3
$$

This verifies the modulo-4 behavior.

---

# 35. Reset Verification

| Reset | Enable | Result         |
| ----: | -----: | -------------- |
|     1 |      X | Count = 0      |
|     0 |      0 | Hold count     |
|     0 |      1 | Increment/wrap |

This gives the functional behavior of the example.

---

# 36. Why Parameters Improve Reuse

Without parameters:

```text
counter_8bit_100
counter_8bit_1000
counter_16bit_100
counter_16bit_1000
```

You might create many separate modules.

With parameters:

```text
parameterized_counter
```

can represent all of them.

---

# 37. Parameterized Design

Think of:

```verilog
parameter WIDTH = 8;
parameter MAX_COUNT = 100;
```

as design configuration.

```text
                   COUNTER
                      |
          +-----------+-----------+
          |                       |
       WIDTH                   MAX_COUNT
          |                       |
        size                   period
```

This makes the RTL reusable.

---

# 38. `localparam` Example

Consider an FSM:

```verilog
module controller (
    input wire clk,
    input wire reset,
    input wire start,
    output reg done
);

    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;

    always @(posedge clk) begin

        if (reset)
            state <= IDLE;

        else begin

            case (state)

                IDLE:
                    if (start)
                        state <= RUN;

                RUN:
                    state <= DONE;

                DONE:
                    state <= IDLE;

                default:
                    state <= IDLE;

            endcase

        end

    end

endmodule
```

The names explain the state values.

---

# 39. Parameter vs Localparam — Interview Table

| Feature                          | `parameter`        | `localparam`                      |
| -------------------------------- | ------------------ | --------------------------------- |
| Constant                         | Yes                | Yes                               |
| Can configure module             | Yes                | No, intended internal             |
| Typical use                      | Width/depth/period | State encoding/internal constants |
| Reusable configuration           | Yes                | No                                |
| Internal implementation constant | Possible           | Preferred                         |

---

# 40. Common Mistake

Bad:

```verilog
parameter MAX = 100;

if (count == 99)
```

Why is this bad?

Because the parameter changed but the comparison did not.

If:

```text
MAX = 200
```

the comparison still uses:

```text
99
```

This defeats the purpose of parameterization.

Correct:

```verilog
if (count == MAX-1)
```

---

# 41. Another Common Mistake

Bad:

```verilog
parameter DEPTH = 16;

reg [7:0] memory [0:15];
```

If:

```text
DEPTH = 32
```

the memory is still only 16 locations.

Correct:

```verilog
reg [7:0] memory [0:DEPTH-1];
```

Better still:

```verilog
parameter DATA_WIDTH = 8;
parameter DEPTH = 16;

reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
```

---

# 42. Avoid Magic Numbers in Testbenches Too

Bad:

```verilog
#100;
```

without explaining why 100 ns is required.

Better:

```verilog
localparam TEST_TIME = 100;
```

Then:

```verilog
#TEST_TIME;
```

Similarly:

```verilog
localparam CLK_PERIOD = 10;
always #(CLK_PERIOD/2) clk = ~clk;
```

This makes the testbench easier to modify.

---

# 43. Avoid Magic Numbers in Clock Generation

Bad:

```verilog
always #5 clk = ~clk;
```

The reader has to infer:

```text
10 ns clock period
100 MHz clock
```

Better:

```verilog
localparam CLK_PERIOD = 10;

always #(CLK_PERIOD/2)
    clk = ~clk;
```

The intent is clearer.

---

# 44. Important Note About Physical Units

A name can also document units.

Instead of:

```verilog
localparam TIMEOUT = 1000;
```

prefer:

```verilog
localparam TIMEOUT_CYCLES = 1000;
```

or:

```verilog
localparam CLK_PERIOD_NS = 10;
```

This tells the reader what the number represents.

---

# 45. Naming Matters

Bad:

```verilog
parameter A = 100;
parameter B = 8;
parameter C = 16;
```

Better:

```verilog
parameter MAX_COUNT = 100;
parameter DATA_WIDTH = 8;
parameter FIFO_DEPTH = 16;
```

The name should communicate meaning.

---

# 46. Placement Interview Questions

## Q1. What is a magic number?

A hard-coded numeric value whose purpose or meaning is not clear from the code.

---

## Q2. Why should magic numbers be avoided?

They reduce readability and make RTL harder to maintain, modify, verify, and reuse.

---

## Q3. How do you replace a magic number?

Use a meaningful:

```text
parameter
```

or:

```text
localparam
```

depending on whether the value should be externally configurable.

---

## Q4. Difference between parameter and localparam?

`parameter` is intended for configurable module properties.

`localparam` is intended for internal constants that should not be externally configured.

---

## Q5. Is every numeric literal a magic number?

No.

A number is not automatically a magic number simply because it is numeric.

The issue is whether its purpose is unclear or it represents an important design constant.

---

## Q6. Why use `MAX_COUNT-1` instead of `99`?

Because:

```text
MAX_COUNT = 100
```

makes the design intent explicit and allows the parameter to change without modifying the comparison.

---

## Q7. How do magic numbers affect parameterized RTL?

If hard-coded values remain in the RTL, changing the parameter may not correctly change the design behavior.

---

## Q8. Give an FSM example.

Instead of:

```verilog
state == 2'b01
```

use:

```verilog
state == RUN
```

where:

```verilog
localparam RUN = 2'b01;
```

---

# 47. Placement Scenario

Interviewer:

> "You have the following code. What is wrong?"

```verilog
if (count == 999)
    count <= 0;
```

Strong answer:

> The value 999 is a magic number unless its purpose is obvious from the surrounding design. If it represents a counter period, I would define a meaningful constant such as `MAX_COUNT` or `TIMEOUT_CYCLES` and write `count == MAX_COUNT-1`.

---

# 48. Placement Scenario 2

Interviewer:

> "What is better?"

### A

```verilog
if (state == 2'b10)
```

### B

```verilog
localparam DONE = 2'b10;

if (state == DONE)
```

Answer:

**B**, because the symbolic name communicates the meaning of the state.

---

# 49. Placement Scenario 3

Interviewer:

> "Why isn't every literal a magic number?"

Answer:

> A numeric literal is not necessarily a magic number. The concern is an unexplained or duplicated design-specific constant whose purpose is unclear. Simple values such as zero or a fixed bit index may be perfectly clear from context.

---

# 50. Day 47 Assignment

Create a parameterized counter with:

```text
WIDTH
MAX_COUNT
ENABLE
RESET
```

Requirements:

```text
1. No unexplained counter limit.
2. Use parameters.
3. Use nonblocking assignments.
4. Use synchronous reset.
5. Verify at least three different MAX_COUNT values.
```

Test:

```text
MAX_COUNT = 4
MAX_COUNT = 10
MAX_COUNT = 16
```

Expected sequences:

```text
MAX_COUNT = 4:
0 1 2 3 0 1 ...

MAX_COUNT = 10:
0 1 2 ... 9 0 1 ...

MAX_COUNT = 16:
0 1 2 ... 15 0 1 ...
```

---

# 51. Advanced Assignment

Take any RTL module you created during Days 1–46 and search for:

```text
hard-coded widths
hard-coded depths
hard-coded counter limits
hard-coded state values
hard-coded protocol constants
```

Replace appropriate values with:

```text
parameter
```

or:

```text
localparam
```

Do not blindly replace every number.

For each replacement, ask:

> What does this number represent?

---

# 52. Day 47 Checklist

Before moving to Day 48:

```text
[ ] What is a magic number?
[ ] Why should magic numbers be avoided?
[ ] What is parameter?
[ ] What is localparam?
[ ] Difference between parameter and localparam?
[ ] How do you parameterize a counter?
[ ] How do you parameterize FIFO depth?
[ ] How do you name FSM states?
[ ] How do you document units in constants?
[ ] Why are meaningful names important?
[ ] Can every numeric literal be considered a magic number?
```

---

# 53. Git Structure

```text
RTL_50_Days/
│
├── Day_44/
│
├── Day_45/
│
├── Day_46/
│
├── Day_47/
│   ├── README.md
│   │
│   ├── rtl/
│   │   └── parameterized_counter.v
│   │
│   ├── tb/
│   │   └── tb_parameterized_counter.v
│   │
│   └── sim/
│
└── ...
```

Commit:

```bash
git add Day_47/
git commit -m "Day 47: Avoid magic numbers in RTL"
git push
```

---

# 54. Key Takeaways

### Magic number

```text
Unexplained design-specific numeric constant
```

### Bad

```verilog
if (count == 999)
```

### Better

```verilog
localparam TIMEOUT_CYCLES = 1000;

if (count == TIMEOUT_CYCLES-1)
```

### Configurable property

Use:

```verilog
parameter
```

### Internal constant

Use:

```verilog
localparam
```

### FSM

Bad:

```verilog
2'b01
```

Better:

```verilog
RUN
```

### Main principle

> **Give important design constants meaningful names instead of scattering unexplained numeric literals throughout the RTL.**

---

# 55. Final Mental Model

```text
                 RTL DESIGN
                     |
          +----------+----------+
          |                     |
          v                     v
     Configuration          Internal constants
          |                     |
      parameter             localparam
          |                     |
          +----------+----------+
                     |
                     v
              Clear RTL intent
                     |
                     v
          Easier maintenance
          Easier verification
          Better reuse
```

Day 47 is complete.

**Next: Day 48 — Robustness**, where we will learn how to make RTL behave safely even when inputs, states, or operating conditions are unexpected.
