# Day 39 — RAM vs ROM Coding Styles

## 1. Objective

Learn how to code:

* ROM in Verilog
* Single-port RAM in Verilog
* Synchronous RAM
* Asynchronous-read RAM
* Read/write behavior
* Memory arrays
* Memory initialization
* RAM vs ROM coding differences
* How synthesis can infer memory hardware
* How to verify memories using Icarus Verilog and GTKWave

### Roadmap Topic

**Day 39 — RAM vs ROM coding styles**

The main goal today is to understand how memory structures are represented in RTL.

---

# 2. What is Memory in RTL?

A memory stores multiple words.

For example:

```text
16 × 8 memory
```

means:

```text
16 locations
8 bits per location
```

Therefore:

```text
Address = 4 bits
Data    = 8 bits
```

because:

$$
2^4=16
$$

A Verilog memory can be declared as:

```verilog
reg [7:0] memory [0:15];
```

Meaning:

```text
memory[0]  → 8 bits
memory[1]  → 8 bits
...
memory[15] → 8 bits
```

---

# 3. RAM vs ROM

## RAM

RAM means:

**Random Access Memory**

It normally supports:

```text
WRITE
READ
```

Example:

```text
CPU
 |
 | address
 | write data
 | write enable
 v
+---------+
|   RAM   |
+---------+
 |
 | read data
 v
CPU
```

---

## ROM

ROM means:

**Read Only Memory**

The contents are normally predetermined/initialized and the design reads them.

Example:

```text
address
   |
   v
+---------+
|   ROM   |
+---------+
   |
   v
 data
```

---

# 4. Basic Comparison

| Feature                       | RAM        | ROM          |
| ----------------------------- | ---------- | ------------ |
| Read                          | Yes        | Yes          |
| Write during normal operation | Yes        | No           |
| Stores data                   | Yes        | Yes          |
| Typical RTL memory array      | Yes        | Yes          |
| Initialization file           | Possible   | Common       |
| Main control                  | Read/write | Read/address |

---

# 5. RAM Coding Style

A simple single-port RAM can be written as:

```verilog
module single_port_ram (
    input  wire       clk,
    input  wire       we,
    input  wire [3:0] addr,
    input  wire [7:0] din,
    output reg  [7:0] dout
);

    reg [7:0] memory [0:15];

    always @(posedge clk) begin

        if (we)
            memory[addr] <= din;

        dout <= memory[addr];

    end

endmodule
```

This describes a memory with:

```text
16 locations
8-bit data
```

---

# 6. Understanding the RAM Code

The memory is:

```verilog
reg [7:0] memory [0:15];
```

The write operation is:

```verilog
if (we)
    memory[addr] <= din;
```

Therefore:

```text
we = 1
```

causes:

```text
memory[address] ← input data
```

The read is:

```verilog
dout <= memory[addr];
```

Therefore the stored value is presented at `dout` on the clock edge.

---

# 7. This RAM Has Synchronous Read

Notice:

```verilog
always @(posedge clk)
```

contains both:

```verilog
memory[addr] <= din;
```

and:

```verilog
dout <= memory[addr];
```

Therefore the read operation is clocked.

Conceptually:

```text
address
   |
   v
+-------+
|  RAM  |
+---+---+
    |
    v
 clock
    |
    v
  dout
```

This is a **synchronous-read RAM style**.

---

# 8. Asynchronous-Read RAM

Another coding style is:

```verilog
module async_read_ram (
    input  wire       clk,
    input  wire       we,
    input  wire [3:0] addr,
    input  wire [7:0] din,
    output wire [7:0] dout
);

    reg [7:0] memory [0:15];

    always @(posedge clk) begin

        if (we)
            memory[addr] <= din;

    end

    assign dout = memory[addr];

endmodule
```

Here:

```text
WRITE → clocked
READ  → asynchronous
```

because:

```verilog
assign dout = memory[addr];
```

continuously follows the selected memory location.

---

# 9. Synchronous vs Asynchronous Read

| Feature                  | Synchronous Read        | Asynchronous Read                        |
| ------------------------ | ----------------------- | ---------------------------------------- |
| Read controlled by clock | Yes                     | No                                       |
| Data changes             | On clock edge           | When address changes                     |
| Common in FPGA block RAM | Often                   | Device-dependent                         |
| RTL style                | `always @(posedge clk)` | Continuous assignment/combinational read |

---

# 10. ROM Coding Style — Case Statement

A small ROM can be written directly using a `case`.

Example:

```verilog
module rom_case (
    input  wire [3:0] addr,
    output reg  [7:0] data
);

    always @(*) begin

        case (addr)

            4'd0:  data = 8'hA5;
            4'd1:  data = 8'h3C;
            4'd2:  data = 8'h7F;
            4'd3:  data = 8'h12;
            4'd4:  data = 8'h88;
            4'd5:  data = 8'h01;
            4'd6:  data = 8'hF0;
            4'd7:  data = 8'h55;
            4'd8:  data = 8'hAA;
            4'd9:  data = 8'h19;
            4'd10: data = 8'hC3;
            4'd11: data = 8'h5E;
            4'd12: data = 8'h77;
            4'd13: data = 8'h20;
            4'd14: data = 8'hDE;
            4'd15: data = 8'h42;

            default:
                data = 8'h00;

        endcase

    end

endmodule
```

---

# 11. How This ROM Works

The address selects a constant.

For example:

```text
addr = 0
```

gives:

```text
data = A5
```

and:

```text
addr = 5
```

gives:

```text
data = 01
```

Therefore:

```text
Address → Decoder → Stored constant
```

---

# 12. ROM Using Memory Array

For larger ROMs, an array is much cleaner.

```verilog
module rom_array (
    input  wire [3:0] addr,
    output wire [7:0] data
);

    reg [7:0] memory [0:15];

    initial begin

        memory[0]  = 8'hA5;
        memory[1]  = 8'h3C;
        memory[2]  = 8'h7F;
        memory[3]  = 8'h12;
        memory[4]  = 8'h88;
        memory[5]  = 8'h01;
        memory[6]  = 8'hF0;
        memory[7]  = 8'h55;
        memory[8]  = 8'hAA;
        memory[9]  = 8'h19;
        memory[10] = 8'hC3;
        memory[11] = 8'h5E;
        memory[12] = 8'h77;
        memory[13] = 8'h20;
        memory[14] = 8'hDE;
        memory[15] = 8'h42;

    end

    assign data = memory[addr];

endmodule
```

---

# 13. ROM Using `$readmemh`

For larger memories, external initialization files are convenient.

```verilog
module rom_mem (
    input  wire [3:0] addr,
    output wire [7:0] data
);

    reg [7:0] memory [0:15];

    initial begin
        $readmemh("rom_data.mem", memory);
    end

    assign data = memory[addr];

endmodule
```

This connects directly to what you learned on **Day 38**.

---

# 14. Three Common ROM Styles

You should recognize these three styles:

### Style 1 — `case`

```verilog
always @(*) begin
    case (addr)
        ...
    endcase
end
```

### Style 2 — Array initialization

```verilog
initial begin
    memory[0] = ...;
    memory[1] = ...;
end
```

### Style 3 — External memory file

```verilog
initial begin
    $readmemh("rom_data.mem", memory);
end
```

For large data sets, external memory files are much easier to maintain.

---

# 15. RAM vs ROM RTL Difference

The fundamental difference is whether the design contains a runtime write operation.

RAM:

```verilog
always @(posedge clk) begin
    if (we)
        memory[addr] <= din;
end
```

ROM:

```verilog
assign dout = memory[addr];
```

with the contents initialized beforehand.

Therefore:

```text
RAM:
        Write + Read

ROM:
        Read + Predefined/Initialized Contents
```

---

# 16. Complete RAM Example

For today's practical experiment, create:

```text
rtl/ram.v
```

```verilog
module single_port_ram (
    input  wire       clk,
    input  wire       we,
    input  wire [3:0] addr,
    input  wire [7:0] din,
    output reg  [7:0] dout
);

    reg [7:0] memory [0:15];

    always @(posedge clk) begin

        if (we)
            memory[addr] <= din;

        dout <= memory[addr];

    end

endmodule
```

---

# 17. RAM Testbench

Create:

```text
tb/tb_ram.v
```

```verilog
`timescale 1ns/1ps

module tb_ram;

    reg clk;
    reg we;
    reg [3:0] addr;
    reg [7:0] din;

    wire [7:0] dout;

    single_port_ram uut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout)
    );

    always #5 clk = ~clk;

    task write_mem;
        input [3:0] address;
        input [7:0] value;

        begin
            @(negedge clk);

            addr = address;
            din  = value;
            we   = 1'b1;

            @(negedge clk);

            we = 1'b0;
        end
    endtask

    task read_mem;
        input [3:0] address;

        begin
            @(negedge clk);

            addr = address;
            we   = 1'b0;

            @(posedge clk);
            #1;

            $display(
                "READ: address=%0d data=%h",
                address,
                dout
            );
        end
    endtask

    initial begin

        $dumpfile("ram.vcd");
        $dumpvars(0, tb_ram);

        clk  = 1'b0;
        we   = 1'b0;
        addr = 4'd0;
        din  = 8'h00;

        // Write operations
        write_mem(4'd0, 8'hAA);
        write_mem(4'd1, 8'h55);
        write_mem(4'd5, 8'h3C);
        write_mem(4'd10, 8'hF0);

        // Read operations
        read_mem(4'd0);
        read_mem(4'd1);
        read_mem(4'd5);
        read_mem(4'd10);

        #20;

        $finish;

    end

endmodule
```

---

# 18. Expected RAM Output

You should see values corresponding to the writes:

```text
READ: address=0 data=aa
READ: address=1 data=55
READ: address=5 data=3c
READ: address=10 data=f0
```

The exact simulator formatting can vary.

The important verification is:

```text
Write:
address 0 → AA

Read:
address 0 → AA
```

and similarly for the other addresses.

---

# 19. Truth-Table Verification of RAM Write Enable

For the write control:

| `we` | Operation                     |
| ---: | ----------------------------- |
|    0 | No write                      |
|    1 | Write `din` to `memory[addr]` |

The complete write behavior is:

```text
we = 0
    ↓
memory unchanged

we = 1
    ↓
memory[addr] = din
```

This is the essential RAM control condition.

---

# 20. RAM Read Verification

For the synchronous-read RAM used above:

| Clock edge  | `we` | Operation                                                                |
| ----------- | ---: | ------------------------------------------------------------------------ |
| rising edge |    0 | Read selected memory location                                            |
| rising edge |    1 | Write selected location and update read output according to RTL behavior |

The exact **read-during-write behavior** can depend on the RTL style and target memory technology.

For placement interviews, remember that FPGA RAM primitives can have configurable read-during-write modes, so don't assume every physical RAM behaves identically from an ambiguous RTL description.

---

# 21. Important Point: `reg` Does NOT Automatically Mean Flip-Flop

Consider:

```verilog
reg [7:0] memory [0:1023];
```

This does not mean:

```text
1024 × 8 individual flip-flops
```

`reg` describes a Verilog variable.

Synthesis may infer:

```text
Block RAM
Distributed RAM
Flip-flops
ROM
```

depending on:

* RTL structure
* memory size
* target FPGA
* synthesis tool
* device resources
* coding style

This is a very important VLSI/FPGA concept.

---

# 22. Memory Inference

When synthesis recognizes a memory coding pattern, it can infer an appropriate memory resource.

Conceptually:

```text
Verilog RTL
    |
    v
Synthesis
    |
    v
Memory inference
    |
    +------> Block RAM
    |
    +------> Distributed RAM
    |
    +------> Registers
```

The exact result depends on the technology.

---

# 23. Why Coding Style Matters

Two RTL descriptions can represent logically similar behavior but may lead synthesis tools toward different hardware implementations.

For example:

```verilog
assign dout = memory[addr];
```

describes an asynchronous read.

While:

```verilog
always @(posedge clk)
    dout <= memory[addr];
```

describes a registered/synchronous read.

That difference can matter greatly for FPGA memory inference.

---

# 24. ROM vs RAM Practical Example

Suppose we need a lookup table for:

```text
Sine waveform
```

The values are predetermined.

ROM is appropriate:

```text
address
   ↓
ROM/LUT
   ↓
sine sample
```

Suppose we need a buffer where a processor writes data and later reads it.

RAM is appropriate:

```text
write data
     ↓
    RAM
     ↑
  address
```

---

# 25. Where This Appears in Real RTL

Memory structures are used in:

* CPU register files
* caches
* FIFOs
* packet buffers
* lookup tables
* instruction memory
* data memory
* waveform generators
* DSP systems
* image buffers
* communication systems

Your later **Day 41 FIFO** topic will use memory concepts directly.

---

# 26. RAM Types

Common RAM organizations include:

### Single-Port RAM

One memory port.

```text
address
data
write enable
clock
```

### Simple Dual-Port RAM

Typically:

```text
one write port
one read port
```

### True Dual-Port RAM

Two independent ports can access memory.

Conceptually:

```text
Port A ──┐
         ├── RAM
Port B ──┘
```

These distinctions become important when designing FIFOs and high-throughput datapaths.

---

# 27. Synchronous RAM vs Asynchronous RAM

Remember:

### Synchronous read

```verilog
always @(posedge clk)
    dout <= memory[addr];
```

Concept:

```text
addr
 |
 v
RAM
 |
clock
 |
 v
dout
```

### Asynchronous read

```verilog
assign dout = memory[addr];
```

Concept:

```text
addr
 |
 v
RAM
 |
 v
dout
```

No read clock is explicitly present in the RTL.

---

# 28. Common Beginner Mistake

Incorrect assumption:

> "If I declare `reg [7:0] memory [0:15]`, synthesis will definitely create 128 flip-flops."

Not necessarily.

The synthesis tool analyzes the entire RTL and target technology.

It may infer a memory resource instead.

Therefore:

```text
Verilog data type ≠ guaranteed physical hardware type
```

---

# 29. Another Important Mistake

Do not accidentally create a latch in combinational ROM logic.

Bad style:

```verilog
always @(*) begin
    if (addr == 4'd0)
        data = 8'hAA;
end
```

What happens for other addresses?

`data` is not assigned.

This can infer latch-like behavior.

Better:

```verilog
always @(*) begin

    data = 8'h00;

    case (addr)
        4'd0: data = 8'hAA;
        4'd1: data = 8'h55;
        ...
        default: data = 8'h00;
    endcase

end
```

Or use a complete `case`.

---

# 30. Run the RAM Simulation

Create:

```text
Day_39/
├── README.md
├── rtl/
│   └── ram.v
├── tb/
│   └── tb_ram.v
└── sim/
```

Compile:

```bash
iverilog -o sim/ram_test \
    rtl/ram.v \
    tb/tb_ram.v
```

Run:

```bash
vvp sim/ram_test
```

Open waveform:

```bash
gtkwave ram.vcd
```

Add:

```text
clk
we
addr
din
dout
```

---

# 31. What to Verify in GTKWave

Check the write to address 0:

```text
addr = 0
din  = AA
we   = 1
```

Then later:

```text
addr = 0
we   = 0
```

and verify:

```text
dout = AA
```

Similarly verify:

```text
address 1 → 55
address 5 → 3C
address 10 → F0
```

---

# 32. Placement Interview Questions

## Q1. What is RAM?

Random Access Memory that supports storage and normally runtime read/write operations.

---

## Q2. What is ROM?

A read-oriented memory whose contents are predetermined or initialized according to the implementation.

---

## Q3. What is the difference between synchronous and asynchronous RAM read?

**Synchronous read:**

Data is registered/updated in relation to a clock edge.

**Asynchronous read:**

Data follows the addressed memory location without an explicit read clock in the RTL.

---

## Q4. What is memory inference?

The process by which synthesis recognizes RTL describing a memory and maps it to an appropriate hardware memory resource.

---

## Q5. Does `reg` mean a physical flip-flop?

No.

`reg` is a Verilog variable type. Physical implementation depends on the RTL and synthesis target.

---

## Q6. What is a single-port RAM?

A RAM architecture with one memory access port.

---

## Q7. What is a dual-port RAM?

A RAM allowing two memory access ports, with the exact read/write capabilities depending on the architecture.

---

## Q8. Why are memory coding styles important?

Because the coding style affects the inferred behavior and can influence which physical memory resources synthesis can use.

---

## Q9. How do you initialize ROM from an external file?

For a hexadecimal memory file:

```verilog
initial begin
    $readmemh("rom_data.mem", memory);
end
```

---

## Q10. What is the difference between RAM and ROM at RTL?

RAM contains a runtime write mechanism:

```verilog
if (we)
    memory[addr] <= din;
```

ROM does not normally contain such a runtime write path.

---

# 33. Placement Questions — Calculate Memory Size

### Question 1

What is the size of:

```verilog
reg [7:0] mem [0:255];
```

There are:

$$
256
$$

locations.

Each location:

$$
8\ bits
$$

Therefore:

$$
256\times8=2048\ bits
$$

or:

$$
256\ bytes
$$

---

### Question 2

What is the size of:

```verilog
reg [31:0] mem [0:1023];
```

$$
1024\times32=32768\ bits
$$

Therefore:

```text
32768 bits
= 4096 bytes
= 4 KB
```

---

### Question 3

What address width is required?

For:

```text
4096 locations
```

$$
\log_2(4096)=12
$$

Therefore:

```text
12-bit address
```

---

# 34. Practice Questions

### Basic

1. What is RAM?
2. What is ROM?
3. What is a memory array?
4. What is memory inference?
5. What is a single-port RAM?

### RTL

6. Write a 32 × 8 RAM.
7. Write an 8 × 16 ROM.
8. Write synchronous RAM.
9. Write asynchronous-read RAM.
10. Initialize ROM using `$readmemh`.

### Placement

11. How many address bits are required for 512 memory locations?
12. What is the storage capacity of a 128 × 16 RAM?
13. What is the difference between block RAM and distributed RAM?
14. What happens if a combinational ROM does not assign its output for every condition?
15. Why does coding style matter for memory inference?

---

# 35. Day 39 Assignment

Implement **both RAM and ROM**.

## Part A — ROM

Create:

```text
16 × 8 ROM
```

Use:

```text
rom_data.mem
```

and:

```verilog
$readmemh(...)
```

Verify all 16 addresses.

---

## Part B — RAM

Create:

```text
16 × 8 single-port RAM
```

Perform:

```text
WRITE:
0  → AA
1  → 55
5  → 3C
10 → F0
```

Then read the same addresses and verify the stored values.

---

## Part C — Compare

Create a table:

| Feature                 | ROM                   | RAM                            |
| ----------------------- | --------------------- | ------------------------------ |
| Read                    | Yes                   | Yes                            |
| Runtime write           | No                    | Yes                            |
| External initialization | Common                | Possible                       |
| `$readmemh`             | Yes                   | Can be used for initialization |
| Typical use             | LUT/program constants | Buffers/data storage           |

---

# 36. Git Structure

```text
RTL_50_Days/
│
├── Day_39/
│   ├── README.md
│   │
│   ├── rtl/
│   │   ├── ram.v
│   │   └── rom.v
│   │
│   ├── tb/
│   │   ├── tb_ram.v
│   │   └── tb_rom.v
│   │
│   ├── data/
│   │   └── rom_data.mem
│   │
│   └── sim/
│
└── ...
```

Commit:

```bash
git add Day_39/
git commit -m "Day 39: RAM and ROM Coding Styles"
git push
```

---

# 37. Day 39 Key Takeaways

Remember these for placement interviews:

```text
RAM
 ↓
Read + Runtime Write

ROM
 ↓
Read + Predefined/Initialized Contents
```

Memory declaration:

```verilog
reg [DATA_WIDTH-1:0] memory [0:DEPTH-1];
```

Hexadecimal initialization:

```verilog
$readmemh("file.mem", memory);
```

Binary initialization:

```verilog
$readmemb("file.mem", memory);
```

Synchronous read:

```verilog
always @(posedge clk)
    dout <= memory[addr];
```

Asynchronous read:

```verilog
assign dout = memory[addr];
```

Most important concept:

> **RTL coding style describes behavior; synthesis determines the physical implementation based on the target technology and constraints.**

---

# Day 39 Final Flow

```text
                 MEMORY
                    |
          +---------+---------+
          |                   |
         ROM                 RAM
          |                   |
   predefined data      runtime write
          |                   |
          +---------+---------+
                    |
                    v
              RTL inference
                    |
                    v
             Synthesis Tool
                    |
          +---------+---------+
          |         |         |
        BRAM      LUT/RAM   FFs
```

**Day 39 complete.**

Next roadmap topic:

**Day 40 — Block Memory vs Distributed Memory / FPGA Memory Resources**
