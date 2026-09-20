# Day 42 — FIFO Calculations

## 1. Objective

Learn how to calculate and analyze the important parameters of a FIFO:

* FIFO depth
* FIFO data width
* Total memory size
* Address width
* Pointer width
* FIFO count width
* Full and empty conditions
* Data-rate requirements
* FIFO depth from burst size
* FIFO depth from clock-rate mismatch
* Throughput
* Latency
* Placement calculations

---

# 2. Quick Revision — Day 41

A FIFO contains:

```text
              +----------------+
write_data -->|                |
              |     MEMORY     |
              |                |
              +----------------+
                  ^        ^
                  |        |
              wr_ptr     rd_ptr
```

Control signals:

```text
wr_en
rd_en
full
empty
count
```

The basic operations were:

$$
do\_write=wr\_en\land\overline{full}
$$

$$
do\_read=rd\_en\land\overline{empty}
$$

For a count-based FIFO:

$$
empty=(count=0)
$$

$$
full=(count=DEPTH)
$$

---

# 3. FIFO Depth

FIFO depth means:

> The number of data entries that the FIFO can store.

Example:

```text
DEPTH = 8
DATA_WIDTH = 8
```

The FIFO can store:

```text
8 entries
```

Each entry contains:

```text
8 bits
```

Therefore:

$$
\boxed{DEPTH=8}
$$

and:

$$
\boxed{DATA\ WIDTH=8}
$$

---

# 4. FIFO Memory Size

The total number of stored bits is:

$$
Memory\ Size=Depth\times Data\ Width
$$

Example:

```text
Depth  = 16
Width  = 8
```

Therefore:

$$
16\times8=128\ bits
$$

So:

```text
128 bits = 16 bytes
```

---

# 5. Example — Memory Size

Suppose:

```text
FIFO depth = 1024
FIFO width = 32 bits
```

Then:

$$
1024\times32=32768\ bits
$$

Convert to bytes:

$$
32768/8=4096\ bytes
$$

Therefore:

```text
4096 bytes = 4 KB
```

### Answer

$$
\boxed{32\,Kbits}
$$

or:

$$
\boxed{4\,KB}
$$

---

# 6. Address Width

To address `DEPTH` locations, the required address width is:

$$
Address\ Width=\lceil\log_2(DEPTH)\rceil
$$

For a power-of-two depth:

$$
Address\ Width=\log_2(DEPTH)
$$

---

# 7. Address Width Examples

### Depth = 8

$$
\log_2(8)=3
$$

Therefore:

```text
3 address bits
```

Addresses:

```text
000 → 0
001 → 1
010 → 2
011 → 3
100 → 4
101 → 5
110 → 6
111 → 7
```

---

### Depth = 16

$$
\log_2(16)=4
$$

Therefore:

```text
4 bits
```

---

### Depth = 32

$$
\log_2(32)=5
$$

Therefore:

```text
5 bits
```

---

### Depth = 1024

$$
\log_2(1024)=10
$$

Therefore:

```text
10 bits
```

---

# 8. Non-Power-of-Two Depth

Suppose:

```text
DEPTH = 10
```

Then:

$$
\log_2(10)\approx3.322
$$

We cannot use 3 bits because:

$$
2^3=8
$$

which is insufficient.

We need:

$$
\lceil3.322\rceil=4
$$

Therefore:

```text
Address width = 4 bits
```

A 4-bit pointer can represent:

```text
0 through 15
```

but our FIFO only has:

```text
0 through 9
```

So the RTL must explicitly handle wrapping.

---

# 9. Pointer Width

For a basic synchronous FIFO whose memory has `DEPTH` locations:

$$
PTR\ WIDTH=\lceil\log_2(DEPTH)\rceil
$$

for the data-address portion.

For example:

```text
DEPTH = 16
```

Then:

$$
PTR\ WIDTH=4
$$

because:

$$
2^4=16
$$

---

# 10. Pointer Wraparound

For:

```text
DEPTH = 8
```

the write pointer sequence is:

```text
0
1
2
3
4
5
6
7
0
1
2
...
```

Therefore:

```text
wr_ptr == DEPTH-1
```

causes:

```text
wr_ptr = 0
```

The read pointer behaves similarly.

---

# 11. Count Width

The count represents the number of valid entries currently stored.

For a FIFO of depth `D`, the count must represent:

```text
0 through D
```

Notice that `D` itself must be representable.

Therefore:

$$
Count\ Width=\lceil\log_2(D+1)\rceil
$$

---

# 12. Count Width Examples

### Depth = 8

Need to represent:

```text
0 to 8
```

Since:

$$
2^3=8
$$

3 bits can only represent:

```text
0 to 7
```

Therefore:

$$
\boxed{4\ bits}
$$

---

### Depth = 16

Need:

```text
0 to 16
```

Since:

$$
2^4=16
$$

4 bits represent only:

```text
0 to 15
```

Therefore:

$$
\boxed{5\ bits}
$$

---

### Depth = 1024

Need:

```text
0 to 1024
```

Since:

$$
2^{10}=1024
$$

10 bits represent:

```text
0 to 1023
```

Therefore:

$$
\boxed{11\ bits}
$$

---

# 13. Important Difference

Do not confuse:

```text
Address width
```

with:

```text
Count width
```

For a depth-8 FIFO:

| Parameter |             Width |
| --------- | ----------------: |
| Address   |            3 bits |
| Data      | Depends on design |
| Count     |            4 bits |

Why?

Address represents:

```text
0 to 7
```

Count represents:

```text
0 to 8
```

This is a very common interview question.

---

# 14. General FIFO Width Formula

For FIFO depth `D`:

### Address width

$$
\boxed{\lceil\log_2(D)\rceil}
$$

### Count width

$$
\boxed{\lceil\log_2(D+1)\rceil}
$$

### Total storage

$$
\boxed{D\times W}
$$

where `W` is the data width.

---

# 15. FIFO Capacity

Suppose:

```text
Depth = 256
Width = 32 bits
```

Capacity:

$$
256\times32=8192\ bits
$$

Convert to bytes:

$$
8192/8=1024\ bytes
$$

Therefore:

```text
FIFO capacity = 1 KB
```

---

# 16. FIFO Depth from Burst Size

This is an important practical calculation.

Suppose a producer sends:

```text
100 words
```

before the consumer starts processing them.

The FIFO must be able to absorb that burst.

Minimum depth:

$$
FIFO\ Depth\geq Burst\ Size
$$

Therefore:

```text
Depth >= 100
```

If the implementation requires a power-of-two depth, choose the next suitable power of two:

```text
128
```

---

# 17. Why Power-of-Two FIFO Depths Are Common

Power-of-two depths simplify pointer logic.

Examples:

```text
8
16
32
64
128
256
512
1024
```

For:

```text
DEPTH = 256
```

the pointer needs exactly:

$$
\log_2(256)=8
$$

bits.

This makes wraparound and pointer comparison convenient.

---

# 18. FIFO with Producer and Consumer Rates

Consider:

```text
Producer rate = 100 words/second
Consumer rate = 80 words/second
```

The FIFO fills at:

$$
100-80=20\ words/second
$$

Therefore, if this continues indefinitely, the FIFO eventually becomes full.

This is an important system-level concept:

> A FIFO does not permanently solve a rate mismatch. It provides temporary buffering.

---

# 19. FIFO Depth from Rate Difference

Suppose:

```text
Producer = 1000 words/s
Consumer = 900 words/s
```

Difference:

$$
1000-900=100\ words/s
$$

If the consumer is delayed for:

```text
0.5 seconds
```

the additional accumulated data is:

$$
100\times0.5=50
$$

Therefore the FIFO needs at least:

```text
50 entries
```

plus any required implementation margin.

---

# 20. Burst-Based FIFO Calculation

Suppose:

```text
Producer = 200 MB/s
Consumer = 100 MB/s
```

Producer runs faster for:

```text
2 ms
```

Additional data accumulated:

$$
(200-100)\ MB/s\times0.002s
$$

$$
=100\times0.002
$$

$$
=0.2\ MB
$$

Therefore:

$$
0.2\ MB=200\ KB
$$

The FIFO must be able to absorb at least approximately:

```text
200 KB
```

for that rate mismatch interval.

---

# 21. Clock-Based FIFO Calculation

Suppose:

```text
Write clock = 100 MHz
Read clock = 80 MHz
```

Assume:

```text
1 word per clock
```

Write rate:

$$
100M\ words/s
$$

Read rate:

$$
80M\ words/s
$$

Difference:

$$
20M\ words/s
$$

If this difference lasts for:

```text
10 clock cycles of the 100 MHz producer
```

time is:

$$
10/100M=100ns
$$

Data accumulated:

$$
20M\times100ns=2\ words
$$

So approximately 2 additional entries accumulate during that interval.

---

# 22. Throughput

Throughput means:

> How much data can be transferred per unit time.

If one word is transferred per clock:

$$
Throughput=Clock\ Frequency\timesWord\ Size
$$

Example:

```text
Clock = 100 MHz
Word size = 32 bits
```

Then:

$$
100M\times32=3.2Gbit/s
$$

Convert to bytes:

$$
3.2Gbit/s\div8=400MB/s
$$

Therefore:

$$
\boxed{400MB/s}
$$

---

# 23. FIFO Throughput

If the FIFO supports one read and one write per clock:

```text
Clock = 100 MHz
Data width = 32 bits
```

Write bandwidth:

$$
100M\times32=3.2Gb/s
$$

Read bandwidth:

$$
100M\times32=3.2Gb/s
$$

If read and write happen simultaneously, the FIFO can maintain one-word-per-cycle flow through the system.

---

# 24. Latency

Latency is:

> The time between an input event and the corresponding output becoming available.

For a synchronous FIFO, latency depends on the implementation.

For example, if data is written on one clock edge and the registered read output becomes available after a later read edge, there is clock-cycle latency associated with that operation.

Do not assume every FIFO has exactly one fixed latency—the RTL implementation determines it.

---

# 25. FIFO Example

Consider:

```text
Depth = 16
Width = 8
Clock = 50 MHz
```

### Total memory

$$
16\times8=128\ bits
$$

### Address width

$$
\log_2(16)=4
$$

### Count width

$$
\lceil\log_2(17)\rceil=5
$$

Therefore:

```text
Memory = 128 bits
Address = 4 bits
Count = 5 bits
```

---

# 26. Example — 64 × 32 FIFO

Given:

```text
Depth = 64
Width = 32
```

### Address width

$$
\log_2(64)=6
$$

### Count width

Need:

```text
0 through 64
```

Therefore:

$$
\lceil\log_2(65)\rceil=7
$$

### Memory

$$
64\times32=2048\ bits
$$

$$
2048/8=256\ bytes
$$

Final:

```text
Depth       = 64
Width       = 32 bits
Address     = 6 bits
Count       = 7 bits
Memory      = 2048 bits
Capacity    = 256 bytes
```

---

# 27. Example — 1024 × 16 FIFO

Given:

```text
Depth = 1024
Width = 16
```

### Address

$$
\log_2(1024)=10
$$

### Count

Need:

```text
0 through 1024
```

Therefore:

$$
\lceil\log_2(1025)\rceil=11
$$

### Memory

$$
1024\times16=16384\ bits
$$

Convert:

$$
16384/8=2048\ bytes
$$

Therefore:

```text
Address = 10 bits
Count   = 11 bits
Memory  = 16 Kbits
Capacity = 2 KB
```

---

# 28. Full and Empty Using Count

The count-based FIFO from Day 41 uses:

$$
empty=(count==0)
$$

and:

$$
full=(count==DEPTH)
$$

For:

```text
DEPTH = 8
```

we get:

| Count | Empty | Full |
| ----: | ----: | ---: |
|     0 |     1 |    0 |
|     1 |     0 |    0 |
|     2 |     0 |    0 |
|     3 |     0 |    0 |
|     4 |     0 |    0 |
|     5 |     0 |    0 |
|     6 |     0 |    0 |
|     7 |     0 |    0 |
|     8 |     0 |    1 |

---

# 29. Pointer-Based FIFO Concept

A more advanced FIFO can determine status from pointers rather than maintaining an explicit count.

For a simple power-of-two FIFO, you may use:

```text
write pointer
read pointer
```

with additional information to distinguish:

```text
empty
```

from:

```text
full
```

because:

```text
wr_ptr == rd_ptr
```

can occur in both situations after wraparound.

This is why practical FIFO designs often use an extra pointer bit or other state information.

---

# 30. Extra Pointer Bit Concept

Suppose FIFO depth is:

```text
8
```

Data address needs:

```text
3 bits
```

An additional bit can indicate whether the pointer has wrapped around.

Conceptually:

```text
{wrap_bit, address}
```

Example:

```text
0000
0001
0010
...
0111
1000
1001
...
1111
```

The lower 3 bits identify the memory location.

The additional bit indicates the wraparound phase.

This allows the design to distinguish:

```text
empty
```

from:

```text
full
```

when the address portions are equal.

This concept becomes especially important in asynchronous FIFOs.

---

# 31. FIFO Calculation Cheat Sheet

Memorize:

$$
\boxed{Memory=D\times W}
$$

$$
\boxed{Address\ Width=\lceil\log_2D\rceil}
$$

$$
\boxed{Count\ Width=\lceil\log_2(D+1)\rceil}
$$

$$
\boxed{Throughput=f_{clk}\times DataWidth}
$$

for one transfer per clock.

For rate mismatch:

$$
\boxed{Accumulated\ Data=(ProducerRate-ConsumerRate)\times Time}
$$

when producer rate exceeds consumer rate during that interval.

---

# 32. Ubuntu Lab

Use the Day 41 FIFO RTL:

```text
Day_41/rtl/synchronous_fifo.v
```

and testbench:

```text
Day_41/tb/tb_fifo.v
```

Create a Day 42 calculation testbench if desired, but the main goal today is mathematical analysis.

Compile:

```bash
cd ~/RTL_50_Days/Day_41
```

Then:

```bash
mkdir -p sim
```

Compile:

```bash
iverilog -o sim/fifo_test \
    rtl/synchronous_fifo.v \
    tb/tb_fifo.v
```

Run:

```bash
vvp sim/fifo_test
```

Waveform:

```bash
gtkwave fifo.vcd
```

---

# 33. Recommended Day 42 RTL Exercise

Modify the Day 41 FIFO to use:

```text
DEPTH = 16
DATA_WIDTH = 32
```

Calculate before coding:

```text
Memory:
16 × 32 = 512 bits

Address:
log2(16) = 4 bits

Count:
ceil(log2(17)) = 5 bits
```

Then verify these values in simulation.

---

# 34. Placement Questions

## Q1. A FIFO has depth 256. How many address bits are required?

$$
\log_2(256)=8
$$

Answer:

```text
8 bits
```

---

## Q2. A FIFO has depth 256. How many count bits are required?

Need to represent:

```text
0 to 256
```

Therefore:

$$
\lceil\log_2(257)\rceil=9
$$

Answer:

```text
9 bits
```

---

## Q3. A FIFO is 512 × 32. What is the memory size?

$$
512\times32=16384\ bits
$$

Answer:

```text
16 Kbits
```

or:

```text
2 KB
```

---

## Q4. A 64-entry FIFO has 16-bit data. What is its capacity?

$$
64\times16=1024\ bits
$$

$$
1024/8=128\ bytes
$$

Answer:

```text
128 bytes
```

---

## Q5. A producer generates 100 words/s and the consumer consumes 80 words/s. How much data accumulates in 3 seconds?

$$
(100-80)\times3
$$

$$
=60
$$

Answer:

```text
60 words
```

---

## Q6. Why can't 3 bits represent a count of 8?

Three bits represent:

```text
000 = 0
...
111 = 7
```

Therefore 8 requires:

```text
1000
```

which needs 4 bits.

---

## Q7. What is the difference between FIFO depth and FIFO width?

**Depth** = number of entries.

**Width** = number of bits in each entry.

Example:

```text
FIFO = 64 × 32
```

means:

```text
64 entries
32 bits/entry
```

---

## Q8. What is FIFO capacity?

Capacity is the total amount of data that can be stored:

$$
Capacity=Depth\times Width
$$

---

## Q9. Why is FIFO depth often chosen as a power of two?

It simplifies address and pointer wraparound and makes binary pointer arithmetic convenient.

---

## Q10. Does a FIFO permanently fix a producer/consumer rate mismatch?

No.

It provides temporary buffering. If the average producer rate remains higher than the consumer rate, the FIFO eventually fills.

---

# 35. Practice Problems

### Problem 1

A FIFO is:

```text
128 × 8
```

Find:

1. Address width
2. Count width
3. Total memory
4. Capacity in bytes

---

### Problem 2

A FIFO is:

```text
256 × 32
```

Find:

1. Address width
2. Count width
3. Total memory
4. Capacity in bytes

---

### Problem 3

Producer:

```text
80 MB/s
```

Consumer:

```text
60 MB/s
```

The mismatch lasts:

```text
5 ms
```

Calculate the minimum amount of data accumulated.

---

### Problem 4

A FIFO operates at:

```text
125 MHz
```

and transfers:

```text
64 bits/clock
```

Calculate the theoretical one-word-per-clock bandwidth in:

1. bits/s
2. bytes/s
3. MB/s

---

### Problem 5

A FIFO depth is 100.

Find the minimum address width.

---

# 36. Assignment

Design a parameterized FIFO and create a calculation table for:

```text
FIFO-1:
Depth = 16
Width = 8

FIFO-2:
Depth = 64
Width = 16

FIFO-3:
Depth = 256
Width = 32

FIFO-4:
Depth = 1024
Width = 64
```

For each one calculate:

```text
Depth
Width
Address width
Count width
Total bits
Total bytes
```

Create:

```text
Day_42/
├── README.md
├── calculations/
│   └── fifo_calculations.txt
├── rtl/
│   └── fifo_calculated.v
└── tb/
    └── tb_fifo_calculated.v
```

---

# 37. Expected Calculation Table

| FIFO   | Depth | Width | Address | Count | Total Bits | Capacity |
| ------ | ----: | ----: | ------: | ----: | ---------: | -------: |
| FIFO-1 |    16 |     8 |       4 |     5 |        128 |     16 B |
| FIFO-2 |    64 |    16 |       6 |     7 |       1024 |    128 B |
| FIFO-3 |   256 |    32 |       8 |     9 |       8192 |     1 KB |
| FIFO-4 |  1024 |    64 |      10 |    11 |      65536 |     8 KB |

Verify every row yourself before committing.

---

# 38. Git Structure

```text
RTL_50_Days/
│
├── Day_41/
│   ├── README.md
│   ├── rtl/
│   ├── tb/
│   └── sim/
│
├── Day_42/
│   ├── README.md
│   ├── calculations/
│   │   └── fifo_calculations.txt
│   ├── rtl/
│   │   └── fifo_calculated.v
│   └── tb/
│       └── tb_fifo_calculated.v
│
└── ...
```

Commit:

```bash
git add Day_42/
git commit -m "Day 42: FIFO calculations"
git push
```

---

# 39. Day 42 Key Takeaways

### FIFO depth

Number of entries:

$$
\boxed{D}
$$

### FIFO width

Bits per entry:

$$
\boxed{W}
$$

### Memory size

$$
\boxed{D\times W}
$$

### Address width

$$
\boxed{\lceil\log_2D\rceil}
$$

### Count width

$$
\boxed{\lceil\log_2(D+1)\rceil}
$$

### Empty

$$
\boxed{count=0}
$$

### Full

$$
\boxed{count=D}
$$

### One-word-per-clock throughput

$$
\boxed{f_{clk}\times W}
$$

### Rate mismatch accumulation

$$
\boxed{(R_{producer}-R_{consumer})\times T}
$$

---

# 40. Most Important Placement Concept

If the interviewer gives:

```text
FIFO = 1024 × 32
```

immediately think:

```text
Depth = 1024
Width = 32 bits

Address width:
log2(1024) = 10

Count width:
ceil(log2(1025)) = 11

Memory:
1024 × 32
= 32768 bits
= 4096 bytes
= 4 KB
```

This type of calculation should become automatic.

---

# 41. Final Mental Model

```text
                    FIFO
                     |
        +------------+------------+
        |                         |
      DEPTH                      WIDTH
        |                         |
 number of entries          bits/entry
        |                         |
        +------------+------------+
                     |
              TOTAL MEMORY
                     |
              DEPTH × WIDTH
```

Then:

```text
DEPTH
  |
  +--> Address width
  |
  +--> Count width
  |
  +--> Full condition
  |
  +--> Pointer wraparound
```

And:

```text
Producer rate
       |
       v
     FIFO
       |
       v
Consumer rate
```

If the producer temporarily exceeds the consumer:

```text
FIFO absorbs the difference
```

If the producer continuously exceeds the consumer:

```text
FIFO eventually becomes FULL
```

**Day 42 complete.**

Next:

# Day 43 — Booth Multiplier

You will learn **signed binary multiplication, Booth's algorithm, arithmetic shifting, partial products, and a 4-bit signed Booth multiplier in Verilog**.
