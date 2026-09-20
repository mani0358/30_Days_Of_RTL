# Day 41 — FIFO (First In, First Out)

## 1. Objective

Learn how to design and verify a basic synchronous FIFO in Verilog.

Today we will cover:

* What a FIFO is   
* FIFO architecture
* Write operation
* Read operation
* Write pointer
* Read pointer
* Full condition
* Empty condition
* FIFO count
* Synchronous FIFO RTL
* Testbench
* Verification with Icarus Verilog and GTKWave
* Placement interview questions
* Connection between FIFO and RAM

---

# 2. What is a FIFO?

FIFO means:

**First In, First Out**

The first data written into the FIFO is the first data read from it.

Example:

```text
Write:

A
B
C
D

Read:

A
B
C
D
```

Therefore:

```text
First written → First read
```

---

# 3. Real-Life Example

Think about a queue:

```text
Person A
Person B
Person C
Person D
```

Person A arrived first.

Therefore Person A leaves first.

A FIFO works in the same way:

```text
WRITE SIDE                         READ SIDE

Data A ──┐
Data B ──┤
Data C ──┤──> FIFO BUFFER ──> A
Data D ──┘                    B
                              C
                              D
```

---

# 4. Why Do We Need FIFOs?

FIFO is used when two parts of a system operate at different rates.

For example:

```text
Producer
   |
   | data
   v
 FIFO
   |
   v
Consumer
```

The producer can temporarily produce data faster than the consumer can process it.

The FIFO stores the excess data.

---

# 5. Common FIFO Applications

FIFOs are used in:

* CPU systems
* UART
* SPI
* Ethernet
* DMA
* DSP
* video processing
* packet processing
* data buffering
* streaming interfaces
* producer/consumer systems
* clock-domain crossing

---

# 6. Basic FIFO Architecture

A basic FIFO contains:

```text
                 +----------------+
write_data ----->|                |
                 |     MEMORY     |
                 |                |
                 +----------------+
                    ^          ^
                    |          |
              write pointer  read pointer
                    |          |
                    v          v
                  WRITE       READ
```

Additional control logic determines:

```text
FULL
EMPTY
```

---

# 7. FIFO Components

A basic synchronous FIFO contains:

```text
1. Memory
2. Write pointer
3. Read pointer
4. Full logic
5. Empty logic
6. Write enable
7. Read enable
```

Conceptually:

```text
             +----------------+
             |     MEMORY     |
             +----------------+
                ^          ^
                |          |
             wr_ptr      rd_ptr
                |          |
                v          v
             write       read
                |
             control
                |
          +-----+-----+
          |           |
         FULL        EMPTY
```

---

# 8. FIFO Parameters

We will build:

```text
FIFO_DEPTH = 8
DATA_WIDTH = 8
```

Therefore:

```text
8 locations
8 bits per location
```

Total storage:

$$
8\times8=64\ bits
$$

or:

```text
8 bytes
```

---

# 9. FIFO Memory

The memory can be declared:

```verilog
reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
```

For our FIFO:

```verilog
reg [7:0] memory [0:7];
```

Therefore:

```text
memory[0]
memory[1]
memory[2]
...
memory[7]
```

---

# 10. Write Pointer

The write pointer tells us:

> Where should the next data item be written?

Suppose:

```text
wr_ptr = 3
```

Then:

```text
memory[3]
```

is the next location used for writing.

After a successful write:

```text
wr_ptr = wr_ptr + 1
```

For an 8-entry FIFO:

```text
0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 0
```

The pointer wraps around.

---

# 11. Read Pointer

The read pointer tells us:

> From which location should the next data item be read?

Example:

```text
rd_ptr = 2
```

means the next read accesses:

```text
memory[2]
```

After a successful read:

```text
rd_ptr = rd_ptr + 1
```

Again:

```text
0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 0
```

---

# 12. Write Operation

A write occurs when:

```text
write_enable = 1
```

and:

```text
FIFO is not full
```

Therefore:

$$
WRITE = wr\_en \land \neg FULL
$$

Then:

```text
memory[wr_ptr] = write_data
```

and:

```text
wr_ptr = wr_ptr + 1
```

---

# 13. Read Operation

A read occurs when:

```text
read_enable = 1
```

and:

```text
FIFO is not empty
```

Therefore:

$$
READ = rd\_en \land \neg EMPTY
$$

Then:

```text
read_data = memory[rd_ptr]
```

and:

```text
rd_ptr = rd_ptr + 1
```

---

# 14. Empty Condition

A simple FIFO can use:

```text
write pointer == read pointer
```

to indicate empty.

Therefore:

$$
EMPTY=(wr\_ptr==rd\_ptr)
$$

Example:

```text
wr_ptr = 3
rd_ptr = 3
```

means there are no unread entries.

So:

```text
EMPTY = 1
```

---

# 15. Full Condition

There are several FIFO implementations.

One simple implementation uses an explicit count.

For today's FIFO:

```text
count = number of stored entries
```

Then:

$$
EMPTY=(count==0)
$$

and:

$$
FULL=(count==DEPTH)
$$

This makes the concept very easy to understand.

Day 42 will go deeper into FIFO calculations and pointer-based full/empty detection.

---

# 16. FIFO Count

For an 8-entry FIFO:

```text
count = 0
```

means:

```text
FIFO empty
```

If one item is written:

```text
count = 1
```

If another item is written:

```text
count = 2
```

Eventually:

```text
count = 8
```

means:

```text
FIFO full
```

---

# 17. FIFO State Table

For an 8-entry FIFO:

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

This is an important verification table.

---

# 18. Write/Read Control Table

Assume:

```text
FULL = 0
EMPTY = 0
```

Then:

| `wr_en` | `rd_en` | Operation    |
| ------: | ------: | ------------ |
|       0 |       0 | Nothing      |
|       0 |       1 | Read         |
|       1 |       0 | Write        |
|       1 |       1 | Read + Write |

But there are important restrictions:

```text
Cannot normally write when FULL=1
Cannot normally read when EMPTY=1
```

Therefore the actual operations are:

$$
do\_write=wr\_en\land\neg full
$$

$$
do\_read=rd\_en\land\neg empty
$$

---

# 19. Simultaneous Read and Write

A FIFO can perform a read and write in the same clock cycle.

Example:

```text
wr_en = 1
rd_en = 1
```

If both operations are legal:

```text
one item enters
one item leaves
```

Therefore the count remains unchanged.

Example:

```text
count = 5
```

After simultaneous read/write:

```text
count = 5
```

This is important for high-throughput systems.

---

# 20. Synchronous FIFO RTL

Create:

```text
Day_41/rtl/synchronous_fifo.v
```

```verilog
module synchronous_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8
)(
    input  wire                  clk,
    input  wire                  reset,

    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,

    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,

    output wire                  full,
    output wire                  empty,

    output reg  [$clog2(DEPTH+1)-1:0] count
);

    localparam PTR_WIDTH = $clog2(DEPTH);

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    reg [PTR_WIDTH-1:0] wr_ptr;
    reg [PTR_WIDTH-1:0] rd_ptr;

    wire do_write;
    wire do_read;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    assign do_write = wr_en && !full;
    assign do_read  = rd_en && !empty;

    always @(posedge clk) begin

        if (reset) begin

            wr_ptr  <= 0;
            rd_ptr  <= 0;
            rd_data <= 0;
            count   <= 0;

        end
        else begin

            // Write
            if (do_write) begin

                memory[wr_ptr] <= wr_data;

                if (wr_ptr == DEPTH-1)
                    wr_ptr <= 0;
                else
                    wr_ptr <= wr_ptr + 1'b1;

            end

            // Read
            if (do_read) begin

                rd_data <= memory[rd_ptr];

                if (rd_ptr == DEPTH-1)
                    rd_ptr <= 0;
                else
                    rd_ptr <= rd_ptr + 1'b1;

            end

            // Count
            case ({do_write, do_read})

                2'b10:
                    count <= count + 1'b1;

                2'b01:
                    count <= count - 1'b1;

                2'b11:
                    count <= count;

                default:
                    count <= count;

            endcase

        end

    end

endmodule
```

---

# 21. Important Note About `$clog2`

We used:

```verilog
$clog2(DEPTH)
```

For:

```text
DEPTH = 8
```

we get:

$$
\log_2(8)=3
$$

Therefore:

```text
PTR_WIDTH = 3
```

and the pointer can represent:

```text
000
001
010
011
100
101
110
111
```

which corresponds to:

```text
0 through 7
```

---

# 22. Why We Explicitly Wrap the Pointer

We use:

```verilog
if (wr_ptr == DEPTH-1)
    wr_ptr <= 0;
else
    wr_ptr <= wr_ptr + 1'b1;
```

instead of relying only on binary overflow.

This is useful because it makes the design behavior explicit and is safer when the depth is not a power of two.

The same idea is used for `rd_ptr`.

---

# 23. Testbench

Create:

```text
Day_41/tb/tb_fifo.v
```

```verilog
`timescale 1ns/1ps

module tb_fifo;

    localparam DATA_WIDTH = 8;
    localparam DEPTH      = 8;

    reg clk;
    reg reset;

    reg wr_en;
    reg [DATA_WIDTH-1:0] wr_data;

    reg rd_en;
    wire [DATA_WIDTH-1:0] rd_data;

    wire full;
    wire empty;

    wire [3:0] count;

    synchronous_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .reset(reset),

        .wr_en(wr_en),
        .wr_data(wr_data),

        .rd_en(rd_en),
        .rd_data(rd_data),

        .full(full),
        .empty(empty),

        .count(count)
    );

    always #5 clk = ~clk;

    task write_fifo;
        input [7:0] data;

        begin

            @(negedge clk);

            wr_en   = 1'b1;
            wr_data = data;

            @(negedge clk);

            wr_en = 1'b0;

        end

    endtask

    task read_fifo;

        begin

            @(negedge clk);

            rd_en = 1'b1;

            @(posedge clk);

            #1;

            $display(
                "READ DATA = %h | COUNT = %0d | EMPTY = %b",
                rd_data,
                count,
                empty
            );

            @(negedge clk);

            rd_en = 1'b0;

        end

    endtask

    initial begin

        $dumpfile("fifo.vcd");
        $dumpvars(0, tb_fifo);

        clk = 0;

        reset = 1;

        wr_en = 0;
        wr_data = 0;

        rd_en = 0;

        #12;

        reset = 0;

        // -------------------------
        // WRITE DATA
        // -------------------------

        write_fifo(8'hA1);
        write_fifo(8'hB2);
        write_fifo(8'hC3);
        write_fifo(8'hD4);

        // -------------------------
        // READ DATA
        // -------------------------

        read_fifo;
        read_fifo;
        read_fifo;
        read_fifo;

        #20;

        $finish;

    end

endmodule
```

---

# 24. Expected Output

The FIFO should return the data in exactly the order in which it was written:

```text
READ DATA = a1
READ DATA = b2
READ DATA = c3
READ DATA = d4
```

This verifies:

```text
A1 → B2 → C3 → D4
```

and:

```text
A1 is read first
D4 is read last
```

Therefore FIFO ordering is verified.

---

# 25. FIFO Verification

We wrote:

```text
A1
B2
C3
D4
```

The memory may physically contain:

```text
memory[0] = A1
memory[1] = B2
memory[2] = C3
memory[3] = D4
```

The read pointer starts at:

```text
rd_ptr = 0
```

Therefore:

```text
Read 1 → memory[0] → A1
Read 2 → memory[1] → B2
Read 3 → memory[2] → C3
Read 4 → memory[3] → D4
```

---

# 26. FIFO Waveform

Open:

```bash
gtkwave fifo.vcd
```

Add:

```text
clk
reset
wr_en
wr_data
rd_en
rd_data
full
empty
count
uut.wr_ptr
uut.rd_ptr
```

You should observe:

```text
WRITE
  |
  v
wr_ptr increases
  |
  v
count increases
```

and:

```text
READ
  |
  v
rd_ptr increases
  |
  v
count decreases
```

---

# 27. Example FIFO Operation

Initially:

```text
wr_ptr = 0
rd_ptr = 0
count  = 0
empty  = 1
full   = 0
```

Write `A1`:

```text
memory[0] = A1
wr_ptr = 1
count = 1
```

Write `B2`:

```text
memory[1] = B2
wr_ptr = 2
count = 2
```

Write `C3`:

```text
memory[2] = C3
wr_ptr = 3
count = 3
```

Read:

```text
rd_ptr = 0
rd_data = A1
rd_ptr = 1
count = 2
```

Read again:

```text
rd_data = B2
rd_ptr = 2
count = 1
```

Therefore:

```text
First In → First Out
```

---

# 28. FIFO Full Example

For:

```text
DEPTH = 8
```

after eight successful writes:

```text
count = 8
```

Therefore:

```text
full = 1
```

If another write is requested:

```text
wr_en = 1
```

the control logic gives:

```text
do_write = wr_en && !full
```

Since:

```text
full = 1
```

we get:

```text
do_write = 0
```

Therefore the extra data is not written.

---

# 29. FIFO Empty Example

Initially:

```text
count = 0
```

therefore:

```text
empty = 1
```

If:

```text
rd_en = 1
```

then:

```text
do_read = rd_en && !empty
```

becomes:

```text
do_read = 0
```

Therefore no invalid read occurs.

---

# 30. FIFO Count Update Truth Table

The count logic is:

| `do_write` | `do_read` | Count operation |
| ---------: | --------: | --------------- |
|          0 |         0 | Hold            |
|          0 |         1 | `count - 1`     |
|          1 |         0 | `count + 1`     |
|          1 |         1 | Hold            |

This is one of the most important FIFO truth tables.

Why does `11` hold?

Because:

```text
one item enters
one item leaves
```

so:

$$
count_{next}=count
$$

---

# 31. FIFO Control Equations

Remember these:

### Write

$$
do\_write=wr\_en\land\overline{full}
$$

### Read

$$
do\_read=rd\_en\land\overline{empty}
$$

### Empty

$$
empty=(count=0)
$$

### Full

$$
full=(count=DEPTH)
$$

### Count

$$
count_{next}=count+1
$$

for write-only,

$$
count_{next}=count-1
$$

for read-only,

and:

$$
count_{next}=count
$$

for neither or both.

---

# 32. Why FIFO Uses RAM Concepts

From Day 39 and Day 40:

```text
FIFO
 |
 +---- Memory
 |
 +---- Read pointer
 |
 +---- Write pointer
```

The memory stores the actual data.

The pointers determine:

```text
where to write
where to read
```

Therefore FIFO combines several topics you've already learned:

```text
Memory
+
Counters
+
Pointers
+
Control logic
+
Sequential RTL
```

---

# 33. Synchronous FIFO

Today's FIFO uses one clock:

```text
             clk
              |
       +------+------+
       |             |
    WRITE          READ
       |             |
       +------+------+
              |
             FIFO
```

Both sides use the same clock.

This is called a:

**Synchronous FIFO**

---

# 34. Asynchronous FIFO

An asynchronous FIFO uses different clocks:

```text
write_clk                  read_clk
    |                          |
    v                          v
 WRITE SIDE                 READ SIDE
    |                          |
    +---------- FIFO ----------+
```

For example:

```text
Producer clock = 100 MHz
Consumer clock = 75 MHz
```

This requires special clock-domain-crossing techniques.

A common design uses:

```text
binary pointer
        ↓
Gray-coded pointer
        ↓
synchronization
        ↓
full/empty detection
```

We are **not implementing the asynchronous FIFO today**.

That is an advanced topic.

---

# 35. Important Placement Question

### Why is Gray code useful in asynchronous FIFOs?

A Gray-code counter changes only one bit between consecutive values.

Example:

```text
Binary:

00
01
10
11
```

Multiple bits can change simultaneously.

Gray code:

```text
00
01
11
10
```

Only one bit changes between adjacent states.

This reduces ambiguity when a multi-bit pointer crosses clock domains.

You will study this more deeply when working with CDC concepts.

---

# 36. Common FIFO Mistakes

## Mistake 1 — Reading when empty

Bad:

```verilog
if (rd_en)
    rd_data <= memory[rd_ptr];
```

Better:

```verilog
if (rd_en && !empty)
    rd_data <= memory[rd_ptr];
```

---

## Mistake 2 — Writing when full

Bad:

```verilog
if (wr_en)
    memory[wr_ptr] <= wr_data;
```

Better:

```verilog
if (wr_en && !full)
    memory[wr_ptr] <= wr_data;
```

---

## Mistake 3 — Incorrect count when read and write happen together

Incorrect:

```verilog
if (write)
    count <= count + 1;

if (read)
    count <= count - 1;
```

When both are true, two nonblocking assignments target `count`.

The final result depends on procedural ordering, which is not the intended clear design style.

Instead use:

```verilog
case ({do_write, do_read})
    2'b10: count <= count + 1;
    2'b01: count <= count - 1;
    default: count <= count;
endcase
```

---

# 37. Why Nonblocking Assignments Are Used

FIFO state is sequential.

Therefore:

```verilog
<=
```

is used.

For example:

```verilog
wr_ptr <= wr_ptr + 1'b1;
rd_ptr <= rd_ptr + 1'b1;
count  <= count + 1'b1;
```

This follows the sequential RTL style learned earlier.

---

# 38. Compile and Run

From:

```text
Day_41/
```

run:

```bash
iverilog -o sim/fifo_test \
    rtl/synchronous_fifo.v \
    tb/tb_fifo.v
```

Then:

```bash
vvp sim/fifo_test
```

Open waveform:

```bash
gtkwave fifo.vcd
```

---

# 39. Expected Verification

You should verify:

### After reset

```text
count = 0
empty = 1
full  = 0
```

### After writing A1

```text
count = 1
empty = 0
```

### After writing four values

```text
count = 4
```

### After reading four values

```text
count = 0
empty = 1
```

### Data order

```text
A1
B2
C3
D4
```

must come out in the same order.

---

# 40. Placement Interview Questions

## Q1. What does FIFO stand for?

First In, First Out.

---

## Q2. What is the main purpose of a FIFO?

To buffer data while preserving the order in which it was written.

---

## Q3. What are the main components of a FIFO?

Typically:

* memory
* write pointer
* read pointer
* full logic
* empty logic
* control signals

---

## Q4. What is the difference between FIFO and RAM?

RAM is a general random-access storage structure.

FIFO provides an ordered queue interface where the oldest valid entry is read first.

---

## Q5. What is the purpose of the write pointer?

It identifies the memory location where the next valid write will occur.

---

## Q6. What is the purpose of the read pointer?

It identifies the memory location containing the next data item to be read.

---

## Q7. What does `empty` mean?

There are no valid unread entries in the FIFO.

---

## Q8. What does `full` mean?

The FIFO has reached its maximum storage capacity.

---

## Q9. Can a FIFO read and write simultaneously?

Yes, provided both operations are valid.

---

## Q10. What happens to the count during simultaneous read/write?

The count remains unchanged.

---

## Q11. What is a synchronous FIFO?

A FIFO in which read and write operations use the same clock domain.

---

## Q12. What is an asynchronous FIFO?

A FIFO in which the read and write sides use different clock domains.

---

## Q13. Why are asynchronous FIFOs more complicated?

Because information must cross between independent clock domains safely.

---

## Q14. Why is Gray code commonly used in asynchronous FIFO pointers?

Because adjacent Gray-code values differ by only one bit, making synchronized pointer transfer safer.

---

## Q15. What happens if you read from an empty FIFO?

A correctly designed FIFO should prevent the invalid read operation.

---

# 41. Placement Calculation Questions

### Question 1

FIFO depth:

```text
16
```

Data width:

```text
8 bits
```

Total storage:

$$
16\times8=128\ bits
$$

or:

```text
16 bytes
```

---

### Question 2

FIFO depth:

```text
1024
```

How many pointer bits are required for the data address?

$$
\log_2(1024)=10
$$

Answer:

```text
10 bits
```

for the address portion.

---

### Question 3

FIFO depth:

```text
32
```

Data width:

```text
16
```

Storage:

$$
32\times16=512\ bits
$$

or:

```text
64 bytes
```

---

# 42. Practice Questions

### Basic

1. What is FIFO?
2. Why is FIFO used?
3. What is a write pointer?
4. What is a read pointer?
5. What is `full`?
6. What is `empty`?

### RTL

7. Design a 16 × 8 synchronous FIFO.
8. Add a `count` output.
9. Prevent writes when full.
10. Prevent reads when empty.
11. Support simultaneous read and write.

### Placement

12. Calculate storage for a 64 × 32 FIFO.
13. Calculate address width for a depth-256 FIFO.
14. Explain synchronous vs asynchronous FIFO.
15. Explain why Gray code is used in asynchronous FIFOs.

---

# 43. Day 41 Assignment

Build a parameterized synchronous FIFO with:

```text
DATA_WIDTH = 8
DEPTH      = 16
```

Required ports:

```text
clk
reset
wr_en
wr_data
rd_en
rd_data
full
empty
count
```

Verify:

### Test 1 — Empty

After reset:

```text
empty = 1
full  = 0
```

### Test 2 — Write

Write:

```text
11
22
33
44
55
```

Verify:

```text
count = 5
```

### Test 3 — Read

Read all five values.

Expected:

```text
11
22
33
44
55
```

### Test 4 — Full

Write 16 values.

Verify:

```text
full = 1
```

### Test 5 — Overflow protection

Attempt another write.

Verify:

```text
count remains 16
```

### Test 6 — Empty protection

Read all 16 values.

Then attempt another read.

Verify:

```text
count remains 0
empty = 1
```

### Test 7 — Simultaneous operation

Perform a valid read and write in the same cycle.

Verify:

```text
count unchanged
```

---

# 44. Recommended Git Structure

```text
RTL_50_Days/
│
├── Day_41/
│   ├── README.md
│   │
│   ├── rtl/
│   │   └── synchronous_fifo.v
│   │
│   ├── tb/
│   │   └── tb_fifo.v
│   │
│   └── sim/
│
└── ...
```

Commit:

```bash
git add Day_41/
git commit -m "Day 41: Synchronous FIFO"
git push
```

---

# 45. Day 41 Key Takeaways

Remember these equations:

$$
do\_write=wr\_en\land\neg full
$$

$$
do\_read=rd\_en\land\neg empty
$$

$$
empty=(count=0)
$$

$$
full=(count=DEPTH)
$$

Count behavior:

```text
write only       → count + 1
read only        → count - 1
read + write     → count unchanged
nothing          → count unchanged
```

Architecture:

```text
                 FIFO
                  |
        +---------+---------+
        |                   |
     WRITE SIDE          READ SIDE
        |                   |
    write pointer       read pointer
        |                   |
        +--------+----------+
                 |
              MEMORY
```

Most important concept:

> **A FIFO is a memory plus control logic that guarantees ordered data movement.**

---

# 46. Day 41 Final Mental Model

```text
                 PRODUCER
                    |
                  wr_data
                    |
                  wr_en
                    |
                    v
             +-------------+
             |             |
             |    FIFO     |
             |             |
             |   MEMORY    |
             |             |
             +-------------+
               |         |
          write_ptr    read_ptr
               |         |
               v         v
             FULL      EMPTY
                         |
                         v
                      rd_data
                         |
                         v
                      CONSUMER
```

### What you should be able to explain in an interview

> "A FIFO is a First-In-First-Out storage structure. A synchronous FIFO typically contains memory, read and write pointers, and full/empty control logic. The write pointer advances only on a valid write, the read pointer advances only on a valid read, and the count tracks the number of stored entries. Simultaneous valid read and write operations leave the count unchanged."

**Day 41 complete.**

Next roadmap topic:

# Day 42 — FIFO Calculations

You will go deeper into **FIFO depth calculation, pointer width, memory size, throughput, latency, and full/empty calculations**.
