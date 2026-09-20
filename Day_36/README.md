# Day 36 — FSM State Diagram — 101 Sequence Detector

## 📌 Topic

**Finite State Machine (FSM) — State Diagram**

## 🎯 Roadmap Objective

Learn how to design an FSM starting from a **state diagram**.

### Day 36 Assignment

Design a Verilog FSM that detects the sequence:

```text
101
```

The detector should generate an output when the input sequence `101` is detected.

---

# 1. Learning Objectives

By the end of Day 36, you should understand:

* What an FSM is.
* Why FSMs are used in RTL.
* States, transitions, inputs, and outputs.
* Moore vs Mealy FSMs.
* How to convert a requirement into a state diagram.
* How to design a `101` sequence detector.
* Overlapping sequence detection.
* State encoding.
* Next-state logic.
* Output logic.
* Sequential state registers.
* Verilog FSM coding style.
* FSM testbench verification.
* Common FSM interview questions.

---

# 2. What is an FSM?

FSM stands for:

**Finite State Machine**

An FSM is a sequential digital system that operates using a finite number of states.

The basic structure is:

```text
              ┌─────────────────┐
              │  Next-State     │
        ┌────►│     Logic       │◄──── Input
        │     └────────┬────────┘
        │              │
        │              ▼
        │       ┌─────────────┐
        │       │ State       │
        │       │ Register    │
        │       └──────┬──────┘
        │              │
        │              ▼
        │       ┌─────────────┐
        └───────│ Output Logic│
                └─────────────┘
```

An FSM remembers what happened previously through its current state.

---

# 3. Why Do We Need States?

Consider the requirement:

> Detect the serial bit sequence `101`.

If the current input is:

```text
1
```

we need to remember that the first bit of the desired sequence has been received.

Therefore:

```text
Input = 1
       ↓
Remember this condition
       ↓
State
```

If the next input is:

```text
0
```

we need to remember:

```text
Received 10
```

Then if the next input is:

```text
1
```

we have:

```text
101
```

and the detector should assert its output.

---

# 4. Sequence to Detect

Our target sequence is:

```text
101
```

We process one input bit per clock.

Example:

```text
Input:

1 0 1
│ │ │
│ │ └── third bit
│ └──── second bit
└────── first bit
```

When the third bit arrives:

```text
101
```

the output becomes `1`.

---

# 5. Moore vs Mealy FSM

There are two common FSM types.

## Moore FSM

Output depends only on the current state.

$$
\boxed{Output=f(State)}
$$

---

## Mealy FSM

Output depends on current state and current input.

$$
\boxed{Output=f(State,Input)}
$$

For a sequence detector, a Mealy implementation can assert the detection output on the transition that receives the final bit.

---

# 6. Which One Will We Use?

For today's `101` detector, we will use a:

**Mealy FSM**

because it allows the detector output to be asserted when the final input bit arrives.

Architecture:

```text
Input
  │
  ▼
┌──────────────────┐
│ Next State Logic │
└────────┬─────────┘
         │
         ▼
   State Register
         │
         ▼
┌──────────────────┐
│  Output Logic    │◄──── Input
└──────────────────┘
         │
         ▼
       Detect
```

---

# 7. Define the States

We need to remember how much of `101` has already been received.

Define:

```text
S0 = nothing useful received
S1 = received 1
S2 = received 10
```

Therefore:

```text
S0
 │
 │ 1
 ▼
S1
 │
 │ 0
 ▼
S2
 │
 │ 1
 ▼
DETECT
```

---

# 8. State Meaning

| State | Meaning                   |
| ----- | ------------------------- |
| `S0`  | No useful prefix detected |
| `S1`  | `1` received              |
| `S2`  | `10` received             |

The transition from `S2` with input `1` detects:

```text
101
```

---

# 9. State Diagram

For a Mealy FSM, transitions can be labelled:

```text
input / output
```

State diagram:

```text
                    1/0
              ┌─────────────┐
              │             ▼
           ┌─────┐       ┌─────┐
     0/0 ─►│ S0  │──────►│ S1  │
           └─────┘  1/0  └─────┘
             ▲             │
             │             │ 0/0
             │             ▼
             │           ┌─────┐
             │      ┌────│ S2  │
             │      │    └─────┘
             │      │      │
             │      │      │ 1/1
             │      │      ▼
             │      └──── S1
             │
             └──────── 0/0
```

The important transitions are:

```text
S0 --1/0--> S1
S1 --0/0--> S2
S2 --1/1--> S1
```

The `S2 → S1` transition is important for **overlapping detection**.

---

# 10. Why Does S2 + 1 Go to S1?

Suppose the input stream is:

```text
101
```

When we receive the final `1`, we detect:

```text
101
```

But that final `1` can also be the beginning of another sequence.

For example:

```text
10101
```

contains:

```text
101
  ↑
  another possible sequence
```

Therefore after detecting `101`, we should remember:

```text
1
```

which corresponds to:

```text
S1
```

This enables overlapping detection.

---

# 11. Complete Transition Table

Let:

```text
X = input
```

and:

```text
Z = detect
```

| Current State |  X | Next State |  Z |
| ------------- | -: | ---------- | -: |
| S0            |  0 | S0         |  0 |
| S0            |  1 | S1         |  0 |
| S1            |  0 | S2         |  0 |
| S1            |  1 | S1         |  0 |
| S2            |  0 | S0         |  0 |
| S2            |  1 | S1         |  1 |

This table is the most important design step.

---

# 12. Verify the Table

### State S0

No useful prefix exists.

If:

```text
X = 0
```

we remain in S0.

If:

```text
X = 1
```

we have received the first bit:

```text
1
```

so:

```text
S0 → S1
```

---

### State S1

We have:

```text
1
```

If:

```text
X = 0
```

we now have:

```text
10
```

so:

```text
S1 → S2
```

If:

```text
X = 1
```

the newest `1` can still represent the beginning of a sequence:

```text
S1 → S1
```

---

### State S2

We have:

```text
10
```

If:

```text
X = 1
```

we have:

```text
101
```

Therefore:

```text
detect = 1
```

and:

```text
S2 → S1
```

If:

```text
X = 0
```

the useful sequence is lost:

```text
S2 → S0
```

---

# 13. Verilog RTL

Create:

```text
101_sequence_detector.v
```

```verilog
module sequence_detector_101 (
    input  wire clk,
    input  wire reset,
    input  wire din,
    output reg  detect
);

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    // State register
    always @(posedge clk) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-state and output logic
    always @(*) begin

        next_state = S0;
        detect     = 1'b0;

        case (state)

            S0: begin
                if (din)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1: begin
                if (din)
                    next_state = S1;
                else
                    next_state = S2;
            end

            S2: begin
                if (din) begin
                    next_state = S1;
                    detect     = 1'b1;
                end
                else begin
                    next_state = S0;
                end
            end

            default: begin
                next_state = S0;
                detect     = 1'b0;
            end

        endcase

    end

endmodule
```

---

# 14. Understanding the RTL

The design has three important pieces.

## 1. State declaration

```verilog
localparam S0 = 2'b00;
localparam S1 = 2'b01;
localparam S2 = 2'b10;
```

---

## 2. State register

```verilog
always @(posedge clk)
```

stores the current state.

Because this is sequential logic, we use:

```verilog
<=
```

not:

```verilog
=
```

---

## 3. Next-state/output logic

```verilog
always @(*)
```

calculates:

```text
next_state
detect
```

from:

```text
current state
input
```

---

# 15. Why Use `localparam` for States?

Instead of using magic numbers:

```verilog
if (state == 2'b01)
```

we use:

```verilog
if (state == S1)
```

This makes the RTL easier to read and maintain.

It also connects directly with the FSM state diagram.

---

# 16. Testbench

Create:

```text
tb_101_sequence_detector.v
```

```verilog
`timescale 1ns/1ps

module tb_101_sequence_detector;

    reg clk;
    reg reset;
    reg din;

    wire detect;

    sequence_detector_101 dut (
        .clk    (clk),
        .reset  (reset),
        .din    (din),
        .detect (detect)
    );

    always #5 clk = ~clk;

    task send_bit;
        input bit_value;
        begin
            @(negedge clk);
            din = bit_value;
        end
    endtask

    initial begin

        $dumpfile("sequence_101.vcd");
        $dumpvars(0, tb_101_sequence_detector);

        clk   = 1'b0;
        reset = 1'b1;
        din   = 1'b0;

        #12;

        reset = 1'b0;

        // 101
        send_bit(1);
        send_bit(0);
        send_bit(1);

        // 10101
        send_bit(0);
        send_bit(1);
        send_bit(0);
        send_bit(1);

        // Additional test pattern
        send_bit(1);
        send_bit(1);
        send_bit(0);
        send_bit(1);

        #20;

        $finish;

    end

    always @(posedge clk) begin
        $display(
            "TIME=%0t DIN=%b STATE=%b DETECT=%b",
            $time,
            din,
            dut.state,
            detect
        );
    end

endmodule
```

---

# 17. Ubuntu Directory

Create:

```bash
mkdir -p ~/RTL_50_Days/Day_36_FSM_State_Diagram
cd ~/RTL_50_Days/Day_36_FSM_State_Diagram
```

Files:

```text
README.md
101_sequence_detector.v
tb_101_sequence_detector.v
```

---

# 18. Compile

Run:

```bash
iverilog -o seq101_sim \
    101_sequence_detector.v \
    tb_101_sequence_detector.v
```

Then:

```bash
vvp seq101_sim
```

---

# 19. Generate Waveform

The testbench creates:

```text
sequence_101.vcd
```

Open:

```bash
gtkwave sequence_101.vcd
```

Add:

```text
clk
reset
din
dut.state
detect
```

---

# 20. Expected Detection

For input:

```text
101
```

the output should be:

```text
Input:   1 0 1
Detect:  0 0 1
```

The `1` occurs when the final bit of `101` is received.

---

# 21. Overlapping Detection

Consider:

```text
10101
```

There are two occurrences of:

```text
101
```

They are:

```text
10101
^^^

  ^^^
```

Therefore:

```text
Input:   1 0 1 0 1
Detect:  0 0 1 0 1
```

This is called:

**Overlapping sequence detection**

---

# 22. Non-Overlapping vs Overlapping

## Non-overlapping

After detecting:

```text
101
```

the FSM may return to S0.

```text
S2 --1/1--> S0
```

This prevents reuse of the final `1`.

---

## Overlapping

After detecting:

```text
101
```

the FSM goes to S1:

```text
S2 --1/1--> S1
```

because the final `1` can start another sequence.

For today's design:

$$
\boxed{\text{Overlapping detector}}
$$

---

# 23. Example: `10101`

Let's trace it.

Initial:

```text
State = S0
```

### Input 1

```text
S0 → S1
```

Sequence remembered:

```text
1
```

---

### Input 0

```text
S1 → S2
```

Sequence remembered:

```text
10
```

---

### Input 1

```text
S2 → S1
```

Detection:

```text
detect = 1
```

Sequence:

```text
101
```

---

### Input 0

```text
S1 → S2
```

Sequence:

```text
10
```

---

### Input 1

```text
S2 → S1
```

Detection:

```text
detect = 1
```

Second sequence:

```text
101
```

---

# 24. Verification Table

For input:

```text
10101
```

| Clock | Input | Current State | Next State | Detect |
| ----: | ----: | ------------- | ---------- | -----: |
|     1 |     1 | S0            | S1         |      0 |
|     2 |     0 | S1            | S2         |      0 |
|     3 |     1 | S2            | S1         |      1 |
|     4 |     0 | S1            | S2         |      0 |
|     5 |     1 | S2            | S1         |      1 |

Therefore:

```text
10101
```

produces:

```text
00101
```

at the detection output.

---

# 25. Another Verification Example

Input:

```text
110101
```

Find the occurrences:

```text
110101
  ^^^
```

and:

```text
110101
   ^^^
```

Actually the sequence occurrences are:

```text
110101
  101
    101
```

Therefore detection occurs at the corresponding third and fifth received bits.

Expected detection stream:

```text
Input:   1 1 0 1 0 1
Detect:  0 0 0 1 0 1
```

This demonstrates overlapping behavior.

---

# 26. Important FSM Design Method

For placement questions, remember this procedure:

```text
Requirement
     ↓
Identify states
     ↓
Draw state diagram
     ↓
Create transition table
     ↓
Choose state encoding
     ↓
Write state register
     ↓
Write next-state logic
     ↓
Write output logic
     ↓
Create testbench
     ↓
Verify transitions
```

This is the standard thought process you should practice.

---

# 27. State Encoding

We have three states:

```text
S0
S1
S2
```

Therefore at least:

$$
\lceil\log_2(3)\rceil=2
$$

state bits are required.

We use:

```text
S0 = 00
S1 = 01
S2 = 10
```

The encoding:

```text
11
```

is unused.

Therefore our default branch sends an illegal state back to S0.

---

# 28. Why Is the Default State Important?

Suppose due to reset, initialization, fault, or another unexpected condition:

```text
state = 2'b11
```

Our RTL contains:

```verilog
default: begin
    next_state = S0;
    detect     = 1'b0;
end
```

Therefore the FSM recovers to a known state.

This is good RTL design practice.

---

# 29. Mealy FSM Timing

Our output is:

```verilog
detect = 1'b1;
```

when:

```text
current state = S2
din = 1
```

Therefore:

```text
S2 + 1
   │
   ▼
detect = 1
```

This is characteristic of a Mealy output.

---

# 30. Moore Version

A Moore implementation would normally add a separate detection state:

```text
S0
 ↓
S1
 ↓
S2
 ↓
S3 = DETECT
```

Then:

```text
S3
```

has:

```text
detect = 1
```

The Moore FSM therefore has an additional state and generally different output timing.

---

# 31. Mealy vs Moore

| Feature                   | Mealy                                | Moore                                     |
| ------------------------- | ------------------------------------ | ----------------------------------------- |
| Output depends on         | State + input                        | State                                     |
| Output changes            | Can change with input                | Changes with state                        |
| States for `101` detector | Usually fewer                        | Usually more                              |
| Output timing             | Can assert on final input transition | Usually associated with detection state   |
| Design consideration      | Combinational input-to-output path   | More state, often simpler output behavior |

---

# 32. Common FSM Mistakes

## Mistake 1 — Missing default assignments

Bad:

```verilog
always @(*) begin
    case(state)
        ...
    endcase
end
```

without assigning outputs/next state in every path.

This can create unintended latch behavior in combinational logic.

---

## Mistake 2 — Using blocking assignment for state register

Sequential state update should normally use:

```verilog
state <= next_state;
```

---

## Mistake 3 — Forgetting illegal states

Always consider:

```verilog
default:
```

---

## Mistake 4 — Wrong overlap transition

For overlapping `101` detection:

```text
S2 + 1 → S1
```

not S0.

---

## Mistake 5 — Mixing combinational and sequential logic incorrectly

Keep the state register clocked and next-state/output logic combinational unless deliberately using another FSM coding style.

---

# 33. Placement Interview Questions

## Q1. What is an FSM?

A finite state machine is a sequential system whose behavior is described using a finite set of states and transitions.

---

## Q2. What are the two major types of FSM?

```text
Mealy
Moore
```

---

## Q3. What is a Mealy FSM?

Its output depends on:

```text
current state + current input
```

---

## Q4. What is a Moore FSM?

Its output depends only on:

```text
current state
```

---

## Q5. How many states are required for the basic overlapping `101` Mealy detector?

Three conceptual states:

```text
S0
S1
S2
```

---

## Q6. Why does S2 transition to S1 after detecting `101`?

Because the final `1` can also be the first bit of another overlapping `101` sequence.

---

## Q7. How many flip-flops are required for 3 binary-encoded states?

$$
\lceil\log_2 3\rceil=2
$$

So:

```text
2 flip-flops
```

are required for the state register.

---

## Q8. What is state encoding?

The assignment of binary values to FSM states.

---

## Q9. Why use `localparam` for states?

It improves readability and avoids hard-coded magic numbers.

---

## Q10. Why is `default` important?

It provides defined behavior for unused or illegal state encodings.

---

# 34. Practice Questions

### Q1

Design the state diagram for detecting:

```text
110
```

---

### Q2

Design an overlapping detector for:

```text
111
```

---

### Q3

How many states are needed for an overlapping Mealy detector for:

```text
1011
```

Think about the useful prefixes.

---

### Q4

Convert the `101` Mealy detector into a Moore FSM.

---

### Q5

For:

```text
Input = 10101
```

what should the detection output be for an overlapping detector?

Answer:

```text
00101
```

---

### Q6

What happens if:

```text
state = 2'b11
```

in our implementation?

Answer:

```text
FSM recovers toward S0 through the default branch.
```

---

# 35. Day 36 Assignment

## Main Assignment

Design and verify an **overlapping `101` sequence detector**.

Requirements:

1. Draw the state diagram.
2. Identify all states.
3. Create the transition table.
4. Implement the FSM in Verilog.
5. Use a clock and reset.
6. Detect `101`.
7. Support overlapping sequences.
8. Generate a one-cycle detection pulse.
9. Verify with:

   * `101`
   * `10101`
   * `110101`
   * sequences without `101`
10. View the result in GTKWave.

---

# 36. Recommended Repository Structure

```text
50-Days-of-RTL/
│
├── Day_34_Error_Detection_Correction/
├── Day_35_Waveform_Generators/
│
└── Day_36_FSM_State_Diagram/
    │
    ├── README.md
    ├── 101_sequence_detector.v
    ├── tb_101_sequence_detector.v
    └── sequence_101.vcd
```

---

# 37. Git Commands

```bash
cd ~/RTL_50_Days
```

```bash
git add Day_36_FSM_State_Diagram/
```

```bash
git commit -m "Day 36: Implement overlapping 101 sequence detector FSM"
```

```bash
git push
```

---

# 38. Day 36 Key Takeaways

```text
1. FSM = Finite State Machine.

2. FSMs model sequential behavior using states.

3. A state represents remembered information about previous inputs.

4. Mealy output depends on state + input.

5. Moore output depends only on state.

6. The 101 detector uses three conceptual states:
   S0 = nothing
   S1 = received 1
   S2 = received 10

7. For overlapping detection:

   S2 + 1 → S1

8. Detection occurs when:

   Current state = S2
   Input = 1

9. Three binary states require two state bits.

10. Use nonblocking assignments in the sequential state register.

11. Use combinational logic for next-state/output logic.

12. Use default assignments and default state recovery.

13. A transition table should be created before writing RTL.

14. Always verify the FSM using a testbench and waveform.
```

## ⭐ Most Important Diagram

```text
              1/0
         ┌───────────┐
         │           ▼
       ┌─────┐     ┌─────┐
  0/0  │ S0  │────►│ S1  │
   ▲   └─────┘ 1/0 └──┬──┘
   │                    │
   │                    │ 0/0
   │                    ▼
   │                  ┌─────┐
   └────── 0/0 ───────│ S2  │
                      └──┬──┘
                         │
                       1/1
                         │
                         ▼
                        S1
```

The critical transition is:

$$
\boxed{S2\xrightarrow{1/1}S1}
$$

because it provides **overlapping `101` detection**.

**Day 36 complete — FSM State Diagram → Mealy FSM → `101` detector → overlapping detection → state encoding → Verilog RTL → testbench → GTKWave → placement preparation.**
