# Day 27 — Arbiters in Verilog RTL

## 1. Today's Objective

Today you will learn:

* What an arbiter is
* Why arbitration is required
* Request and grant signals
* Priority arbiter
* Fixed-priority arbitration
* Round-robin arbitration
* Priority encoding
* Grant validity
* Combinational vs sequential arbitration
* How to implement a 4-request arbiter
* How to verify every request combination
* Fairness and starvation
* Placement interview questions

---

# 2. What Is an Arbiter?

An **arbiter** is a digital circuit that decides **which requester gets access to a shared resource** when multiple requesters request access at the same time.

For example:

```text
Requester 0 ──┐
Requester 1 ──┤
Requester 2 ──┼──> ARBITER ──> Shared Resource
Requester 3 ──┘
```

Only one requester should normally receive the grant at a time.

---

# 3. Why Do We Need an Arbiter?

Imagine four devices want to access one memory:

```text
CPU  ──┐
DMA  ──┤
USB  ──┼──> Memory
GPU  ──┘
```

If all request access simultaneously, the system needs a mechanism to decide:

```text
Who gets access?
```

That decision is performed by the arbiter.

---

# 4. Request and Grant

The two most important signals are:

```text
REQ
GRANT
```

For four requesters:

```text
req[3:0]
grant[3:0]
```

Example:

```text
req = 0101
```

means:

```text
Requester 0 → requesting
Requester 1 → not requesting
Requester 2 → requesting
Requester 3 → not requesting
```

The arbiter might produce:

```text
grant = 0001
```

meaning requester 0 wins.

---

# 5. One-Hot Grant

A common arbiter requirement is:

> At most one grant bit should be HIGH.

For example:

```text
0000  → nobody granted
0001  → requester 0
0010  → requester 1
0100  → requester 2
1000  → requester 3
```

These are **one-hot** grant values.

The invalid multi-grant examples are:

```text
0011
0101
1010
1111
```

because more than one requester has been granted.

---

# 6. Basic Arbiter Requirements

A good arbiter should satisfy:

### Rule 1 — No request means no grant

```text
REQ = 0000
```

should produce:

```text
GRANT = 0000
```

### Rule 2 — Grant only a requester

If:

```text
req[i] = 0
```

then:

```text
grant[i] = 0
```

### Rule 3 — Normally only one grant

```text
one-hot grant
```

### Rule 4 — Every grant must correspond to a request

```text
grant ⊆ request
```

---

# 7. Types of Arbiters

Two important types for placement preparation are:

```text
1. Fixed-Priority Arbiter
2. Round-Robin Arbiter
```

---

# 8. Fixed-Priority Arbiter

A fixed-priority arbiter always gives higher priority to one requester.

Suppose:

```text
REQ3 > REQ2 > REQ1 > REQ0
```

Then:

```text
Requester 3 = highest priority
Requester 0 = lowest priority
```

If:

```text
req = 0101
```

then requester 2 and requester 0 are requesting.

Requester 2 wins:

```text
grant = 0100
```

---

# 9. Priority Arbiter Truth Table

For four requesters with:

```text
REQ3 > REQ2 > REQ1 > REQ0
```

the complete request behavior is:

| req[3:0] | Grant | Winner |
| :------: | :---: | :----: |
|   0000   |  0000 |  None  |
|   0001   |  0001 |    0   |
|   0010   |  0010 |    1   |
|   0011   |  0010 |    1   |
|   0100   |  0100 |    2   |
|   0101   |  0100 |    2   |
|   0110   |  0100 |    2   |
|   0111   |  0100 |    2   |
|   1000   |  1000 |    3   |
|   1001   |  1000 |    3   |
|   1010   |  1000 |    3   |
|   1011   |  1000 |    3   |
|   1100   |  1000 |    3   |
|   1101   |  1000 |    3   |
|   1110   |  1000 |    3   |
|   1111   |  1000 |    3   |

This is the complete 16-case verification for a 4-request fixed-priority arbiter.

---

# 10. Priority Logic

The basic logic is:

```text
if req[3]
    grant = 1000
else if req[2]
    grant = 0100
else if req[1]
    grant = 0010
else if req[0]
    grant = 0001
else
    grant = 0000
```

Notice that only the **first true condition** is used.

That is why the ordering determines priority.

---

# 11. RTL — 4-to-4 Priority Arbiter

Create:

```bash
mkdir -p ~/Verilog_50_Days/Day_27/{rtl,tb,sim,wave}
cd ~/Verilog_50_Days/Day_27
```

Create:

```bash
nano rtl/priority_arbiter_4.v
```

Use:

```verilog
module priority_arbiter_4 (
    input  wire [3:0] req,
    output reg  [3:0] grant
);

    always @(*) begin

        grant = 4'b0000;

        if (req[3])
            grant = 4'b1000;
        else if (req[2])
            grant = 4'b0100;
        else if (req[1])
            grant = 4'b0010;
        else if (req[0])
            grant = 4'b0001;

    end

endmodule
```

---

# 12. Understand the Code

First:

```verilog
grant = 4'b0000;
```

This provides a default value.

Then:

```verilog
if (req[3])
```

checks the highest-priority requester.

If requester 3 is active:

```text
grant = 1000
```

and the remaining `else if` conditions are skipped.

If requester 3 isn't requesting, we check requester 2:

```verilog
else if (req[2])
```

and so on.

---

# 13. Why Is This a Combinational Circuit?

There is no clock:

```verilog
always @(*)
```

and no state storage.

Therefore:

```text
Current request
      ↓
Combinational priority logic
      ↓
Current grant
```

The grant changes when the request changes.

---

# 14. Why Is It Called a Priority Arbiter?

Because the priority is predetermined.

Our priority is:

```text
REQ3
 ↓
REQ2
 ↓
REQ1
 ↓
REQ0
```

If several requests are active simultaneously, the highest-priority active requester wins.

---

# 15. Testbench

Create:

```bash
nano tb/tb_priority_arbiter_4.v
```

Use:

```verilog
`timescale 1ns/1ps

module tb_priority_arbiter_4;

    reg  [3:0] req;
    wire [3:0] grant;

    integer i;
    integer expected;
    integer errors;

    priority_arbiter_4 dut (
        .req   (req),
        .grant (grant)
    );

    initial begin

        $dumpfile("sim/priority_arbiter_4.vcd");
        $dumpvars(0, tb_priority_arbiter_4);

        errors = 0;

        for (i = 0; i < 16; i = i + 1) begin

            req = i[3:0];

            #1;

            if (req[3])
                expected = 4'b1000;
            else if (req[2])
                expected = 4'b0100;
            else if (req[1])
                expected = 4'b0010;
            else if (req[0])
                expected = 4'b0001;
            else
                expected = 4'b0000;

            if (grant !== expected) begin

                $display(
                    "ERROR: req=%b grant=%b expected=%b",
                    req,
                    grant,
                    expected
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS: req=%b grant=%b",
                    req,
                    grant
                );

            end

        end

        if (errors == 0)
            $display("ALL 16 PRIORITY ARBITER TESTS PASSED");
        else
            $display("%0d TESTS FAILED", errors);

        $finish;

    end

endmodule
```

---

# 16. Compile

Run:

```bash
iverilog -o sim/day27 rtl/priority_arbiter_4.v tb/tb_priority_arbiter_4.v
```

Then:

```bash
vvp sim/day27
```

You should eventually see:

```text
ALL 16 PRIORITY ARBITER TESTS PASSED
```

---

# 17. GTKWave

Run:

```bash
gtkwave sim/priority_arbiter_4.vcd
```

Add:

```text
req
grant
```

Observe that:

```text
grant
```

is always either:

```text
0000
0001
0010
0100
1000
```

and never has multiple active bits.

---

# 18. Priority vs Normal Encoder

Don't confuse an ordinary encoder with a priority encoder/arbiter.

An ordinary encoder generally assumes a valid one-hot input.

A priority encoder can handle multiple active requests and selects one according to priority.

An arbiter goes one step further conceptually:

```text
Requesters competing for a resource
                ↓
             Arbiter
                ↓
          Grant one requester
```

---

# 19. What Is Starvation?

Consider:

```text
REQ3 > REQ2 > REQ1 > REQ0
```

Suppose:

```text
REQ3 = 1
```

continuously.

Then:

```text
REQ0
```

may never receive a grant.

This is called **starvation**.

A lower-priority requester can be continuously blocked by higher-priority requesters.

---

# 20. Why Round-Robin Arbitration?

Round-robin arbitration attempts to provide fairer access by rotating the starting priority.

For example:

```text
Round 1:
3 > 2 > 1 > 0

Round 2:
2 > 1 > 0 > 3

Round 3:
1 > 0 > 3 > 2

Round 4:
0 > 3 > 2 > 1
```

The exact starting point and update policy depend on the design.

The key idea is:

> Priority rotates after service.

---

# 21. Fixed Priority vs Round Robin

| Feature                | Fixed Priority  | Round Robin                                    |
| ---------------------- | --------------- | ---------------------------------------------- |
| Priority               | Fixed           | Rotates                                        |
| Hardware complexity    | Lower           | Higher                                         |
| Fairness               | Can be unequal  | Intended to be more balanced                   |
| Starvation possibility | Possible        | Reduced under appropriate protocol assumptions |
| State required         | Not necessarily | Usually yes                                    |
| Clock                  | Not necessarily | Usually used for pointer/state                 |
| Typical use            | Simple control  | Shared-resource fairness                       |

---

# 22. Round-Robin Concept

Suppose four requesters are:

```text
R0 R1 R2 R3
```

A round-robin arbiter maintains a pointer:

```text
pointer
```

The pointer tells us where to begin looking for a requester.

Example:

```text
pointer = 2
```

Search order might be:

```text
2 → 3 → 0 → 1
```

If requester 3 wins:

```text
next pointer = 0
```

This prevents requester 2 from automatically winning every time.

---

# 23. Simple Round-Robin Example

Suppose:

```text
request = 1111
```

and initial pointer is requester 0.

First grant:

```text
0001
```

Then pointer moves to requester 1.

Next grant:

```text
0010
```

Then:

```text
0100
```

Then:

```text
1000
```

Then back to:

```text
0001
```

So the service order is:

```text
0 → 1 → 2 → 3 → 0 → ...
```

when all requesters continuously request.

---

# 24. Important Point About Round Robin

A complete round-robin arbiter is **sequential** because it needs to remember the current priority pointer.

Therefore it contains state.

Conceptually:

```text
Requests
   |
   v
Round-Robin Logic <--- Priority Pointer
   |
   v
 Grant
   |
   v
Pointer Update
```

This is different from our fixed-priority arbiter.

---

# 25. Simple 4-Requester Round-Robin RTL

For learning the concept, we can implement a rotating pointer.

Create:

```bash
nano rtl/round_robin_arbiter_4.v
```

```verilog
module round_robin_arbiter_4 (
    input  wire       clk,
    input  wire       reset,
    input  wire [3:0] req,
    output reg  [3:0] grant
);

    reg [1:0] pointer;

    always @(*) begin

        grant = 4'b0000;

        case (pointer)

            2'd0: begin
                if      (req[0]) grant = 4'b0001;
                else if (req[1]) grant = 4'b0010;
                else if (req[2]) grant = 4'b0100;
                else if (req[3]) grant = 4'b1000;
            end

            2'd1: begin
                if      (req[1]) grant = 4'b0010;
                else if (req[2]) grant = 4'b0100;
                else if (req[3]) grant = 4'b1000;
                else if (req[0]) grant = 4'b0001;
            end

            2'd2: begin
                if      (req[2]) grant = 4'b0100;
                else if (req[3]) grant = 4'b1000;
                else if (req[0]) grant = 4'b0001;
                else if (req[1]) grant = 4'b0010;
            end

            2'd3: begin
                if      (req[3]) grant = 4'b1000;
                else if (req[0]) grant = 4'b0001;
                else if (req[1]) grant = 4'b0010;
                else if (req[2]) grant = 4'b0100;
            end

        endcase

    end

    always @(posedge clk) begin

        if (reset)
            pointer <= 2'd0;

        else begin

            case (grant)

                4'b0001: pointer <= 2'd1;
                4'b0010: pointer <= 2'd2;
                4'b0100: pointer <= 2'd3;
                4'b1000: pointer <= 2'd0;

                default: pointer <= pointer;

            endcase

        end

    end

endmodule
```

---

# 26. Understand the Round-Robin Code

There are two parts.

### Part 1 — Arbitration

```verilog
always @(*)
```

determines the current grant.

### Part 2 — Pointer update

```verilog
always @(posedge clk)
```

updates the priority pointer.

Therefore:

```text
Combinational:
req + pointer → grant
```

and:

```text
Sequential:
grant → new pointer
```

This is an important RTL architecture.

---

# 27. Why Is `pointer` 2 Bits?

There are four possible priority positions:

```text
0
1
2
3
```

Therefore:

```text
2^2 = 4
```

so:

```text
pointer[1:0]
```

is sufficient.

---

# 28. Example Round-Robin Operation

Suppose:

```text
req = 1111
```

and:

```text
pointer = 0
```

Search:

```text
0 → 1 → 2 → 3
```

Requester 0 wins:

```text
grant = 0001
```

At the next clock:

```text
pointer = 1
```

Now:

```text
1 → 2 → 3 → 0
```

Requester 1 wins:

```text
grant = 0010
```

Then:

```text
pointer = 2
```

Then requester 2 wins.

Then requester 3.

Then back to requester 0.

---

# 29. Important Real-Design Consideration

An arbiter often exists around a protocol that determines:

* When a request is accepted
* When a grant is valid
* How long a grant remains active
* When the requester releases the resource
* Whether a requester can hold the resource
* How arbitration occurs again

Therefore, the exact round-robin implementation can differ between designs.

For today's learning, focus on the fundamental concepts:

```text
request
grant
priority
pointer
fairness
```

---

# 30. Arbiter Verification

For a fixed-priority arbiter, we can exhaustively test all four-request combinations.

There are:

```text
2^4 = 16
```

possible request patterns.

For every pattern, verify:

### Property 1

At most one grant:

```text
$onehot0(grant)
```

Conceptually:

```text
grant has zero or one 1
```

### Property 2

Grant must correspond to a request:

```text
grant & ~req = 0
```

### Property 3

If no request:

```text
req = 0000
```

then:

```text
grant = 0000
```

### Property 4

Highest-priority requester wins.

---

# 31. Very Important Arbiter Properties

For:

```text
req = 1011
```

with:

```text
3 > 2 > 1 > 0
```

requesters:

```text
3, 1, 0
```

are active.

Requester 3 must win:

```text
grant = 1000
```

Not:

```text
0001
0010
1010
```

---

# 32. One-Hot Verification

Suppose:

```text
grant = 0100
```

Number of `1`s:

```text
1
```

Valid.

Suppose:

```text
grant = 0000
```

Number of `1`s:

```text
0
```

Also valid if no requester is selected.

But:

```text
grant = 0110
```

contains two `1`s.

That violates the one-grant-at-a-time requirement.

---

# 33. Priority Arbiter Boolean Equations

For priority:

```text
REQ3 > REQ2 > REQ1 > REQ0
```

we can derive:

```text
G3 = R3
```

```text
G2 = ~R3 & R2
```

```text
G1 = ~R3 & ~R2 & R1
```

```text
G0 = ~R3 & ~R2 & ~R1 & R0
```

These equations verify the `if/else` implementation.

---

# 34. Verify the Equations

Suppose:

```text
R = 0101
```

Therefore:

```text
R3 = 0
R2 = 1
R1 = 0
R0 = 1
```

Then:

```text
G3 = 0
```

```text
G2 = ~0 & 1 = 1
```

```text
G1 = ~0 & ~1 & 0 = 0
```

```text
G0 = ~0 & ~1 & ~0 & 1 = 0
```

Therefore:

```text
G = 0100
```

Correct.

---

# 35. Common Mistake

Do not write:

```verilog
if (req[0])
    grant = 4'b0001;

if (req[1])
    grant = 4'b0010;

if (req[2])
    grant = 4'b0100;

if (req[3])
    grant = 4'b1000;
```

This creates multiple sequential procedural assignments where the last true condition can overwrite the previous grant.

For priority behavior, use:

```verilog
if
else if
else if
else if
```

because only one branch should determine the winner.

---

# 36. Another Common Mistake

Don't forget the default:

```verilog
grant = 4'b0000;
```

Without a complete combinational assignment, synthesis can infer a latch.

Good:

```verilog
always @(*) begin

    grant = 4'b0000;

    if (...)
        ...
    else if (...)
        ...

end
```

---

# 37. Fixed Priority vs Round Robin — Interview Answer

If asked:

**"What is the difference between a fixed-priority arbiter and a round-robin arbiter?"**

Answer:

> A fixed-priority arbiter always uses the same priority order, so a continuously requesting high-priority client can prevent lower-priority clients from being served. A round-robin arbiter rotates the starting priority using stored state, which provides more balanced access under the appropriate arbitration protocol.

---

# 38. Placement Interview Questions

### Q1. What is an arbiter?

A circuit that selects one requester from multiple competing requesters for access to a shared resource.

### Q2. What are REQ and GRANT?

`REQ` indicates that a requester wants access, while `GRANT` indicates which requester has been selected.

### Q3. What is a fixed-priority arbiter?

An arbiter with a predetermined priority order.

### Q4. What is a round-robin arbiter?

An arbiter whose priority rotates among requesters.

### Q5. What is starvation?

A requester continuously fails to receive service because other requesters repeatedly win arbitration.

### Q6. Why can starvation occur in fixed-priority arbitration?

Because a higher-priority requester can continuously win.

### Q7. How does round-robin arbitration address this?

It rotates the starting priority so that requesters get opportunities according to the arbitration policy.

### Q8. Why is a round-robin arbiter sequential?

Because it needs to remember the priority pointer.

### Q9. Can a fixed-priority arbiter be purely combinational?

Yes. A simple fixed-priority arbiter does not require stored state.

### Q10. What does one-hot grant mean?

At most one bit of the grant vector is asserted.

### Q11. For four requesters, how many request combinations exist?

```text
2^4 = 16
```

### Q12. What is the priority equation for requester 1?

For:

```text
REQ3 > REQ2 > REQ1 > REQ0
```

```text
G1 = ~R3 & ~R2 & R1
```

---

# 39. Day 27 Assignment

## Part A — Fixed Priority

Design an **8-request priority arbiter**.

Priority:

```text
REQ7 > REQ6 > REQ5 > REQ4 >
REQ3 > REQ2 > REQ1 > REQ0
```

Inputs:

```text
req[7:0]
```

Outputs:

```text
grant[7:0]
valid
```

Requirements:

* One-hot grant
* No request → no grant
* Highest-priority request wins
* Verify all:

```text
2^8 = 256
```

request combinations.

---

## Part B — Round Robin

Modify your 4-request round-robin arbiter so that:

```text
pointer = 0
```

after reset.

For:

```text
req = 1111
```

verify the service sequence:

```text
0 → 1 → 2 → 3 → 0 → ...
```

---

# 40. Challenge Question

Suppose:

```text
Priority:
R3 > R2 > R1 > R0
```

and:

```text
REQ = 1101
```

Answer:

1. Which requesters are active?
2. Which requester wins?
3. What is `GRANT`?
4. What would happen if R3 were removed?
5. Could R0 starve if R3 continuously requests?

Work it out before looking at the answer.

### Answer

Active:

```text
R3, R2, R0
```

Winner:

```text
R3
```

Grant:

```text
1000
```

If R3 becomes inactive:

```text
REQ = 0101
```

R2 wins:

```text
GRANT = 0100
```

And yes, under a continuously active higher-priority requester, a lower-priority requester such as R0 can starve.

---

# 41. Day 27 Checklist

Before moving to Day 28, you should be able to explain:

* [ ] What an arbiter is
* [ ] Request signal
* [ ] Grant signal
* [ ] One-hot grant
* [ ] Fixed-priority arbitration
* [ ] Priority ordering
* [ ] Priority encoder vs arbiter
* [ ] Starvation
* [ ] Round-robin arbitration
* [ ] Priority pointer
* [ ] Why round-robin requires state
* [ ] Combinational priority arbiter
* [ ] Sequential round-robin arbiter
* [ ] Invalid/multiple grants
* [ ] How to exhaustively verify a 4-request arbiter
* [ ] How to derive priority equations

---

# 42. Golden Rules

```text
Arbiter:
multiple requesters → select one

REQ:
request for resource

GRANT:
selected requester

Fixed priority:
priority does not rotate

Round robin:
priority rotates

One-hot grant:
0000 or exactly one active bit

4 requesters:
2^4 = 16 request combinations
```

For a fixed priority:

```text
REQ3 > REQ2 > REQ1 > REQ0
```

the key equations are:

```text
G3 = R3

G2 = ~R3 & R2

G1 = ~R3 & ~R2 & R1

G0 = ~R3 & ~R2 & ~R1 & R0
```

The fundamental architecture is:

```text
             FIXED PRIORITY

REQ[3:0]
   |
   v
Priority Logic
   |
   v
GRANT[3:0]
```

while a round-robin arbiter adds state:

```text
                 +-----------+
REQ[3:0] ------> | Round     |
                 | Robin     | ----> GRANT
Pointer -------> | Logic     |
                 +-----------+
                       |
                       v
                   New Pointer
                       |
                       v
                    Register
```

## Day 27 takeaway

> **An arbiter controls access to a shared resource. Fixed-priority arbitration uses a permanent priority order, while round-robin arbitration rotates priority to provide more balanced access.**
