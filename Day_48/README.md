# Day 48 — Robustness in RTL Design

## 1. Objective

Learn how to make RTL designs **robust**.

By the end of Day 48, you should understand:

* What robustness means in RTL
* Why invalid inputs and states must be handled
* How to recover from illegal FSM states
* How to handle overflow and underflow
* How to protect counters
* How to handle FIFO full/empty conditions
* Why default assignments are important
* How reset contributes to robustness
* How to write defensive RTL
* How robust RTL improves verification and reliability

---

# 2. Roadmap Connection

The final RTL-quality topics are:

```text
Day 45 → High Cohesion
Day 46 → Low Coupling
Day 47 → Avoid Magic Numbers
Day 48 → Robustness
Day 49 → Readability
Day 50 → DRY
```

So far:

```text
High Cohesion
      ↓
Low Coupling
      ↓
Avoid Magic Numbers
      ↓
ROBUSTNESS
```

The goal is not just to make RTL work for valid inputs.

The goal is:

> **Make the RTL behave predictably even when unexpected conditions occur.**

---

# 3. What is Robustness?

Robustness is the ability of a design to continue behaving correctly or recover safely when it encounters unexpected or abnormal conditions.

Examples:

```text
invalid FSM state
FIFO full
FIFO empty
counter overflow
counter underflow
unexpected input
invalid command
reset
illegal combination of controls
```

---

# 4. Normal vs Unexpected Operation

Suppose we have a FIFO.

Normal operation:

```text
write → data enters FIFO
read  → data leaves FIFO
```

But what if:

```text
FIFO is full
```

and the system requests another write?

Or:

```text
FIFO is empty
```

and the system requests a read?

A robust design must define what happens.

---

# 5. Robust RTL Mental Model

Think of a module as:

```text
                INPUTS
                  |
                  v
        +-------------------+
        |                   |
        |   RTL MODULE      |
        |                   |
        |  normal behavior  |
        |  error handling   |
        |  recovery logic   |
        |                   |
        +-------------------+
                  |
                  v
                OUTPUTS
```

The module should not assume that everything is always perfect.

---

# 6. Example: Counter Overflow

Consider:

```verilog id="c7b0ut"
reg [3:0] count;

always @(posedge clk)
    count <= count + 1'b1;
```

A 4-bit counter has:

$$
2^4=16
$$

possible values:

```text
0 → 15
```

After:

```text
15 + 1
```

the 4-bit result wraps:

```text
15 → 0
```

This may be correct for a modulo-16 counter.

But what if the design requires the counter to stop at 15?

Then simply allowing wraparound is not robust.

---

# 7. Saturating Counter

A robust implementation can explicitly handle the maximum value.

```verilog id="p6f2rm"
module robust_counter (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    output reg [3:0] count
);

    always @(posedge clk) begin

        if (reset) begin
            count <= 4'd0;
        end

        else if (enable) begin

            if (count == 4'd15)
                count <= 4'd15;
            else
                count <= count + 1'b1;

        end

    end

endmodule
```

Now:

```text
14 → 15
15 → 15
```

instead of:

```text
14 → 15
15 → 0
```

This is called **saturation**.

---

# 8. Why This Matters

The correct behavior depends on the specification.

### Modulo counter

```text
14 → 15 → 0 → 1
```

### Saturating counter

```text
14 → 15 → 15 → 15
```

Neither is automatically better.

Robust RTL means:

> **Explicitly define what should happen at the boundary.**

---

# 9. FIFO Full Condition

From Day 41:

```text
FIFO
```

has:

```text
full
empty
```

Suppose:

```text
full = 1
wr_en = 1
```

A robust FIFO should not blindly perform another write.

Use:

```verilog
if (wr_en && !full)
    // perform write
```

Similarly:

```verilog
if (rd_en && !empty)
    // perform read
```

---

# 10. Safe FIFO Control

Define:

```verilog id="tq2fkl"
wire do_write;
wire do_read;

assign do_write = wr_en && !full;
assign do_read  = rd_en && !empty;
```

Now:

```text
write occurs only when:
wr_en = 1 AND full = 0
```

and:

```text
read occurs only when:
rd_en = 1 AND empty = 0
```

This is defensive RTL.

---

# 11. Truth Table — FIFO Write

For the write operation:

$$
DO\_WRITE = WR\_EN \land \overline{FULL}
$$

| WR_EN | FULL | DO_WRITE |
| ----: | ---: | -------: |
|     0 |    0 |        0 |
|     0 |    1 |        0 |
|     1 |    0 |        1 |
|     1 |    1 |        0 |

The important case is:

```text
WR_EN = 1
FULL = 1
```

Result:

```text
DO_WRITE = 0
```

No overflow occurs.

---

# 12. Truth Table — FIFO Read

$$
DO\_READ = RD\_EN \land \overline{EMPTY}
$$

| RD_EN | EMPTY | DO_READ |
| ----: | ----: | ------: |
|     0 |     0 |       0 |
|     0 |     1 |       0 |
|     1 |     0 |       1 |
|     1 |     1 |       0 |

Therefore:

```text
RD_EN = 1
EMPTY = 1
```

does not perform a read.

This prevents an invalid FIFO read.

---

# 13. FSM Robustness

FSMs are an important source of robustness problems.

Suppose:

```verilog id="r3w7i6"
localparam IDLE = 2'b00;
localparam RUN  = 2'b01;
localparam DONE = 2'b10;
```

There are four possible 2-bit states:

```text
00 → IDLE
01 → RUN
10 → DONE
11 → unused
```

What happens if:

```text
state = 2'b11
```

?

A robust FSM should have a recovery mechanism.

---

# 14. Bad FSM

```verilog id="u7a4hk"
always @(*) begin

    case (state)

        IDLE:
            next_state = RUN;

        RUN:
            next_state = DONE;

        DONE:
            next_state = IDLE;

    endcase

end
```

There is no explicit handling for:

```text
2'b11
```

That is undesirable.

---

# 15. Robust FSM

Add:

```verilog id="4p4m68"
default:
    next_state = IDLE;
```

Example:

```verilog id="4dj1zt"
always @(*) begin

    case (state)

        IDLE:
            next_state = RUN;

        RUN:
            next_state = DONE;

        DONE:
            next_state = IDLE;

        default:
            next_state = IDLE;

    endcase

end
```

Now:

```text
illegal state
     ↓
  IDLE
```

This provides a recovery path.

---

# 16. Why Default Recovery Matters

Consider:

```text
00 → IDLE
01 → RUN
10 → DONE
11 → invalid
```

Without recovery:

```text
11
 ↓
undefined behavior
```

With recovery:

```text
11
 ↓
IDLE
```

This is much safer.

---

# 17. Important FSM Principle

A robust FSM should define behavior for:

```text
all valid states
+
unexpected/unused states
```

Typical pattern:

```verilog
default:
    next_state = IDLE;
```

---

# 18. Invalid Input Handling

Suppose a module accepts a 2-bit command:

```text
00 = IDLE
01 = READ
10 = WRITE
11 = invalid
```

A robust design should explicitly handle:

```text
11
```

Example:

```verilog id="q0qvqa"
case (command)

    2'b00:
        operation = IDLE;

    2'b01:
        operation = READ;

    2'b10:
        operation = WRITE;

    default:
        operation = IDLE;

endcase
```

---

# 19. Avoid Unassigned Outputs

Consider:

```verilog id="6azwuk"
always @(*) begin

    if (enable)
        y = a;

end
```

What happens when:

```text
enable = 0
```

?

`y` has no assignment in that branch.

This can infer unintended storage in combinational logic.

---

# 20. Robust Combinational Coding

Set defaults first:

```verilog id="jvpx8g"
always @(*) begin

    y = 1'b0;

    if (enable)
        y = a;

end
```

Now every execution of the block gives `y` a defined value.

---

# 21. Default Assignment Pattern

A common robust combinational structure is:

```verilog id="3d40ic"
always @(*) begin

    next_state = IDLE;
    output_a   = 1'b0;
    output_b   = 1'b0;

    case (state)

        IDLE: begin
            ...
        end

        RUN: begin
            ...
        end

        default: begin
            ...
        end

    endcase

end
```

This helps prevent incomplete assignments.

---

# 22. Robustness and Reset

Reset places sequential logic into a known state.

Example:

```verilog id="2a2n6k"
always @(posedge clk) begin

    if (reset) begin
        state <= IDLE;
        count <= 0;
        data  <= 0;
    end

end
```

Without reset, registers may begin in unknown (`X`) states during simulation or otherwise lack a defined startup condition, depending on the target technology.

---

# 23. Why Reset Helps

Without reset:

```text
state = X
count = X
data  = X
```

With reset:

```text
state = IDLE
count = 0
data  = 0
```

This makes the design easier to initialize and verify.

---

# 24. Robustness Does Not Mean "Reset Everything"

Do not blindly add reset to every signal.

Reset strategy depends on:

* architecture
* FPGA/ASIC technology
* timing
* initialization requirements
* design specification

The principle is:

> Reset the state that must have a defined startup condition.

---

# 25. Robustness Against Illegal States

Consider a 3-bit FSM with only five valid states:

```text
000
001
010
011
100
```

Unused:

```text
101
110
111
```

A robust FSM can recover:

```text
101 → 000
110 → 000
111 → 000
```

using:

```verilog id="1i2j0g"
default:
    next_state = IDLE;
```

---

# 26. Robustness Against Overflow

Suppose an 8-bit counter stores:

```text
0–255
```

If the specification says overflow is illegal, explicitly detect it:

```verilog id="3muw8g"
if (count == 8'hFF) begin
    overflow <= 1'b1;
    count    <= count;
end
else begin
    count <= count + 1'b1;
end
```

Now the overflow condition is visible.

---

# 27. Error Flag

Sometimes robust designs don't silently ignore an error.

They report it.

Example:

```verilog id="v9w3pr"
if (count == 8'hFF) begin
    overflow <= 1'b1;
end
```

The system can then respond.

Architecture:

```text
             overflow
                 |
                 v
+------------+   +----------+
|   Counter  |-->| Controller|
+------------+   +----------+
```

---

# 28. Robustness vs Silent Failure

Consider an invalid command.

Bad approach:

```text
invalid command
      ↓
ignore silently
```

Better:

```text
invalid command
      ↓
safe default
      +
error/status indication
```

For example:

```verilog id="d3h9nq"
default: begin
    operation = IDLE;
    error     = 1'b1;
end
```

---

# 29. Robustness Example — Command Decoder

Create:

```text id="s4n2ib"
rtl/command_decoder.v
```

```verilog id="xkqf6c"
module command_decoder (
    input  wire [1:0] command,
    output reg        read_en,
    output reg        write_en,
    output reg        error
);

    localparam CMD_IDLE  = 2'b00;
    localparam CMD_READ  = 2'b01;
    localparam CMD_WRITE = 2'b10;

    always @(*) begin

        read_en  = 1'b0;
        write_en = 1'b0;
        error    = 1'b0;

        case (command)

            CMD_IDLE: begin
                // Nothing to do
            end

            CMD_READ: begin
                read_en = 1'b1;
            end

            CMD_WRITE: begin
                write_en = 1'b1;
            end

            default: begin
                error = 1'b1;
            end

        endcase

    end

endmodule
```

---

# 30. Why This Is Robust

For valid commands:

```text
00 → idle
01 → read
10 → write
```

For invalid command:

```text
11 → error
```

Instead of producing unpredictable control signals.

---

# 31. Truth Table

| Command | Meaning | READ | WRITE | ERROR |
| ------- | ------- | ---: | ----: | ----: |
| 00      | IDLE    |    0 |     0 |     0 |
| 01      | READ    |    1 |     0 |     0 |
| 10      | WRITE   |    0 |     1 |     0 |
| 11      | INVALID |    0 |     0 |     1 |

This is an important verification table.

---

# 32. Testbench

Create:

```text id="0uhwga"
tb/tb_command_decoder.v
```

```verilog id="hshq9d"
`timescale 1ns/1ps

module tb_command_decoder;

    reg  [1:0] command;
    wire       read_en;
    wire       write_en;
    wire       error;

    command_decoder uut (
        .command  (command),
        .read_en  (read_en),
        .write_en (write_en),
        .error    (error)
    );

    initial begin

        $dumpfile("day48.vcd");
        $dumpvars(0, tb_command_decoder);

        command = 2'b00;
        #10;

        command = 2'b01;
        #10;

        command = 2'b10;
        #10;

        command = 2'b11;
        #10;

        $finish;

    end

    always @(*) begin
        #1;
        $display(
            "TIME=%0t CMD=%b READ=%b WRITE=%b ERROR=%b",
            $time,
            command,
            read_en,
            write_en,
            error
        );
    end

endmodule
```

---

# 33. Compile

Create the directory:

```bash
mkdir -p sim
```

Compile:

```bash
iverilog -o sim/day48_test \
    rtl/command_decoder.v \
    tb/tb_command_decoder.v
```

Run:

```bash
vvp sim/day48_test
```

Open waveform:

```bash
gtkwave day48.vcd
```

---

# 34. Expected Behavior

You should observe:

```text
CMD = 00
READ = 0
WRITE = 0
ERROR = 0
```

```text
CMD = 01
READ = 1
WRITE = 0
ERROR = 0
```

```text
CMD = 10
READ = 0
WRITE = 1
ERROR = 0
```

```text
CMD = 11
READ = 0
WRITE = 0
ERROR = 1
```

---

# 35. Robustness Through Defensive Coding

A useful mental model is:

```text
Normal case
    ↓
Handle normally

Boundary case
    ↓
Handle explicitly

Invalid case
    ↓
Safe behavior

Unexpected state
    ↓
Recovery

Error condition
    ↓
Report/flag
```

---

# 36. Robustness in Day 36 FSM

Our 101 sequence detector had:

```verilog id="d8k6uc"
default: begin
    next_state = S0;
    detect = 1'b0;
end
```

This is already a robustness mechanism.

If an invalid state appears:

```text
→ S0
```

The FSM recovers.

---

# 37. Robustness in Day 41 FIFO

Our FIFO had:

```verilog id="1qk9v8"
assign do_write = wr_en && !full;
assign do_read  = rd_en && !empty;
```

This prevents:

```text
write when full
read when empty
```

Again, this is robustness.

---

# 38. Robustness in Day 47 Counter

Day 47 introduced parameterization:

```verilog
parameter MAX_COUNT = 100;
```

Day 48 asks:

> What happens at the boundary?

For example:

```text
count = MAX_COUNT-1
```

Should it:

```text
wrap?
hold?
raise error?
```

The answer depends on the specification.

A robust design makes that behavior explicit.

---

# 39. Robustness Checklist for RTL

When designing a module, ask:

### Inputs

```text
Can inputs contain invalid values?
```

### FSM

```text
What happens in an illegal state?
```

### Counters

```text
What happens at maximum value?
```

### FIFO

```text
What happens when full?
What happens when empty?
```

### Arithmetic

```text
What happens on overflow?
What happens on underflow?
```

### Combinational logic

```text
Are all outputs assigned?
```

### Reset

```text
What state does the module enter after reset?
```

### Errors

```text
Should an error be reported?
```

---

# 40. Robust RTL Pattern

A useful template is:

```verilog
always @(*) begin

    // Safe defaults
    next_state = IDLE;
    output_a   = 1'b0;
    output_b   = 1'b0;

    case (state)

        IDLE: begin
            ...
        end

        RUN: begin
            ...
        end

        DONE: begin
            ...
        end

        default: begin
            next_state = IDLE;
        end

    endcase

end
```

This pattern is extremely useful for placement interviews.

---

# 41. Robust Sequential Pattern

```verilog
always @(posedge clk) begin

    if (reset) begin
        state <= IDLE;
        count <= 0;
    end

    else begin

        if (enable)
            ...
        
    end

end
```

Use nonblocking assignment:

```verilog
<=
```

for sequential state updates.

---

# 42. Robustness and Unknown Values

During simulation you may encounter:

```text
X = unknown
Z = high impedance
```

For example:

```text
state = XX
```

A `default` branch can help ensure that a case statement has a defined recovery path when the simulator encounters an unexpected case value, though exact `X` behavior also depends on the case construct and coding style.

For robust RTL, don't assume every signal always contains a valid binary value.

---

# 43. Important Caution

Robustness does **not** mean hiding every error.

For example, if an illegal command occurs:

```text
invalid input
```

you may want:

```text
safe state
+
error flag
```

rather than simply:

```text
ignore it
```

The appropriate behavior should come from the design specification.

---

# 44. Placement Interview Questions

## Q1. What is robustness in RTL?

Robustness is the ability of RTL to behave predictably and recover or respond appropriately when abnormal, boundary, or unexpected conditions occur.

---

## Q2. How do you make an FSM robust?

Use:

```verilog
default:
    next_state = IDLE;
```

or another defined safe recovery state.

---

## Q3. Why is `default` important in an FSM?

It provides defined behavior for unused or unexpected state encodings.

---

## Q4. How do you prevent FIFO overflow?

Only write when:

```verilog
wr_en && !full
```

---

## Q5. How do you prevent FIFO underflow?

Only read when:

```verilog
rd_en && !empty
```

---

## Q6. What is saturation?

Saturation means the value stops at its maximum or minimum boundary instead of wrapping around.

Example:

```text
255 → 255
```

instead of:

```text
255 → 0
```

---

## Q7. Is saturation always required?

No.

The required behavior depends on the specification.

---

## Q8. Why are default assignments useful in combinational logic?

They help ensure that outputs are assigned for all execution paths and prevent unintended inferred storage.

---

## Q9. How does reset improve robustness?

Reset establishes known initial states for required sequential elements.

---

## Q10. What is defensive RTL coding?

Writing RTL that explicitly handles boundary, invalid, and unexpected conditions rather than assuming all inputs and states are always valid.

---

# 45. Placement Scenario

### Interviewer:

> Your FSM has three states encoded using two bits. What happens if the state becomes `2'b11`?

### Answer:

There is an unused state encoding. A robust FSM should provide a recovery path, typically using a `default` branch that sends the FSM to a known safe state such as `IDLE`.

---

# 46. Placement Scenario 2

### Interviewer:

> Your FIFO is full and `wr_en=1`. What should happen?

### Answer:

The FIFO should not perform the write. A common implementation is:

```verilog
do_write = wr_en && !full;
```

This prevents overflow.

---

# 47. Placement Scenario 3

### Interviewer:

> Your counter reaches its maximum value. What should it do?

### Answer:

It depends on the specification. It may wrap around, saturate, hold, or generate an overflow indication. Robust RTL explicitly defines the required behavior instead of leaving it accidental.

---

# 48. Placement Scenario 4

### Interviewer:

> Why should you provide default assignments before a case statement?

### Answer:

It establishes safe values for outputs and helps ensure all combinational outputs have defined assignments, reducing the risk of unintended inferred latches.

---

# 49. Day 48 Assignment

Design a **robust 4-state controller**.

States:

```text
IDLE
LOAD
RUN
DONE
```

Use:

```verilog
localparam
```

for state names.

Requirements:

### 1. Reset

After reset:

```text
IDLE
```

### 2. Transitions

```text
IDLE → LOAD
LOAD → RUN
RUN  → DONE
DONE → IDLE
```

### 3. Illegal state

If the state is invalid:

```text
→ IDLE
```

### 4. Outputs

| State | busy | done |
| ----- | ---: | ---: |
| IDLE  |    0 |    0 |
| LOAD  |    0 |    0 |
| RUN   |    1 |    0 |
| DONE  |    0 |    1 |

### 5. Coding requirements

Use:

```text
localparam
nonblocking assignments
combinational next-state logic
default assignments
default FSM recovery
```

---

# 50. Advanced Assignment

Take one of your previous projects:

```text
101 detector
FIFO
Booth multiplier
clock divider
PWM
RAM
```

and perform a **robustness review**.

Make a table:

| Module  | Unexpected condition | Current behavior | Required behavior       |
| ------- | -------------------- | ---------------- | ----------------------- |
| FIFO    | write when full      | ?                | no write                |
| FIFO    | read when empty      | ?                | no read                 |
| FSM     | invalid state        | ?                | IDLE                    |
| Counter | maximum              | ?                | specification-dependent |
| Decoder | invalid command      | ?                | safe output + error     |

This is excellent placement preparation.

---

# 51. Day 48 Checklist

Before moving to Day 49:

```text
[ ] What is robustness?
[ ] Why is robustness important?
[ ] What is an illegal FSM state?
[ ] How do you recover from an illegal FSM state?
[ ] Why is default useful in case statements?
[ ] How do you prevent FIFO overflow?
[ ] How do you prevent FIFO underflow?
[ ] What is counter overflow?
[ ] What is saturation?
[ ] Why are default combinational assignments useful?
[ ] How does reset improve robustness?
[ ] What is defensive RTL coding?
[ ] How should invalid commands be handled?
```

---

# 52. Git Structure

```text
RTL_50_Days/
│
├── Day_44/
├── Day_45/
├── Day_46/
├── Day_47/
│
├── Day_48/
│   ├── README.md
│   │
│   ├── rtl/
│   │   ├── command_decoder.v
│   │   └── robust_controller.v
│   │
│   ├── tb/
│   │   ├── tb_command_decoder.v
│   │   └── tb_robust_controller.v
│   │
│   └── sim/
│
└── ...
```

Commit:

```bash
git add Day_48/
git commit -m "Day 48: Robust RTL design"
git push
```

---

# 53. Key Takeaways

### Robustness

```text
Unexpected condition
        ↓
Defined behavior
        ↓
Safe operation/recovery
```

### FSM

```verilog
default:
    next_state = IDLE;
```

### FIFO

```verilog
do_write = wr_en && !full;
do_read  = rd_en && !empty;
```

### Combinational logic

```verilog
always @(*) begin
    output = SAFE_DEFAULT;
    ...
end
```

### Counter

Explicitly define:

```text
overflow behavior
```

### Invalid input

Use:

```text
safe output
+
optional error indication
```

### Main principle

> **Never assume that only the normal case will happen. Define what the RTL should do at boundaries, invalid inputs, illegal states, and error conditions.**

---

# 54. Final Mental Model

```text
                    ROBUST RTL
                        |
        +---------------+---------------+
        |               |               |
        v               v               v
   VALID INPUTS    BOUNDARY CASES   INVALID CASES
        |               |               |
        v               v               v
    Normal          Explicit         Safe recovery
    behavior        handling         / error flag
        \               |               /
         \              |              /
          +-------------+-------------+
                        |
                        v
                Predictable RTL
```

**Day 48 complete.**

Next in the roadmap: **Day 49 — Readability**, where we will learn how to make RTL easy for another engineer to understand, review, debug, and maintain.
