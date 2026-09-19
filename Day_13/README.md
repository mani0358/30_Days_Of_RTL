# Day 13 — Combinational vs Sequential Logic

## 1. Day 13 Objective

Today you will learn:

* What combinational logic is
* What sequential logic is
* The difference between them
* Why memory/state exists in sequential circuits
* Role of the clock
* Role of reset
* Examples of combinational and sequential circuits
* How to identify combinational vs sequential RTL
* How incomplete assignments can create unwanted storage
* How to implement a combinational multiplier
* How to implement a sequential multiplier conceptually
* How to verify the combinational multiplier using a testbench
* Placement/interview questions

### Roadmap Topic

**Combinational vs Sequential Logic**

### Roadmap Assignment

**Combinational/Sequential Multiplier**

---

# 2. The Fundamental Difference

The most important idea of Day 13 is:

> **Combinational logic depends only on current inputs.**

> **Sequential logic depends on current inputs and previous state.**

Mathematically:

### Combinational

$$
Y=f(X)
$$

### Sequential

$$
Y=f(X,Q_{previous})
$$

where `Q_previous` represents stored state.

---

# 3. Combinational Logic

A combinational circuit has:

```text
Inputs
  ↓
Logic
  ↓
Outputs
```

There is no internal memory.

For example:

```text
A ──┐
    ├── AND ── Y
B ──┘
```

The output is:

$$
Y=A\cdot B
$$

If `A` or `B` changes, the output changes according to the logic function.

---

# 4. Examples of Combinational Circuits

Common examples:

* AND gate
* OR gate
* NOT gate
* XOR gate
* Multiplexer
* Demultiplexer
* Encoder
* Decoder
* Comparator
* Adder
* Subtractor
* Combinational multiplier

You have already implemented several of these in Days 1–12.

---

# 5. Example — Combinational AND

```verilog
module and_gate (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a & b;

endmodule
```

There is:

```text
No clock
No memory
No previous state
```

Therefore this is combinational.

---

# 6. Combinational Truth Table

For:

$$
Y=A\cdot B
$$

| A | B | Y |
| - | - | - |
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

The output depends only on the current `A` and `B`.

---

# 7. Sequential Logic

A sequential circuit contains **state/storage**.

Conceptually:

```text
          ┌──────────────┐
Input ───►│ Combinational│───► Output
          │    Logic     │
          └──────┬───────┘
                 │
                 ▼
              Storage
                 │
                 └────────── feedback
```

The output/state can depend on previous values.

Typical storage elements include:

* Latches
* Flip-flops
* Registers
* Memories

---

# 8. Examples of Sequential Circuits

Examples include:

* D flip-flop
* Registers
* Counters
* Shift registers
* Finite-state machines
* Sequential multipliers
* Synchronous memories

You will study these in much more detail in later days.

---

# 9. Role of Clock

Sequential synchronous circuits commonly use a clock.

Example:

```verilog
always @(posedge clk) begin
    q <= d;
end
```

The state changes at the rising edge of `clk`.

Conceptually:

```text
       CLK
        │
        ▼
D ──► D Flip-Flop ──► Q
```

The flip-flop stores information.

---

# 10. Combinational vs Sequential

| Feature                   | Combinational       | Sequential                           |
| ------------------------- | ------------------- | ------------------------------------ |
| Depends on current input  | Yes                 | Yes                                  |
| Depends on previous state | No                  | Yes                                  |
| Memory                    | No                  | Yes                                  |
| Clock required            | No                  | Commonly yes for synchronous designs |
| Feedback                  | Usually no          | Often present                        |
| Examples                  | Adder, MUX, decoder | Counter, register, FSM               |

Important:

> A clock is not the definition of sequential logic by itself. The fundamental property is **state/memory**.

---

# 11. How to Identify Combinational RTL

Consider:

```verilog
always @(*) begin
    y = a & b;
end
```

This is combinational because:

```text
y depends only on a and b
```

There is no state being stored.

---

# 12. How to Identify Sequential RTL

Consider:

```verilog
always @(posedge clk) begin
    q <= d;
end
```

This is sequential because:

```text
q retains its value between clock edges
```

and updates at a clock edge.

---

# 13. Very Important Coding Rule

For combinational logic:

```verilog
always @(*) begin
    ...
end
```

For clocked sequential logic:

```verilog
always @(posedge clk) begin
    ...
end
```

This distinction is extremely important in RTL design.

---

# 14. Combinational Logic Must Have Complete Assignments

Consider:

```verilog
always @(*) begin
    if (a)
        y = b;
end
```

What happens when:

```text
a = 0
```

There is no assignment to `y`.

Therefore `y` has to retain its previous value in simulation.

This can result in **latch inference** during synthesis.

---

# 15. Correct Combinational Style

Provide a default value:

```verilog
always @(*) begin

    y = 1'b0;

    if (a)
        y = b;

end
```

Now every execution gives `y` a value.

This creates combinational logic.

---

# 16. Why Latches Matter

A latch is a storage element.

If you intended:

```text
Combinational logic
```

but your RTL infers:

```text
Latch
```

then the synthesized hardware is not what you intended.

Therefore:

> **For combinational RTL, make sure every output is assigned for every possible input condition.**

---

# 17. Day 13 Assignment — Multiplier

The roadmap assignment asks you to consider:

> **Combinational/Sequential Multiplier**

We will first implement the **combinational multiplier**.

Suppose:

```text
A = 4 bits
B = 4 bits
```

The maximum value is:

```text
1111 = 15
```

Therefore:

$$
15\times15=225
$$

Binary `225` requires 8 bits:

```text
11100001
```

So:

```text
4-bit × 4-bit → 8-bit result
```

---

# 18. Combinational Multiplier

The basic mathematical operation is:

$$
P=A\times B
$$

There is:

```text
No clock
No storage
No previous state
```

Therefore it is combinational.

---

# 19. 4-bit Combinational Multiplier RTL

Create:

```text
~/Verilog_50_Days/Day_13/rtl/combinational_multiplier.v
```

```verilog
module combinational_multiplier (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [7:0] product
);

    assign product = a * b;

endmodule
```

This is dataflow-style combinational RTL.

---

# 20. Why is the Output 8 Bits?

For unsigned numbers:

```text
4-bit A
×
4-bit B
```

The maximum product is:

$$
(2^4-1)(2^4-1)
$$

$$
=15\times15
$$

$$
=225
$$

The largest 8-bit unsigned value is:

$$
2^8-1=255
$$

Therefore an 8-bit product is sufficient.

So:

$$
\boxed{4\times4\rightarrow8\text{ bits}}
$$

---

# 21. Multiplier Verification

There are:

```text
4 input bits for A
4 input bits for B
```

Therefore:

$$
2^4\times2^4=16\times16=256
$$

possible combinations.

A complete testbench can therefore verify:

$$
\boxed{256\text{ combinations}}
$$

---

# 22. Testbench

Create:

```text
~/Verilog_50_Days/Day_13/tb/tb_combinational_multiplier.v
```

```verilog
`timescale 1ns/1ps

module tb_combinational_multiplier;

    reg  [3:0] a;
    reg  [3:0] b;
    wire [7:0] product;

    integer i;
    integer j;

    combinational_multiplier dut (
        .a(a),
        .b(b),
        .product(product)
    );

    initial begin

        $dumpfile("sim/combinational_multiplier.vcd");
        $dumpvars(0, tb_combinational_multiplier);

        for (i = 0; i < 16; i = i + 1) begin

            for (j = 0; j < 16; j = j + 1) begin

                a = i;
                b = j;

                #1;

                if (product !== (a * b))
                    $display(
                        "FAIL: A=%0d B=%0d Product=%0d Expected=%0d",
                        a, b, product, (a * b)
                    );
                else
                    $display(
                        "PASS: A=%0d B=%0d Product=%0d",
                        a, b, product
                    );

            end

        end

        $finish;

    end

endmodule
```

---

# 23. Why Use `#1`?

After:

```verilog
a = i;
b = j;
```

we wait:

```verilog
#1;
```

This gives the combinational logic time to propagate in simulation before checking the output.

For RTL simulation, this is useful for separating stimulus changes from checking.

---

# 24. Directory Setup

Run:

```bash
mkdir -p ~/Verilog_50_Days/Day_13/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_13
```

Check:

```bash
tree
```

Expected:

```text
Day_13/
├── rtl/
│   └── combinational_multiplier.v
├── tb/
│   └── tb_combinational_multiplier.v
├── sim/
└── wave/
```

---

# 25. Compile

```bash
iverilog -o sim/combinational_multiplier_sim \
    rtl/combinational_multiplier.v \
    tb/tb_combinational_multiplier.v
```

---

# 26. Run

```bash
vvp sim/combinational_multiplier_sim
```

You should see many:

```text
PASS
```

messages.

There should be:

$$
256
$$

tested input combinations.

No `FAIL` messages should appear.

---

# 27. GTKWave

Run:

```bash
gtkwave sim/combinational_multiplier.vcd
```

Add:

```text
a
b
product
```

You can observe:

```text
A × B = Product
```

For example:

| A    | B    | Product  |
| ---- | ---- | -------- |
| 0000 | 0000 | 00000000 |
| 0001 | 0011 | 00000011 |
| 0010 | 0011 | 00000110 |
| 0101 | 0011 | 00001111 |
| 1111 | 1111 | 11100001 |

Check the last row:

$$
15\times15=225
$$

and:

$$
225_{10}=11100001_2
$$

Correct.

---

# 28. Sequential Multiplier — Concept

A sequential multiplier does not necessarily perform the entire multiplication in one combinational operation.

Instead, it can perform multiplication over multiple clock cycles using:

* Registers
* Adder
* Control logic
* Clock
* Partial products

Conceptually:

```text
             ┌─────────────┐
             │ Control FSM │
             └──────┬──────┘
                    │
                    ▼
A ──► Register ──► Arithmetic ──► Result Register
                    ▲
                    │
                 Feedback
```

The exact architecture can vary.

The key difference is:

```text
Combinational multiplier:
Result produced through combinational logic.

Sequential multiplier:
Operation spread across clock cycles using stored state.
```

---

# 29. Conceptual Comparison

Suppose:

```text
A = 7
B = 5
```

### Combinational

The multiplier continuously produces:

```text
7 × 5 = 35
```

without waiting for a clock.

### Sequential

The multiplier may take several clock cycles to perform the operation.

For example:

```text
Clock 1 → partial operation
Clock 2 → partial operation
Clock 3 → partial operation
...
Final clock → result
```

The exact number of cycles depends on the architecture.

---

# 30. Why Use a Sequential Multiplier?

A sequential multiplier can use fewer hardware resources by reusing arithmetic hardware across multiple cycles.

Trade-off:

```text
Less hardware
     ↕
More cycles
```

Whereas a fully combinational multiplier can provide a result without multi-cycle control but may require more combinational hardware and have greater combinational delay/area.

This is an important **architecture trade-off**.

---

# 31. Combinational vs Sequential Multiplier

| Feature        | Combinational                    | Sequential                              |
| -------------- | -------------------------------- | --------------------------------------- |
| Clock          | Not required                     | Required for synchronous implementation |
| State          | No                               | Yes                                     |
| Result         | Combinationally generated        | Generated over cycles                   |
| Hardware reuse | Less                             | More possible                           |
| Latency        | Combinational propagation delay  | Multiple clock cycles possible          |
| Control        | Simple                           | More complex                            |
| Registers      | Not required for basic operation | Required for stored intermediate state  |

---

# 32. Important Distinction

Do not say:

> "Combinational circuits are always faster."

That is too broad.

A better statement is:

> A combinational implementation can produce its result after its combinational propagation delay, while a sequential implementation may intentionally trade additional clock-cycle latency for reduced/reused hardware resources.

---

# 33. How to Identify a Combinational Circuit in RTL

Ask yourself:

### Question 1

Does it remember a previous value?

```text
No → likely combinational
Yes → sequential
```

### Question 2

Does the output depend only on current inputs?

```text
Yes → combinational
```

### Question 3

Is there storage/state?

```text
Yes → sequential
```

### Question 4

Does the RTL contain a clocked block?

```verilog
always @(posedge clk)
```

This is a strong indication of synchronous sequential logic.

---

# 34. Combinational Example

```verilog
always @(*) begin
    y = a & b;
end
```

Output:

$$
Y=A\cdot B
$$

No state.

---

# 35. Sequential Example

```verilog
always @(posedge clk) begin
    q <= d;
end
```

Here `q` stores state.

Between clock edges, it retains its value.

Therefore it is sequential logic.

---

# 36. Another Important Example

Consider:

```verilog
always @(*) begin

    if (enable)
        q = d;

end
```

Although it has an `always` block, this is **not automatically sequential because of the `always` keyword**.

The incomplete assignment can infer a latch.

A latch is sequential storage.

So:

```text
always
    ≠
automatically sequential
```

The actual behavior determines the hardware.

---

# 37. Very Important Interview Rule

> **Do not identify combinational or sequential logic simply by looking at `always`. Look at the sensitivity/clocking and whether the logic requires state.**

For example:

```verilog
always @(*) 
```

usually describes combinational logic when assignments are complete.

While:

```verilog
always @(posedge clk)
```

describes clocked sequential logic.

---

# 38. Common RTL Mistakes

## Mistake 1 — Missing assignment

Bad:

```verilog
always @(*) begin
    if (enable)
        y = a;
end
```

Potential latch.

Better:

```verilog
always @(*) begin
    y = 0;

    if (enable)
        y = a;
end
```

---

## Mistake 2 — Accidentally creating state

If you want combinational logic, don't unintentionally retain an old value.

---

## Mistake 3 — Thinking `reg` means sequential

This is wrong:

> `reg` = hardware register.

Correct:

> `reg` is a traditional Verilog variable type. The RTL behavior determines whether synthesis produces combinational logic, a latch, or flip-flops.

---

# 39. Placement Questions

### Q1. What is combinational logic?

Logic whose output depends only on the current input values.

### Q2. What is sequential logic?

Logic whose behavior depends on current inputs and stored state/previous values.

### Q3. Does combinational logic have memory?

No.

### Q4. Does sequential logic have memory?

Yes.

### Q5. Give examples of combinational circuits.

Adder, subtractor, MUX, decoder, comparator, multiplier.

### Q6. Give examples of sequential circuits.

Flip-flop, register, counter, shift register, FSM.

### Q7. Is a clock mandatory for every sequential circuit?

No. Sequential circuits can include asynchronous storage elements such as latches. In synchronous RTL, however, flip-flop-based state is commonly controlled by a clock.

### Q8. What does `always @(*)` generally describe?

Combinational procedural logic when the block completely assigns its outputs.

### Q9. What does `always @(posedge clk)` generally describe?

Clocked sequential logic.

### Q10. What happens if a combinational output is not assigned on every path?

A latch may be inferred.

### Q11. What is a 4×4 multiplier?

A multiplier with two 4-bit operands producing an 8-bit product.

### Q12. How many input combinations exist for a 4×4 multiplier?

There are eight independent input bits:

$$
2^8=256
$$

combinations.

### Q13. Why is the product 8 bits?

Because the maximum unsigned product is:

$$
15\times15=225
$$

which fits in 8 bits.

### Q14. What is the main difference between combinational and sequential multipliers?

A combinational multiplier performs the operation through combinational logic, while a sequential multiplier can reuse hardware and generate the result over multiple clock cycles using state.

---

# 40. Day 13 Practice

## Practice 1 — 2×2 Multiplier

Create:

```text
2-bit × 2-bit → 4-bit
```

Verify all:

$$
2^4=16
$$

combinations.

---

## Practice 2 — 4×4 Multiplier

Complete the Day 13 lab and verify all:

$$
256
$$

combinations.

---

## Practice 3 — Behavioral Multiplier

Implement:

```verilog
always @(*) begin
    product = a * b;
end
```

Compare it with the dataflow implementation.

---

## Practice 4 — Latch Experiment

Start with:

```verilog
always @(*) begin
    if (enable)
        y = a;
end
```

Simulate it.

Then change it to:

```verilog
always @(*) begin
    y = 1'b0;

    if (enable)
        y = a;
end
```

Compare the behavior.

---

## Practice 5 — Identify the Type

For each circuit, decide whether it is combinational or sequential:

### A

```verilog
assign y = a ^ b;
```

### B

```verilog
always @(posedge clk)
    q <= d;
```

### C

```verilog
assign sum = a + b;
```

### D

```verilog
always @(posedge clk)
    count <= count + 1;
```

Answers:

```text
A → Combinational
B → Sequential
C → Combinational
D → Sequential
```

---

# 41. Day 13 Golden Concept

Remember this:

```text
                 DIGITAL LOGIC
                      │
             ┌────────┴────────┐
             │                 │
       COMBINATIONAL       SEQUENTIAL
             │                 │
       Current inputs      Current inputs
             │                 │
             │            Previous state
             │                 │
        No memory            Memory
             │                 │
      Adder / MUX         Counter / FF
      Decoder / ALU       Register / FSM
      Multiplier          Shift Register
```

---

# 42. Day 13 Golden Code

### Combinational multiplier

```verilog
module combinational_multiplier (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [7:0] product
);

    assign product = a * b;

endmodule
```

The essential relationship is:

$$
\boxed{Product=A\times B}
$$

---

# 43. Day 13 Golden Interview Answer

If an interviewer asks:

### "What is the difference between combinational and sequential logic?"

Answer:

> **Combinational logic produces outputs based only on the current inputs and does not store state. Sequential logic contains state, so its behavior depends on current inputs as well as previously stored information. Examples of combinational circuits include adders, multiplexers, and decoders, while counters, registers, and flip-flops are sequential circuits.**

---

# 44. Day 13 Checklist

* [ ] Understand combinational logic
* [ ] Understand sequential logic
* [ ] Know the fundamental difference
* [ ] Understand state/memory
* [ ] Understand the role of clock
* [ ] Understand `always @(*)`
* [ ] Understand `always @(posedge clk)`
* [ ] Understand latch inference
* [ ] Know why complete combinational assignments are important
* [ ] Implement 4×4 combinational multiplier
* [ ] Verify all 256 combinations
* [ ] Understand sequential multiplier concept
* [ ] Run Icarus Verilog
* [ ] Inspect waveform in GTKWave
* [ ] Answer placement questions

# Final Day 13 Takeaway

$$
\boxed{\text{Combinational: }Y=f(X)}
$$

$$
\boxed{\text{Sequential: }Y=f(X,\text{previous state})}
$$

The most important mental model is:

> **Combinational logic calculates. Sequential logic calculates + remembers.**
