# Day 30 — Recursive Systems in Verilog RTL

## 📌 Topic

**Recursive Systems**

## 🎯 Roadmap Objective

Explore how recursive systems like **Fibonacci generators** are implemented in hardware.

---

# 1. Learning Objectives

By the end of Day 30, you should understand:

* What a recursive system is.
* What recursion means mathematically.
* Why hardware recursion is different from software recursion.
* How previous results can be stored in registers.
* How a Fibonacci sequence can be implemented using registers.
* How sequential logic implements a recursive relationship.
* The role of clock and reset.
* The difference between combinational feedback and registered feedback.
* How to simulate a recursive hardware system.
* How to verify a Fibonacci generator using Icarus Verilog and GTKWave.

---

# 2. What is a Recursive System?

A recursive system is a system where the current output/state depends on one or more previous values.

A simple mathematical example is the Fibonacci sequence:

```text
F(0) = 0
F(1) = 1

F(n) = F(n-1) + F(n-2)
```

The sequence is:

```text
0, 1, 1, 2, 3, 5, 8, 13, 21, 34, ...
```

Each new value depends on previous values.

```text
       ┌─────────┐
       │         │
F(n-2) ├───► +   ├───► F(n)
       │         │
F(n-1) ├───►     │
       └─────────┘
```

The important hardware idea is that the previous values must be **stored**.

---

# 3. Recursion in Software vs Hardware

In software, recursion can mean a function calling itself:

```text
function
   ↓
function
   ↓
function
   ↓
...
```

Hardware does not normally implement recursion by repeatedly calling a function.

Instead, recursive relationships are implemented using:

* Registers
* Combinational logic
* Feedback paths
* Clocked state updates

For Fibonacci:

```text
Previous values
      │
      ▼
     ADD
      │
      ▼
New value
      │
      ▼
  Registers
      │
      └──────► next cycle
```

---

# 4. Fibonacci Recurrence

The Fibonacci equation is:

$$
F(n)=F(n-1)+F(n-2)
$$

We need two previous values.

Let:

```text
a = F(n-2)
b = F(n-1)
```

Then:

```text
next = a + b
```

After generating the next value:

```text
a ← b
b ← next
```

This continues every clock cycle.

---

# 5. Hardware Interpretation

The system can be represented as:

```text
             ┌─────────────┐
             │             │
     a ─────►│             │
             │     ADD     ├────► next
     b ─────►│             │
             └─────────────┘
                    │
                    ▼
              ┌──────────┐
              │ Registers│
              └──────────┘
                 │    │
                 │    │
                 ▼    ▼
                 a    b
                 │    │
                 └────┘
                    │
                    ▼
                  ADD
```

The registers remember the previous Fibonacci values.

---

# 6. Why Registers Are Necessary

Consider:

```text
F(n) = F(n-1) + F(n-2)
```

The hardware must remember:

```text
F(n-1)
F(n-2)
```

Therefore we use registers.

Without storage, the circuit would not have a way to remember previous clock-cycle values.

This is the key connection between **recursion and sequential logic**.

---

# 7. Fibonacci Sequence

Starting with:

```text
F(0) = 0
F(1) = 1
```

we obtain:

|  n | F(n) |
| -: | ---: |
|  0 |    0 |
|  1 |    1 |
|  2 |    1 |
|  3 |    2 |
|  4 |    3 |
|  5 |    5 |
|  6 |    8 |
|  7 |   13 |
|  8 |   21 |
|  9 |   34 |
| 10 |   55 |
| 11 |   89 |
| 12 |  144 |
| 13 |  233 |
| 14 |  377 |
| 15 |  610 |

Verification:

```text
1 + 0 = 1
1 + 1 = 2
2 + 1 = 3
3 + 2 = 5
5 + 3 = 8
8 + 5 = 13
```

and so on.

---

# 8. RTL Design

We will design a Fibonacci generator with:

```text
Inputs:
    clk
    reset

Output:
    fib
```

The generator will produce:

```text
0, 1, 1, 2, 3, 5, 8, 13, ...
```

one value per clock cycle.

---

# 9. Fibonacci Generator RTL

Create:

```text
fibonacci_generator.v
```

```verilog
module fibonacci_generator #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,
    output reg [WIDTH-1:0]  fib
);

    reg [WIDTH-1:0] prev;
    reg [WIDTH-1:0] current;

    always @(posedge clk) begin

        if (reset) begin
            prev    <= {WIDTH{1'b0}};
            current <= {{(WIDTH-1){1'b0}}, 1'b1};
            fib     <= {WIDTH{1'b0}};
        end

        else begin
            fib     <= current;
            prev    <= current;
            current <= prev + current;
        end

    end

endmodule
```

---

# 10. Understanding the RTL

The important part is:

```verilog
prev    <= current;
current <= prev + current;
```

Because these are **nonblocking assignments**, both RHS expressions use the old values.

Suppose:

```text
prev    = 0
current = 1
```

At the clock edge:

```text
fib     = 1
prev    = 1
current = 0 + 1 = 1
```

Next clock:

```text
prev    = 1
current = 1
```

Therefore:

```text
fib     = 1
prev    = 1
current = 1 + 1 = 2
```

Next:

```text
fib     = 2
prev    = 2
current = 1 + 2 = 3
```

Then:

```text
fib     = 3
prev    = 3
current = 2 + 3 = 5
```

Thus the sequence develops naturally from the stored state.

---

# 11. Why `<=` Is Important

Do NOT replace the sequential assignments with ordinary blocking assignments.

Correct:

```verilog
prev    <= current;
current <= prev + current;
```

The nonblocking assignments allow both registers to update from the values belonging to the previous state.

This is exactly what we want for a clocked recursive relationship.

---

# 12. Fibonacci State Transition

The state can be represented as:

```text
(prev, current)
```

Starting state:

```text
(0, 1)
```

Then:

| Clock | prev | current | Next current |
| ----: | ---: | ------: | -----------: |
|     0 |    0 |       1 |            1 |
|     1 |    1 |       1 |            2 |
|     2 |    1 |       2 |            3 |
|     3 |    2 |       3 |            5 |
|     4 |    3 |       5 |            8 |
|     5 |    5 |       8 |           13 |
|     6 |    8 |      13 |           21 |

The transition equation is:

$$
(prev,current)
\rightarrow
(current,prev+current)
$$

This is the hardware implementation of the recursive relationship.

---

# 13. Testbench

Create:

```text
tb_fibonacci_generator.v
```

```verilog
`timescale 1ns/1ps

module tb_fibonacci_generator;

    reg clk;
    reg reset;

    wire [7:0] fib;

    fibonacci_generator #(
        .WIDTH(8)
    ) dut (
        .clk(clk),
        .reset(reset),
        .fib(fib)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("fibonacci.vcd");
        $dumpvars(0, tb_fibonacci_generator);

        clk   = 1'b0;
        reset = 1'b1;

        #12;

        reset = 1'b0;

        #160;

        $finish;

    end

    initial begin
        $monitor(
            "TIME=%0t RESET=%b PREV=%0d CURRENT=%0d FIB=%0d",
            $time,
            reset,
            dut.prev,
            dut.current,
            fib
        );
    end

endmodule
```

---

# 14. Ubuntu Directory

Create:

```bash
mkdir -p ~/RTL_50_Days/Day_30_Recursive_Systems
cd ~/RTL_50_Days/Day_30_Recursive_Systems
```

Create the RTL:

```bash
nano fibonacci_generator.v
```

Create the testbench:

```bash
nano tb_fibonacci_generator.v
```

---

# 15. Compile

Use Icarus Verilog:

```bash
iverilog -o fibonacci_sim fibonacci_generator.v tb_fibonacci_generator.v
```

If compilation succeeds:

```bash
vvp fibonacci_sim
```

---

# 16. Expected Sequence

After reset is released, you should observe the Fibonacci sequence developing:

```text
0
1
1
2
3
5
8
13
21
34
55
89
144
...
```

The exact first displayed value depends on the reset/clock timing of the testbench, so use the internal `prev` and `current` signals in GTKWave to understand the state transition.

---

# 17. GTKWave

The testbench generates:

```text
fibonacci.vcd
```

Open it:

```bash
gtkwave fibonacci.vcd
```

Add:

```text
clk
reset
fib
```

Also add the internal registers:

```text
dut.prev
dut.current
```

You should see:

```text
prev
current
   │
   ▼
addition
   │
   ▼
next state
```

---

# 18. Waveform Concept

Suppose:

```text
prev = 3
current = 5
```

At the next positive edge:

```text
fib     = 5
prev    = 5
current = 8
```

Next:

```text
fib     = 8
prev    = 8
current = 13
```

Therefore the waveform should show the state moving forward every clock.

---

# 19. Why This is a Recursive System

The next value depends on previous values:

$$
F(n)=F(n-1)+F(n-2)
$$

Hardware implementation:

```text
Previous state
     ↓
   Adder
     ↓
New state
     ↓
Registers
     ↓
Previous state
```

This feedback of stored state is what allows the hardware to implement the recursive relationship.

---

# 20. Combinational Feedback vs Registered Feedback

This is an important concept.

## Combinational feedback

Example:

```text
A → logic → A
```

This can create an unstable or non-converging combinational loop.

It is generally something to avoid in normal synchronous RTL.

## Registered feedback

Example:

```text
Register
   ↓
Combinational logic
   ↓
Register
   ↓
...
```

This is a normal synchronous design technique.

Our Fibonacci generator uses **registered feedback**.

```text
       ┌───────────────┐
       │               │
       ▼               │
    Registers ──► ADD ─┘
       │
       ▼
   Next state
```

---

# 21. Width Limitation

Our example uses:

```verilog
parameter WIDTH = 8
```

An 8-bit unsigned value can represent:

```text
0 → 255
```

But Fibonacci numbers grow rapidly.

For example:

```text
F(12) = 144
F(13) = 233
F(14) = 377
```

377 cannot be represented in 8 bits.

Therefore overflow will eventually occur.

---

# 22. Overflow

For an 8-bit unsigned register:

```text
255 + 1
```

wraps around modulo 256.

Therefore:

```text
256 → 0
257 → 1
```

For a Fibonacci generator, once the result exceeds the selected width, the generated sequence no longer represents the mathematical Fibonacci sequence.

This is an important hardware consideration.

---

# 23. Parameterization

We used:

```verilog
parameter WIDTH = 8
```

Therefore we can instantiate:

```verilog
fibonacci_generator #(
    .WIDTH(16)
)
```

or:

```verilog
fibonacci_generator #(
    .WIDTH(32)
)
```

This makes the module reusable.

The roadmap previously introduced parameters and localparams, and here we use the same concept to make the recursive generator configurable.

---

# 24. Hardware Resources

The Fibonacci generator requires:

```text
Registers
+
Adder
+
Control/reset logic
```

Conceptually:

```text
       ┌──────────┐
       │ Register │
       └────┬─────┘
            │
            ▼
          ┌───┐
          │ + │
          └─┬─┘
            │
            ▼
       ┌──────────┐
       │ Register │
       └──────────┘
```

The exact FPGA resources used after synthesis depend on the target device and synthesis implementation.

---

# 25. Why Not Use a Recursive Function?

In software we might write something like:

```text
fib(n) = fib(n-1) + fib(n-2)
```

But that does not mean we should directly translate software recursion into synthesizable hardware.

A hardware implementation needs to represent:

```text
state
+
storage
+
combinational operation
+
clocked update
```

For this reason, the Fibonacci generator is implemented as a sequential state machine/data path rather than repeatedly calling a function at runtime.

---

# 26. Fibonacci Truth/Transition Verification

For the hardware state:

```text
(prev, current)
```

the transition is:

$$
(prev,current)\rightarrow(current,prev+current)
$$

Examples:

| Current State `(prev,current)` | Next State |
| ------------------------------ | ---------- |
| `(0,1)`                        | `(1,1)`    |
| `(1,1)`                        | `(1,2)`    |
| `(1,2)`                        | `(2,3)`    |
| `(2,3)`                        | `(3,5)`    |
| `(3,5)`                        | `(5,8)`    |
| `(5,8)`                        | `(8,13)`   |

This verifies the recursive relation directly.

---

# 27. Placement Interview Questions

## Q1. What is a recursive system?

A system whose current or next value depends on previous values.

---

## Q2. Give an example of a recursive sequence.

The Fibonacci sequence:

$$
F(n)=F(n-1)+F(n-2)
$$

---

## Q3. How is recursion implemented in hardware?

Using stored state, combinational logic, and feedback through registers.

---

## Q4. Why are registers required?

Registers store previous values so that they can be used during the next clock cycle.

---

## Q5. What is registered feedback?

A feedback path containing registers between the output and the combinational logic.

---

## Q6. Why is registered feedback useful?

It allows sequential systems to use previous state values safely on clock boundaries.

---

## Q7. Why do we use nonblocking assignments?

Because the Fibonacci state is updated synchronously using registers.

---

## Q8. What happens if the Fibonacci width is too small?

The result eventually overflows and wraps according to the register width.

---

## Q9. Why does Fibonacci grow quickly?

Each new value is the sum of the previous two values.

---

## Q10. What hardware operation generates the next Fibonacci value?

An adder:

```text
next = prev + current
```

---

# 28. Practice Questions

### Question 1

What is:

$$
F(8)
$$

### Answer

$$
F(8)=21
$$

---

### Question 2

If:

```text
prev = 8
current = 13
```

what is the next value?

### Answer

$$
8+13=21
$$

---

### Question 3

What is the next state for:

```text
(prev,current) = (13,21)
```

### Answer

```text
(21,34)
```

---

### Question 4

Why can't an 8-bit unsigned Fibonacci generator represent 377 correctly?

Because:

```text
8-bit unsigned maximum = 255
```

and:

```text
377 > 255
```

---

### Question 5

What is the main difference between combinational and registered feedback?

Combinational feedback has no storage element between iterations, while registered feedback stores state and updates it at clock edges.

---

# 29. Day 30 Assignment

Implement a parameterized Fibonacci generator.

Requirements:

```text
Inputs:
    clk
    reset

Output:
    fib
```

Requirements:

1. Use a parameterized width.
2. Generate Fibonacci values sequentially.
3. Use registered state.
4. Use nonblocking assignments.
5. Verify the sequence in simulation.
6. Observe `prev`, `current`, and `fib` in GTKWave.
7. Investigate what happens when the Fibonacci result exceeds the selected width.

Expected sequence:

```text
0
1
1
2
3
5
8
13
21
34
55
89
144
233
...
```

---

# 30. Git Repository Structure

Your repository should now contain:

```text
50-Days-of-RTL/
│
├── Day_01_Naming_Convention/
├── Day_02_Text_Based_Design_Flow/
├── ...
├── Day_27_Arbiters/
├── Day_28_Pipeline/
├── Day_29_Concurrency/
│
└── Day_30_Recursive_Systems/
    ├── README.md
    ├── fibonacci_generator.v
    └── tb_fibonacci_generator.v
```

---

# 31. Git Commit

After completing the Day 30 lab:

```bash
git add Day_30_Recursive_Systems/
```

```bash
git commit -m "Day 30: Implement recursive Fibonacci system"
```

```bash
git push
```

---

# 32. Day 30 Key Takeaways

Remember these points:

```text
1. A recursive system depends on previous values.

2. Fibonacci is a classic recursive sequence.

3. Hardware implements recursion using stored state.

4. Registers store previous values.

5. An adder generates the next Fibonacci value.

6. Registered feedback is used to create the next state.

7. Nonblocking assignment is used for sequential state updates.

8. Limited register width causes overflow.

9. Parameters make the Fibonacci generator reusable.

10. Registered feedback is fundamentally different from an
   uncontrolled combinational feedback loop.
```

## ⭐ Most Important Concept

```text
        ┌──────────────────────┐
        │                      │
        ▼                      │
   ┌─────────┐                 │
   │ Register│───┐             │
   └─────────┘   │             │
                 ▼             │
              ┌─────┐          │
              │ ADD │───────────┘
              └─────┘
                 │
                 ▼
             Next State
```

Mathematically:

$$
\boxed{F(n)=F(n-1)+F(n-2)}
$$

Hardware:

$$
\boxed{\text{Registers}+\text{Adder}+\text{Registered Feedback}}
$$

**Day 30 complete — Recursive Systems.**
