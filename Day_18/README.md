# Day 18 — `case` Statement in Verilog RTL

## 1. Day 18 Objective

Today you will learn:

* `case`
* `case`, `casez`, and `casex`
* `default`
* `case` syntax
* `case` for combinational logic
* `case` for MUX design
* `case` for ALU operation selection
* Difference between `if/else` and `case`
* Avoiding latch inference
* `case` and X/Z behavior
* Testbench verification with Icarus Verilog
* Placement interview questions

### Roadmap connection

```text
Day 15 → Blocking assignment
Day 16 → Nonblocking assignment
Day 17 → if/else
Day 18 → case
```

---

# 2. What is `case`?

The `case` statement allows Verilog to select one block of code according to the value of an expression.

Basic syntax:

```verilog
case (expression)

    value1: statement1;
    value2: statement2;
    value3: statement3;

    default: statement_default;

endcase
```

Example:

```verilog
always @(*) begin

    case (sel)

        2'b00: y = a;
        2'b01: y = b;
        2'b10: y = c;
        2'b11: y = d;

        default: y = 1'b0;

    endcase

end
```

This describes a 4:1 multiplexer.

---

# 3. Why Use `case`?

Suppose you need:

```text
00 → operation A
01 → operation B
10 → operation C
11 → operation D
```

You could write:

```verilog
if (sel == 2'b00)
    ...
else if (sel == 2'b01)
    ...
else if (sel == 2'b10)
    ...
else
    ...
```

But `case` is usually much easier to read:

```verilog
case (sel)
    2'b00: ...
    2'b01: ...
    2'b10: ...
    2'b11: ...
endcase
```

So `case` is especially useful when one selector has several possible values.

---

# 4. 4:1 MUX Using `case`

Inputs:

```text
a
b
c
d
```

Select:

```text
sel[1:0]
```

Output:

```text
y
```

Truth table:

| sel1 | sel0 | y |
| ---: | ---: | - |
|    0 |    0 | a |
|    0 |    1 | b |
|    1 |    0 | c |
|    1 |    1 | d |

Therefore:

```text
00 → a
01 → b
10 → c
11 → d
```

---

# 5. RTL — 4:1 MUX

```verilog
module mux_4to1 (
    input  wire       a,
    input  wire       b,
    input  wire       c,
    input  wire       d,
    input  wire [1:0] sel,
    output reg        y
);

    always @(*) begin

        case (sel)

            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            2'b11: y = d;

            default: y = 1'b0;

        endcase

    end

endmodule
```

---

# 6. Understanding `default`

Consider:

```verilog
case (sel)

    2'b00: y = a;
    2'b01: y = b;
    2'b10: y = c;
    2'b11: y = d;

    default: y = 1'b0;

endcase
```

`default` executes when none of the listed case items match.

It is good RTL practice to explicitly define what happens for unexpected values.

For a 2-bit selector, normal binary values are:

```text
00
01
10
11
```

But simulation can also contain:

```text
X
Z
```

For example:

```text
sel = 2'b0x
```

The `default` branch can provide a defined output rather than leaving the output unassigned.

---

# 7. Why Complete Assignment Matters

Consider:

```verilog
always @(*) begin

    case (sel)

        2'b00: y = a;
        2'b01: y = b;

    endcase

end
```

What happens for:

```text
sel = 10
```

or:

```text
sel = 11
```

There is no assignment to `y`.

In combinational RTL, this can cause latch inference.

Better:

```verilog
always @(*) begin

    case (sel)

        2'b00: y = a;
        2'b01: y = b;
        2'b10: y = c;
        2'b11: y = d;

        default: y = 1'b0;

    endcase

end
```

---

# 8. Default Assignment Style

Another good style is:

```verilog
always @(*) begin

    y = 1'b0;

    case (sel)

        2'b00: y = a;
        2'b01: y = b;
        2'b10: y = c;
        2'b11: y = d;

    endcase

end
```

The initial assignment guarantees that `y` gets a value.

This style becomes particularly useful in larger combinational blocks.

---

# 9. `case` vs `if/else`

### `if/else`

Best suited when conditions have priority.

Example:

```verilog
if (req3)
    grant = 2'b11;
else if (req2)
    grant = 2'b10;
else if (req1)
    grant = 2'b01;
else
    grant = 2'b00;
```

Priority:

```text
req3 > req2 > req1
```

### `case`

Best suited when selecting based on a selector value.

Example:

```verilog
case (sel)

    2'b00: y = a;
    2'b01: y = b;
    2'b10: y = c;
    2'b11: y = d;

endcase
```

Conceptually:

```text
if/else → condition-oriented
case    → value/selector-oriented
```

---

# 10. Important: Ordinary `case` Is Not Automatically Priority Logic

Consider:

```verilog
case (sel)

    2'b00: y = a;
    2'b01: y = b;
    2'b10: y = c;
    2'b11: y = d;

endcase
```

Each case item represents a value of `sel`.

It is not written as a priority chain like:

```verilog
if (condition1)
...
else if (condition2)
...
```

For normal mutually exclusive binary selector values, this distinction is straightforward.

---

# 11. `case` Syntax

General form:

```verilog
case (expression)

    expression1:
        statement1;

    expression2:
        statement2;

    expression3:
        statement3;

    default:
        statement_default;

endcase
```

Multiple statements can be placed inside `begin/end`:

```verilog
case (sel)

    2'b00: begin
        y = a;
        valid = 1'b1;
    end

    2'b01: begin
        y = b;
        valid = 1'b1;
    end

    default: begin
        y = 1'b0;
        valid = 1'b0;
    end

endcase
```

---

# 12. Day 18 Main Practical — 4-bit ALU Using `case`

Now we will use `case` in a realistic RTL block.

Inputs:

```text
a[3:0]
b[3:0]
op[2:0]
```

Output:

```text
y[3:0]
```

Operations:

| `op`  | Operation |
| ----- | --------- |
| `000` | A + B     |
| `001` | A - B     |
| `010` | A & B     |
| `011` | A | B     |
| `100` | A ^ B     |
| `101` | ~A        |
| `110` | A << 1    |
| `111` | A >> 1    |

This is a good example because the operation is selected using one control signal.

---

# 13. ALU RTL

Create:

```text
Day_18/rtl/alu_case.v
```

```verilog
module alu_case (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] op,
    output reg  [3:0] y
);

    always @(*) begin

        // Default output
        y = 4'b0000;

        case (op)

            3'b000: y = a + b;
            3'b001: y = a - b;
            3'b010: y = a & b;
            3'b011: y = a | b;
            3'b100: y = a ^ b;
            3'b101: y = ~a;
            3'b110: y = a << 1;
            3'b111: y = a >> 1;

            default: y = 4'b0000;

        endcase

    end

endmodule
```

---

# 14. Understanding the ALU

Suppose:

```text
a = 4'b1010
b = 4'b0011
```

Then:

### `op = 000`

```text
A + B
1010
0011
----
1101
```

So:

```text
y = 1101
```

---

### `op = 001`

```text
A - B

1010 - 0011 = 0111
```

So:

```text
y = 0111
```

---

### `op = 010`

```text
A & B

1010
0011
----
0010
```

---

### `op = 011`

```text
A | B

1010
0011
----
1011
```

---

### `op = 100`

```text
A ^ B

1010
0011
----
1001
```

---

### `op = 101`

```text
~A

~1010 = 0101
```

---

### `op = 110`

```text
A << 1

1010 << 1 = 0100
```

The result is 4 bits, so the bit shifted beyond the MSB is discarded.

---

### `op = 111`

```text
A >> 1

1010 >> 1 = 0101
```

---

# 15. ALU Testbench

Create:

```text
Day_18/tb/tb_alu_case.v
```

```verilog
`timescale 1ns/1ps

module tb_alu_case;

    reg  [3:0] a;
    reg  [3:0] b;
    reg  [2:0] op;

    wire [3:0] y;

    integer i;
    integer errors;

    reg [3:0] expected;

    alu_case dut (
        .a(a),
        .b(b),
        .op(op),
        .y(y)
    );

    initial begin

        $dumpfile("sim/alu_case.vcd");
        $dumpvars(0, tb_alu_case);

        errors = 0;

        // Test several representative values
        a = 4'b1010;
        b = 4'b0011;

        for (i = 0; i < 8; i = i + 1) begin

            op = i;
            #1;

            case (op)
                3'b000: expected = a + b;
                3'b001: expected = a - b;
                3'b010: expected = a & b;
                3'b011: expected = a | b;
                3'b100: expected = a ^ b;
                3'b101: expected = ~a;
                3'b110: expected = a << 1;
                3'b111: expected = a >> 1;
                default: expected = 4'b0000;
            endcase

            if (y !== expected) begin
                $display("ERROR: op=%b y=%b expected=%b",
                         op, y, expected);
                errors = errors + 1;
            end
            else begin
                $display("PASS: op=%b y=%b", op, y);
            end

        end

        if (errors == 0)
            $display("ALL ALU TESTS PASSED");
        else
            $display("ALU TEST FAILED: %0d errors", errors);

        $finish;

    end

endmodule
```

---

# 16. Compile and Run

Create directories:

```bash
mkdir -p ~/Verilog_50_Days/Day_18/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_18
```

Compile:

```bash
iverilog -o sim/day18 \
rtl/alu_case.v \
tb/tb_alu_case.v
```

Run:

```bash
vvp sim/day18
```

---

# 17. Expected Output

You should get results similar to:

```text
PASS: op=000 y=1101
PASS: op=001 y=0111
PASS: op=010 y=0010
PASS: op=011 y=1011
PASS: op=100 y=1001
PASS: op=101 y=0101
PASS: op=110 y=0100
PASS: op=111 y=0101
ALL ALU TESTS PASSED
```

The exact formatting of time/display output can vary.

---

# 18. GTKWave

The testbench creates:

```text
sim/alu_case.vcd
```

Open:

```bash
gtkwave sim/alu_case.vcd
```

Add:

```text
a
b
op
y
```

Observe that changing `op` changes the selected ALU operation.

---

# 19. Better Verification — Exhaustive ALU Test

For placement-quality verification, don't only test one pair of operands.

There are:

```text
16 possible A values
×
16 possible B values
×
8 possible operations
```

Therefore:

```text
16 × 16 × 8 = 2048
```

possible combinations.

A strong testbench can verify all 2048 cases.

Replace the representative-value loop with:

```verilog
integer ai;
integer bi;
integer oi;

initial begin

    errors = 0;

    for (ai = 0; ai < 16; ai = ai + 1) begin

        for (bi = 0; bi < 16; bi = bi + 1) begin

            for (oi = 0; oi < 8; oi = oi + 1) begin

                a  = ai;
                b  = bi;
                op = oi;

                #1;

                case (op)
                    3'b000: expected = a + b;
                    3'b001: expected = a - b;
                    3'b010: expected = a & b;
                    3'b011: expected = a | b;
                    3'b100: expected = a ^ b;
                    3'b101: expected = ~a;
                    3'b110: expected = a << 1;
                    3'b111: expected = a >> 1;
                    default: expected = 4'b0000;
                endcase

                if (y !== expected)
                    errors = errors + 1;

            end

        end

    end

    if (errors == 0)
        $display("ALL 2048 ALU TESTS PASSED");
    else
        $display("FAILED: %0d errors", errors);

    $finish;

end
```

This is a much stronger verification method.

---

# 20. `case` With Multiple Statements

You can execute multiple statements for one case item:

```verilog
case (op)

    2'b00: begin
        y = a + b;
        carry = 1'b0;
    end

    2'b01: begin
        y = a - b;
        carry = 1'b0;
    end

    default: begin
        y = 4'b0000;
        carry = 1'b0;
    end

endcase
```

Use:

```verilog
begin
    ...
end
```

when one case branch contains multiple procedural statements.

---

# 21. `case` and X/Z Values

Verilog uses four-state logic:

```text
0
1
X
Z
```

Consider:

```verilog
case (sel)

    2'b00: y = 0;
    2'b01: y = 1;
    2'b10: y = 2;
    2'b11: y = 3;

    default: y = 0;

endcase
```

If:

```text
sel = 2'b0x
```

it does not exactly match the ordinary binary item `2'b00` or `2'b01`.

The `default` branch can therefore be selected.

This is useful for detecting unexpected simulation states.

---

# 22. `casez`

`casez` treats `Z` and `?` as don't-care bits for matching.

Example:

```verilog
casez (req)

    4'b1???: grant = 2'b11;
    4'b01??: grant = 2'b10;
    4'b001?: grant = 2'b01;
    4'b0001: grant = 2'b00;

    default: grant = 2'b00;

endcase
```

This can be useful for pattern matching.

The `?` character represents a don't-care position in the case item.

---

# 23. `casex`

`casex` treats X and Z as don't-care values.

Example:

```verilog
casex (sel)

    4'b1xxx: ...
    4'b01xx: ...
    4'b001x: ...
    4'b0001: ...

endcase
```

However, `casex` can hide unknown (`X`) values during simulation.

For robust RTL verification, be careful with `casex`.

A useful general rule:

```text
case   → exact matching
casez  → Z/? don't-care matching
casex  → X/Z don't-care matching
```

---

# 24. `case` vs `casez` vs `casex`

| Statement | Matching behavior                  |
| --------- | ---------------------------------- |
| `case`    | Exact 4-state matching             |
| `casez`   | Z and `?` can act as don't-care    |
| `casex`   | X, Z and `?` can act as don't-care |

For ordinary selector logic:

```verilog
case (sel)
```

is often the clearest choice.

---

# 25. `case` in Sequential RTL

`case` is not restricted to combinational logic.

It can also be used inside a clocked block.

Example:

```verilog
always @(posedge clk) begin

    case (state)

        2'b00: state <= 2'b01;
        2'b01: state <= 2'b10;
        2'b10: state <= 2'b11;
        2'b11: state <= 2'b00;

        default: state <= 2'b00;

    endcase

end
```

This is sequential logic because the block is triggered by:

```verilog
posedge clk
```

and uses:

```verilog
<=
```

Later, this becomes extremely important when we study FSMs.

---

# 26. `case` for FSMs

A common FSM coding style is:

```verilog
always @(posedge clk) begin

    case (state)

        IDLE:
            state <= RUN;

        RUN:
            state <= DONE;

        DONE:
            state <= IDLE;

        default:
            state <= IDLE;

    endcase

end
```

You will use this heavily when we reach the FSM section of the roadmap.

---

# 27. Common Mistakes

## Mistake 1 — Missing `default`

```verilog
case (sel)
    2'b00: y = a;
    2'b01: y = b;
endcase
```

For combinational logic, uncovered values can cause incomplete assignment.

Better:

```verilog
default: y = 1'b0;
```

---

## Mistake 2 — Missing assignment in a branch

Bad:

```verilog
case (sel)

    2'b00: begin
        y = a;
    end

    2'b01: begin
        // y not assigned
    end

endcase
```

Every required output should be assigned.

---

## Mistake 3 — Using blocking incorrectly in clocked logic

Avoid:

```verilog
always @(posedge clk)
    q = d;
```

Prefer:

```verilog
always @(posedge clk)
    q <= d;
```

---

## Mistake 4 — Confusing `case` with priority logic

If your conditions overlap and you specifically need priority, an ordered `if/else if` chain may make that intent clearer.

---

# 28. Day 18 Practice Problems

### Practice 1 — 4:1 MUX

Implement:

```text
a,b,c,d
sel[1:0]
y
```

using `case`.

---

### Practice 2 — 8:1 MUX

Inputs:

```text
d[7:0]
```

Select:

```text
sel[2:0]
```

Output:

```text
y
```

Use `case`.

Verify all 8 selector values.

---

### Practice 3 — ALU

Expand today's ALU with:

```text
000 → ADD
001 → SUB
010 → AND
011 → OR
100 → XOR
101 → NOT
110 → SHIFT LEFT
111 → SHIFT RIGHT
```

Then create an exhaustive testbench.

---

### Practice 4 — Decoder

Implement a 2-to-4 decoder:

```text
00 → 0001
01 → 0010
10 → 0100
11 → 1000
```

using `case`.

---

# 29. Placement Interview Questions

### Q1. What is a `case` statement?

A Verilog procedural construct that selects a statement based on the value of an expression.

### Q2. What is the purpose of `default`?

It handles values that do not match any explicit case item.

### Q3. Why is `default` useful in combinational logic?

It helps ensure outputs receive defined assignments for unexpected/uncovered input values and can prevent unintended latch inference.

### Q4. Difference between `case` and `if/else`?

`case` is convenient for matching one expression against multiple values, while `if/else` is convenient for conditional and priority-based decisions.

### Q5. What does `casez` do?

It allows Z and `?` to act as don't-care bits during matching.

### Q6. What does `casex` do?

It treats X and Z as don't-care values during matching.

### Q7. Why can `casex` be dangerous in verification?

Because an actual unknown `X` can be treated as a don't-care, potentially hiding an unknown or uninitialized condition.

### Q8. Can `case` be used in sequential logic?

Yes.

Example:

```verilog
always @(posedge clk)
    case (state)
        ...
    endcase
```

### Q9. What assignment should normally be used in a clocked `case` block?

Nonblocking:

```verilog
<=
```

### Q10. What hardware can a combinational `case` describe?

Depending on the coding structure, it can describe MUXes, decoders, ALU operation selection, and other combinational selection logic.

---

# 30. Day 18 Placement-Level Concept

Think of:

```verilog
case (op)
    3'b000: y = A;
    3'b001: y = B;
    3'b010: y = C;
    3'b011: y = D;
endcase
```

as:

```text
              ┌─────────┐
A ────────────┤         │
B ────────────┤         │
C ────────────┤  MUX    ├── Y
D ────────────┤         │
              └─────────┘
                   ↑
                  op
```

The Verilog code is a behavioral description of the hardware selection.

That is the RTL mindset:

```text
Verilog statement
      ↓
hardware behavior
      ↓
synthesis
      ↓
gates / muxes / registers
```

---

# 31. Day 18 Checklist

Before moving to Day 19, you should know:

* [ ] What `case` does
* [ ] Basic `case` syntax
* [ ] `default`
* [ ] Why complete assignment matters
* [ ] `case` vs `if/else`
* [ ] `casez`
* [ ] `casex`
* [ ] X/Z behavior
* [ ] 4:1 MUX using `case`
* [ ] ALU using `case`
* [ ] `case` in sequential logic
* [ ] `case` in FSMs
* [ ] Why `<=` is used in clocked logic
* [ ] How to verify a `case` design
* [ ] How to inspect the waveform using GTKWave

---

# 32. Golden Rules

```text
case → selector/value-based decision
```

```text
if/else → condition/priority-based decision
```

```text
combinational case → use blocking =
```

```text
clocked case → normally use nonblocking <=
```

```text
default → handle unmatched cases
```

```text
casex → use carefully because X values can be hidden
```

### Most important concept

```text
case (selector)
      ↓
match selector value
      ↓
select corresponding operation
      ↓
combinational/sequential hardware
```

# Day 18 Final Assignment

Implement a **4-bit ALU using `case`** with:

```text
op = 000 → ADD
op = 001 → SUB
op = 010 → AND
op = 011 → OR
op = 100 → XOR
op = 101 → NOT A
op = 110 → A << 1
op = 111 → A >> 1
```

Then verify:

```text
16 × 16 × 8 = 2048
```

input combinations.

Your target workflow is:

```text
RTL
 ↓
Icarus Verilog
 ↓
VVP
 ↓
PASS/FAIL checking
 ↓
GTKWave
```
