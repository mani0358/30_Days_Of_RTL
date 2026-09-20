# Day 38 — File I/O: COE/MEM Random ROM Test

## 1. Objective

Learn how Verilog can read memory contents from external files.

Today we will learn:

* What File I/O means in RTL
* `$readmemh`
* `$readmemb`
* `.mem` files
* `.coe` files and their purpose
* ROM initialization
* Random ROM testing
* How to verify memory contents using a testbench
* Icarus Verilog simulation
* GTKWave verification
* Placement interview questions

---

# 2. Why Do We Need File I/O?

Suppose we want to implement a ROM containing 16 values.

We could write:

```verilog
memory[0] = 8'hA5;
memory[1] = 8'h3C;
memory[2] = 8'h7F;
...
```

But this becomes inconvenient for large memories.

For example:

```text
1024 × 8 ROM
4096 × 16 ROM
65536 × 32 ROM
```

Instead, we can store the memory contents in an external file.

```text
memory.mem
```

Then Verilog loads it:

```verilog
$readmemh("memory.mem", memory);
```

Architecture:

```text
             memory.mem
                  |
                  v
          +---------------+
          | $readmemh()   |
          +-------+-------+
                  |
                  v
             +---------+
address ---->|   ROM   |
             +----+----+
                  |
                  v
                data
```

---

# 3. Important Verilog System Tasks

Two important memory-loading system tasks are:

```verilog
$readmemh
```

and

```verilog
$readmemb
```

## `$readmemh`

Reads hexadecimal values.

Example:

```verilog
$readmemh("memory.mem", memory);
```

File:

```text
A5
3C
7F
12
```

---

## `$readmemb`

Reads binary values.

Example:

```verilog
$readmemb("memory.mem", memory);
```

File:

```text
10100101
00111100
01111111
00010010
```

---

# 4. `$readmemh` vs `$readmemb`

| Feature          | `$readmemh`          | `$readmemb`                 |
| ---------------- | -------------------- | --------------------------- |
| Input format     | Hexadecimal          | Binary                      |
| Example          | `A5`                 | `10100101`                  |
| Useful for       | Compact memory files | Explicit bit representation |
| Common extension | `.mem`               | `.mem`                      |

The file extension itself does **not** determine whether the data is hexadecimal or binary.

The system task determines how Verilog interprets it.

---

# 5. What is a ROM?

ROM means:

**Read Only Memory**

For today's example:

```text
16 locations
8 bits/location
```

Therefore:

$$
ROM = 16 \times 8
$$

Address width:

$$
\log_2(16)=4
$$

Therefore:

```text
address = 4 bits
data    = 8 bits
```

Address range:

```text
0000 → 1111
```

or:

```text
0 → 15
```

---

# 6. ROM Structure

Our ROM will look like:

```text
             +----------------+
 address --->|                |
             |    16 × 8     |----> data
             |      ROM       |
             |                |
             +----------------+
```

There are:

```text
16 addresses
```

and each location contains:

```text
8 bits
```

---

# 7. Memory Declaration

In Verilog:

```verilog
reg [7:0] memory [0:15];
```

Meaning:

```text
[7:0]  → each memory location is 8 bits
[0:15] → there are 16 locations
```

Visual representation:

```text
Address       Data

0             8 bits
1             8 bits
2             8 bits
3             8 bits
...
15            8 bits
```

---

# 8. Create the Memory File

Create:

```text
rom_data.mem
```

Put:

```text
A5
3C
7F
12
88
01
F0
55
AA
19
C3
5E
77
20
DE
42
```

Each line represents one ROM location.

Therefore:

```text
Address 0 → A5
Address 1 → 3C
Address 2 → 7F
Address 3 → 12
Address 4 → 88
Address 5 → 01
Address 6 → F0
Address 7 → 55
Address 8 → AA
Address 9 → 19
Address 10 → C3
Address 11 → 5E
Address 12 → 77
Address 13 → 20
Address 14 → DE
Address 15 → 42
```

---

# 9. ROM RTL

Create:

```text
rtl/rom.v
```

Code:

```verilog
module rom #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] data
);

    reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    // Load ROM contents
    initial begin
        $readmemh("rom_data.mem", memory);
    end

    // Asynchronous read
    always @(*) begin
        data = memory[addr];
    end

endmodule
```

---

# 10. Why `initial`?

We use:

```verilog
initial begin
    $readmemh(...);
end
```

because the memory contents need to be loaded once at the beginning of simulation.

This is primarily a **memory initialization/simulation mechanism**.

In FPGA design flows, memory initialization files can also be used by synthesis/implementation tools to initialize FPGA memory resources, but exact support depends on the target tool and device.

---

# 11. Why is `memory` a `reg`?

We declared:

```verilog
reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
```

because the memory contents are being stored and accessed as variables in the Verilog model.

This does **not** mean every `reg` necessarily becomes a physical register.

Synthesis determines the appropriate hardware based on the RTL and target technology.

---

# 12. Asynchronous ROM Read

Our read logic is:

```verilog
always @(*) begin
    data = memory[addr];
end
```

Therefore:

```text
address changes
      |
      v
ROM data changes
```

There is no clock controlling the read.

Conceptually:

```text
addr ──────> ROM ──────> data
```

---

# 13. Testbench

Create:

```text
tb/tb_rom.v
```

```verilog
`timescale 1ns/1ps

module tb_rom;

    reg  [3:0] addr;
    wire [7:0] data;

    integer i;

    // DUT
    rom uut (
        .addr(addr),
        .data(data)
    );

    initial begin

        $dumpfile("rom.vcd");
        $dumpvars(0, tb_rom);

        $display("================================");
        $display("        ROM CONTENT TEST");
        $display("================================");
        $display("Address       Data");
        $display("--------------------------------");

        // Read every ROM location
        for (i = 0; i < 16; i = i + 1) begin

            addr = i;
            #10;

            $display("   %2d          %h", addr, data);

        end

        $display("================================");

        $finish;
    end

endmodule
```

---

# 14. Expected Output

You should get approximately:

```text
================================
        ROM CONTENT TEST
================================
Address       Data
--------------------------------
    0          A5
    1          3C
    2          7F
    3          12
    4          88
    5          01
    6          F0
    7          55
    8          AA
    9          19
   10          C3
   11          5E
   12          77
   13          20
   14          DE
   15          42
================================
```

The exact formatting can vary slightly depending on the simulator.

---

# 15. Compile on Ubuntu

Directory:

```text
Day_38/
├── README.md
├── rtl/
│   └── rom.v
├── tb/
│   └── tb_rom.v
├── data/
│   └── rom_data.mem
└── sim/
```

If your `.mem` file is inside `data/`, update the RTL:

```verilog
$readmemh("data/rom_data.mem", memory);
```

Then compile:

```bash
iverilog -o sim/rom_test \
    rtl/rom.v \
    tb/tb_rom.v
```

Run:

```bash
vvp sim/rom_test
```

---

# 16. GTKWave

The testbench generates:

```text
rom.vcd
```

Open:

```bash
gtkwave rom.vcd
```

Add:

```text
addr
data
```

You should see:

```text
addr:
0 → 1 → 2 → 3 → ... → 15

data:
A5 → 3C → 7F → 12 → ... → 42
```

---

# 17. Random ROM Test

The roadmap assignment specifically asks for a **COE/MEM random ROM test**.

Instead of checking addresses sequentially only, we can access random addresses.

For example:

```text
address sequence:

5
12
3
14
7
0
9
15
```

The ROM must return the corresponding contents.

---

# 18. Random ROM Testbench

Replace the previous testbench with:

```verilog
`timescale 1ns/1ps

module tb_rom_random;

    reg  [3:0] addr;
    wire [7:0] data;

    reg [7:0] expected;
    integer i;
    integer random_addr;

    // Reference memory
    reg [7:0] expected_memory [0:15];

    rom uut (
        .addr(addr),
        .data(data)
    );

    initial begin

        $dumpfile("rom_random.vcd");
        $dumpvars(0, tb_rom_random);

        // Reference copy of the ROM contents
        expected_memory[0]  = 8'hA5;
        expected_memory[1]  = 8'h3C;
        expected_memory[2]  = 8'h7F;
        expected_memory[3]  = 8'h12;
        expected_memory[4]  = 8'h88;
        expected_memory[5]  = 8'h01;
        expected_memory[6]  = 8'hF0;
        expected_memory[7]  = 8'h55;
        expected_memory[8]  = 8'hAA;
        expected_memory[9]  = 8'h19;
        expected_memory[10] = 8'hC3;
        expected_memory[11] = 8'h5E;
        expected_memory[12] = 8'h77;
        expected_memory[13] = 8'h20;
        expected_memory[14] = 8'hDE;
        expected_memory[15] = 8'h42;

        $display("======================================");
        $display("       RANDOM ROM TEST");
        $display("======================================");

        // Test 20 random addresses
        for (i = 0; i < 20; i = i + 1) begin

            random_addr = $urandom_range(0, 15);

            addr = random_addr;

            #1;

            expected = expected_memory[random_addr];

            if (data === expected)
                $display(
                    "PASS: addr=%0d data=%h",
                    addr,
                    data
                );
            else
                $display(
                    "FAIL: addr=%0d expected=%h actual=%h",
                    addr,
                    expected,
                    data
                );

            #9;
        end

        $display("======================================");

        $finish;
    end

endmodule
```

---

# 19. Why Use `===` in the Testbench?

We used:

```verilog
if (data === expected)
```

instead of:

```verilog
if (data == expected)
```

`===` is **case equality**.

It considers:

```text
0
1
X
Z
```

as explicit four-state values.

For testbenches, this can be useful when we want to detect unknown values rather than allow an `X` to propagate through a normal `==` comparison.

---

# 20. What is a `.mem` File?

A `.mem` file is simply a text representation of memory contents.

Example:

```text
A5
3C
7F
12
```

It can be loaded with:

```verilog
$readmemh("file.mem", memory);
```

There is no universal requirement that memory initialization files use the `.mem` extension; the important part is the format expected by the tool/system task.

---

# 21. What is a COE File?

**COE** commonly means:

**Coefficient File**

In Xilinx/Vivado flows, a `.coe` file is used to describe initialization data for certain IP/memory-generation flows.

A typical COE-style file can look like:

```text
memory_initialization_radix=16;
memory_initialization_vector=
A5,3C,7F,12,88,01,F0,55,
AA,19,C3,5E,77,20,DE,42;
```

Important:

> A COE file is not the same syntax as a `$readmemh` `.mem` file.

For the Icarus Verilog exercise today, use the `.mem` file directly.

---

# 22. `.mem` vs `.coe`

| Feature              | `.mem`                             | `.coe`                          |
| -------------------- | ---------------------------------- | ------------------------------- |
| Typical use          | Verilog/FPGA memory initialization | Xilinx/Vivado IP initialization |
| Syntax               | Usually simple data lines          | Has initialization keywords     |
| `$readmemh` directly | Yes, if formatted as hex           | No, not in normal COE syntax    |
| Tool dependence      | Relatively simple                  | More tool/IP-flow specific      |

Example `.mem`:

```text
A5
3C
7F
12
```

Example `.coe`:

```text
memory_initialization_radix=16;
memory_initialization_vector=
A5,3C,7F,12;
```

---

# 23. Important: Don't Confuse COE and MEM

A common beginner mistake is:

```verilog
$readmemh("rom.coe", memory);
```

when the COE file contains:

```text
memory_initialization_radix=16;
```

That is not the normal `$readmemh` input format.

For today's Icarus simulation:

```text
Use .mem
```

For a Vivado IP-generation flow:

```text
COE may be used
```

---

# 24. Memory Addressing

Our memory is:

```verilog
reg [7:0] memory [0:15];
```

Therefore:

```text
memory[0]
memory[1]
memory[2]
...
memory[15]
```

are valid.

The address is:

```verilog
reg [3:0] addr;
```

because:

$$
2^4=16
$$

---

# 25. Address Width Formula

For a memory depth of `DEPTH`:

$$
ADDR\_WIDTH = \lceil \log_2(DEPTH) \rceil
$$

Examples:

| Depth | Address bits |
| ----: | -----------: |
|     2 |            1 |
|     4 |            2 |
|     8 |            3 |
|    16 |            4 |
|    32 |            5 |
|    64 |            6 |
|  1024 |           10 |

For:

```text
1024 locations
```

we need:

```text
10-bit address
```

because:

$$
2^{10}=1024
$$

---

# 26. `$readmemh` Address Ranges

Verilog also allows optional start/end addresses.

Example:

```verilog
$readmemh("rom_data.mem", memory, 0, 15);
```

This explicitly tells the simulator to load:

```text
address 0 → address 15
```

For a partial load:

```verilog
$readmemh("rom_data.mem", memory, 4, 7);
```

the file data is loaded into:

```text
memory[4]
memory[5]
memory[6]
memory[7]
```

---

# 27. Useful File-I/O System Tasks

Verilog provides several file-related system tasks/functions.

Important examples:

```text
$readmemh
$readmemb
$fopen
$fclose
$fdisplay
$fwrite
$fscanf
$finish
```

For today's ROM exercise, the most important ones are:

```text
$readmemh
$readmemb
```

We will study more general file handling later if needed.

---

# 28. Synthesis vs Simulation

This distinction is very important for placements.

### Simulation

```verilog
initial begin
    $readmemh(...);
end
```

can load the memory model at simulation start.

### FPGA implementation

An FPGA vendor tool may use an initialization file to initialize an actual block RAM or ROM.

The exact mechanism depends on:

* FPGA family
* synthesis tool
* memory inference style
* IP generation flow

Therefore do not assume that every simulator-only construct automatically maps to hardware.

---

# 29. Random Testing Concept

Random testing is useful because manually testing:

```text
0
1
2
3
...
15
```

only checks a predictable sequence.

Random testing can produce:

```text
7
2
15
4
7
11
0
13
...
```

This can expose errors in address decoding and memory access.

However:

> Random testing should complement deterministic tests, not replace important directed corner-case tests.

For a small ROM, exhaustive testing of every address is easy and valuable.

---

# 30. Exhaustive Verification

For our 16-entry ROM:

```text
16 possible addresses
```

We can simply test all 16.

```verilog
for (i = 0; i < 16; i = i + 1)
```

This is actually stronger than random testing for this tiny address space.

For a huge memory:

```text
1M addresses
```

exhaustive simulation may be expensive, so random and constrained-random testing becomes more useful.

---

# 31. Placement Interview Questions

### Q1. What is `$readmemh`?

A Verilog system task used to initialize a memory array from hexadecimal text data.

---

### Q2. What is `$readmemb`?

It initializes a memory array from binary text data.

---

### Q3. Difference between `$readmemh` and `$readmemb`?

```text
$readmemh → hexadecimal
$readmemb → binary
```

---

### Q4. What is a ROM?

A memory structure intended for read access whose contents are initialized/stored according to the implementation.

---

### Q5. For a 1024 × 8 ROM, what are the address and data widths?

```text
Depth = 1024
Data width = 8

Address width:
log2(1024) = 10
```

Therefore:

```text
Address = 10 bits
Data = 8 bits
```

---

### Q6. How many memory locations are in:

```verilog
reg [15:0] mem [0:255];
```

Answer:

```text
256 locations
```

Each location:

```text
16 bits
```

Therefore:

```text
256 × 16 memory
```

---

### Q7. What does this mean?

```verilog
reg [7:0] mem [0:1023];
```

It means:

```text
1024 locations
8 bits per location
```

---

### Q8. Is `reg [7:0] mem [0:15]` a 16-bit register?

No.

It is:

```text
16 memory locations
each 8 bits wide
```

---

### Q9. What does `$readmemh` load?

It loads values from a hexadecimal text file into a Verilog memory array.

---

### Q10. Why are memory initialization files useful?

They allow large memory contents to be maintained externally rather than hard-coded into RTL.

---

# 32. Practice Questions

### Question 1

What is the address width of:

```text
256 × 32 ROM
```

Answer:

$$
\log_2(256)=8
$$

Therefore:

```text
8-bit address
32-bit data
```

---

### Question 2

How many bits are stored in:

```text
64 × 16 RAM
```

Answer:

$$
64\times16=1024
$$

Therefore:

```text
1024 bits
```

---

### Question 3

What does this represent?

```verilog
reg [31:0] memory [0:1023];
```

Answer:

```text
1024 × 32 memory
```

Total storage:

$$
1024\times32=32768\ bits
$$

or:

```text
4096 bytes
```

---

### Question 4

Which command should be used for:

```text
10101100
```

when loading a binary memory file?

Answer:

```verilog
$readmemb(...)
```

---

### Question 5

Which command should be used for:

```text
AC
7F
12
```

?

Answer:

```verilog
$readmemh(...)
```

---

# 33. Day 38 Assignment

Implement:

## Random ROM Test

Requirements:

```text
ROM:
16 × 8

Input:
4-bit address

Output:
8-bit data
```

Create:

```text
rom_data.mem
```

with at least 16 random hexadecimal values.

Then:

1. Load the file using `$readmemh`.
2. Read every address.
3. Perform random address tests.
4. Compare actual and expected values.
5. Print `PASS` or `FAIL`.
6. Generate a VCD file.
7. Verify the address/data relationship in GTKWave.

Expected architecture:

```text
                 rom_data.mem
                      |
                      v
                 $readmemh
                      |
                      v
                 +---------+
     address --->|   ROM   |----> data
                 +---------+
                      |
                      v
                 Testbench
                      |
                PASS / FAIL
```

---

# 34. Git Commit

After completing the experiment:

```bash
git add Day_38/
git commit -m "Day 38: File I/O and ROM Memory Test"
git push
```

---

# 35. Day 38 Key Takeaways

Remember these five points:

### 1. `$readmemh`

```text
Hexadecimal memory initialization
```

### 2. `$readmemb`

```text
Binary memory initialization
```

### 3. Memory declaration

```verilog
reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
```

### 4. Address width

$$
ADDR\_WIDTH=\lceil\log_2(DEPTH)\rceil
$$

### 5. COE vs MEM

```text
.mem → simple memory data, convenient with $readmemh/$readmemb

.coe → commonly used by Xilinx/Vivado IP/memory initialization flows
```

---

# Final Day 38 Flow

```text
             External Memory File
                      |
                      v
             +----------------+
             |  $readmemh()   |
             +-------+--------+
                     |
                     v
              +-------------+
              |     ROM     |
              +------+------+
                     |
              address/data
                     |
                     v
                Testbench
                     |
             +-------+-------+
             |               |
           PASS            FAIL
             |
             v
          GTKWave
```

**Day 38 concept:** external memory initialization + ROM verification.

**Next:** Day 39 — **RAM vs ROM coding styles**.
