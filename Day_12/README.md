# Day 12 — Switch Modeling & CMOS Inverter

## 1. Day 12 Objective

Today you will learn:

* What switch-level modeling is
* Why switch modeling is different from RTL/dataflow/behavioral modeling
* Verilog MOS switch primitives
* `nmos`
* `pmos`
* `cmos`
* How an NMOS behaves as a switch
* How a PMOS behaves as a switch
* CMOS inverter structure
* CMOS inverter truth table
* CMOS inverter using Verilog switch primitives
* Testbench and simulation
* Icarus Verilog + GTKWave
* Placement/viva questions

### Day 12 Roadmap Assignment

**CMOS Inverter**

---

# 2. What is Switch Modeling?

So far you have studied:

```text
Day 9  → Dataflow Modeling
Day 10 → Behavioral Modeling
Day 11 → Structural Modeling
Day 12 → Switch Modeling
```

Switch-level modeling describes digital circuits using **switch primitives**.

Instead of describing:

```text
Y = ~A
```

we describe the actual transistor-level switching behavior.

For MOS circuits, Verilog provides primitives such as:

```text
nmos
pmos
cmos
```

---

# 3. Why Study Switch Modeling?

At the transistor level, digital CMOS circuits are constructed from:

```text
PMOS
NMOS
```

For example, a CMOS inverter contains:

```text
        VDD
         |
       PMOS
         |
         +---- Y
         |
       NMOS
         |
        GND
```

The two transistors operate complementarily.

Therefore, switch-level modeling helps you understand the connection between:

```text
CMOS transistor
      ↓
Switch behavior
      ↓
Logic function
```

---

# 4. NMOS as a Switch

An NMOS can be viewed as a controlled switch.

Conceptually:

```text
       source
          |
        NMOS
          |
        drain
          |
        output

       gate
         |
       control
```

For the simplified digital switch model:

| Control | NMOS |
| ------- | ---- |
| 0       | OFF  |
| 1       | ON   |

So:

```text
Control = 0 → switch open
Control = 1 → switch closed
```

---

# 5. PMOS as a Switch

For a PMOS, the switching behavior is complementary.

| Control | PMOS |
| ------- | ---- |
| 0       | ON   |
| 1       | OFF  |

Therefore:

```text
NMOS:
0 → OFF
1 → ON

PMOS:
0 → ON
1 → OFF
```

This complementary behavior is fundamental to CMOS logic.

---

# 6. CMOS Inverter

A CMOS inverter contains:

```text
1 PMOS
1 NMOS
```

connected in series between:

```text
VDD
 |
PMOS
 |
OUTPUT
 |
NMOS
 |
GND
```

Both transistor gates are connected to the same input.

```text
             VDD
              |
             PMOS
              |
              +------ Y
              |
             NMOS
              |
             GND
              |
             

       Input A ─────┬──── Gate PMOS
                    │
                    └──── Gate NMOS
```

The output is:

$$
\boxed{Y=\overline{A}}
$$

---

# 7. CMOS Inverter Operation

## Case 1: Input A = 0

PMOS:

```text
A = 0
PMOS = ON
```

NMOS:

```text
A = 0
NMOS = OFF
```

Therefore the output is connected to VDD:

```text
VDD
 |
PMOS ON
 |
Y
```

So:

```text
Y = 1
```

---

## Case 2: Input A = 1

PMOS:

```text
A = 1
PMOS = OFF
```

NMOS:

```text
A = 1
NMOS = ON
```

Therefore the output is connected to GND:

```text
Y
 |
NMOS ON
 |
GND
```

So:

```text
Y = 0
```

---

# 8. CMOS Inverter Truth Table

This table is extremely important.

| Input A | PMOS | NMOS | Output Y |
| ------: | ---- | ---- | -------: |
|       0 | ON   | OFF  |        1 |
|       1 | OFF  | ON   |        0 |

Therefore:

$$
\boxed{Y=\overline{A}}
$$

The circuit is an inverter/NOT gate.

---

# 9. Why CMOS Uses Complementary Transistors

The PMOS and NMOS operate oppositely.

For:

```text
A = 0
```

PMOS conducts and NMOS does not.

For:

```text
A = 1
```

NMOS conducts and PMOS does not.

Ideally, in steady-state logic, one network pulls the output toward VDD while the other pulls it toward GND.

This complementary operation is the basic principle behind CMOS logic.

---

# 10. Verilog Switch-Level Primitives

Verilog provides transistor primitives.

Basic syntax:

```verilog
nmos (output, input, control);
```

and:

```verilog
pmos (output, input, control);
```

The exact terminal ordering matters.

For this lesson, we will use:

```verilog
nmos (output, source, gate);
pmos (output, source, gate);
```

---

# 11. NMOS Example

Consider:

```verilog
nmos n1 (
    y,
    a,
    control
);
```

Conceptually:

```text
a ── NMOS ── y
       ↑
    control
```

When `control=1`, the NMOS conducts.

When `control=0`, it is OFF.

---

# 12. PMOS Example

Similarly:

```verilog
pmos p1 (
    y,
    a,
    control
);
```

The PMOS has complementary control behavior.

```text
control = 0 → ON
control = 1 → OFF
```

---

# 13. CMOS Primitive

Verilog also provides a CMOS switch primitive:

```verilog
cmos (output, nmos_input, nmos_control,
               pmos_input, pmos_control);
```

The exact use is more specialized.

For learning the CMOS inverter, explicitly instantiating:

```text
PMOS
+
NMOS
```

makes the transistor structure easier to understand.

---

# 14. CMOS Inverter RTL Using Switch Primitives

Create:

```text
~/Verilog_50_Days/Day_12/rtl/cmos_inverter.v
```

Use:

```verilog
module cmos_inverter (
    input  wire a,
    output wire y
);

    supply1 vdd;
    supply0 gnd;

    pmos p1 (y, vdd, a);
    nmos n1 (y, gnd, a);

endmodule
```

---

# 15. Understanding the Code

### `supply1`

```verilog
supply1 vdd;
```

represents a constant logic-high supply.

Therefore:

```text
VDD = 1
```

### `supply0`

```verilog
supply0 gnd;
```

represents a constant logic-low supply.

Therefore:

```text
GND = 0
```

### PMOS

```verilog
pmos p1 (y, vdd, a);
```

This connects:

```text
VDD → PMOS → Y
```

controlled by `A`.

### NMOS

```verilog
nmos n1 (y, gnd, a);
```

This connects:

```text
Y → NMOS → GND
```

controlled by `A`.

---

# 16. Complete Circuit

The Verilog:

```verilog
supply1 vdd;
supply0 gnd;

pmos p1 (y, vdd, a);
nmos n1 (y, gnd, a);
```

represents:

```text
                 VDD
                  |
                  |
                PMOS
                  |
                  |
                  +--------- Y
                  |
                NMOS
                  |
                  |
                 GND

                 A
              ┌──┴──┐
              │     │
           PMOS   NMOS
            gate   gate
```

This is a CMOS inverter.

---

# 17. Testbench

Create:

```text
~/Verilog_50_Days/Day_12/tb/tb_cmos_inverter.v
```

```verilog
`timescale 1ns/1ps

module tb_cmos_inverter;

    reg  a;
    wire y;

    cmos_inverter dut (
        .a(a),
        .y(y)
    );

    initial begin

        $dumpfile("sim/cmos_inverter.vcd");
        $dumpvars(0, tb_cmos_inverter);

        a = 1'b0;
        #10;

        a = 1'b1;
        #10;

        a = 1'b0;
        #10;

        $finish;

    end

endmodule
```

---

# 18. Directory Structure

Create:

```bash
mkdir -p ~/Verilog_50_Days/Day_12/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_12
```

Your directory should look like:

```text
Day_12/
├── rtl/
│   └── cmos_inverter.v
├── tb/
│   └── tb_cmos_inverter.v
├── sim/
└── wave/
```

---

# 19. Compile

Run:

```bash
iverilog -o sim/cmos_inverter_sim \
    rtl/cmos_inverter.v \
    tb/tb_cmos_inverter.v
```

If there are no compilation errors, continue.

---

# 20. Run Simulation

```bash
vvp sim/cmos_inverter_sim
```

Expected:

```text
VCD info: dumpfile sim/cmos_inverter.vcd opened for output.
```

---

# 21. Open GTKWave

Run:

```bash
gtkwave sim/cmos_inverter.vcd
```

Add:

```text
a
y
```

You should see:

```text
A = 0 → Y = 1
A = 1 → Y = 0
A = 0 → Y = 1
```

Therefore:

$$
\boxed{Y=\overline{A}}
$$

---

# 22. Truth-Table Verification

Our simulation should produce:

|  Time |  A | Expected Y | Actual behavior   |
| ----: | -: | ---------: | ----------------- |
|  0 ns |  0 |          1 | PMOS ON, NMOS OFF |
| 10 ns |  1 |          0 | PMOS OFF, NMOS ON |
| 20 ns |  0 |          1 | PMOS ON, NMOS OFF |

Therefore the switch-level implementation matches the CMOS inverter truth table.

---

# 23. What Happens When A = 0?

Let's trace the circuit.

```text
A = 0
```

PMOS:

```text
PMOS → ON
```

NMOS:

```text
NMOS → OFF
```

Therefore:

```text
VDD
 |
PMOS ON
 |
 Y
```

Thus:

```text
Y = 1
```

---

# 24. What Happens When A = 1?

Now:

```text
A = 1
```

PMOS:

```text
PMOS → OFF
```

NMOS:

```text
NMOS → ON
```

Therefore:

```text
Y
 |
NMOS ON
 |
GND
```

Thus:

```text
Y = 0
```

---

# 25. Important Comparison — CMOS Inverter vs Verilog NOT

You could write an inverter very simply:

```verilog
assign y = ~a;
```

But that is **dataflow modeling**.

Our Day 12 implementation:

```verilog
pmos p1 (y, vdd, a);
nmos n1 (y, gnd, a);
```

is **switch-level modeling**.

The difference is what is being modeled.

### Dataflow

```text
Logic equation
```

### Switch-level

```text
Transistor switching behavior
```

---

# 26. Four Verilog Modeling Styles So Far

| Day    | Modeling   | Main Idea                  |
| ------ | ---------- | -------------------------- |
| Day 9  | Dataflow   | Signal equations           |
| Day 10 | Behavioral | Circuit behavior           |
| Day 11 | Structural | Module interconnection     |
| Day 12 | Switch     | Transistor/switch behavior |

This progression is important for interviews.

---

# 27. Switch-Level Primitives

Important Verilog switch primitives include:

```text
nmos
pmos
cmos
tran
tranif1
tranif0
rtran
rtranif1
rtranif0
```

For this roadmap day, the most important ones are:

```text
nmos
pmos
cmos
```

---

# 28. NMOS vs PMOS

| Property              | NMOS              | PMOS            |
| --------------------- | ----------------- | --------------- |
| Transistor type       | N-channel         | P-channel       |
| Control 0             | OFF               | ON              |
| Control 1             | ON                | OFF             |
| Used in CMOS inverter | Pull-down network | Pull-up network |

Remember:

> **NMOS turns ON with logic 1; PMOS turns ON with logic 0.**

---

# 29. CMOS Inverter as Pull-Up/Pull-Down Network

The CMOS inverter has two networks:

### Pull-up network

```text
PMOS
```

connects output toward:

```text
VDD
```

### Pull-down network

```text
NMOS
```

connects output toward:

```text
GND
```

Therefore:

```text
        VDD
         |
      Pull-Up
         |
         Y
         |
     Pull-Down
         |
        GND
```

For an inverter:

```text
Pull-Up  → PMOS
Pull-Down → NMOS
```

---

# 30. Why CMOS Has Low Static Power

In the ideal steady states:

```text
A = 0 → PMOS ON, NMOS OFF
A = 1 → PMOS OFF, NMOS ON
```

Thus there is ideally no direct DC path from VDD to GND in either stable logic state.

This is one of the fundamental reasons CMOS logic has very low static power consumption.

Dynamic power still occurs during switching.

---

# 31. Important Viva Questions

### Q1. What is switch-level modeling?

It is a Verilog modeling method that represents circuits using switch/transistor primitives.

### Q2. What is an NMOS?

An NMOS is an N-channel MOS transistor. In the simplified Verilog switch model, it conducts when its control input is logic 1.

### Q3. What is a PMOS?

A PMOS is a P-channel MOS transistor. In the simplified Verilog switch model, it conducts when its control input is logic 0.

### Q4. What is a CMOS inverter?

A CMOS inverter consists of a PMOS pull-up transistor and an NMOS pull-down transistor controlled by the same input.

### Q5. What is the Boolean equation of a CMOS inverter?

$$
\boxed{Y=\overline{A}}
$$

### Q6. What happens when A=0?

PMOS ON, NMOS OFF, therefore:

```text
Y = 1
```

### Q7. What happens when A=1?

PMOS OFF, NMOS ON, therefore:

```text
Y = 0
```

### Q8. What does `supply1` represent?

A constant logic-high supply.

### Q9. What does `supply0` represent?

A constant logic-low supply.

### Q10. Why is PMOS used for pull-up?

Because PMOS conducts for a low gate control and can connect the output to the high supply.

### Q11. Why is NMOS used for pull-down?

Because NMOS conducts for a high gate control and can connect the output to ground.

### Q12. What is the difference between switch-level and dataflow modeling?

Dataflow describes logic relationships using constructs such as `assign`, while switch-level modeling represents transistor/switch behavior using primitives.

---

# 32. Placement Questions

### Question 1

A CMOS inverter has:

```text
A = 0
```

What is the output?

**Answer:**

```text
Y = 1
```

because PMOS is ON and NMOS is OFF.

---

### Question 2

A CMOS inverter has:

```text
A = 1
```

What is the output?

**Answer:**

```text
Y = 0
```

because PMOS is OFF and NMOS is ON.

---

### Question 3

How many transistors are required for a basic CMOS inverter?

**Answer:**

```text
1 PMOS + 1 NMOS = 2 transistors
```

---

### Question 4

Which transistor forms the pull-up network?

**Answer:**

PMOS.

---

### Question 5

Which transistor forms the pull-down network?

**Answer:**

NMOS.

---

### Question 6

Which transistor turns ON for a high gate input?

**Answer:**

NMOS.

---

### Question 7

Which transistor turns ON for a low gate input?

**Answer:**

PMOS.

---

# 33. Day 12 Practice

## Practice 1 — CMOS NAND

Study how to construct a CMOS NAND gate using:

```text
PMOS network
NMOS network
```

Determine the transistor connections and truth table.

---

## Practice 2 — CMOS NOR

Construct a CMOS NOR gate using PMOS and NMOS transistor networks.

---

## Practice 3 — NMOS Switch

Create a simple switch-level circuit using:

```verilog
nmos
```

and verify its ON/OFF behavior.

---

## Practice 4 — PMOS Switch

Repeat using:

```verilog
pmos
```

---

## Practice 5 — Compare Modeling Styles

Implement an inverter using:

### Dataflow

```verilog
assign y = ~a;
```

### Behavioral

```verilog
always @(*) begin
    y = ~a;
end
```

### Switch-level

```verilog
pmos p1 (y, vdd, a);
nmos n1 (y, gnd, a);
```

Then compare the three implementations.

---

# 34. Day 12 Golden Workflow

```text
CMOS Inverter Specification
          ↓
Understand PMOS/NMOS
          ↓
Create Pull-Up Network
          ↓
Create Pull-Down Network
          ↓
Verilog Switch Primitives
          ↓
Write Testbench
          ↓
Icarus Verilog
          ↓
GTKWave
          ↓
Verify Y = ~A
```

---

# 35. Day 12 Golden Code

The most important code to remember:

```verilog
module cmos_inverter (
    input  wire a,
    output wire y
);

    supply1 vdd;
    supply0 gnd;

    pmos p1 (y, vdd, a);
    nmos n1 (y, gnd, a);

endmodule
```

And the fundamental operation:

```text
A = 0 → PMOS ON  → Y = 1
A = 1 → NMOS ON  → Y = 0
```

Therefore:

$$
\boxed{Y=\overline{A}}
$$

---

# 36. Day 12 Checklist

* [ ] Understand switch-level modeling
* [ ] Understand NMOS
* [ ] Understand PMOS
* [ ] Understand `nmos`
* [ ] Understand `pmos`
* [ ] Know `supply1`
* [ ] Know `supply0`
* [ ] Understand CMOS inverter
* [ ] Know PMOS pull-up network
* [ ] Know NMOS pull-down network
* [ ] Write CMOS inverter using switch primitives
* [ ] Write testbench
* [ ] Simulate using Icarus
* [ ] Verify using GTKWave
* [ ] Know the CMOS inverter truth table
* [ ] Answer placement/viva questions

# Final Day 12 Concept

> **Switch-level modeling represents digital circuits using switch/transistor primitives. A CMOS inverter uses one PMOS as the pull-up device and one NMOS as the pull-down device. When the input is 0, PMOS turns ON and the output is 1; when the input is 1, NMOS turns ON and the output is 0.**

$$
\boxed{Y=\overline{A}}
$$

# Days 1–12 Completed

You have now completed the first major section of the RTL roadmap:

```text
Day 01 → Naming Convention
Day 02 → Text-Based Design Flow
Day 03 → Graphic-Based Design Flow
Day 04 → wire
Day 05 → reg
Day 06 → integer
Day 07 → parameter / localparam
Day 08 → initialization
Day 09 → dataflow modeling
Day 10 → behavioral modeling
Day 11 → structural modeling
Day 12 → switch modeling
```

The next section begins with **Day 13 — Combinational vs Sequential Logic**.
