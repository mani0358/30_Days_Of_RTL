# Day 46 — Low Coupling in RTL Design

## 1. Objective

Learn the RTL design principle of **Low Coupling**.

By the end of Day 46, you should understand:

* What coupling means
* What low coupling means
* Difference between coupling and cohesion
* Why excessive coupling is dangerous
* How modules should communicate
* How interfaces reduce dependencies
* How to design reusable RTL modules
* How to apply low coupling to Verilog
* How high cohesion + low coupling improve RTL architecture

---

# 2. Roadmap Connection

Day 45:

```text
HIGH COHESION
```

Day 46:

```text
LOW COUPLING
```

Together:

```text
        GOOD RTL ARCHITECTURE
                 |
        +--------+--------+
        |                 |
        v                 v
 High Cohesion       Low Coupling
        |                 |
 Focused modules     Independent modules
```

---

# 3. What is Coupling?

**Coupling** describes how strongly one module depends on another module.

In simple terms:

> Coupling tells us how much one piece of RTL depends on another piece of RTL.

For example:

```text
Module A
   |
   | depends heavily
   v
Module B
```

has high coupling.

If:

```text
Module A
   |
   | simple interface
   v
Module B
```

and A does not need to know B's internal implementation, the design has lower coupling.

---

# 4. Simple Analogy

Consider two machines.

### High coupling

Machine A directly depends on many internal components of Machine B:

```text
A
 |
 +---- B internal motor
 |
 +---- B internal sensor
 |
 +---- B internal controller
 |
 +---- B internal wiring
```

Changing B becomes difficult because A depends on its internal details.

### Low coupling

A uses a defined interface:

```text
A
 |
 | interface
 v
+----------+
| Machine B|
+----------+
```

A only needs to know:

```text
input
output
control
```

It doesn't need to know B's internal implementation.

---

# 5. RTL Example

Suppose we have:

```text
CPU
 |
 v
FIFO
 |
 v
UART
```

A well-designed architecture might be:

```text
CPU
 |
 | data / control interface
 v
FIFO
 |
 | data / valid
 v
UART
```

The CPU should not directly manipulate:

```text
FIFO internal memory
FIFO write pointer
FIFO read pointer
```

Those are FIFO implementation details.

---

# 6. High Coupling Example

Consider:

```verilog
module cpu (
    input wire clk
);

    reg [7:0] fifo_memory [0:15];
    reg [3:0] fifo_wr_ptr;
    reg [3:0] fifo_rd_ptr;

    // CPU directly manipulating FIFO internals

endmodule
```

This is poor architecture.

The CPU is now coupled to:

```text
FIFO memory
FIFO write pointer
FIFO read pointer
```

If the FIFO implementation changes, CPU logic may also need modification.

---

# 7. Low-Coupling Version

Instead, create a FIFO module:

```verilog
module fifo (
    input  wire       clk,
    input  wire       reset,
    input  wire       wr_en,
    input  wire [7:0] wr_data,
    input  wire       rd_en,
    output wire [7:0] rd_data,
    output wire       full,
    output wire       empty
);

    // FIFO implementation

endmodule
```

The CPU communicates through:

```text
wr_en
wr_data
rd_en
rd_data
full
empty
```

The CPU does not know:

```text
memory array
write pointer
read pointer
```

This reduces coupling.

---

# 8. Interface vs Implementation

This is one of the most important concepts.

## Interface

What the module exposes:

```text
inputs
outputs
control signals
protocol
```

## Implementation

How the module internally works:

```text
registers
counters
FSM
memory
pointers
internal logic
```

A low-coupled design allows other modules to depend mainly on the **interface**, not the implementation.

---

# 9. Example

Suppose:

```text
FIFO
```

has this interface:

```text
wr_en
wr_data
rd_en
rd_data
full
empty
```

Internally it could use:

```text
Implementation A:
counter-based FIFO
```

or:

```text
Implementation B:
pointer-based FIFO
```

or:

```text
Implementation C:
FPGA BRAM FIFO
```

The surrounding module can continue using the same interface.

This is a major advantage of low coupling.

---

# 10. High Coupling vs Low Coupling

| High Coupling                       | Low Coupling                |
| ----------------------------------- | --------------------------- |
| Strong dependency                   | Limited dependency          |
| Modules know implementation details | Modules use interfaces      |
| Harder modification                 | Easier modification         |
| Harder reuse                        | Better reuse                |
| Changes propagate easily            | Changes are more localized  |
| Harder testing                      | Easier module-level testing |

---

# 11. Day 45 vs Day 46

This distinction is very important for interviews.

## High Cohesion

Looks **inside a module**.

Question:

> Are the functions inside this module closely related?

Example:

```text
FIFO
├── memory
├── read pointer
├── write pointer
├── full
└── empty
```

These belong together.

---

## Low Coupling

Looks **between modules**.

Question:

> How strongly does one module depend on another?

Example:

```text
CPU ---> FIFO
```

The CPU should depend on the FIFO interface rather than its internal implementation.

---

# 12. Combined Architecture

The ideal goal is:

```text
        HIGH COHESION
              +
        LOW COUPLING
              |
              v
       MODULAR RTL DESIGN
```

Example:

```text
              TOP
               |
       +-------+-------+
       |       |       |
       v       v       v
     FIFO     UART    CRC
       |       |       |
    focused focused focused
    logic     logic    logic
```

and the modules communicate through clean interfaces.

---

# 13. Example: Coupled Counter + PWM

Consider:

```verilog
module pwm (
    input wire clk,
    input wire [7:0] external_counter,
    input wire [7:0] duty,
    output reg pwm_out
);

    always @(posedge clk) begin
        if (external_counter < duty)
            pwm_out <= 1'b1;
        else
            pwm_out <= 1'b0;
    end

endmodule
```

This PWM depends on an externally provided counter.

Another module must know that PWM requires a counter in exactly this format.

This creates unnecessary dependency.

---

# 14. Better PWM

Let PWM own its counter:

```verilog
module pwm #(
    parameter WIDTH = 8
)(
    input wire             clk,
    input wire             reset,
    input wire [WIDTH-1:0] duty,
    output reg             pwm_out
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

Now the PWM module owns:

```text
counter
comparison
PWM output
```

This also reinforces **high cohesion** from Day 45.

---

# 15. Module Interface

A clean interface could look like:

```text
             PWM
              |
       +------+------+
       |             |
     duty           clk
       |             |
       v             v
   +--------------------+
   |        PWM         |
   +--------------------+
            |
            v
         pwm_out
```

The outside world only needs:

```text
clk
reset
duty
pwm_out
```

It does not need to know the internal counter.

---

# 16. Why Internal Signals Should Usually Stay Internal

Suppose a FIFO internally contains:

```verilog
reg [3:0] wr_ptr;
reg [3:0] rd_ptr;
```

It is generally unnecessary for unrelated modules to access these signals directly.

Instead expose:

```text
full
empty
```

For example:

```text
Outside world
     |
     +-- wr_en
     +-- wr_data
     +-- rd_en
     |
     v
   FIFO
     |
     +-- rd_data
     +-- full
     +-- empty
```

This hides implementation details.

---

# 17. Interface Signals

A good module interface often contains:

### Data

```text
data_in
data_out
```

### Control

```text
enable
start
stop
write
read
```

### Status

```text
busy
done
valid
ready
full
empty
```

These signals form a clean contract between modules.

---

# 18. Example: Start/Done Interface

Suppose we have a multiplier.

Instead of exposing:

```text
partial_product
internal_counter
shift_register
accumulator
```

we expose:

```text
start
multiplicand
multiplier
product
busy
done
```

Architecture:

```text
             start
               |
               v
       +---------------+
 A --->|               |
 B --->|  MULTIPLIER   |---> product
       |               |
       +---------------+
          |        |
         busy     done
```

The surrounding system doesn't need to understand the multiplication algorithm.

This is low coupling.

---

# 19. Example: Day 43 Booth Multiplier

Our Day 43 Booth multiplier contains:

```text
A
M
Q
Q-1
count
temporary registers
```

These are internal implementation details.

The external interface is:

```text
clk
reset
start
multiplicand
multiplier
product
busy
done
```

A top-level module should use this interface rather than manipulating:

```text
A
Q
Q-1
```

directly.

That is a practical example of low coupling.

---

# 20. Coupling Through Shared Signals

Consider:

```text
Module A
   |
   +---- signal1
   +---- signal2
   +---- signal3
   +---- signal4
   +---- signal5
   +---- signal6
   |
   v
Module B
```

If Module B requires many internal details from A, the modules become tightly connected.

A cleaner interface might be:

```text
Module A
   |
   | request/data
   v
Module B
   |
   | response/status
   v
Module A
```

---

# 21. Ready/Valid Interface

The Day 33 ready/valid interface is an excellent example of reducing coupling.

```text
VALID
READY
DATA
```

A producer doesn't need to know the internal implementation of the consumer.

The basic transfer condition is:

$$
TRANSFER = VALID \land READY
$$

Truth table:

| VALID | READY | TRANSFER |
| ----: | ----: | -------: |
|     0 |     0 |        0 |
|     0 |     1 |        0 |
|     1 |     0 |        0 |
|     1 |     1 |        1 |

The interface defines the communication contract.

---

# 22. Why Interfaces Are Powerful

Suppose:

```text
Producer
```

sends data to:

```text
Consumer
```

The producer only needs to know:

```text
DATA
VALID
READY
```

The consumer can internally contain:

```text
FIFO
FSM
BRAM
registers
processing logic
```

The producer doesn't need to know any of that.

This is low coupling.

---

# 23. Bad Design Example

Avoid designs like:

```verilog
module top;

    reg [7:0] fifo_memory [0:15];

    // UART directly accesses FIFO memory
    // CRC directly accesses FIFO pointers
    // CPU directly changes FIFO state

endmodule
```

Now multiple blocks depend on internal implementation details.

Changing FIFO architecture becomes dangerous.

---

# 24. Better Design

```text
                    TOP
                     |
       +-------------+-------------+
       |             |             |
       v             v             v
     CPU            FIFO          UART
       |             |             |
       |       clean interface     |
       +-------------+-------------+
```

Each module owns its internal state.

---

# 25. Low Coupling Through Encapsulation

Encapsulation means:

> Keep internal implementation details inside the module and expose only what other modules need.

Example:

```text
+--------------------------+
|          FIFO            |
|                          |
|  memory                  |
|  wr_ptr                  |
|  rd_ptr                  |
|  count                   |
|                          |
|--------------------------|
| wr_en                    |
| wr_data                  |
| rd_en                    |
| rd_data                  |
| full                     |
| empty                    |
+--------------------------+
```

The boundary separates:

```text
interface
```

from:

```text
implementation
```

---

# 26. Coupling and Reusability

High coupling makes reuse harder.

Suppose:

```text
UART module
```

directly depends on:

```text
specific FIFO memory array
specific pointer width
specific system counter
```

You cannot easily reuse it.

But if UART simply expects:

```text
data
valid
ready
```

it can work with many different sources.

---

# 27. Parameterization and Coupling

Parameters can also help avoid unnecessary dependencies.

Example:

```verilog
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
);
```

The surrounding module doesn't need to know the FIFO's internal implementation.

It only configures:

```text
DATA_WIDTH
DEPTH
```

---

# 28. Avoid Direct Internal Access

Bad:

```text
CPU → FIFO.memory[5]
```

Better:

```text
CPU → FIFO interface
```

For example:

```text
CPU
 |
 | write request
 v
FIFO
 |
 | internal memory operation
 v
memory
```

The FIFO owns its memory.

---

# 29. Practical RTL Example

Let's build two modules:

```text
producer
consumer
```

The producer generates data.

The consumer receives it.

Use a simple:

```text
valid/ready/data
```

interface.

---

# 30. Producer

Create:

```text
rtl/producer.v
```

```verilog
module producer (
    input  wire       clk,
    input  wire       reset,
    input  wire       ready,
    output reg        valid,
    output reg [7:0]  data
);

    always @(posedge clk) begin

        if (reset) begin
            valid <= 1'b0;
            data  <= 8'd0;
        end

        else begin

            if (!valid || ready) begin
                valid <= 1'b1;
                data  <= data + 8'd1;
            end

        end

    end

endmodule
```

The producer doesn't know what the consumer does internally.

It only knows:

```text
ready
```

---

# 31. Consumer

Create:

```text
rtl/consumer.v
```

```verilog
module consumer (
    input  wire       clk,
    input  wire       reset,
    input  wire       valid,
    input  wire [7:0] data,
    output wire       ready
);

    assign ready = 1'b1;

    always @(posedge clk) begin

        if (!reset && valid && ready)
            $display(
                "Consumer received: %0d",
                data
            );

    end

endmodule
```

The consumer doesn't know how the producer generated the data.

---

# 32. Top-Level Connection

```verilog
module top (
    input wire clk,
    input wire reset
);

    wire       valid;
    wire       ready;
    wire [7:0] data;

    producer producer_inst (
        .clk   (clk),
        .reset (reset),
        .ready (ready),
        .valid (valid),
        .data  (data)
    );

    consumer consumer_inst (
        .clk   (clk),
        .reset (reset),
        .valid (valid),
        .data  (data),
        .ready (ready)
    );

endmodule
```

Notice the important point:

```text
producer ↔ interface ↔ consumer
```

Neither module needs access to the other's internal registers.

---

# 33. Testbench

Create:

```text
tb/tb_top.v
```

```verilog
`timescale 1ns/1ps

module tb_top;

    reg clk;
    reg reset;

    top uut (
        .clk   (clk),
        .reset (reset)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("day46.vcd");
        $dumpvars(0, tb_top);

        clk   = 1'b0;
        reset = 1'b1;

        #20;

        reset = 1'b0;

        #150;

        $finish;

    end

endmodule
```

---

# 34. Compile

Create the simulation directory:

```bash
mkdir -p sim
```

Compile:

```bash
iverilog -o sim/day46_test \
    rtl/producer.v \
    rtl/consumer.v \
    rtl/top.v \
    tb/tb_top.v
```

Run:

```bash
vvp sim/day46_test
```

You should see the consumer receiving a sequence of values.

Then:

```bash
gtkwave day46.vcd
```

---

# 35. Functional Verification

For the ready/valid interface:

$$
TRANSFER=VALID \land READY
$$

Truth table:

| VALID | READY | Data transfer? |
| ----: | ----: | -------------: |
|     0 |     0 |             No |
|     0 |     1 |             No |
|     1 |     0 |             No |
|     1 |     1 |            Yes |

This is the key verification table for the interface.

---

# 36. Important Protocol Rule

When using a standard ready/valid interface:

> If `VALID=1` and `READY=0`, the producer must keep the transaction available until the consumer accepts it.

Conceptually:

```text
VALID = 1
READY = 0
       ↓
WAIT
       ↓
READY = 1
       ↓
TRANSFER
```

This prevents data from being lost.

---

# 37. High Cohesion + Low Coupling Example

Consider:

```text
                TOP
                 |
       +---------+---------+
       |                   |
       v                   v
   PRODUCER             CONSUMER
       |                   ^
       |                   |
       +--- VALID/DATA ----+
             READY
```

Producer:

```text
high cohesion
```

because it handles production.

Consumer:

```text
high cohesion
```

because it handles consumption.

Connection:

```text
low coupling
```

because they communicate through a small defined interface.

---

# 38. What NOT to Do

Avoid:

```text
producer accessing consumer internal registers
```

Avoid:

```text
consumer accessing producer internal counters
```

Avoid:

```text
top modifying internal FIFO pointers
```

Avoid exposing unnecessary signals.

Instead:

```text
module
 |
 +--- required inputs
 |
 +--- required outputs
 |
 +--- internal implementation
```

---

# 39. Interview Questions

## Q1. What is coupling?

Coupling is the degree of dependency between modules or components.

---

## Q2. What is low coupling?

Low coupling means modules have limited dependency on one another and communicate through well-defined interfaces.

---

## Q3. Why is low coupling important?

It improves:

* reuse
* maintainability
* debugging
* verification
* modification
* scalability

---

## Q4. What is the difference between cohesion and coupling?

**Cohesion** focuses on the relationship between functions **inside a module**.

**Coupling** focuses on the dependency **between modules**.

---

## Q5. Give an RTL example of low coupling.

A FIFO exposing:

```text
wr_en
wr_data
rd_en
rd_data
full
empty
```

while hiding its internal:

```text
memory
read pointer
write pointer
count
```

is a good example.

---

## Q6. Why should internal signals normally not be exposed?

Because external modules would become dependent on implementation details.

Changing the internal design could then require changes throughout the system.

---

## Q7. How can interfaces reduce coupling?

A clearly defined interface establishes a contract between modules and hides internal implementation details.

---

## Q8. Is low coupling the same as no coupling?

No.

Modules must communicate.

The goal is to minimize **unnecessary dependency**, not eliminate communication.

---

## Q9. Can two modules be highly cohesive and highly coupled?

Yes.

These are independent design properties.

A module can have a very focused internal responsibility while still being heavily dependent on another module.

The architectural goal is generally:

```text
High Cohesion
+
Low Coupling
```

---

## Q10. What is encapsulation in RTL?

Keeping implementation details internal to a module and exposing only the signals required by other modules.

---

# 40. Placement Scenario

Interviewer:

> "Your UART module directly accesses the internal memory array of your FIFO. Is this good architecture?"

Answer:

> No. This creates unnecessary coupling between UART and FIFO implementation details. The FIFO should expose a defined interface such as data, valid/ready, read/write controls, full and empty status. UART should communicate through that interface rather than accessing FIFO internals.

---

# 41. Placement Scenario 2

Interviewer:

> "Why is a standard interface useful?"

Answer:

> It separates the module's interface from its implementation. This allows the internal implementation to change without requiring unrelated modules to change.

---

# 42. Placement Scenario 3

Interviewer:

> "What happens if coupling is too high?"

Possible consequences include:

```text
harder modifications
harder debugging
reduced reuse
more dependencies
larger impact of changes
more complicated verification
```

---

# 43. Day 46 Assignment

Design:

```text
producer → FIFO → consumer
```

using separate modules.

Architecture:

```text
+----------+
| Producer |
+----------+
     |
     | valid/data
     v
+----------+
|   FIFO   |
+----------+
     |
     | valid/data
     v
+----------+
| Consumer |
+----------+
```

Requirements:

### Producer

Generate:

```text
0,1,2,3,...,15
```

### FIFO

Use an 8-bit data width and depth 8.

### Consumer

Read and display the data.

### Important requirement

The producer and consumer must **not access FIFO internal memory or pointers**.

They must communicate through the FIFO interface.

---

# 44. Advanced Assignment

Modify the Day 43 Booth multiplier so that a top-level module communicates with it only through:

```text
start
multiplicand
multiplier
busy
done
product
```

Do not access:

```text
A
M
Q
Q_minus_1
count
```

from the top level.

Explain why this is a low-coupling architecture.

---

# 45. Day 46 Checklist

Before moving to Day 47:

```text
[ ] What is coupling?
[ ] What is low coupling?
[ ] What is high coupling?
[ ] Difference between cohesion and coupling?
[ ] Why should internal signals remain internal?
[ ] What is an interface?
[ ] What is encapsulation?
[ ] How does low coupling improve reuse?
[ ] How does low coupling simplify debugging?
[ ] Why is VALID/READY a useful interface?
[ ] Why is high cohesion + low coupling desirable?
```

---

# 46. Git Structure

```text
RTL_50_Days/
│
├── Day_44/
│
├── Day_45/
│
├── Day_46/
│   ├── README.md
│   │
│   ├── rtl/
│   │   ├── producer.v
│   │   ├── consumer.v
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
git add Day_46/
git commit -m "Day 46: Low coupling in RTL design"
git push
```

---

# 47. Key Takeaways

Remember these points for placement:

### Cohesion

```text
Inside a module
```

Question:

> Do the functions belong together?

### Coupling

```text
Between modules
```

Question:

> How strongly do these modules depend on each other?

### Good RTL architecture

```text
        HIGH COHESION
              +
        LOW COUPLING
              |
              v
      MODULAR RTL DESIGN
```

### Best practice

Expose:

```text
interface
```

Hide:

```text
implementation
```

### Example

Instead of:

```text
UART → FIFO internal memory
```

use:

```text
UART
 |
 | interface
 v
FIFO
```

The most important rule for Day 46 is:

> **Modules should communicate through clean, well-defined interfaces rather than depending on each other's internal implementation.**
