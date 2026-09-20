# Day 37 — FSM Flowchart: Single-Way Traffic Light FSM

## 1. Objective

Learn how to convert an **FSM flowchart** into synthesizable Verilog RTL.

### Assignment from the 50-Day RTL roadmap

> Design a **single-way traffic light FSM**.

We will design:

**GREEN → YELLOW → RED → GREEN**

The FSM changes state when `timer_done = 1`.

---

# 2. What is an FSM Flowchart?

An **FSM (Finite State Machine)** is a sequential circuit that:

* has a finite number of states,
* changes state according to inputs,
* produces outputs according to the current state or inputs.

An FSM flowchart represents the behavior using:

* **states**
* **decisions**
* **transitions**
* **outputs/actions**

For our traffic light:

```text
          +---------+
          |  GREEN  |
          +---------+
               |
          timer_done
               |
               v
          +---------+
          | YELLOW  |
          +---------+
               |
          timer_done
               |
               v
          +---------+
          |   RED   |
          +---------+
               |
          timer_done
               |
               v
          +---------+
          |  GREEN  |
          +---------+
```

---

# 3. Traffic Light States

We have three states.

| State  | Meaning                   |
| ------ | ------------------------- |
| GREEN  | Vehicles can move         |
| YELLOW | Warning / prepare to stop |
| RED    | Vehicles must stop        |

We use 2 bits to encode the three states.

```text
GREEN  = 00
YELLOW = 01
RED    = 10
```

`11` is unused and will be recovered to GREEN.

---

# 4. State Transition Table

The transition depends on `timer_done`.

| Current State | timer_done | Next State |
| ------------- | ---------: | ---------- |
| GREEN         |          0 | GREEN      |
| GREEN         |          1 | YELLOW     |
| YELLOW        |          0 | YELLOW     |
| YELLOW        |          1 | RED        |
| RED           |          0 | RED        |
| RED           |          1 | GREEN      |

The important idea is:

```text
timer_done = 0
        ↓
Stay in current state

timer_done = 1
        ↓
Move to next state
```

---

# 5. Output Table

The traffic-light outputs are:

* `green`
* `yellow`
* `red`

Only one light should be ON at a time.

| State  | Green | Yellow | Red |
| ------ | ----: | -----: | --: |
| GREEN  |     1 |      0 |   0 |
| YELLOW |     0 |      1 |   0 |
| RED    |     0 |      0 |   1 |

This is effectively a **one-hot output condition**.

---

# 6. FSM Architecture

A standard FSM can be divided into three parts:

```text
                  +----------------+
                  |                |
       input ---->| Next-State     |
                  | Logic          |
                  +-------+--------+
                          |
                          v
                  +----------------+
             clk  | State Register |
                  +-------+--------+
                          |
                          v
                  +----------------+
                  | Output Logic   |
                  +-------+--------+
                          |
                          v
                     Outputs
```

For our design:

```text
timer_done
     |
     v
+-------------+
| Next State  |
|   Logic     |
+------+------+
       |
       v
+-------------+
|   State     |
|  Register   |
+------+------+
       |
       v
+-------------+
| Output      |
|   Logic     |
+-------------+
       |
       +----> green
       +----> yellow
       +----> red
```

---

# 7. Moore FSM

Our traffic light is a **Moore FSM**.

Why?

Because the outputs depend only on the **current state**.

```text
GREEN  → green=1
YELLOW → yellow=1
RED    → red=1
```

The `timer_done` input controls the state transition but does not directly control the light outputs.

Therefore:

```text
Output = f(Current State)
```

---

# 8. Verilog RTL

Create:

```text
day37_traffic_light.v
```

## Complete RTL

```verilog
module traffic_light_fsm (
    input  wire clk,
    input  wire reset,
    input  wire timer_done,

    output reg green,
    output reg yellow,
    output reg red
);

    // State encoding
    localparam GREEN  = 2'b00;
    localparam YELLOW = 2'b01;
    localparam RED    = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    //==================================================
    // State Register
    //==================================================
    always @(posedge clk) begin
        if (reset)
            state <= GREEN;
        else
            state <= next_state;
    end

    //==================================================
    // Next-State Logic
    //==================================================
    always @(*) begin

        // Default: remain in current state
        next_state = state;

        case (state)

            GREEN: begin
                if (timer_done)
                    next_state = YELLOW;
            end

            YELLOW: begin
                if (timer_done)
                    next_state = RED;
            end

            RED: begin
                if (timer_done)
                    next_state = GREEN;
            end

            default: begin
                next_state = GREEN;
            end

        endcase
    end

    //==================================================
    // Output Logic
    //==================================================
    always @(*) begin

        // Default outputs
        green  = 1'b0;
        yellow = 1'b0;
        red    = 1'b0;

        case (state)

            GREEN: begin
                green = 1'b1;
            end

            YELLOW: begin
                yellow = 1'b1;
            end

            RED: begin
                red = 1'b1;
            end

            default: begin
                green = 1'b1;
            end

        endcase
    end

endmodule
```

---

# 9. Why `timer_done`?

A real traffic light should not change state on every FPGA clock.

For example:

```text
100 MHz FPGA clock
```

would make:

```text
GREEN
YELLOW
RED
GREEN
...
```

change extremely quickly.

Instead, another circuit can generate a slower signal:

```text
100 MHz clock
      |
      v
Timer / Counter
      |
      v
timer_done
      |
      v
Traffic FSM
```

For example:

```text
GREEN  → wait 30 seconds
YELLOW → wait 5 seconds
RED    → wait 30 seconds
```

The Day 37 FSM focuses on the **control FSM**. The timer itself can be designed separately.

This is an important RTL design principle:

> Separate timing/counting logic from control-state logic when practical.

---

# 10. Truth-Table Verification

The state transition logic can be verified directly.

## GREEN

| State | timer_done | Next State |
| ----- | ---------: | ---------- |
| GREEN |          0 | GREEN      |
| GREEN |          1 | YELLOW     |

## YELLOW

| State  | timer_done | Next State |
| ------ | ---------: | ---------- |
| YELLOW |          0 | YELLOW     |
| YELLOW |          1 | RED        |

## RED

| State | timer_done | Next State |
| ----- | ---------: | ---------- |
| RED   |          0 | RED        |
| RED   |          1 | GREEN      |

Output verification:

| State  |  G |  Y |  R |
| ------ | -: | -: | -: |
| GREEN  |  1 |  0 |  0 |
| YELLOW |  0 |  1 |  0 |
| RED    |  0 |  0 |  1 |

Therefore:

```text
G + Y + R = 1
```

for every valid state.

---

# 11. Testbench

Create:

```text
tb_traffic_light.v
```

```verilog
`timescale 1ns/1ps

module tb_traffic_light;

    reg clk;
    reg reset;
    reg timer_done;

    wire green;
    wire yellow;
    wire red;

    // DUT
    traffic_light_fsm uut (
        .clk(clk),
        .reset(reset),
        .timer_done(timer_done),
        .green(green),
        .yellow(yellow),
        .red(red)
    );

    // 10 ns clock period
    always #5 clk = ~clk;

    initial begin

        $dumpfile("traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);

        clk = 1'b0;
        reset = 1'b1;
        timer_done = 1'b0;

        // Reset
        #12;

        reset = 1'b0;

        // GREEN -> YELLOW
        #8;
        timer_done = 1'b1;

        #10;
        timer_done = 1'b0;

        // YELLOW -> RED
        #10;
        timer_done = 1'b1;

        #10;
        timer_done = 1'b0;

        // RED -> GREEN
        #10;
        timer_done = 1'b1;

        #10;
        timer_done = 1'b0;

        #20;

        $finish;
    end

    initial begin
        $monitor(
            "Time=%0t | reset=%b timer_done=%b | G=%b Y=%b R=%b",
            $time,
            reset,
            timer_done,
            green,
            yellow,
            red
        );
    end

endmodule
```

---

# 12. Directory Structure

Create:

```text
Day_37/
├── README.md
├── rtl/
│   └── traffic_light_fsm.v
├── tb/
│   └── tb_traffic_light.v
└── sim/
```

---

# 13. Run on Ubuntu

Go to your Day 37 directory:

```bash
cd ~/RTL_50_Days/Day_37
```

Compile:

```bash
iverilog -o sim/traffic_light \
    rtl/traffic_light_fsm.v \
    tb/tb_traffic_light.v
```

Run:

```bash
vvp sim/traffic_light
```

You should see transitions similar to:

```text
Time=... | reset=1 timer_done=0 | G=1 Y=0 R=0
Time=... | reset=0 timer_done=0 | G=1 Y=0 R=0
Time=... | reset=0 timer_done=1 | G=1 Y=0 R=0
Time=... | reset=0 timer_done=0 | G=0 Y=1 R=0
Time=... | reset=0 timer_done=1 | G=0 Y=1 R=0
Time=... | reset=0 timer_done=0 | G=0 Y=0 R=1
Time=... | reset=0 timer_done=1 | G=0 Y=0 R=1
Time=... | reset=0 timer_done=0 | G=1 Y=0 R=0
```

Generate:

```text
traffic_light.vcd
```

Then open GTKWave:

```bash
gtkwave traffic_light.vcd
```

Add:

```text
clk
reset
timer_done
green
yellow
red
```

---

# 14. Expected Waveform

The sequence should be:

```text
RESET
  |
  v
GREEN
  |
timer_done
  |
  v
YELLOW
  |
timer_done
  |
  v
RED
  |
timer_done
  |
  v
GREEN
```

So the light sequence is:

```text
🟢 → 🟡 → 🔴 → 🟢 → 🟡 → 🔴 ...
```

---

# 15. Important RTL Concept: State Register

This part:

```verilog
always @(posedge clk) begin
    if (reset)
        state <= GREEN;
    else
        state <= next_state;
end
```

is the **sequential part**.

It stores the current state.

Therefore:

```text
state register = memory
```

---

# 16. Important RTL Concept: Next-State Logic

This part:

```verilog
always @(*) begin

    next_state = state;

    case (state)

        GREEN:
            if (timer_done)
                next_state = YELLOW;

        YELLOW:
            if (timer_done)
                next_state = RED;

        RED:
            if (timer_done)
                next_state = GREEN;

        default:
            next_state = GREEN;

    endcase
end
```

is **combinational logic**.

It determines:

```text
Current State + Input
          ↓
      Next State
```

---

# 17. Important RTL Concept: Output Logic

```verilog
always @(*) begin

    green  = 1'b0;
    yellow = 1'b0;
    red    = 1'b0;

    case (state)

        GREEN:
            green = 1'b1;

        YELLOW:
            yellow = 1'b1;

        RED:
            red = 1'b1;

        default:
            green = 1'b1;

    endcase

end
```

This is also combinational logic.

It implements:

```text
Current State
     |
     v
Output Decoder
     |
     +----> Green
     +----> Yellow
     +----> Red
```

---

# 18. Why Use `localparam`?

We could write:

```verilog
2'b00
2'b01
2'b10
```

everywhere.

But that is less readable.

Instead:

```verilog
localparam GREEN  = 2'b00;
localparam YELLOW = 2'b01;
localparam RED    = 2'b10;
```

Now:

```verilog
if (state == GREEN)
```

is much easier to understand.

This is especially important in large RTL projects.

---

# 19. Why `<=` for the State Register?

The state register is sequential logic:

```verilog
always @(posedge clk)
```

Therefore we use:

```verilog
state <= next_state;
```

not:

```verilog
state = next_state;
```

The nonblocking assignment models the flip-flop behavior correctly.

Remember:

```text
Combinational → =
Sequential    → <=
```

---

# 20. Why `always @(*)`?

The next-state and output blocks are combinational.

Therefore:

```verilog
always @(*)
```

automatically includes the signals read by the block in its sensitivity list.

This prevents accidental simulation mismatches caused by incomplete sensitivity lists.

---

# 21. Invalid-State Recovery

We have:

```text
00 = GREEN
01 = YELLOW
10 = RED
11 = unused
```

If the FSM somehow reaches:

```text
11
```

the `default` case sends it to:

```text
GREEN
```

Therefore:

```verilog
default:
    next_state = GREEN;
```

This improves FSM robustness.

---

# 22. Moore vs Mealy

## Moore FSM

Output depends on:

```text
Current State
```

Example:

```text
GREEN  → green light
YELLOW → yellow light
RED    → red light
```

## Mealy FSM

Output depends on:

```text
Current State + Input
```

General form:

```text
Output = f(State, Input)
```

For our traffic light:

```text
Output = f(State)
```

so it is a **Moore FSM**.

---

# 23. Common Interview Question

### Q1. What is an FSM?

An FSM is a sequential model having a finite number of states, where transitions between states depend on inputs and outputs are generated according to the FSM definition.

---

### Q2. What are the two major types of FSM?

```text
1. Moore
2. Mealy
```

---

### Q3. What is the difference?

| Moore                         | Mealy                           |
| ----------------------------- | ------------------------------- |
| Output depends on state       | Output depends on state + input |
| Output changes with state     | Output can change with input    |
| Often simpler output behavior | Can respond faster to inputs    |

---

### Q4. Why is our traffic light a Moore FSM?

Because:

```text
green/yellow/red outputs
```

depend only on the current state.

---

### Q5. Why do we need a state register?

Because the FSM needs memory to remember its current state.

---

### Q6. What does `timer_done` do?

It tells the FSM that the current light interval has completed and that it may transition to the next state.

---

### Q7. Why is `default` important?

It provides recovery from unused or illegal state encodings.

---

### Q8. Why use `localparam` for states?

For readable and maintainable state encoding.

---

### Q9. What happens if `timer_done = 0`?

The FSM remains in the current state.

```text
next_state = state
```

---

### Q10. What happens after reset?

The FSM enters:

```text
GREEN
```

because:

```verilog
if (reset)
    state <= GREEN;
```

---

# 24. Placement-Level Questions

### Question 1

**How many flip-flops are required for three states using binary encoding?**

We need:

$$
\lceil\log_2(3)\rceil = 2
$$

Therefore:

```text
2 flip-flops
```

---

### Question 2

Why isn't 1 flip-flop enough?

One flip-flop provides:

$$
2^1=2
$$

states.

But we need three states.

Therefore two flip-flops are required.

---

### Question 3

How many unused binary states exist?

With 2 bits:

$$
2^2=4
$$

states are possible.

We use:

```text
00
01
10
```

Unused:

```text
11
```

Therefore there is:

```text
1 unused state
```

---

### Question 4

What is the advantage of separating the FSM into three blocks?

It clearly separates:

```text
State memory
Next-state logic
Output logic
```

which improves readability, debugging, and synthesis understanding.

---

# 25. Practice Questions

## Basic

1. What is an FSM?
2. What is a state?
3. What is a state transition?
4. What is a Moore FSM?
5. What is a Mealy FSM?
6. Why is a traffic light a good FSM example?

## RTL

7. Why is the state register sequential?
8. Why is next-state logic combinational?
9. Why do we use `<=` in the state register?
10. Why use `always @(*)`?
11. Why use `localparam`?
12. Why is `default` useful?

## Placement

13. How many flip-flops are needed for 5 states?
14. How many binary states are possible with 3 flip-flops?
15. What happens if an FSM enters an illegal state?
16. What is state encoding?
17. Compare binary and one-hot state encoding.

---

# 26. Assignment

Modify the traffic light FSM so that each state has a different duration.

Required behavior:

```text
GREEN  → 30 seconds
YELLOW → 5 seconds
RED    → 30 seconds
```

Architecture:

```text
             +-------------+
clock ------>| Timer       |
             +------+------+
                    |
              timer_done
                    |
                    v
             +-------------+
             | Traffic FSM |
             +------+------+
                    |
          +---------+---------+
          |         |         |
        GREEN     YELLOW      RED
```

Do **not** put the entire timer inside the state-transition logic initially.

Keep:

```text
Timer
```

and

```text
FSM
```

as separate modules.

This will prepare you for larger RTL designs.

---

# 27. Recommended Git Structure

```text
RTL_50_Days/
│
├── Day_37/
│   ├── README.md
│   │
│   ├── rtl/
│   │   └── traffic_light_fsm.v
│   │
│   ├── tb/
│   │   └── tb_traffic_light.v
│   │
│   └── sim/
│
└── ...
```

Git commands:

```bash
git add Day_37/
git commit -m "Day 37: FSM Flowchart Traffic Light"
git push
```

---

# 28. Day 37 Key Takeaways

You should now understand:

```text
FSM
 ↓
States
 ↓
State transitions
 ↓
State register
 ↓
Next-state logic
 ↓
Output logic
 ↓
Verilog implementation
 ↓
Simulation
```

The traffic light FSM is:

```text
             timer_done
GREEN -----------------> YELLOW
  ^                         |
  |                         |
  |                     timer_done
  |                         |
  |                         v
  +----------------------- RED
          timer_done
```

### Most important RTL pattern

```verilog
// State register
always @(posedge clk) begin
    if (reset)
        state <= GREEN;
    else
        state <= next_state;
end

// Next-state logic
always @(*) begin
    next_state = state;

    case (state)
        ...
    endcase
end

// Output logic
always @(*) begin
    ...
end
```

This **three-part FSM structure** is one of the most important coding patterns for RTL and placement interviews.
