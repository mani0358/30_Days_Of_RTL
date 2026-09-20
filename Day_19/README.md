# Day 19 — Tasks and Functions in Verilog

## 1. Day 19 Objective

Today you will learn:

* What a task is
* What a function is
* Task syntax
* Function syntax
* Inputs, outputs, and inouts
* Task vs function
* Timing restrictions
* Returning values from functions
* Using tasks/functions in testbenches
* Synthesizable tasks/functions
* Practical RTL example
* Placement interview questions

---

# 2. Why Do We Need Tasks and Functions?

Suppose you repeatedly need to perform the same operation.

Without a task/function:

```verilog
initial begin
    a = 4'b0011;
    b = 4'b0101;
    #10;

    a = 4'b1000;
    b = 4'b0010;
    #10;

    a = 4'b1111;
    b = 4'b0001;
    #10;
end
```

You may instead create reusable procedural code.

A **task** or **function** allows you to define the operation once and call it multiple times.

Conceptually:

```text
Define once
    ↓
Call many times
    ↓
Less repeated code
    ↓
Better readability
```

---

# 3. Task

A task is a reusable procedural block.

Basic syntax:

```verilog
task task_name;

    input  ...;
    output ...;

    begin
        // statements
    end

endtask
```

A task can have:

* inputs
* outputs
* inout arguments
* multiple statements
* timing controls

---

# 4. Simple Task Example

```verilog
task display_sum;

    input [3:0] a;
    input [3:0] b;

    begin
        $display("A=%d B=%d SUM=%d", a, b, a+b);
    end

endtask
```

Calling it:

```verilog
display_sum(4'd5, 4'd3);
```

Output:

```text
A=5 B=3 SUM=8
```

---

# 5. Task With Output

A task can return results through output arguments.

Example:

```verilog
task add_numbers;

    input  [3:0] a;
    input  [3:0] b;
    output [4:0] sum;

    begin
        sum = a + b;
    end

endtask
```

Call:

```verilog
reg [4:0] result;

add_numbers(4'd7, 4'd5, result);
```

Now:

```text
result = 12
```

---

# 6. Function

A function is another reusable procedural block.

Unlike a task, a function returns a value.

Basic syntax:

```verilog
function function_name;

    input ...;

    begin
        function_name = ...;
    end

endfunction
```

Example:

```verilog
function [4:0] add_numbers;

    input [3:0] a;
    input [3:0] b;

    begin
        add_numbers = a + b;
    end

endfunction
```

Calling:

```verilog
result = add_numbers(a, b);
```

---

# 7. Function Return Value

This is extremely important.

For a Verilog function:

```verilog
function [3:0] my_function;
```

the function name itself acts as the return variable.

Example:

```verilog
function [3:0] square;

    input [1:0] a;

    begin
        square = a * a;
    end

endfunction
```

Call:

```verilog
result = square(2'b11);
```

Therefore:

```text
3 × 3 = 9
```

and:

```text
result = 4'b1001
```

---

# 8. Task vs Function — Main Difference

The most important difference:

| Feature                   | Task                            | Function                                                     |
| ------------------------- | ------------------------------- | ------------------------------------------------------------ |
| Returns a value directly  | No                              | Yes                                                          |
| Can have multiple outputs | Yes                             | Limited by output/inout arguments depending on Verilog style |
| Can have input            | Yes                             | Yes                                                          |
| Can have output           | Yes                             | Yes                                                          |
| Can have inout            | Yes                             | Yes                                                          |
| Timing control            | Can contain timing controls     | Traditional Verilog function cannot contain timing controls  |
| Can call another task     | Yes                             | No                                                           |
| Usually used for          | Procedures/testbench operations | Calculations/combinational operations                        |

The key placement answer:

> **A function returns a value and is intended to execute without consuming simulation time; a task can consume simulation time and can have multiple outputs.**

---

# 9. Function Timing Restriction

Consider:

```verilog
function [3:0] add;
    input [3:0] a;
    input [3:0] b;

    begin
        add = a + b;
    end
endfunction
```

This is fine.

But a traditional Verilog function should not contain:

```verilog
#10
```

or:

```verilog
@(posedge clk)
```

or:

```verilog
wait(...)
```

because those consume simulation time.

A task can contain timing controls.

Example:

```verilog
task drive_data;

    input [3:0] data;

    begin
        #10;
        bus = data;
    end

endtask
```

This is a common testbench use of tasks.

---

# 10. Task With Timing Control

Example:

```verilog
task send_data;

    input [3:0] data;

    begin
        #10;
        $display("Sending data = %b", data);
    end

endtask
```

Call:

```verilog
initial begin

    send_data(4'b1010);
    send_data(4'b1100);
    send_data(4'b0011);

end
```

Because each call contains:

```text
#10
```

simulation time advances.

---

# 11. Function Example — Maximum of Two Numbers

```verilog
function [3:0] maximum;

    input [3:0] a;
    input [3:0] b;

    begin

        if (a > b)
            maximum = a;
        else
            maximum = b;

    end

endfunction
```

Usage:

```verilog
result = maximum(a, b);
```

This is a good example because the function performs a calculation and returns one result.

---

# 12. Function Inside RTL

Functions can be used inside RTL modules.

Example:

```verilog
module comparator_function (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output reg  [3:0] max_value
);

    function [3:0] maximum;

        input [3:0] x;
        input [3:0] y;

        begin
            if (x > y)
                maximum = x;
            else
                maximum = y;
        end

    endfunction

    always @(*) begin
        max_value = maximum(a, b);
    end

endmodule
```

The function improves code organization.

---

# 13. Function Does Not Automatically Mean Hardware

This is an important RTL concept.

Writing:

```verilog
function [3:0] maximum;
```

does not mean:

```text
hardware function block
```

by itself.

The synthesizer looks at what the function actually does.

For example:

```verilog
if (a > b)
    maximum = a;
else
    maximum = b;
```

can synthesize into comparison and selection logic.

Think:

```text
Verilog function
       ↓
behavioral description
       ↓
synthesis
       ↓
hardware
```

---

# 14. Task Can Also Be Synthesizable

Tasks are not only for testbenches.

A simple task containing synthesizable combinational operations may be synthesizable depending on the synthesis tool and coding style.

Example:

```verilog
task add_values;

    input  [3:0] a;
    input  [3:0] b;
    output [4:0] result;

    begin
        result = a + b;
    end

endtask
```

However, tasks containing simulation-only constructs such as:

```verilog
#10
$display(...)
```

are not suitable for normal synthesizable hardware.

---

# 15. Day 19 Practical — ALU Function

We will build a small ALU using a **function**.

Operations:

```text
000 → ADD
001 → SUB
010 → AND
011 → OR
100 → XOR
```

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

---

# 16. RTL

Create:

```text
Day_19/rtl/alu_function.v
```

```verilog
module alu_function (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] op,
    output reg  [3:0] y
);

    function [3:0] calculate;

        input [3:0] x;
        input [3:0] z;
        input [2:0] operation;

        begin

            case (operation)

                3'b000: calculate = x + z;
                3'b001: calculate = x - z;
                3'b010: calculate = x & z;
                3'b011: calculate = x | z;
                3'b100: calculate = x ^ z;

                default: calculate = 4'b0000;

            endcase

        end

    endfunction

    always @(*) begin
        y = calculate(a, b, op);
    end

endmodule
```

---

# 17. How This RTL Works

The function:

```verilog
function [3:0] calculate;
```

takes:

```text
x
z
operation
```

and returns:

```text
calculate
```

Then:

```verilog
y = calculate(a, b, op);
```

calls the function.

For:

```text
a = 1010
b = 0011
op = 000
```

the function performs:

```text
1010 + 0011 = 1101
```

Therefore:

```text
y = 1101
```

---

# 18. Testbench

Create:

```text
Day_19/tb/tb_alu_function.v
```

```verilog
`timescale 1ns/1ps

module tb_alu_function;

    reg [3:0] a;
    reg [3:0] b;
    reg [2:0] op;

    wire [3:0] y;

    integer ai;
    integer bi;
    integer oi;
    integer errors;

    reg [3:0] expected;

    alu_function dut (
        .a(a),
        .b(b),
        .op(op),
        .y(y)
    );

    initial begin

        $dumpfile("sim/alu_function.vcd");
        $dumpvars(0, tb_alu_function);

        errors = 0;

        for (ai = 0; ai < 16; ai = ai + 1) begin

            for (bi = 0; bi < 16; bi = bi + 1) begin

                for (oi = 0; oi < 5; oi = oi + 1) begin

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

                        default: expected = 4'b0000;

                    endcase

                    if (y !== expected) begin

                        $display(
                            "ERROR: A=%b B=%b OP=%b Y=%b EXPECTED=%b",
                            a, b, op, y, expected
                        );

                        errors = errors + 1;

                    end

                end

            end

        end

        if (errors == 0)
            $display("ALL 1280 FUNCTION ALU TESTS PASSED");
        else
            $display("FAILED: %0d errors", errors);

        $finish;

    end

endmodule
```

---

# 19. Why 1280 Tests?

We have:

```text
16 possible A values
×
16 possible B values
×
5 operations
```

Therefore:

```text
16 × 16 × 5 = 1280
```

test cases.

This gives exhaustive verification for the five implemented operations.

---

# 20. Run on Ubuntu

Create directories:

```bash
mkdir -p ~/Verilog_50_Days/Day_19/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_19
```

Compile:

```bash
iverilog -o sim/day19 \
rtl/alu_function.v \
tb/tb_alu_function.v
```

Run:

```bash
vvp sim/day19
```

Expected:

```text
ALL 1280 FUNCTION ALU TESTS PASSED
```

If you get:

```text
FAILED: ...
```

then stop and inspect the RTL/testbench rather than assuming the design is correct.

---

# 21. GTKWave

The testbench generates:

```text
sim/alu_function.vcd
```

Open it:

```bash
gtkwave sim/alu_function.vcd
```

Add:

```text
a
b
op
y
```

You can observe the function being evaluated whenever its input values change.

---

# 22. Task Practical

Now create a simple task-based testbench.

Create:

```text
Day_19/tb/task_demo.v
```

```verilog
`timescale 1ns/1ps

module task_demo;

    reg [3:0] a;
    reg [3:0] b;

    task check_add;

        input [3:0] x;
        input [3:0] z;

        begin

            a = x;
            b = z;

            #10;

            if ((a + b) == (x + z))
                $display(
                    "PASS: A=%d B=%d SUM=%d",
                    x, z, a+b
                );
            else
                $display("FAIL");

        end

    endtask

    initial begin

        check_add(4'd2, 4'd3);
        check_add(4'd7, 4'd4);
        check_add(4'd10, 4'd5);
        check_add(4'd15, 4'd1);

        $finish;

    end

endmodule
```

Run:

```bash
iverilog -o sim/task_demo tb/task_demo.v
vvp sim/task_demo
```

This demonstrates why tasks are convenient in testbenches.

---

# 23. Task With Multiple Outputs

One advantage of a task is that it can produce multiple output values.

Example:

```verilog
task add_with_carry;

    input  [3:0] a;
    input  [3:0] b;
    output [3:0] sum;
    output       carry;

    reg [4:0] temp;

    begin

        temp  = a + b;
        sum   = temp[3:0];
        carry = temp[4];

    end

endtask
```

Call:

```verilog
add_with_carry(a, b, sum, carry);
```

Now the task gives:

```text
sum
carry
```

---

# 24. Function With One Return Value

Equivalent calculation using a function could return the entire 5-bit result:

```verilog
function [4:0] add_with_carry;

    input [3:0] a;
    input [3:0] b;

    begin
        add_with_carry = a + b;
    end

endfunction
```

Then:

```verilog
result = add_with_carry(a, b);
```

and:

```text
result[3:0] → sum
result[4]   → carry
```

---

# 25. Important Difference

### Task

Can naturally return multiple values:

```text
task
 ├── sum
 └── carry
```

### Function

Has one function return value:

```text
function
    ↓
one returned value
```

Although Verilog functions can have output/inout arguments depending on the language version/style, for placement interviews remember the basic distinction:

> **Function → return a value. Task → procedural operation that can have multiple outputs.**

---

# 26. Function Called in an Expression

A function can be used naturally in expressions.

Example:

```verilog
assign y = maximum(a, b);
```

or:

```verilog
always @(*) begin
    y = maximum(a, b);
end
```

This is one reason functions are convenient for calculations.

---

# 27. Task Is Called as a Statement

A task is normally invoked as its own procedural statement:

```verilog
initial begin

    check_data(a, b);

end
```

You don't normally write:

```verilog
y = check_data(a, b);
```

because a task does not have the same direct return-value semantics as a function.

---

# 28. Scope of Tasks and Functions

A task/function can be declared inside a module.

Example:

```verilog
module example;

    function [3:0] double_value;
        input [3:0] a;

        begin
            double_value = a << 1;
        end
    endfunction

endmodule
```

It can then be called from procedural code in that module.

This is useful for organizing large RTL designs.

---

# 29. Tasks and Functions in Testbenches

Testbenches frequently use tasks.

Example:

```text
task
 ↓
drive inputs
 ↓
wait
 ↓
check output
 ↓
display result
```

This prevents repeating the same test sequence many times.

Example concept:

```verilog
task test_case;

    input [3:0] a;
    input [3:0] b;

    begin

        // drive inputs
        // wait
        // calculate expected value
        // compare DUT output
        // report PASS/FAIL

    end

endtask
```

This is a very useful verification pattern.

---

# 30. Synthesizable vs Simulation-Only

Not every task/function is synthesizable.

### Generally synthesizable operations

```text
+
-
&
|
^
if
case
comparisons
```

when written in synthesizable RTL style.

### Simulation-oriented operations

```text
#10
$display
$monitor
$finish
```

These are generally testbench/simulation constructs rather than hardware.

Therefore:

```text
RTL code
   ↓
must describe hardware
```

while:

```text
Testbench
   ↓
can control simulation time
```

---

# 31. Common Mistakes

## Mistake 1 — Putting delay in a traditional function

Avoid:

```verilog
function [3:0] add;
    input [3:0] a;
    input [3:0] b;

    begin
        #10;
        add = a + b;
    end
endfunction
```

Use a task if the procedure genuinely needs simulation timing.

---

## Mistake 2 — Forgetting function assignment

Wrong:

```verilog
function [3:0] add;
    input [3:0] a;
    input [3:0] b;

    begin
        a + b;
    end
endfunction
```

Correct:

```verilog
add = a + b;
```

The function name receives the returned value.

---

## Mistake 3 — Confusing task output with function return

Task:

```verilog
task add;
    output [3:0] result;
```

Function:

```verilog
function [3:0] add;
```

The function name itself is the return variable.

---

# 32. Day 19 Practice

## Practice 1 — Maximum Function

Write:

```verilog
function [7:0] maximum;
```

It should return the larger of two 8-bit numbers.

Test:

```text
10, 20 → 20
50, 30 → 50
255, 1 → 255
```

---

## Practice 2 — Even/Odd Function

Create:

```verilog
function is_even;
```

For an 8-bit input:

```text
LSB = 0 → even
LSB = 1 → odd
```

Expected:

```text
8'b00001010 → 1
8'b00001011 → 0
```

---

## Practice 3 — Full Adder Function

Create a function that calculates:

```text
sum
carry
```

You can return both together using a 2-bit function:

```verilog
function [1:0] full_adder_function;
```

Return:

```text
{carry, sum}
```

Verify all 8 combinations of:

```text
A
B
Cin
```

---

## Practice 4 — Testbench Task

Create:

```verilog
task test_add;
```

The task should:

1. Drive A
2. Drive B
3. Wait
4. Calculate expected result
5. Compare DUT output
6. Print PASS/FAIL

This is an important verification skill.

---

# 33. Placement Interview Questions

### Q1. What is a task?

A reusable procedural block that can have inputs, outputs, and inout arguments and can contain timing controls.

### Q2. What is a function?

A reusable procedural block that returns a value and, in traditional Verilog, executes without consuming simulation time.

### Q3. Can a function contain `#10`?

No, not in traditional Verilog function usage.

### Q4. Can a task contain `#10`?

Yes.

### Q5. Which is commonly used for testbench stimulus?

Tasks are commonly used.

### Q6. Which is convenient for calculations?

Functions are commonly used.

### Q7. How does a Verilog function return a value?

The function name itself is assigned the result.

Example:

```verilog
function [3:0] add;
    ...
    add = a + b;
endfunction
```

### Q8. Can a task have multiple outputs?

Yes.

### Q9. Can a function be used in an expression?

Yes.

Example:

```verilog
y = add(a, b);
```

### Q10. Are all tasks synthesizable?

No. Synthesizability depends on the contents and the synthesis tool. Simulation-only constructs such as delays and system tasks are not normal synthesizable hardware.

### Q11. Can tasks be used inside RTL?

Yes, if the task is written in a synthesizable manner and supported by the synthesis flow.

### Q12. What is the main difference between a task and function?

The short placement answer:

```text
Function → returns a value and does not consume simulation time.

Task → procedural block that can have multiple outputs and can consume simulation time.
```

---

# 34. Day 19 Golden Rules

```text
FUNCTION
    ↓
returns a value
    ↓
used for calculations
    ↓
no simulation-time control in traditional Verilog
```

```text
TASK
    ↓
procedural operation
    ↓
can have multiple outputs
    ↓
can contain timing controls
```

Remember:

```text
Function → value
Task     → procedure
```

---

# 35. Day 19 Verification Workflow

Use:

```text
Specification
      ↓
Choose task/function
      ↓
Write RTL
      ↓
Write testbench
      ↓
Icarus Verilog
      ↓
VVP
      ↓
PASS/FAIL
      ↓
GTKWave
```

For today's ALU:

```text
16 × 16 × 5 = 1280
```

combinations are verified.

---

# 36. Day 19 Final Assignment

Create a **4-bit full-adder function**.

Inputs:

```text
A
B
Cin
```

Output:

```text
{Cout, Sum}
```

Use:

```verilog
function [1:0] full_adder_function;
```

Verify all:

```text
2³ = 8
```

combinations.

Truth table:

|  A |  B | Cin | Cout | Sum |
| -: | -: | --: | ---: | --: |
|  0 |  0 |   0 |    0 |   0 |
|  0 |  0 |   1 |    0 |   1 |
|  0 |  1 |   0 |    0 |   1 |
|  0 |  1 |   1 |    1 |   0 |
|  1 |  0 |   0 |    0 |   1 |
|  1 |  0 |   1 |    1 |   0 |
|  1 |  1 |   0 |    1 |   0 |
|  1 |  1 |   1 |    1 |   1 |

Expected equations:

```text
Sum  = A ^ B ^ Cin

Cout = AB + ACin + BCin
```

The final returned value should be:

```verilog
{Cout, Sum}
```

so for:

```text
A=1
B=1
Cin=1
```

the function returns:

```text
{1,1} = 2'b11
```

---

# Day 19 Checklist

Before moving to Day 20:

* [ ] Understand task
* [ ] Understand function
* [ ] Know task syntax
* [ ] Know function syntax
* [ ] Know how a function returns a value
* [ ] Know task output arguments
* [ ] Know task timing controls
* [ ] Know function timing restriction
* [ ] Know task vs function
* [ ] Know synthesizable vs simulation-only constructs
* [ ] Use functions for reusable calculations
* [ ] Use tasks for reusable procedural/testbench sequences
* [ ] Successfully run the ALU function
* [ ] Verify the 4-bit full-adder function
