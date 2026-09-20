# Day 17 — `if/else` in Verilog RTL

## 1. Day 17 Objective

Today you will learn:

* `if`
* `if/else`
* `if/else if/else`
* Nested `if`
* Priority behavior of `if/else`
* `if/else` in combinational RTL
* Complete assignments and latch prevention
* `if/else` with enable signals
* `if/else` for a priority encoder
* Testbench verification using Icarus Verilog
* Placement/interview questions

### Roadmap connection

Day 15 → Blocking assignment `=`

Day 16 → Nonblocking assignment `<=`

**Day 17 → `if/else`**

The important combination is:

```text
Combinational logic + always @(*) + if/else + blocking (=)
```

---

# 2. What is `if`?

`if` allows Verilog to select an operation based on a condition.

Basic syntax:

```verilog
if (condition) begin
    statement;
end
```

Example:

```verilog
always @(*) begin
    if (a == 1'b1)
        y = 1'b1;
end
```

Meaning:

```text
If a = 1 → y = 1
```

But this example is incomplete because nothing specifies what happens when:

```text
a = 0
```

That can result in latch inference in synthesizable combinational logic.

---

# 3. `if/else`

Syntax:

```verilog
if (condition) begin
    statement1;
end
else begin
    statement2;
end
```

Example:

```verilog
always @(*) begin
    if (a)
        y = b;
    else
        y = c;
end
```

This describes:

```text
a = 1 → y = b
a = 0 → y = c
```

This is effectively a 2:1 multiplexer.

---

# 4. Truth Table — 2:1 MUX

For:

```verilog
if (sel)
    y = b;
else
    y = a;
```

| sel |  a |  b |  y |
| --: | -: | -: | -: |
|   0 |  0 |  0 |  0 |
|   0 |  0 |  1 |  0 |
|   0 |  1 |  0 |  1 |
|   0 |  1 |  1 |  1 |
|   1 |  0 |  0 |  0 |
|   1 |  0 |  1 |  1 |
|   1 |  1 |  0 |  0 |
|   1 |  1 |  1 |  1 |

Therefore:

```text
sel = 0 → y = a
sel = 1 → y = b
```

Equation:

```text
Y = (~sel & a) | (sel & b)
```

So an `if/else` statement can describe ordinary combinational hardware.

---

# 5. `if/else if/else`

When there are multiple conditions:

```verilog
if (condition1)
    statement1;
else if (condition2)
    statement2;
else if (condition3)
    statement3;
else
    statement4;
```

Example:

```verilog
always @(*) begin
    if (a > b)
        result = 2'b01;
    else if (a == b)
        result = 2'b00;
    else
        result = 2'b10;
end
```

Meaning:

```text
a > b  → result = 01
a = b  → result = 00
a < b  → result = 10
```

---

# 6. Important: `if/else` Creates Priority

Consider:

```verilog
if (req0)
    grant = 2'b01;
else if (req1)
    grant = 2'b10;
else
    grant = 2'b00;
```

If:

```text
req0 = 1
req1 = 1
```

then:

```text
grant = 01
```

because `req0` is checked first.

Therefore:

```text
if/else if/else
```

naturally represents **priority**.

This is different from independent conditions.

---

# 7. Priority Example

Suppose:

```text
req0 = 1
req1 = 1
req2 = 1
```

and:

```verilog
if (req0)
    grant = 3'b001;
else if (req1)
    grant = 3'b010;
else if (req2)
    grant = 3'b100;
else
    grant = 3'b000;
```

Only:

```text
grant = 001
```

is selected.

Priority:

```text
req0 > req1 > req2
```

The first true condition wins.

---

# 8. Nested `if`

An `if` can exist inside another `if`.

Example:

```verilog
always @(*) begin
    if (enable) begin
        if (sel)
            y = a;
        else
            y = b;
    end
    else begin
        y = 1'b0;
    end
end
```

Logic:

```text
enable = 0 → y = 0

enable = 1:
    sel = 0 → y = b
    sel = 1 → y = a
```

Nested `if` is useful when decisions depend on previous decisions.

---

# 9. Complete Assignment — Very Important

Consider:

```verilog
always @(*) begin
    if (enable)
        q = d;
end
```

What happens when:

```text
enable = 0
```

There is no assignment to `q`.

The synthesizer may infer storage:

```text
q retains its previous value
```

That means a latch can be created.

---

# 10. Correct Combinational Version

Use:

```verilog
always @(*) begin
    if (enable)
        q = d;
    else
        q = 1'b0;
end
```

Now both conditions are covered.

```text
enable = 1 → q = d
enable = 0 → q = 0
```

No storage is required.

---

# 11. Better Coding Style — Default Assignment

Another useful style is:

```verilog
always @(*) begin
    q = 1'b0;

    if (enable)
        q = d;
end
```

This gives a default value first.

Then the condition overrides it.

This is particularly useful for larger combinational blocks.

---

# 12. `if` with Sequential Logic

`if/else` is also heavily used in clocked logic.

For example:

```verilog
always @(posedge clk) begin
    if (reset)
        q <= 1'b0;
    else
        q <= d;
end
```

This describes a D flip-flop with synchronous reset.

Notice the assignment:

```verilog
<=
```

because this is sequential logic.

### Remember

```text
Combinational:
always @(*)
    =
```

```text
Sequential:
always @(posedge clk)
    <=
```

---

# 13. Enable Register

A common RTL pattern:

```verilog
always @(posedge clk) begin
    if (reset)
        q <= 4'b0000;
    else if (enable)
        q <= d;
end
```

Hardware behavior:

```text
reset = 1
    ↓
q = 0000

reset = 0, enable = 1
    ↓
q = d

reset = 0, enable = 0
    ↓
q holds previous value
```

Here holding the previous value is intentional because this is **sequential logic**.

This is different from incomplete assignment in combinational logic.

---

# 14. Day 17 Assignment — 4-to-2 Priority Encoder

We will implement a priority encoder using `if/else`.

Inputs:

```text
req[3:0]
```

Outputs:

```text
valid
grant[1:0]
```

Priority:

```text
req3 > req2 > req1 > req0
```

Therefore:

```text
If req3 = 1 → grant = 11
Else if req2 = 1 → grant = 10
Else if req1 = 1 → grant = 01
Else if req0 = 1 → grant = 00
Else → valid = 0
```

---

# 15. Truth Table

Because this is a priority encoder, multiple requests can be active.

| req3 | req2 | req1 | req0 | valid | grant |
| ---: | ---: | ---: | ---: | ----: | :---: |
|    0 |    0 |    0 |    0 |     0 |   XX  |
|    0 |    0 |    0 |    1 |     1 |   00  |
|    0 |    0 |    1 |    0 |     1 |   01  |
|    0 |    0 |    1 |    1 |     1 |   01  |
|    0 |    1 |    0 |    0 |     1 |   10  |
|    0 |    1 |    0 |    1 |     1 |   10  |
|    0 |    1 |    1 |    0 |     1 |   10  |
|    0 |    1 |    1 |    1 |     1 |   10  |
|    1 |    0 |    0 |    0 |     1 |   11  |
|    1 |    0 |    0 |    1 |     1 |   11  |
|    1 |    0 |    1 |    0 |     1 |   11  |
|    1 |    0 |    1 |    1 |     1 |   11  |
|    1 |    1 |    0 |    0 |     1 |   11  |
|    1 |    1 |    0 |    1 |     1 |   11  |
|    1 |    1 |    1 |    0 |     1 |   11  |
|    1 |    1 |    1 |    1 |     1 |   11  |

The important observation:

```text
req3 has highest priority.
```

For example:

```text
req = 4'b1011
```

Both `req3`, `req1`, and `req0` are active.

But:

```text
req3 wins
```

so:

```text
valid = 1
grant = 11
```

---

# 16. RTL — 4-to-2 Priority Encoder

Create:

```text
Day_17/rtl/priority_encoder_4to2.v
```

```verilog
module priority_encoder_4to2 (
    input  wire [3:0] req,
    output reg        valid,
    output reg  [1:0] grant
);

    always @(*) begin

        // Default values
        valid = 1'b0;
        grant = 2'b00;

        if (req[3]) begin
            valid = 1'b1;
            grant = 2'b11;
        end
        else if (req[2]) begin
            valid = 1'b1;
            grant = 2'b10;
        end
        else if (req[1]) begin
            valid = 1'b1;
            grant = 2'b01;
        end
        else if (req[0]) begin
            valid = 1'b1;
            grant = 2'b00;
        end

    end

endmodule
```

---

# 17. Understand the Code

First:

```verilog
valid = 1'b0;
grant = 2'b00;
```

These are default assignments.

Then:

```verilog
if (req[3])
```

checks the highest-priority request.

If it is zero:

```verilog
else if (req[2])
```

is checked.

Then:

```text
req3
 ↓
req2
 ↓
req1
 ↓
req0
```

This creates priority.

---

# 18. Testbench

Create:

```text
Day_17/tb/tb_priority_encoder_4to2.v
```

```verilog
`timescale 1ns/1ps

module tb_priority_encoder_4to2;

    reg  [3:0] req;
    wire       valid;
    wire [1:0] grant;

    integer i;

    priority_encoder_4to2 dut (
        .req(req),
        .valid(valid),
        .grant(grant)
    );

    initial begin

        $dumpfile("sim/priority_encoder_4to2.vcd");
        $dumpvars(0, tb_priority_encoder_4to2);

        $display("Time\tREQ\tVALID\tGRANT");

        for (i = 0; i < 16; i = i + 1) begin

            req = i;
            #10;

            $display("%0t\t%b\t%b\t%b",
                     $time, req, valid, grant);

        end

        $finish;

    end

endmodule
```

---

# 19. Directory Structure

Create:

```text
~/Verilog_50_Days/Day_17/
```

Inside:

```text
Day_17/
├── README.md
├── rtl/
│   └── priority_encoder_4to2.v
├── tb/
│   └── tb_priority_encoder_4to2.v
├── sim/
└── wave/
```

---

# 20. Create Directories

Ubuntu:

```bash
mkdir -p ~/Verilog_50_Days/Day_17/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_17
```

Check:

```bash
tree
```

If `tree` is not installed:

```bash
sudo apt install tree
```

---

# 21. Compile

From:

```text
~/Verilog_50_Days/Day_17
```

run:

```bash
iverilog -o sim/day17 \
rtl/priority_encoder_4to2.v \
tb/tb_priority_encoder_4to2.v
```

If there are no errors:

```bash
vvp sim/day17
```

---

# 22. Expected Output

You should see results similar to:

```text
Time    REQ    VALID   GRANT
10000   0000   0       00
20000   0001   1       00
30000   0010   1       01
40000   0011   1       01
50000   0100   1       10
60000   0101   1       10
70000   0110   1       10
80000   0111   1       10
90000   1000   1       11
...
160000  1111   1       11
```

The key verification:

```text
0000 → invalid

0001 → grant 00
001x → grant 01
01xx → grant 10
1xxx → grant 11
```

---

# 23. Open GTKWave

Run:

```bash
gtkwave sim/priority_encoder_4to2.vcd
```

Add:

```text
req
valid
grant
```

Observe that the highest asserted request always wins.

---

# 24. Important `if/else` Rule

Suppose:

```verilog
if (a)
    y = 1;
else if (b)
    y = 2;
else if (c)
    y = 3;
else
    y = 4;
```

If:

```text
a = 1
b = 1
c = 1
```

the result is:

```text
y = 1
```

because the first true condition wins.

Therefore:

> **The order of conditions matters in an `if/else if` chain.**

---

# 25. `if` vs Multiple Independent `if`

### Priority

```verilog
if (a)
    y = 1;
else if (b)
    y = 2;
```

First true condition wins.

### Independent

```verilog
if (a)
    y = 1;

if (b)
    y = 2;
```

The second `if` can overwrite the first assignment.

This is an important RTL coding difference.

---

# 26. `if/else` and `case`

Both can describe combinational selection.

### `if/else`

Good when:

```text
conditions have priority
```

Example:

```verilog
if (req3)
    ...
else if (req2)
    ...
```

### `case`

Often convenient when:

```text
one selector has multiple values
```

Example:

```verilog
case (sel)
    2'b00: ...
    2'b01: ...
    2'b10: ...
    2'b11: ...
endcase
```

You will study `case` in more detail later in the roadmap.

---

# 27. Common Mistakes

### Mistake 1 — Missing `else`

```verilog
always @(*) begin
    if (enable)
        y = d;
end
```

May infer a latch.

---

### Mistake 2 — Forgetting default assignment

For larger combinational blocks:

```verilog
always @(*) begin
    if (a)
        y = 1;
    else if (b)
        y = 2;
end
```

What happens when:

```text
a = 0
b = 0
```

`y` has no assignment.

Better:

```verilog
always @(*) begin

    y = 0;

    if (a)
        y = 1;
    else if (b)
        y = 2;

end
```

---

### Mistake 3 — Using `=` incorrectly in sequential logic

Avoid:

```verilog
always @(posedge clk)
    q = d;
```

For normal sequential RTL, use:

```verilog
always @(posedge clk)
    q <= d;
```

---

# 28. Combinational vs Sequential `if`

### Combinational

```verilog
always @(*) begin
    if (sel)
        y = a;
    else
        y = b;
end
```

Hardware:

```text
MUX
```

### Sequential

```verilog
always @(posedge clk) begin
    if (enable)
        q <= d;
end
```

Hardware:

```text
Flip-flop + enable behavior
```

Same `if`, different surrounding RTL → different hardware.

---

# 29. Placement Interview Questions

### Q1. What is the purpose of `if/else`?

It conditionally selects which procedural assignment is executed.

### Q2. Does `if/else` always create a multiplexer?

No. The resulting hardware depends on the surrounding RTL and whether the logic is combinational or sequential.

### Q3. What happens if a combinational `always` block does not assign an output in every possible condition?

A latch may be inferred.

### Q4. Why is `else if` useful for priority logic?

Because conditions are evaluated in order and the first true condition is selected.

### Q5. What is the difference between:

```verilog
if (a)
    y = 1;
else if (b)
    y = 2;
```

and:

```verilog
if (a)
    y = 1;

if (b)
    y = 2;
```

The first creates priority. In the second, both conditions can execute and the later assignment can overwrite the earlier one.

### Q6. What assignment operator is normally used for combinational procedural logic?

```verilog
=
```

### Q7. What assignment operator is normally used for clocked sequential logic?

```verilog
<=
```

### Q8. What is a priority encoder?

A circuit that selects the encoded value of the highest-priority active input.

### Q9. For priority:

```text
req3 > req2 > req1 > req0
```

what is the output for:

```text
req = 4'b1011
```

Answer:

```text
valid = 1
grant = 2'b11
```

because `req3` has the highest priority.

### Q10. Why do we use `always @(*)`?

It automatically includes signals read inside the procedural block in the combinational sensitivity list.

---

# 30. Day 17 Practice

## Practice 1

Implement a 4-bit comparator using `if/else`:

```text
a > b → greater = 1
a = b → equal = 1
a < b → less = 1
```

Verify all:

```text
16 × 16 = 256
```

input combinations.

---

## Practice 2

Implement a 4:1 MUX using `if/else`.

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

Expected:

```text
00 → a
01 → b
10 → c
11 → d
```

---

## Practice 3

Create an 8-to-3 priority encoder.

Priority:

```text
req7 > req6 > ... > req0
```

---

## Practice 4

Modify today's priority encoder so that when no request is active:

```text
valid = 0
grant = 2'b00
```

---

# 31. Day 17 Checklist

Before moving to Day 18, you should be able to explain:

* [ ] What `if` does
* [ ] What `if/else` does
* [ ] What `else if` does
* [ ] What nested `if` means
* [ ] Why `if/else if` creates priority
* [ ] Difference between independent `if` statements
* [ ] Why incomplete combinational assignment can infer a latch
* [ ] How to provide default assignments
* [ ] `=` vs `<=`
* [ ] Combinational `if`
* [ ] Sequential `if`
* [ ] Priority encoder
* [ ] How to verify RTL with a testbench
* [ ] How to inspect the waveform in GTKWave

---

# 32. Golden Rules for Day 17

```text
if/else → conditional decision
```

```text
else if → priority when conditions overlap
```

```text
always @(*) + complete assignments → combinational RTL
```

```text
always @(posedge clk) + <= → sequential RTL
```

```text
Incomplete combinational assignment → possible latch
```

```text
First true condition in an if/else chain wins
```

### Most important placement concept

Do not think:

```text
if statement = software only
```

Think:

```text
Verilog if/else
       ↓
hardware decision
       ↓
MUX / priority logic / enable / control logic
```

That is the RTL mindset you need for placement preparation.

# Day 17 Final Assignment

Implement and verify:

```text
8-to-3 Priority Encoder
```

with:

```text
req[7:0]
valid
grant[2:0]
```

Priority:

```text
req7 > req6 > req5 > req4 > req3 > req2 > req1 > req0
```

Use:

```verilog
always @(*)
```

and:

```verilog
if / else if / else
```

Then verify all:

```text
2^8 = 256
```

input combinations.
