# Day 49 — Readability in RTL Design

## 1. Objective

Learn how to write RTL that is:

* Easy to understand
* Easy to review
* Easy to debug
* Easy to modify
* Consistent
* Self-explanatory
* Suitable for team-based chip design
   
The main principle is:

> **RTL should be written for humans first and synthesis tools second.**

The synthesis tool can understand complicated RTL, but another engineer should also be able to understand it quickly.

---

# 2. Roadmap Connection

```text
Day 45 → High Cohesion
Day 46 → Low Coupling
Day 47 → Avoid Magic Numbers
Day 48 → Robustness
Day 49 → Readability
Day 50 → DRY
```

We have already learned:

```text
High Cohesion
      ↓
Low Coupling
      ↓
No Magic Numbers
      ↓
Robustness
      ↓
READABILITY
      ↓
DRY
```

Readability brings all these practices together.

---

# 3. What is Readability?

Readability means writing RTL so that another engineer can understand the design without spending unnecessary time decoding the code.

Compare:

```verilog
if (c == 3)
    s <= 2;
```

with:

```verilog
if (count == MAX_COUNT-1)
    state <= DONE;
```

The second version communicates the design intent much more clearly.

---

# 4. Why Readability Matters in VLSI?

RTL is rarely written and forgotten.

A typical project goes through:

```text
RTL
 ↓
Code Review
 ↓
Simulation
 ↓
Lint
 ↓
Synthesis
 ↓
STA
 ↓
Physical Design
 ↓
Verification
 ↓
ECO / Modification
```

Engineers may need to understand the same RTL months later.

Readable RTL reduces:

* Debugging time
* Review time
* Integration mistakes
* Maintenance effort
* Misunderstanding between designers

---

# 5. Example of Poor Readability

```verilog
module m(input a,b,c,d, output reg y);

reg [3:0] x;

always @(*) begin
    x[0]=a&b;
    x[1]=c|d;
    x[2]=x[0]^x[1];
    x[3]=x[2]&a;
    y=x[3];
end

endmodule
```

The code may work, but the reader has to figure out what:

```text
x[0]
x[1]
x[2]
x[3]
```

represent.

---

# 6. Better Readability

```verilog
module logic_control (
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    output reg  y
);

reg ab_and;
reg cd_or;
reg intermediate;

always @(*) begin

    ab_and      = a & b;
    cd_or       = c | d;
    intermediate = ab_and ^ cd_or;
    y           = intermediate & a;

end

endmodule
```

Now the intent is much easier to understand.

---

# 7. Principle 1 — Use Meaningful Names

Bad:

```verilog
reg [7:0] x;
reg [7:0] y;
reg [7:0] z;
```

Better:

```verilog
reg [7:0] data_in;
reg [7:0] data_out;
reg [7:0] processed_data;
```

The name itself communicates information.

---

# 8. Naming Examples

### Bad

```verilog
reg clk1;
reg x;
reg a1;
reg tmp;
```

### Better

```verilog
reg clk_div;
reg request_pending;
reg packet_valid;
reg checksum_error;
```

Use names that describe **function**, not merely physical location.

---

# 9. Boolean Signals

For signals representing conditions, names such as:

```text
valid
ready
busy
done
enable
reset
error
overflow
empty
full
```

are easy to understand.

You can also use:

```text
fifo_full
fifo_empty
packet_valid
transfer_done
write_enable
```

---

# 10. Active-Low Signals

Make polarity clear.

For example:

```verilog
reset_n
enable_n
cs_n
```

usually indicates active-low behavior.

Example:

```verilog
if (!reset_n)
    state <= IDLE;
```

This is clearer than using an unexplained name such as:

```verilog
if (!r)
```

---

# 11. Principle 2 — Use Parameters

Instead of:

```verilog
if (count == 99)
```

use:

```verilog
parameter MAX_COUNT = 100;

if (count == MAX_COUNT-1)
```

This combines readability with the Day 47 principle:

> **Avoid magic numbers.**

---

# 12. Principle 3 — Use `localparam` for States

Poor:

```verilog
case (state)

    2'b00: ...
    2'b01: ...
    2'b10: ...

endcase
```

Better:

```verilog
localparam IDLE = 2'b00;
localparam RUN  = 2'b01;
localparam DONE = 2'b10;

case (state)

    IDLE: ...
    RUN:  ...
    DONE: ...

endcase
```

Now the code describes the FSM directly.

---

# 13. FSM Readability

Consider:

```verilog
if (state == 2'b01)
```

The reader must remember what `01` means.

Instead:

```verilog
if (state == RUN)
```

Immediately communicates the intent.

---

# 14. Principle 4 — Separate Sequential and Combinational Logic

A readable FSM generally uses:

```text
             +----------------+
             |                |
             | Next-State      |
             | Combinational   |
             | Logic           |
             |                |
             +-------+--------+
                     |
                     v
                +----+----+
                | State   |
                | Register|
                +----+----+
                     |
                     +----------+
                                |
                                v
                         Next-State Logic
```

RTL:

```verilog
always @(posedge clk) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    next_state = IDLE;

    case (state)
        ...
    endcase
end
```

This is easier to read and debug.

---

# 15. Principle 5 — One Responsibility Per Block

Avoid putting unrelated operations into one huge `always` block.

Poor:

```verilog
always @(posedge clk) begin

    // FIFO
    ...

    // UART
    ...

    // Counter
    ...

    // PWM
    ...

    // State machine
    ...

end
```

This becomes difficult to understand.

Instead, separate logical responsibilities.

```text
FIFO logic
UART logic
Counter logic
PWM logic
FSM logic
```

This also supports **high cohesion** from Day 45.

---

# 16. Principle 6 — Use Comments for Intent

Comments should explain **why**, not simply repeat **what** the code says.

Poor:

```verilog
count <= count + 1'b1; // increment count
```

The code already says that.

Better:

```verilog
// Hold the counter at the terminal value to prevent overflow.
if (count == MAX_COUNT-1)
    count <= count;
```

The comment provides useful design intent.

---

# 17. Good Comment Example

```verilog
// Keep VALID asserted until the receiver accepts the data.
// Transfer occurs only when VALID and READY are both high.
if (ready)
    valid <= 1'b0;
```

This explains the protocol requirement.

---

# 18. Bad Comments

Avoid comments such as:

```verilog
// Add 1
count <= count + 1;

// Set y
y = a & b;

// Case statement
case (state)
```

These add almost no information.

---

# 19. Principle 7 — Keep Expressions Understandable

Instead of a huge expression:

```verilog
assign result = ((a & b) | (c & d)) ^ ((e | f) & g);
```

you can use intermediate signals when they improve clarity:

```verilog
wire ab_and;
wire cd_and;
wire first_term;
wire ef_or;
wire second_term;

assign ab_and     = a & b;
assign cd_and     = c & d;
assign first_term = ab_and | cd_and;

assign ef_or      = e | f;
assign second_term = ef_or & g;

assign result     = first_term ^ second_term;
```

The hardware can still be optimized by synthesis.

---

# 20. Readability Does Not Mean More Hardware

A common misconception is:

> "If I split an expression into multiple signals, synthesis will create extra hardware."

Not necessarily.

For example:

```verilog
assign y = (a & b) | (c & d);
```

and:

```verilog
wire ab;
wire cd;

assign ab = a & b;
assign cd = c & d;
assign y  = ab | cd;
```

can synthesize to equivalent hardware.

Readable RTL does not automatically mean inefficient RTL.

---

# 21. Principle 8 — Consistent Indentation

Bad:

```verilog
always@(posedge clk)begin
if(reset)begin
state<=IDLE;
end else begin
if(enable)
state<=RUN;
end
end
```

Better:

```verilog
always @(posedge clk) begin

    if (reset) begin
        state <= IDLE;
    end
    else if (enable) begin
        state <= RUN;
    end

end
```

Indentation makes hierarchy visible.

---

# 22. Principle 9 — Consistent Spacing

Use:

```verilog
assign y = a & b;
```

rather than:

```verilog
assign y=a&b;
```

Both are syntactically valid, but consistent spacing improves review.

---

# 23. Principle 10 — Keep Lines Manageable

Avoid extremely long lines:

```verilog
assign output_data = enable && valid && ready && !error && !full && (count < MAX_COUNT) && mode;
```

Break complicated logic into meaningful intermediate signals when necessary:

```verilog
wire transfer_allowed;

assign transfer_allowed =
       enable &&
       valid &&
       ready &&
       !error &&
       !full;

assign output_data = transfer_allowed &&
                     (count < MAX_COUNT) &&
                     mode;
```

---

# 24. Principle 11 — Make Interfaces Clear

Compare:

```verilog
module m(
    input a,
    input b,
    input c,
    output y,
    output z
);
```

with:

```verilog
module packet_controller (
    input  wire       clk,
    input  wire       reset,
    input  wire       packet_valid,
    input  wire [7:0] packet_data,
    output wire       ready,
    output reg        packet_done
);
```

The second interface immediately communicates the module's purpose.

---

# 25. Principle 12 — Group Related Signals

For example:

```verilog
input wire        clk;
input wire        reset;

input wire        valid_in;
input wire [7:0]  data_in;
output wire       ready_in;

output wire       valid_out;
output wire [7:0] data_out;
input wire        ready_out;
```

The interface structure becomes obvious:

```text
Clock/reset
Input interface
Output interface
```

---

# 26. Principle 13 — Use Consistent Signal Direction

A useful convention is:

```text
*_in
*_out
```

Examples:

```text
data_in
data_out
valid_in
valid_out
ready_in
ready_out
```

This is especially useful in large systems.

---

# 27. Principle 14 — Use Consistent Clock/Reset Naming

For example:

```text
clk
reset
```

or:

```text
clk
rst_n
```

The exact convention can vary between organizations.

The important point is:

> Choose a convention and use it consistently.

---

# 28. Principle 15 — Make Widths Obvious

Poor:

```verilog
reg [7:0] x;
```

Better:

```verilog
reg [7:0] packet_data;
```

Also avoid unnecessary width ambiguity.

For example:

```verilog
count <= count + 1'b1;
```

clearly indicates a one-bit increment value.

---

# 29. Principle 16 — Use Named Operations

Instead of:

```verilog
case (op)

    3'b000: ...
    3'b001: ...
    3'b010: ...

endcase
```

use:

```verilog
localparam OP_ADD = 3'b000;
localparam OP_SUB = 3'b001;
localparam OP_AND = 3'b010;

case (op)

    OP_ADD: ...
    OP_SUB: ...
    OP_AND: ...

endcase
```

---

# 30. Readable ALU Example

```verilog
module readable_alu (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] operation,
    output reg  [3:0] result
);

    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;

    always @(*) begin

        result = 4'b0000;

        case (operation)

            OP_ADD:
                result = a + b;

            OP_SUB:
                result = a - b;

            OP_AND:
                result = a & b;

            OP_OR:
                result = a | b;

            OP_XOR:
                result = a ^ b;

            default:
                result = 4'b0000;

        endcase

    end

endmodule
```

This is much easier to review than unexplained binary operation codes.

---

# 31. Truth Table — ALU Control

For the operations above:

| Operation | Meaning      |
| --------- | ------------ |
| `000`     | ADD          |
| `001`     | SUB          |
| `010`     | AND          |
| `011`     | OR           |
| `100`     | XOR          |
| Other     | Safe default |

For example:

```text
A = 1010
B = 0011
```

### ADD

```text
1010
0011
----
1101
```

### AND

```text
1010
0011
----
0010
```

### OR

```text
1010
0011
----
1011
```

### XOR

```text
1010
0011
----
1001
```

---

# 32. Principle 17 — Avoid Unnecessary Cleverness

Bad RTL sometimes tries to be "smart":

```verilog
assign y = condition ? (a ? b : c) : (d ? e : f);
```

This may be valid, but if the logic becomes difficult to understand, use structured code.

Readable:

```verilog
always @(*) begin

    y = DEFAULT_VALUE;

    if (condition) begin

        if (a)
            y = b;
        else
            y = c;

    end
    else begin

        if (d)
            y = e;
        else
            y = f;

    end

end
```

The goal is not to minimize source-code characters.

The goal is to make the design intent obvious.

---

# 33. Principle 18 — Avoid Duplicate Meaning

If a signal has a meaningful name, use it.

Instead of repeatedly writing:

```verilog
if (valid && ready)
```

you can define:

```verilog
wire transfer;

assign transfer = valid && ready;
```

Then:

```verilog
if (transfer)
```

This is particularly useful when the condition represents a protocol concept.

---

# 34. Readability + Robustness

From Day 48:

```verilog
default:
    next_state = IDLE;
```

Readable version:

```verilog
default: begin
    // Recover from an illegal state.
    next_state = IDLE;
end
```

The comment is useful because it explains **why** the default exists.

---

# 35. Readability + High Cohesion

Day 45 taught:

> A module should have a focused responsibility.

For example:

```text
fifo.v
```

should primarily implement:

```text
FIFO behavior
```

rather than:

```text
FIFO
+
UART
+
PWM
+
clock divider
+
packet parser
```

Focused modules are easier to read.

---

# 36. Readability + Low Coupling

Day 46 taught:

> Modules should communicate through clear interfaces.

Instead of allowing another module to depend on internal FIFO signals:

```text
FIFO internal memory
FIFO internal pointers
FIFO internal counters
```

use:

```text
wr_en
wr_data
rd_en
rd_data
full
empty
```

A clean interface improves readability.

---

# 37. Complete Readable Counter

Create:

```text
rtl/readable_counter.v
```

```verilog
module readable_counter #(
    parameter WIDTH = 8,
    parameter MAX_COUNT = 100
)(
    input  wire              clk,
    input  wire              reset,
    input  wire              enable,
    output reg [WIDTH-1:0]   count
);

    always @(posedge clk) begin

        if (reset) begin
            count <= {WIDTH{1'b0}};
        end

        else if (enable) begin

            if (count == MAX_COUNT-1) begin
                // Return to zero after reaching the terminal count.
                count <= {WIDTH{1'b0}};
            end

            else begin
                count <= count + 1'b1;
            end

        end

    end

endmodule
```

Notice the combination of:

```text
parameterization
meaningful names
indentation
comments
clear structure
nonblocking assignment
```

---

# 38. Testbench

Create:

```text
tb/tb_readable_counter.v
```

```verilog
`timescale 1ns/1ps

module tb_readable_counter;

    localparam WIDTH = 4;
    localparam MAX_COUNT = 5;

    reg clk;
    reg reset;
    reg enable;

    wire [WIDTH-1:0] count;

    readable_counter #(
        .WIDTH(WIDTH),
        .MAX_COUNT(MAX_COUNT)
    ) dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("day49_counter.vcd");
        $dumpvars(0, tb_readable_counter);

        clk    = 1'b0;
        reset  = 1'b1;
        enable = 1'b0;

        #12;

        reset  = 1'b0;
        enable = 1'b1;

        #60;

        enable = 1'b0;

        #20;

        $finish;

    end

    always @(posedge clk) begin
        $display(
            "TIME=%0t RESET=%b ENABLE=%b COUNT=%0d",
            $time,
            reset,
            enable,
            count
        );
    end

endmodule
```

---

# 39. Expected Counter Sequence

With:

```text
MAX_COUNT = 5
```

the count should be:

```text
0
1
2
3
4
0
1
2
...
```

Truth/behavior table:

| Current Count | Enable | Next Count |
| ------------: | -----: | ---------: |
|             0 |      1 |          1 |
|             1 |      1 |          2 |
|             2 |      1 |          3 |
|             3 |      1 |          4 |
|             4 |      1 |          0 |
|             X |      0 |       Hold |

The final row represents the enable-disabled behavior rather than an actual unknown simulation value.

---

# 40. Run on Ubuntu

Directory:

```bash
cd ~/RTL_50_Days/Day_49
```

Compile:

```bash
iverilog -o sim/day49_test \
    rtl/readable_counter.v \
    tb/tb_readable_counter.v
```

Run:

```bash
vvp sim/day49_test
```

Open waveform:

```bash
gtkwave day49_counter.vcd
```

---

# 41. Self-Checking Testbench

For placement-level practice, improve the testbench so it automatically detects an error.

Example:

```verilog
if (count !== expected_count) begin
    $display(
        "ERROR: expected=%0d actual=%0d",
        expected_count,
        count
    );
end
```

This is better than manually inspecting every waveform.

---

# 42. Readability Checklist

When reviewing RTL, ask:

### Naming

```text
[ ] Are signal names meaningful?
[ ] Are active-low signals clearly named?
[ ] Are module names descriptive?
```

### Structure

```text
[ ] Is sequential logic separated from combinational logic?
[ ] Are related signals grouped?
[ ] Does each block have a clear purpose?
```

### Constants

```text
[ ] Are magic numbers avoided?
[ ] Are parameters/localparams used?
```

### Comments

```text
[ ] Do comments explain design intent?
[ ] Are unnecessary comments avoided?
```

### Formatting

```text
[ ] Is indentation consistent?
[ ] Is spacing consistent?
[ ] Are expressions readable?
```

### Robustness

```text
[ ] Are default cases present where appropriate?
[ ] Are boundary conditions handled?
[ ] Are outputs assigned in all combinational paths?
```

---

# 43. Before vs After

## Before

```verilog
module m(input c,r,e, output reg [3:0] q);

always @(posedge c)
if(r)
q<=0;
else if(e)
if(q==9)
q<=0;
else
q<=q+1;

endmodule
```

## After

```verilog
module decade_counter (
    input wire       clk,
    input wire       reset,
    input wire       enable,
    output reg [3:0] count
);

    localparam MAX_COUNT = 10;

    always @(posedge clk) begin

        if (reset) begin
            count <= 4'd0;
        end

        else if (enable) begin

            if (count == MAX_COUNT-1)
                count <= 4'd0;
            else
                count <= count + 1'b1;

        end

    end

endmodule
```

The second version communicates its intent immediately.

---

# 44. What Readability Is NOT

Readability does not mean:

```text
more comments
more lines
more signals
more complicated structure
```

Readable RTL means:

> **The simplest code that clearly communicates the intended hardware behavior.**

---

# 45. Placement Interview Questions

## Q1. What is RTL readability?

It is the practice of writing RTL so that its behavior and design intent can be understood easily by other engineers.

---

## Q2. Why are meaningful signal names important?

They communicate the purpose of signals and reduce the amount of interpretation required during design review and debugging.

---

## Q3. Why use `localparam` for FSM states?

It replaces unexplained state encodings with meaningful names.

---

## Q4. Why should sequential and combinational logic be separated?

It makes the RTL structure easier to understand, verify, debug, and maintain.

---

## Q5. What should comments explain?

Preferably the **design intent or reason** behind the implementation rather than simply repeating what the code already says.

---

## Q6. Does readable RTL necessarily synthesize into more hardware?

No. Synthesis can optimize intermediate signals and equivalent RTL structures into the same hardware.

---

## Q7. Why is consistent naming important?

It allows engineers to recognize signal roles quickly across a large RTL codebase.

---

## Q8. What is better?

```verilog
if (state == 2'b01)
```

or:

```verilog
if (state == RUN)
```

The second is generally more readable because `RUN` communicates the state meaning directly.

---

## Q9. Why should extremely long expressions sometimes be broken into intermediate signals?

To expose the logical structure and make debugging and review easier.

---

## Q10. What is the relationship between readability and maintainability?

Readable RTL is generally easier to modify safely because engineers can understand the existing design intent before making changes.

---

# 46. Placement Question — Explain Your Coding Style

A strong answer:

> "I use meaningful signal and module names, localparams for state and operation encodings, parameters for configurable values, consistent indentation, separate sequential and combinational logic, safe default assignments, and comments for design intent. I also try to keep each module focused on one responsibility."

---

# 47. Day 49 Assignment

Take **three RTL modules from Days 1–48** and perform a readability refactoring.

Recommended:

```text
1. FIFO
2. 101 sequence detector
3. Booth multiplier
```

For each module:

### Step 1

Find unclear names:

```text
x
y
tmp
a1
s
```

### Step 2

Replace them with meaningful names.

### Step 3

Replace magic numbers with:

```verilog
parameter
localparam
```

### Step 4

Improve indentation.

### Step 5

Separate sequential and combinational logic where appropriate.

### Step 6

Add comments explaining important design decisions.

### Step 7

Run the original and refactored versions.

### Step 8

Verify that the functionality remains identical.

---

# 48. Readability Review Example

Create this table:

| Item        | Before       | After               |
| ----------- | ------------ | ------------------- |
| Module name | `m1`         | `packet_controller` |
| Signal      | `x`          | `packet_valid`      |
| Signal      | `r`          | `reset`             |
| State       | `2'b01`      | `RUN`               |
| Constant    | `999`        | `MAX_COUNT`         |
| Formatting  | inconsistent | consistent          |
| Comments    | what         | why                 |
| Logic       | mixed        | structured          |

This is a good code-review exercise.

---

# 49. Git Structure

```text
RTL_50_Days/
│
├── Day_47/
├── Day_48/
│
├── Day_49/
│   ├── README.md
│   │
│   ├── rtl/
│   │   └── readable_counter.v
│   │
│   ├── tb/
│   │   └── tb_readable_counter.v
│   │
│   └── sim/
│
└── Day_50/
```

Git commands:

```bash
git add Day_49/
git commit -m "Day 49: Improve RTL readability"
git push
```

---

# 50. Day 49 Final Checklist

Before moving to Day 50, make sure you can answer:

```text
[ ] What is RTL readability?
[ ] Why are meaningful names important?
[ ] Why use localparam for FSM states?
[ ] Why use parameters for configurable values?
[ ] Why separate sequential and combinational logic?
[ ] What should a useful comment explain?
[ ] Why is indentation important?
[ ] Why should long expressions sometimes be split?
[ ] How does readability help debugging?
[ ] How does readability help code review?
[ ] How does readability improve maintainability?
[ ] How are readability, robustness and cohesion related?
```

---

# 51. Key Takeaways

### 1. Meaningful names

```verilog
packet_valid
```

is better than:

```verilog
x
```

### 2. Named states

```verilog
localparam IDLE = 2'b00;
localparam RUN  = 2'b01;
```

are better than unexplained encodings.

### 3. Named constants

```verilog
parameter MAX_COUNT = 100;
```

is better than:

```verilog
if (count == 99)
```

### 4. Clear structure

```text
Sequential logic
       +
Combinational logic
       +
Clear interfaces
```

makes RTL easier to understand.

### 5. Useful comments

Explain:

```text
WHY
```

rather than simply:

```text
WHAT
```

### 6. Main principle

> **Write RTL so another engineer can understand the hardware intent quickly without having to reverse-engineer your code.**

---

# 52. Final Mental Model

```text
                 READABLE RTL
                      |
       +--------------+--------------+
       |              |              |
       v              v              v
 Meaningful       Clear          Consistent
   names         structure        style
       |              |              |
       +--------------+--------------+
                      |
                      v
              Easier code review
                      |
                      v
                Easier debugging
                      |
                      v
              Easier maintenance
                      |
                      v
               Better RTL quality
```

## Day 49 Complete

Next:

**Day 50 — DRY (Don't Repeat Yourself)**

We will finish the 50-day RTL roadmap by learning how to eliminate unnecessary duplicated RTL while keeping the design clear, reusable, and maintainable.
