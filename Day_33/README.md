# Day 33 — Glue Logic in Verilog RTL

## 📌 Topic

**Glue Logic**

## 🎯 Roadmap Objective

Learn best practices for interconnecting modules using glue logic.

The Day 33 assignment from the roadmap is a practical interface-conversion problem:

> Subsystem A produces an `8-bit data` bus with a `VALID` signal, while Subsystem B accepts data only when `READY` is asserted. Design Verilog glue logic that handles this handshaking correctly.

---

# 1. Learning Objectives

By the end of Day 33, you should understand:

* What glue logic means.
* Why glue logic is required between modules.
* How two modules can have different interface requirements.
* `VALID` and `READY` handshaking.
* The meaning of a transfer.
* Why `VALID` and `READY` must be considered together.
* How to preserve data while waiting for `READY`.
* How to write synthesizable glue logic.
* How to verify a handshake using a testbench.
* Common handshake mistakes asked in placement interviews.

---

# 2. What is Glue Logic?

**Glue logic** is the small amount of logic used to connect two or more modules whose interfaces do not directly match.

For example:

```text
        Subsystem A
             │
             │ VALID + DATA
             ▼
       ┌─────────────┐
       │ Glue Logic  │
       └─────────────┘
             │
             │ READY + DATA
             ▼
        Subsystem B
```

The glue logic acts as an interface between the two subsystems.

---

# 3. Why is Glue Logic Needed?

Suppose:

### Subsystem A

Produces:

```text
VALID
DATA[7:0]
```

Subsystem A says:

> "I have valid data."

But Subsystem B has a different requirement.

### Subsystem B

Accepts data only when:

```text
READY = 1
```

Therefore, both modules need to cooperate.

```text
A                         B

VALID ────────────────►
DATA[7:0] ────────────►

              ◄──────── READY
```

Glue logic coordinates these signals.

---

# 4. VALID/READY Handshake

The basic rule is:

$$
\boxed{TRANSFER = VALID \land READY}
$$

A transfer occurs when:

```text
VALID = 1
READY = 1
```

Truth table:

| VALID | READY | Transfer |
| ----: | ----: | -------: |
|     0 |     0 |        0 |
|     0 |     1 |        0 |
|     1 |     0 |        0 |
|     1 |     1 |        1 |

This table is extremely important for interviews.

---

# 5. Meaning of VALID

`VALID = 1` means:

> The source is presenting valid data.

For example:

```text
VALID = 1
DATA  = 10110101
```

means the source is presenting:

```text
10110101
```

as valid data.

---

# 6. Meaning of READY

`READY = 1` means:

> The destination is able to accept the data.

For example:

```text
READY = 1
```

means the receiver is ready.

---

# 7. When Does Transfer Occur?

Only when:

```text
VALID = 1
READY = 1
```

Therefore:

```text
VALID ──┐
        ├── AND ──► TRANSFER
READY ──┘
```

RTL:

```verilog
assign transfer = valid & ready;
```

---

# 8. Important Rule

A source should not assume that:

```text
VALID = 1
```

automatically means that the transfer occurred.

It means:

```text
DATA IS VALID
```

The actual transfer occurs when:

```text
VALID && READY
```

---

# 9. Example Timing

Suppose:

```text
Cycle 1:
VALID = 1
READY = 0
```

No transfer.

```text
Cycle 2:
VALID = 1
READY = 0
```

No transfer.

```text
Cycle 3:
VALID = 1
READY = 1
```

Transfer occurs.

```text
Cycle 4:
VALID = 0
READY = 1
```

No transfer.

Therefore:

```text
Cycle       1   2   3   4
VALID       1   1   1   0
READY       0   0   1   1
TRANSFER    0   0   1   0
```

---

# 10. The Problem in Day 33

Our source:

```text
Subsystem A
```

produces:

```text
valid_in
data_in[7:0]
```

Our destination:

```text
Subsystem B
```

provides:

```text
ready_out
```

The glue logic must make sure that data is transferred only when both sides agree.

Architecture:

```text
              Subsystem A
                  │
            ┌─────┴─────┐
            │           │
          VALID       DATA
            │           │
            ▼           ▼
        ┌───────────────────┐
        │    Glue Logic     │
        └─────────┬─────────┘
                  │
             transfer
                  │
                  ▼
             Subsystem B
                  ▲
                  │
                READY
```

---

# 11. Basic Combinational Glue Logic

For a simple interface where the source data remains valid until accepted:

```verilog
module glue_logic_basic (
    input  wire       valid_in,
    input  wire [7:0] data_in,
    input  wire       ready_out,

    output wire       valid_out,
    output wire [7:0] data_out,
    output wire       transfer
);

    assign valid_out = valid_in;
    assign data_out  = data_in;
    assign transfer  = valid_in & ready_out;

endmodule
```

Here:

```text
VALID
```

and

```text
DATA
```

are passed through.

The glue logic generates:

```text
TRANSFER = VALID & READY
```

---

# 12. Truth Table Verification

For the transfer signal:

| `valid_in` | `ready_out` | `transfer` |
| ---------: | ----------: | ---------: |
|          0 |           0 |          0 |
|          0 |           1 |          0 |
|          1 |           0 |          0 |
|          1 |           1 |          1 |

Therefore:

$$
\boxed{transfer=valid\_in\land ready\_out}
$$

---

# 13. Why Data Must Remain Stable

Consider:

```text
VALID = 1
READY = 0
```

The source is saying:

> "I have data, but the receiver isn't ready."

The source should keep the transaction available until the receiver accepts it.

Conceptually:

```text
Cycle       1      2      3
VALID       1      1      1
READY       0      0      1
DATA       A5     A5     A5
                     │
                     ▼
                 Transfer
```

The data remains stable until the handshake occurs.

---

# 14. Registered Glue Logic

For a more realistic interface, we can place a register between the source and destination.

Architecture:

```text
Subsystem A
     │
     ▼
┌──────────────┐
│ Data Register│
└──────┬───────┘
       │
       ▼
Subsystem B
```

The register stores the data until it is accepted.

This prevents the source from changing the data while the receiver is not ready.

---

# 15. Registered VALID/READY Adapter

Create:

```text
valid_ready_glue.v
```

```verilog
module valid_ready_glue (
    input  wire       clk,
    input  wire       reset,

    input  wire       valid_in,
    input  wire [7:0] data_in,

    output wire       ready_in,

    output reg        valid_out,
    output reg  [7:0] data_out,

    input  wire       ready_out
);

    /*
     * The input can be accepted when the output register
     * is empty or when its current contents are being accepted.
     */
    assign ready_in = ~valid_out | ready_out;

    always @(posedge clk) begin

        if (reset) begin
            valid_out <= 1'b0;
            data_out  <= 8'b0;
        end

        else begin

            if (ready_in) begin
                valid_out <= valid_in;

                if (valid_in)
                    data_out <= data_in;
            end

        end

    end

endmodule
```

---

# 16. Understanding `ready_in`

This is the key expression:

```verilog
assign ready_in = ~valid_out | ready_out;
```

There are two cases where the glue logic can accept new input data.

### Case 1: Output register is empty

```text
valid_out = 0
```

Then:

```text
ready_in = 1
```

The input can be accepted.

### Case 2: Current output is being accepted

```text
ready_out = 1
```

Then the existing transaction can leave and a new transaction can enter.

Therefore:

$$
\boxed{ready\_in=\overline{valid\_out}+ready\_out}
$$

---

# 17. Truth Table for `ready_in`

| `valid_out` | `ready_out` | `ready_in` |
| ----------: | ----------: | ---------: |
|           0 |           0 |          1 |
|           0 |           1 |          1 |
|           1 |           0 |          0 |
|           1 |           1 |          1 |

This is equivalent to:

```text
ready_in = NOT valid_out OR ready_out
```

---

# 18. Data Flow

Suppose:

```text
DATA = 8'hA5
VALID = 1
READY = 0
```

The glue logic stores:

```text
data_out = A5
valid_out = 1
```

While:

```text
ready_out = 0
```

the output remains valid.

When:

```text
ready_out = 1
```

the destination accepts:

```text
A5
```

---

# 19. Handshake Transfer Equation

At the destination:

$$
\boxed{
transfer_{out}=valid_{out}\land ready_{out}
}
$$

At the input:

$$
\boxed{
transfer_{in}=valid_{in}\land ready_{in}
}
$$

These two concepts are important when designing streaming interfaces.

---

# 20. Complete Testbench

Create:

```text
tb_valid_ready_glue.v
```

```verilog
`timescale 1ns/1ps

module tb_valid_ready_glue;

    reg        clk;
    reg        reset;

    reg        valid_in;
    reg [7:0]  data_in;

    wire       ready_in;

    wire       valid_out;
    wire [7:0] data_out;

    reg        ready_out;

    valid_ready_glue dut (
        .clk       (clk),
        .reset     (reset),

        .valid_in  (valid_in),
        .data_in   (data_in),
        .ready_in  (ready_in),

        .valid_out (valid_out),
        .data_out  (data_out),
        .ready_out (ready_out)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("valid_ready_glue.vcd");
        $dumpvars(0, tb_valid_ready_glue);

        clk       = 1'b0;
        reset     = 1'b1;

        valid_in  = 1'b0;
        data_in   = 8'h00;
        ready_out = 1'b0;

        #20;

        reset = 1'b0;

        // Send A5
        @(negedge clk);
        valid_in = 1'b1;
        data_in  = 8'hA5;

        // Receiver not ready
        @(negedge clk);
        ready_out = 1'b0;

        @(negedge clk);
        ready_out = 1'b1;

        // Next transaction
        @(negedge clk);
        valid_in = 1'b1;
        data_in  = 8'h3C;

        @(negedge clk);
        valid_in = 1'b0;

        // Receiver accepts
        ready_out = 1'b1;

        #30;

        $finish;

    end

    always @(posedge clk) begin
        $display(
            "TIME=%0t VALID_IN=%b DATA_IN=%h READY_IN=%b VALID_OUT=%b DATA_OUT=%h READY_OUT=%b",
            $time,
            valid_in,
            data_in,
            ready_in,
            valid_out,
            data_out,
            ready_out
        );
    end

endmodule
```

---

# 21. Compile

From Ubuntu:

```bash
iverilog -o glue_sim \
    valid_ready_glue.v \
    tb_valid_ready_glue.v
```

Run:

```bash
vvp glue_sim
```

You should see the handshake behavior in the terminal.

---

# 22. GTKWave

Open:

```bash
gtkwave valid_ready_glue.vcd
```

Observe:

```text
clk
reset

valid_in
data_in
ready_in

valid_out
data_out
ready_out
```

Also observe:

```text
dut
```

signals if required.

---

# 23. What You Should See

The important behavior is:

```text
VALID_IN = 1
DATA_IN  = A5
READY_OUT = 0
```

The data is held.

Then:

```text
READY_OUT = 1
```

and the transaction is accepted.

Conceptually:

```text
              WAIT
               │
               │ READY=0
               ▼
          ┌───────────┐
          │   HOLD    │
          └─────┬─────┘
                │
             READY=1
                │
                ▼
           TRANSACTION
              ACCEPT
```

---

# 24. Important Handshake Rule

For a standard ready/valid interface:

### Source

The source asserts `VALID` when data is available.

### Destination

The destination asserts `READY` when it can accept data.

### Transfer

A transfer occurs when:

```text
VALID && READY
```

Therefore:

$$
\boxed{TRANSFER=VALID\land READY}
$$

---

# 25. Common Mistake #1

Incorrect idea:

```verilog
if (ready_out)
    valid_out = 1'b0;
```

without considering whether the current transaction was actually valid.

Correct reasoning:

```text
Transaction completes only when:

VALID = 1
AND
READY = 1
```

---

# 26. Common Mistake #2

Changing the data while:

```text
VALID = 1
READY = 0
```

can cause the receiver to observe inconsistent transaction data.

The source should maintain the transaction until acceptance.

---

# 27. Common Mistake #3

Thinking:

```text
READY = 1
```

means a transfer occurred.

It does not.

Example:

```text
VALID = 0
READY = 1
```

There is no transfer.

Truth table confirms:

```text
0 & 1 = 0
```

---

# 28. Common Mistake #4

Creating combinational loops between modules.

For example:

```text
A VALID → B READY
A READY ← B VALID
```

with both sides depending combinationally on each other can create problematic paths.

Good interface architecture should avoid unintended combinational loops.

---

# 29. Glue Logic Examples in Real RTL

Glue logic can be used for:

```text
Module A
   │
   ▼
Width conversion
   │
   ▼
Module B
```

or:

```text
Protocol A
   │
   ▼
Protocol conversion
   │
   ▼
Protocol B
```

or:

```text
Different control signals
        │
        ▼
    Glue Logic
        │
        ▼
 Compatible interface
```

Examples include:

* signal adaptation
* control-signal generation
* enable generation
* handshake conversion
* data-width adaptation
* interface connection
* status/control mapping

---

# 30. Placement Interview Questions

## Q1. What is glue logic?

Small logic used to connect modules or subsystems whose interfaces do not directly match.

---

## Q2. What is a VALID/READY handshake?

A protocol in which the source indicates valid data using `VALID` and the destination indicates its ability to accept using `READY`.

---

## Q3. When does a transfer occur?

$$
\boxed{VALID=1\ AND\ READY=1}
$$

---

## Q4. Does `VALID=1` guarantee a transfer?

No.

The destination must also assert `READY`.

---

## Q5. Does `READY=1` guarantee a transfer?

No.

`VALID` must also be asserted.

---

## Q6. What happens when `VALID=1` and `READY=0`?

The source has valid data, but the destination is not ready. The transaction must remain available until it can be accepted.

---

## Q7. What is the transfer equation?

$$
\boxed{TRANSFER=VALID\land READY}
$$

---

## Q8. Why is glue logic useful?

It allows independently designed modules with different interface requirements to communicate correctly.

---

## Q9. What is backpressure?

Backpressure occurs when the receiver cannot currently accept data and indicates this through `READY=0`.

The sender must then wait.

---

## Q10. What is the purpose of a registered interface adapter?

It can store data and control information so that the transaction remains stable while the receiver is not ready.

---

# 31. Practice Questions

### Practice 1

```text
VALID = 0
READY = 0
```

Transfer?

**Answer:**

```text
0
```

---

### Practice 2

```text
VALID = 0
READY = 1
```

Transfer?

**Answer:**

```text
0
```

---

### Practice 3

```text
VALID = 1
READY = 0
```

Transfer?

**Answer:**

```text
0
```

The source must wait.

---

### Practice 4

```text
VALID = 1
READY = 1
```

Transfer?

**Answer:**

```text
1
```

---

### Practice 5

Why must data remain stable while `VALID=1` and `READY=0`?

Because the receiver has not accepted the transaction yet. Changing the data could cause the receiver to see a different value when `READY` eventually becomes high.

---

# 32. Day 33 Assignment

Implement the roadmap assignment:

### Subsystem A

Inputs/outputs:

```text
VALID
DATA[7:0]
READY
```

### Glue Logic

Create an interface adapter that:

1. Accepts data from Subsystem A.
2. Stores the data when necessary.
3. Maintains `VALID` until the destination accepts the transaction.
4. Connects to Subsystem B.
5. Uses the VALID/READY handshake.
6. Does not lose data when `READY=0`.

Verify at least these cases:

```text
Case 1:
VALID=0, READY=0

Case 2:
VALID=0, READY=1

Case 3:
VALID=1, READY=0

Case 4:
VALID=1, READY=1
```

Then verify multiple consecutive data transfers.

---

# 33. Git Repository Structure

Your repository should now look like:

```text
50-Days-of-RTL/
│
├── Day_29_Concurrency/
├── Day_30_Recursive_Systems/
├── Day_31_Clock_Dividers/
├── Day_32_Fractional_Clock_Dividers/
│
└── Day_33_Glue_Logic/
    ├── README.md
    ├── glue_logic_basic.v
    ├── valid_ready_glue.v
    └── tb_valid_ready_glue.v
```

---

# 34. Git Commit

```bash
git add Day_33_Glue_Logic/
```

```bash
git commit -m "Day 33: Implement VALID READY glue logic"
```

```bash
git push
```

---

# 35. Day 33 Key Takeaways

Remember these for placement:

```text
1. Glue logic connects modules whose interfaces do not directly match.

2. VALID means the source has valid data.

3. READY means the destination can accept data.

4. A transfer occurs only when:

   VALID && READY

5. VALID=1 and READY=0 means WAIT.

6. The transaction/data should remain stable while waiting.

7. READY=1 alone does not mean a transfer.

8. VALID=1 alone does not mean a transfer.

9. Registered glue logic can store transactions.

10. Avoid unintended combinational loops between interfaces.
```

## ⭐ Most Important Formula

$$
\boxed{TRANSFER=VALID\land READY}
$$

### The four possible conditions

```text
VALID READY | TRANSFER
------------+---------
  0     0   |    0
  0     1   |    0
  1     0   |    0
  1     1   |    1
```

**Day 33 complete — Glue Logic and VALID/READY Handshaking.**
