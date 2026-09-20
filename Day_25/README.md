# Day 25 — Custom Sequence Generators

## 1. Today's Objective

Today you will learn:

* What a custom sequence generator is
* How it differs from a normal counter
* State and next-state concepts
* How to generate an arbitrary sequence
* `case`-based sequence generation
* Handling unused/invalid states
* Self-recovery from invalid states
* Resetting a sequence generator
* Verilog implementation using nonblocking assignment
* Testbench verification
* Placement interview questions

---

# 2. What Is a Custom Sequence Generator?

A normal binary counter follows a fixed sequence:

```text
0000
0001
0010
0011
0100
0101
0110
0111
...
```

A **custom sequence generator** produces a user-defined sequence.

For example:

```text
000
010
100
111
001
000
...
```

The sequence does not have to follow normal binary counting.

---

# 3. Why Do We Need Custom Sequences?

Digital systems often need specific state sequences.

Examples include:

* Control circuits
* Timing controllers
* Protocol controllers
* FSMs
* Special counters
* Pattern generators
* Traffic controllers
* Test-pattern generation

Instead of allowing every binary state, we explicitly define which state comes next.

---

# 4. Basic Concept

Suppose we want:

```text
0 → 2 → 5 → 7 → 3 → 0
```

In binary:

```text
000 → 010 → 101 → 111 → 011 → 000
```

We can represent this as:

```text
Current State     Next State
----------------------------
000               010
010               101
101               111
111               011
011               000
```

This is the fundamental idea behind a custom sequence generator.

---

# 5. State and Next State

The register stores the **current state**.

At every clock edge:

```text
Current State
      |
      v
 Next-State Logic
      |
      v
 Next State
      |
      v
 Flip-Flop
      |
      +----> Current State
```

In RTL:

```verilog
always @(posedge clk)
    state <= next_state;
```

The important distinction is:

```text
state      = current stored value

next_state = value that will be stored on the next clock
```

---

# 6. Example Sequence

Let's design:

```text
0 → 2 → 5 → 7 → 3 → 0
```

3-bit representation:

| Decimal | Binary |
| ------: | :----: |
|       0 |   000  |
|       2 |   010  |
|       5 |   101  |
|       7 |   111  |
|       3 |   011  |

Therefore:

```text
000 → 010 → 101 → 111 → 011 → 000
```

---

# 7. State Transition Table

| Current State | Next State |
| :-----------: | :--------: |
|      000      |     010    |
|      010      |     101    |
|      101      |     111    |
|      111      |     011    |
|      011      |     000    |

What about the other 3-bit states?

There are eight possible states:

```text
000
001
010
011
100
101
110
111
```

Our sequence uses:

```text
000
010
011
101
111
```

Unused states are:

```text
001
100
110
```

We should decide what happens if the circuit somehow enters one of these states.

A robust design should recover to a known valid state.

For example:

```text
001 → 000
100 → 000
110 → 000
```

This is called **invalid-state recovery**.

---

# 8. RTL Implementation

Create:

```bash
mkdir -p ~/Verilog_50_Days/Day_25/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_25
```

Create:

```bash
nano rtl/custom_sequence_generator.v
```

Use:

```verilog
module custom_sequence_generator (
    input  wire       clk,
    input  wire       reset,
    output reg  [2:0] state
);

    always @(posedge clk) begin
        if (reset) begin
            state <= 3'b000;
        end
        else begin
            case (state)

                3'b000: state <= 3'b010;
                3'b010: state <= 3'b101;
                3'b101: state <= 3'b111;
                3'b111: state <= 3'b011;
                3'b011: state <= 3'b000;

                default: state <= 3'b000;

            endcase
        end
    end

endmodule
```

---

# 9. Understand the RTL

The first part:

```verilog
always @(posedge clk)
```

means the state changes only at the active clock edge.

Reset:

```verilog
if (reset)
    state <= 3'b000;
```

puts the sequence at its starting state.

Then:

```verilog
case (state)
```

checks the current state.

For example:

```verilog
3'b000: state <= 3'b010;
```

means:

```text
If current state = 000

next state = 010
```

Similarly:

```verilog
3'b010: state <= 3'b101;
```

means:

```text
010 → 101
```

---

# 10. Why `default` Is Important

We have eight possible states but only five valid states.

Therefore we include:

```verilog
default:
    state <= 3'b000;
```

If the circuit somehow reaches:

```text
001
100
110
```

it returns to:

```text
000
```

Therefore the generator can recover automatically.

This is especially useful in robust RTL design.

---

# 11. Sequence Verification

Starting from reset:

```text
State = 000
```

After the first active clock:

```text
000 → 010
```

Second:

```text
010 → 101
```

Third:

```text
101 → 111
```

Fourth:

```text
111 → 011
```

Fifth:

```text
011 → 000
```

Then the sequence repeats.

Therefore:

```text
000 → 010 → 101 → 111 → 011 → 000
 ↑                             |
 +-----------------------------+
```

---

# 12. Testbench

Create:

```bash
nano tb/tb_custom_sequence_generator.v
```

Use:

```verilog
`timescale 1ns/1ps

module tb_custom_sequence_generator;

    reg       clk;
    reg       reset;
    wire [2:0] state;

    custom_sequence_generator dut (
        .clk   (clk),
        .reset (reset),
        .state (state)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("sim/custom_sequence_generator.vcd");
        $dumpvars(0, tb_custom_sequence_generator);

        clk   = 1'b0;
        reset = 1'b1;

        #12;

        reset = 1'b0;

        repeat (12) begin
            @(posedge clk);
            #1;
            $display(
                "Time=%0t  State=%b  Decimal=%0d",
                $time,
                state,
                state
            );
        end

        $finish;

    end

endmodule
```

---

# 13. Compile

From:

```bash
cd ~/Verilog_50_Days/Day_25
```

run:

```bash
iverilog -o sim/day25 rtl/custom_sequence_generator.v tb/tb_custom_sequence_generator.v
```

Then:

```bash
vvp sim/day25
```

---

# 14. Expected Sequence

After reset is released, you should observe:

```text
010
101
111
011
000
010
101
111
011
000
...
```

The repeating sequence is:

```text
2 → 5 → 7 → 3 → 0 → 2 → ...
```

The exact first displayed state depends on where the testbench releases reset relative to the clock edge, so focus on the repeating state transitions.

---

# 15. GTKWave

Run:

```bash
gtkwave sim/custom_sequence_generator.vcd
```

Add:

```text
clk
reset
state
```

You should see the state change only on clock edges.

---

# 16. Truth/Transition Verification

For sequential circuits, the equivalent of a combinational truth table is the **state-transition table**.

Our design:

| Current State | Next State | Decimal Transition |
| :-----------: | :--------: | :----------------: |
|      000      |     010    |        0 → 2       |
|      010      |     101    |        2 → 5       |
|      101      |     111    |        5 → 7       |
|      111      |     011    |        7 → 3       |
|      011      |     000    |        3 → 0       |
|      001      |     000    |     Invalid → 0    |
|      100      |     000    |     Invalid → 0    |
|      110      |     000    |     Invalid → 0    |

This table completely describes the state behavior.

---

# 17. Custom Sequence vs Normal Counter

### Normal counter

```text
000
001
010
011
100
101
110
111
```

### Custom sequence

```text
000
010
101
111
011
000
```

A normal counter can often be implemented with:

```verilog
state <= state + 1'b1;
```

A custom sequence generally requires explicit next-state logic such as:

```verilog
case (state)
```

---

# 18. Another Example

Suppose the required sequence is:

```text
1 → 3 → 6 → 4 → 2 → 1
```

Binary:

```text
001 → 011 → 110 → 100 → 010 → 001
```

State table:

| Current | Next |
| :-----: | :--: |
|   001   |  011 |
|   011   |  110 |
|   110   |  100 |
|   100   |  010 |
|   010   |  001 |

The RTL pattern is:

```verilog
always @(posedge clk) begin
    if (reset)
        state <= 3'b001;
    else begin
        case (state)
            3'b001: state <= 3'b011;
            3'b011: state <= 3'b110;
            3'b110: state <= 3'b100;
            3'b100: state <= 3'b010;
            3'b010: state <= 3'b001;
            default: state <= 3'b001;
        endcase
    end
end
```

The important skill is not memorizing this code.

You should be able to create it from a required sequence.

---

# 19. General Design Procedure

Whenever an interviewer gives you a custom sequence, follow these steps.

### Step 1 — Write the required sequence

Example:

```text
0 → 2 → 5 → 7 → 3 → 0
```

### Step 2 — Convert to binary

```text
000 → 010 → 101 → 111 → 011 → 000
```

### Step 3 — Determine number of bits

There are five states.

We need:

```text
2^2 = 4  < 5
2^3 = 8  ≥ 5
```

Therefore:

```text
3 flip-flops
```

### Step 4 — Create state-transition table

```text
Current → Next
```

### Step 5 — Decide invalid-state behavior

For example:

```text
invalid → starting state
```

### Step 6 — Write `case` RTL

### Step 7 — Add reset

### Step 8 — Verify every valid transition

This is the standard design method.

---

# 20. Number of Flip-Flops

If a custom sequence contains `N` distinct states, the minimum number of flip-flops is:

```text
2^M ≥ N
```

where `M` is the number of flip-flops.

Therefore:

```text
M = ceil(log2(N))
```

Examples:

| Number of States | Flip-Flops |
| ---------------: | ---------: |
|                2 |          1 |
|              3–4 |          2 |
|              5–8 |          3 |
|             9–16 |          4 |
|            17–32 |          5 |

For our five-state sequence:

```text
2^2 = 4
2^3 = 8
```

So:

```text
3 flip-flops
```

---

# 21. Important Concept: State Encoding

We used the binary values directly:

```text
0 = 000
2 = 010
5 = 101
7 = 111
3 = 011
```

This is a form of **binary state encoding**.

Other FSM designs can use different encoding schemes, but for today's basic custom sequence generator, binary encoding is sufficient.

---

# 22. Invalid States

For a 3-bit state register:

```text
8 possible states
```

Our sequence uses only:

```text
5 states
```

Therefore:

```text
8 - 5 = 3 unused states
```

They are:

```text
001
100
110
```

A robust design specifies what happens to these states.

We chose:

```text
001 → 000
100 → 000
110 → 000
```

This is why:

```verilog
default: state <= 3'b000;
```

is important.

---

# 23. Common Mistake: Blocking Assignment

For the state register, don't use:

```verilog
always @(posedge clk)
    state = next_state;
```

For sequential RTL, use:

```verilog
always @(posedge clk)
    state <= next_state;
```

Therefore remember:

```text
Combinational procedural logic → =
Sequential logic              → <=
```

---

# 24. Custom Sequence Generator vs FSM

A custom sequence generator is closely related to a finite-state machine.

Both have:

```text
Current State
      ↓
Next-State Logic
      ↓
Next State
```

A more complete FSM can also have:

```text
Inputs
  ↓
Next-State Logic
  ↓
State Register
  ↓
Outputs
```

So today's topic is an important stepping stone toward the FSM topics later in the roadmap.

---

# 25. Placement Interview Questions

### Q1. What is a custom sequence generator?

A sequential circuit that follows a specified sequence of states instead of normal binary counting.

### Q2. How do you design one?

```text
Required sequence
→ binary encoding
→ state-transition table
→ invalid-state handling
→ RTL
→ simulation
```

### Q3. How many flip-flops are needed for 10 states?

Find:

```text
2^3 = 8 < 10
2^4 = 16 ≥ 10
```

Therefore:

```text
4 flip-flops
```

### Q4. Why do we need a default case?

To define behavior for unused or unexpected states and allow recovery to a known state.

### Q5. What is the difference between a counter and a custom sequence generator?

A counter normally follows an arithmetic sequence, while a custom sequence generator follows explicitly defined state transitions.

### Q6. Is a custom sequence generator combinational or sequential?

Sequential, because it contains state storage.

### Q7. Why is reset important?

Reset establishes a known starting state.

### Q8. Why use `<=`?

The state register is clocked sequential logic.

### Q9. What happens if there are 7 states?

```text
2^2 = 4 < 7
2^3 = 8 ≥ 7
```

Therefore:

```text
3 flip-flops
```

### Q10. What is invalid-state recovery?

The mechanism by which the circuit returns from an unused/unexpected state to a valid state.

---

# 26. Day 25 Assignment

Design the following sequence generator:

```text
0 → 3 → 6 → 5 → 2 → 7 → 1 → 0
```

### Requirements

1. Determine the number of flip-flops.
2. Convert every state to binary.
3. Create the complete state-transition table.
4. Identify unused states.
5. Make unused states return to `000`.
6. Implement using `case`.
7. Add synchronous reset.
8. Write a self-checking testbench.
9. Simulate at least two complete sequence cycles.
10. Open the waveform in GTKWave.

### Expected sequence

```text
000
011
110
101
010
111
001
000
...
```

---

# 27. Challenge Question

Design a sequence generator for:

```text
1 → 4 → 6 → 2 → 7 → 3 → 1
```

Determine:

```text
1. Number of states
2. Number of flip-flops
3. Binary state encoding
4. Unused states
5. State-transition table
6. Invalid-state recovery state
```

Do this on paper **before writing Verilog**.

---

# 28. Day 25 Golden Rules

```text
Custom sequence generator
        ↓
State register + next-state logic
```

For `N` states:

```text
Number of FFs = ceil(log2(N))
```

Typical RTL:

```verilog
always @(posedge clk) begin
    if (reset)
        state <= START_STATE;
    else begin
        case (state)
            STATE_0: state <= STATE_1;
            STATE_1: state <= STATE_2;
            STATE_2: state <= STATE_3;
            ...
            default: state <= START_STATE;
        endcase
    end
end
```

Most important concept:

> **A custom sequence generator is essentially a state machine whose states follow a deliberately specified sequence.**

---

# Day 25 Checklist

Before moving forward, you should be able to:

* [ ] Explain a custom sequence generator
* [ ] Create a state-transition table
* [ ] Calculate required flip-flops
* [ ] Convert decimal states to binary
* [ ] Identify unused states
* [ ] Implement a sequence using `case`
* [ ] Add reset
* [ ] Add invalid-state recovery
* [ ] Explain current state vs next state
* [ ] Use `<=` for the state register
* [ ] Verify the sequence in simulation
* [ ] Read the sequence from a GTKWave waveform
* [ ] Design an arbitrary sequence without copying a template

**Day 25 takeaway:**

> **Don't start with Verilog. Start with the required sequence → state table → binary encoding → RTL → verification.**
