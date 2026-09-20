# Day 24 — Shift Registers in Verilog RTL

## 1. Today's Objective

By the end of Day 24, you should understand:

* What a shift register is
* Why flip-flops are used to build shift registers
* Left shift vs right shift
* Serial input and serial output
* Parallel input and parallel output
* SISO, SIPO, PISO and PIPO registers
* How to code shift registers using Verilog
* Why nonblocking assignment `<=` is used
* How to verify a shift register using a testbench
* How shift registers are asked in campus-placement interviews

---

# 2. What Is a Shift Register?

A **shift register** is a group of flip-flops connected so that data can be shifted from one flip-flop to another on every active clock edge.

For example, a 4-bit right-shift register:

```text
Serial Input
     |
     v
   +-----+     +-----+     +-----+     +-----+
   | DFF | --> | DFF | --> | DFF | --> | DFF |
   | Q3  |     | Q2  |     | Q1  |     | Q0  |
   +-----+     +-----+     +-----+     +-----+
                                      |
                                      v
                                 Serial Output
```

On every clock:

```text
Q3 <= Serial_Input
Q2 <= old Q3
Q1 <= old Q2
Q0 <= old Q1
```

Therefore:

```text
New Q = {Serial_Input, Old_Q[3:1]}
```

---

# 3. Why Is It Sequential Logic?

A shift register contains flip-flops.

Flip-flops store information.

Therefore:

```text
Shift Register = Sequential Circuit
```

Its output depends on the previous stored value as well as the current input.

---

# 4. 4-bit Right Shift

Suppose:

```text
Initial Q = 1011
Serial input = 0
```

After one right shift:

```text
1011
  ↓
0101
```

The rightmost bit is shifted out.

For a 4-bit register:

```text
Before:

Q3 Q2 Q1 Q0
1  0  1  1

After right shift with SI=0:

0  1  0  1
↑
SI
```

Therefore:

```text
Q3(new) = SI
Q2(new) = Q3(old)
Q1(new) = Q2(old)
Q0(new) = Q1(old)
```

---

# 5. Right Shift Equation

For a 4-bit register:

```verilog
q <= {serial_in, q[3:1]};
```

Example:

```text
q       = 1011
q[3:1]  = 101
serial  = 0

new q = {0,101}

      = 0101
```

---

# 6. Left Shift

For a left shift:

```text
Q3 Q2 Q1 Q0
```

the bits move toward Q3:

```text
Q3 <= Q2
Q2 <= Q1
Q1 <= Q0
Q0 <= Serial_Input
```

Therefore:

```verilog
q <= {q[2:0], serial_in};
```

Example:

```text
Initial:

1011

Serial input = 0

After left shift:

0110
```

---

# 7. Right Shift vs Left Shift

| Operation   | Verilog                     |
| ----------- | --------------------------- |
| Right shift | `q <= {serial_in, q[3:1]};` |
| Left shift  | `q <= {q[2:0], serial_in};` |

Remember:

```text
Right shift:
bits move toward Q0

Left shift:
bits move toward Q3
```

---

# 8. Types of Shift Registers

There are four important configurations.

## SISO

**Serial-In Serial-Out**

```text
Serial Input → Register → Serial Output
```

Data enters one bit at a time and leaves one bit at a time.

---

## SIPO

**Serial-In Parallel-Out**

```text
             → Q3
             → Q2
Serial Input → Q1
             → Q0
```

Data enters serially and becomes available as a parallel word.

Useful for:

* Serial-to-parallel conversion
* Communication interfaces
* Expanding GPIO

---

## PISO

**Parallel-In Serial-Out**

Parallel data is loaded simultaneously and then shifted out one bit at a time.

```text
P[3:0]
  |
  v
Register
  |
  v
Serial Output
```

Useful for:

* Parallel-to-serial conversion
* Data transmission

---

## PIPO

**Parallel-In Parallel-Out**

```text
Parallel Input
      |
      v
   Register
      |
      v
Parallel Output
```

This is essentially a bank of flip-flops used for temporary storage.

---

# 9. SISO Example

Let's implement a 4-bit Serial-In Serial-Out right-shift register.

## RTL

Create:

```text
~/Verilog_50_Days/Day_24/rtl/shift_register_siso.v
```

Code:

```verilog
module shift_register_siso (
    input  wire       clk,
    input  wire       reset,
    input  wire       serial_in,
    output wire       serial_out,
    output reg  [3:0] q
);

    always @(posedge clk) begin
        if (reset)
            q <= 4'b0000;
        else
            q <= {serial_in, q[3:1]};
    end

    assign serial_out = q[0];

endmodule
```

---

# 10. Understand the Important Line

```verilog
q <= {serial_in, q[3:1]};
```

Suppose:

```text
q = 1011
serial_in = 0
```

Then:

```text
q[3:1] = 101
```

Concatenation:

```text
{serial_in, q[3:1]}

{0,101}

= 0101
```

So:

```text
1011 → 0101
```

---

# 11. Why `<=` Instead of `=`?

Because the shift register is sequential logic.

Use:

```verilog
always @(posedge clk)
```

and:

```verilog
<=
```

Therefore:

```verilog
always @(posedge clk) begin
    q <= {serial_in, q[3:1]};
end
```

This models simultaneous flip-flop updates correctly.

---

# 12. Shift Register Truth/Operation Table

For a right-shifting 4-bit register:

| Serial In | Old Q | New Q |
| --------: | :---: | :---: |
|         0 |  0000 |  0000 |
|         1 |  0000 |  1000 |
|         0 |  1000 |  0100 |
|         1 |  0100 |  1010 |
|         1 |  1010 |  1101 |
|         0 |  1101 |  0110 |

Notice that each new bit enters at Q3.

---

# 13. Example: Serial Data `1011`

Start with:

```text
Q = 0000
```

Send serial bits:

```text
1 0 1 1
```

Assuming right shift:

### Clock 1

```text
SI = 1

0000 → 1000
```

### Clock 2

```text
SI = 0

1000 → 0100
```

### Clock 3

```text
SI = 1

0100 → 1010
```

### Clock 4

```text
SI = 1

1010 → 1101
```

Therefore after four clocks:

```text
Q = 1101
```

This is an important point:

**The order in which bits appear in the register depends on the shift direction and which side is considered the first/last bit.**

---

# 14. Testbench

Create:

```text
~/Verilog_50_Days/Day_24/tb/tb_shift_register_siso.v
```

Code:

```verilog
`timescale 1ns/1ps

module tb_shift_register_siso;

    reg        clk;
    reg        reset;
    reg        serial_in;

    wire       serial_out;
    wire [3:0] q;

    shift_register_siso dut (
        .clk(clk),
        .reset(reset),
        .serial_in(serial_in),
        .serial_out(serial_out),
        .q(q)
    );

    always #5 clk = ~clk;

    task shift_bit;
        input bit_value;
        begin
            serial_in = bit_value;
            @(posedge clk);
            #1;
            $display(
                "Time=%0t SI=%b Q=%b SO=%b",
                $time, serial_in, q, serial_out
            );
        end
    endtask

    initial begin

        $dumpfile("sim/shift_register_siso.vcd");
        $dumpvars(0, tb_shift_register_siso);

        clk = 0;
        reset = 1;
        serial_in = 0;

        #12;

        reset = 0;

        shift_bit(1);
        shift_bit(0);
        shift_bit(1);
        shift_bit(1);

        #10;

        $finish;
    end

endmodule
```

---

# 15. Directory Setup

Run:

```bash
mkdir -p ~/Verilog_50_Days/Day_24/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_24
```

Create the RTL:

```bash
nano rtl/shift_register_siso.v
```

Create the testbench:

```bash
nano tb/tb_shift_register_siso.v
```

---

# 16. Compile

Run:

```bash
iverilog -o sim/day24 rtl/shift_register_siso.v tb/tb_shift_register_siso.v
```

If compilation succeeds, there should be no error.

---

# 17. Run

```bash
vvp sim/day24
```

You should see the register changing after each clock.

The important sequence should be approximately:

```text
SI=1  Q=1000
SI=0  Q=0100
SI=1  Q=1010
SI=1  Q=1101
```

---

# 18. Open GTKWave

```bash
gtkwave sim/shift_register_siso.vcd
```

Add:

```text
clk
reset
serial_in
q
serial_out
```

Observe that the serial input propagates through the flip-flops one clock at a time.

---

# 19. SIPO Shift Register

Now modify the concept slightly.

A SIPO register keeps all flip-flop outputs available:

```verilog
module shift_register_sipo (
    input  wire       clk,
    input  wire       reset,
    input  wire       serial_in,
    output reg  [3:0] q
);

    always @(posedge clk) begin
        if (reset)
            q <= 4'b0000;
        else
            q <= {serial_in, q[3:1]};
    end

endmodule
```

Here:

```text
serial_in
    |
    v
+---+---+---+---+
|Q3 |Q2 |Q1 |Q0 |
+---+---+---+---+
 |   |   |   |
 +---+---+---+----> Parallel outputs
```

---

# 20. PISO Shift Register

PISO needs a **parallel load** operation followed by shifting.

Conceptually:

```verilog
always @(posedge clk) begin
    if (reset)
        q <= 4'b0000;
    else if (load)
        q <= parallel_in;
    else
        q <= {serial_in, q[3:1]};
end
```

The important control is:

```text
load = 1 → load parallel data

load = 0 → shift
```

For example:

```text
parallel_in = 1011
```

Load:

```text
Q = 1011
```

Then shift repeatedly to transmit the stored data serially.

---

# 21. Shift Register with Enable

Often we don't want the register to shift on every clock.

We can add an enable:

```verilog
module shift_register_enable (
    input  wire       clk,
    input  wire       reset,
    input  wire       enable,
    input  wire       serial_in,
    output reg  [3:0] q
);

    always @(posedge clk) begin
        if (reset)
            q <= 4'b0000;
        else if (enable)
            q <= {serial_in, q[3:1]};
    end

endmodule
```

Behavior:

```text
reset=1  → clear

reset=0, enable=0 → hold

reset=0, enable=1 → shift
```

---

# 22. Shift Register vs Counter

Don't confuse these.

### Counter

```text
0000
0001
0010
0011
0100
...
```

The next state is generated by arithmetic.

### Shift Register

```text
1000
0100
1010
1101
...
```

The next state is generated by moving bits and inserting a serial input.

---

# 23. Shift Register Applications

Shift registers are used in:

* Serial-to-parallel conversion
* Parallel-to-serial conversion
* Data buffering
* Digital communication
* Delay lines
* LED/display control
* Data serialization
* Deserialization
* FPGA/ASIC datapaths
* Pipeline structures

---

# 24. Important Placement Concept: Shift Register as Delay

Consider:

```verilog
always @(posedge clk) begin
    q1 <= data;
    q2 <= q1;
    q3 <= q2;
end
```

This creates a 3-stage delay.

If:

```text
data = A
```

then:

```text
Clock 1 → q1 = A
Clock 2 → q2 = A
Clock 3 → q3 = A
```

So the data is delayed by clock cycles.

This is the basic idea behind **pipeline registers**.

---

# 25. Why Nonblocking Assignment Matters

Consider:

```verilog
always @(posedge clk) begin
    q1 <= data;
    q2 <= q1;
    q3 <= q2;
end
```

All three assignments use the **old values** at that clock edge.

Therefore:

```text
new q1 = old data
new q2 = old q1
new q3 = old q2
```

This is exactly what we want from a chain of flip-flops.

---

# 26. Common Mistake

Do NOT write sequential shift-register RTL like this:

```verilog
always @(posedge clk) begin
    q[3] = serial_in;
    q[2] = q[3];
    q[1] = q[2];
    q[0] = q[1];
end
```

With blocking assignments, the simulation can effectively propagate the newly assigned value through the statements in the same clocked procedural block.

Instead:

```verilog
always @(posedge clk) begin
    q[3] <= serial_in;
    q[2] <= q[3];
    q[1] <= q[2];
    q[0] <= q[1];
end
```

or preferably the compact form:

```verilog
q <= {serial_in, q[3:1]};
```

---

# 27. Important Interview Questions

### Q1. What is a shift register?

A shift register is a sequential circuit made from flip-flops that shifts stored data from one stage to another on clock edges.

### Q2. What is SISO?

Serial-In Serial-Out.

### Q3. What is SIPO?

Serial-In Parallel-Out.

### Q4. What is PISO?

Parallel-In Serial-Out.

### Q5. What is PIPO?

Parallel-In Parallel-Out.

### Q6. How do you implement a right shift?

```verilog
q <= {serial_in, q[3:1]};
```

### Q7. How do you implement a left shift?

```verilog
q <= {q[2:0], serial_in};
```

### Q8. Why is `<=` used?

Because the shift register is sequential logic and nonblocking assignment models simultaneous flip-flop updates.

### Q9. How many flip-flops are required for a 4-bit shift register?

```text
4 flip-flops
```

### Q10. How many flip-flops are required for an N-bit shift register?

```text
N flip-flops
```

### Q11. Is a shift register combinational or sequential?

```text
Sequential
```

### Q12. What happens when enable is `0`?

The register retains its previous value.

---

# 28. Campus Placement Question

Suppose:

```text
Q = 1011
```

and:

```text
serial_in = 0
```

For a right shift:

```verilog
q <= {serial_in, q[3:1]};
```

What is the new Q?

Answer:

```text
q[3:1] = 101

new Q = {0,101}

      = 0101
```

### Verify:

```text
Old Q:     1 0 1 1
             ↓ ↓ ↓
Shift:     0 1 0 1
           ↑
          SI=0
```

Correct:

```text
0101
```

---

# 29. Day 24 Assignment

Implement a **4-bit PISO shift register** with:

```text
clk
reset
load
parallel_in[3:0]
serial_out
```

Required behavior:

```text
reset = 1
    ↓
Q = 0000

load = 1
    ↓
Q = parallel_in

load = 0
    ↓
shift one bit every clock
```

Test it with:

```text
parallel_in = 1011
```

and verify the serial output for every shift.

Also implement:

```text
4-bit SIPO
```

and verify it by sending:

```text
1 0 1 1
```

---

# 30. Day 24 Checklist

Before moving to Day 25, you should be able to explain:

* [ ] What is a shift register?
* [ ] Why is it sequential?
* [ ] SISO
* [ ] SIPO
* [ ] PISO
* [ ] PIPO
* [ ] Left shift
* [ ] Right shift
* [ ] Serial input
* [ ] Serial output
* [ ] Parallel input
* [ ] Parallel output
* [ ] Shift enable
* [ ] Parallel load
* [ ] Why `<=` is used
* [ ] How to code a shift register
* [ ] How to verify it in Icarus
* [ ] How to inspect it in GTKWave

---

# Golden Rules — Day 24

```text
Shift register = sequential circuit

N-bit shift register = N flip-flops

Right shift:
q <= {serial_in, q[N-1:1]}

Left shift:
q <= {q[N-2:0], serial_in}

Clocked sequential logic:
always @(posedge clk)

Sequential assignment:
<=
```

The most important RTL pattern from today is:

```verilog
always @(posedge clk) begin
    if (reset)
        q <= 4'b0000;
    else
        q <= {serial_in, q[3:1]};
end
```

**Day 24 takeaway:**

> A shift register stores data and moves that data one position per clock cycle.
