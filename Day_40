# Day 40 — Block Memory vs Distributed Memory

## 1. Objective

Learn how FPGA memory can be implemented using different physical resources.

Today we will understand:

* FPGA memory resources
* Block RAM (BRAM)
* Distributed RAM
* LUT-based memory
* Registers vs RAM
* When synthesis infers each type
* RAM coding styles
* Memory size calculations
* BRAM vs distributed RAM
* FPGA-specific synthesis considerations
* Practical Verilog experiments
* Placement interview questions

---

# 2. Why Do We Need Different Memory Resources?

In an FPGA, memory does not have to be implemented only using flip-flops.

An FPGA typically contains resources such as:

```text
FPGA
│
├── LUTs
├── Flip-Flops
├── Block RAM
├── DSP blocks
└── Other dedicated resources
```

Memory can therefore be implemented using:

```text
1. Flip-flops
2. Distributed RAM using LUTs
3. Block RAM
```

The synthesis tool decides how to map the RTL according to:

* memory size
* coding style
* read/write behavior
* target FPGA
* synthesis settings
* timing/resource requirements

---

# 3. Three Important Memory Implementations

Conceptually:

```text
                 Memory RTL
                     |
          +----------+----------+
          |          |          |
          v          v          v
       Registers   LUT RAM    Block RAM
```

### Registers

Small memories can be implemented using flip-flops.

### Distributed RAM

LUTs can be configured as small RAM structures.

### Block RAM

Dedicated memory blocks inside the FPGA are used.

---

# 4. What is Block RAM?

**Block RAM**, commonly abbreviated as **BRAM**, is dedicated memory hardware available inside many FPGAs.

Instead of constructing a large memory from thousands of LUTs or flip-flops, the FPGA provides dedicated memory blocks.

Conceptually:

```text
              FPGA
+-----------------------------------+
|                                   |
|   LUT   LUT   LUT                |
|                                   |
|       +-------------+             |
|       |   BRAM      |             |
|       |             |             |
|       | Memory      |             |
|       +-------------+             |
|                                   |
|   LUT   LUT   LUT                |
|                                   |
+-----------------------------------+
```

BRAM is particularly useful for larger memories.

---

# 5. Why Use BRAM?

Suppose you need:

```text
16 KB memory
```

Implementing it entirely using flip-flops would consume a large number of registers.

A dedicated BRAM resource can store the data much more efficiently.

Advantages include:

* efficient memory usage
* predictable memory structure
* good density
* useful synchronous memory interfaces
* reduced consumption of general-purpose logic resources

---

# 6. What is Distributed RAM?

Distributed RAM uses FPGA LUT resources to implement memory.

Conceptually:

```text
LUT
 ↓
configured as
 ↓
small RAM
```

Several LUTs can therefore form a memory.

```text
LUT RAM + LUT RAM + LUT RAM
          |
          v
    Distributed RAM
```

It is generally useful for smaller memories or memories where the FPGA architecture and desired access behavior favor LUT-based implementation.

---

# 7. BRAM vs Distributed RAM

| Feature                           | Block RAM                      | Distributed RAM             |
| --------------------------------- | ------------------------------ | --------------------------- |
| Physical resource                 | Dedicated memory blocks        | LUT resources               |
| Best suited                       | Larger memories                | Smaller memories            |
| Uses LUTs                         | No, for storage itself         | Yes                         |
| Uses dedicated RAM blocks         | Yes                            | No                          |
| Memory density                    | High                           | Lower                       |
| General-purpose logic consumption | Lower for storage              | Uses LUT resources          |
| Typical use                       | Buffers, FIFOs, large memories | Small tables, small buffers |

Do not interpret this as an absolute rule.

The actual mapping depends on the FPGA architecture and synthesis tool.

---

# 8. Example

Suppose you need:

```text
16 × 8 memory
```

This is:

$$
16\times8=128\ bits
$$

This is a very small memory.

A synthesis tool may implement it using LUT-based resources or registers rather than consuming a dedicated block RAM resource, depending on the device and coding style.

Now consider:

```text
4096 × 32
```

Storage:

$$
4096\times32=131072\ bits
$$

which is:

$$
16,384\ bytes=16\ KB
$$

A dedicated block-memory resource becomes much more attractive.

---

# 9. Distributed RAM Concept

A simplified conceptual model:

```text
             Address
                |
                v
        +---------------+
        |      LUT      |
        |    as RAM     |
        +-------+-------+
                |
                v
             Data
```

Multiple LUTs can be combined:

```text
             Address
                |
      +---------+---------+
      |         |         |
      v         v         v
    LUT-RAM   LUT-RAM   LUT-RAM
      |         |         |
      +---------+---------+
                |
                v
              Data
```

---

# 10. Block RAM Concept

Block RAM is a dedicated memory resource:

```text
             Address
                |
                v
       +----------------+
       |                |
       |     BRAM       |
       |                |
       |  Dedicated     |
       |    Memory      |
       |                |
       +-------+--------+
               |
               v
             Data
```

The FPGA architecture determines the exact BRAM organization and port capabilities.

---

# 11. Registers vs Distributed RAM vs BRAM

A useful conceptual comparison:

| Memory implementation | Best general use                  |
| --------------------- | --------------------------------- |
| Flip-flops            | Very small storage/control state  |
| Distributed RAM       | Small memories                    |
| BRAM                  | Medium/large memories and buffers |

For example:

```text
Small lookup table
       ↓
Distributed RAM / LUT

Large data buffer
       ↓
BRAM

Few configuration registers
       ↓
Flip-flops
```

---

# 12. Memory Inference

This is one of the most important concepts today.

You normally write behavioral RTL:

```verilog
reg [7:0] memory [0:1023];
```

and describe how it is accessed.

The synthesis tool analyzes the RTL.

```text
RTL
 |
 v
Synthesis
 |
 v
Memory inference
 |
 +--------> FFs
 |
 +--------> LUT RAM
 |
 +--------> BRAM
```

You are describing **behavior**.

The synthesis tool maps that behavior to the target FPGA architecture.

---

# 13. Example RAM

Consider:

```verilog
module ram (
    input wire clk,
    input wire we,
    input wire [9:0] addr,
    input wire [7:0] din,
    output reg [7:0] dout
);

    reg [7:0] memory [0:1023];

    always @(posedge clk) begin

        if (we)
            memory[addr] <= din;

        dout <= memory[addr];

    end

endmodule
```

Memory size:

```text
1024 × 8
```

Address width:

$$
\log_2(1024)=10
$$

Storage:

$$
1024\times8=8192\ bits
$$

or:

```text
1024 bytes
1 KB
```

Depending on the FPGA and synthesis constraints, this could potentially be mapped to block RAM or another memory resource.

---

# 14. Why Synchronous Read Often Matters

A common FPGA RAM style is:

```verilog
always @(posedge clk) begin
    dout <= memory[addr];
end
```

This describes a clocked read.

Conceptually:

```text
address
   |
   v
 memory
   |
 clock edge
   |
   v
 dout
```

This style often aligns well with dedicated FPGA block-memory architectures, although exact inference depends on the target device and tool.

---

# 15. Asynchronous Read

Compare:

```verilog
assign dout = memory[addr];
```

Here:

```text
address changes
      |
      v
data changes
```

without an explicit read clock.

This type of behavior can be more naturally implemented using LUT-based structures on some FPGA architectures.

However:

> Never assume a particular resource will always be inferred solely from one line of RTL.

Always verify with the target synthesis tool.

---

# 16. FPGA-Specific Memory Mapping

For your FPGA work, think in terms of:

```text
RTL memory
     |
     v
Synthesis
     |
     v
Target FPGA
     |
     +----> LUT/Distributed RAM
     |
     +----> Block RAM
     |
     +----> Registers
```

The same RTL may map differently on different FPGA families.

---

# 17. Important: Xilinx FPGA Example

You are working with Xilinx/Vivado in your FPGA projects.

A Xilinx FPGA may provide dedicated memory resources such as:

* Block RAM
* LUT-based distributed RAM

The exact capacity and organization depends on the particular FPGA family/device.

For example, a design targeting a **Zynq-7000** device should be analyzed using the memory resources available in that specific device.

Therefore, don't memorize one universal BRAM capacity for every Xilinx FPGA.

---

# 18. What is a LUT?

LUT means:

**Look-Up Table**

At a simplified level, a LUT implements a programmable truth table.

For example, a small combinational function:

```text
A B C
 ↓ ↓ ↓
+-------+
|  LUT  |
+-------+
   |
   Y
```

The FPGA can also configure suitable LUT structures to implement distributed RAM.

Thus:

```text
LUT
 ↓
Logic

or

LUT
 ↓
Distributed RAM
```

depending on configuration.

---

# 19. Distributed RAM Example

A small RAM can be written as:

```verilog
module distributed_ram_example (
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

This describes:

```text
16 × 8 RAM
```

with:

```text
clocked write
asynchronous read
```

On an FPGA that supports LUT-based distributed RAM with this behavior, the synthesis tool may infer distributed RAM.

But the correct mapping should be confirmed in synthesis reports.

---

# 20. BRAM-Oriented RAM Example

A synchronous-read style is:

```verilog
module bram_style (
    input  wire       clk,
    input  wire       we,
    input  wire [9:0] addr,
    input  wire [31:0] din,
    output reg  [31:0] dout
);

    reg [31:0] memory [0:1023];

    always @(posedge clk) begin

        if (we)
            memory[addr] <= din;

        dout <= memory[addr];

    end

endmodule
```

This describes:

```text
1024 × 32
```

or:

$$
32768\ bits
$$

which is:

```text
4 KB
```

The target FPGA may map this into block memory resources.

---

# 21. Don't Force a Resource Without Reason

A beginner may think:

> "I want BRAM, so I will just write `reg [..] memory[..]`."

That is not enough to guarantee a particular implementation.

Similarly:

> "I wrote a small RAM, so it must become distributed RAM."

Not necessarily.

Resource inference depends on:

```text
RTL
+
target architecture
+
synthesis tool
+
constraints/settings
```

---

# 22. Explicit FPGA Memory Primitives

Some FPGA designs instantiate vendor-specific primitives directly.

Conceptually:

```text
RTL
 |
 +---- inferred memory
 |
 +---- explicit FPGA primitive
```

Inference is generally more portable.

Primitive instantiation provides more direct control over device-specific resources but reduces portability.

For placement interviews, know the difference:

### Inference

```text
Behavioral RTL
→ synthesis determines implementation
```

### Primitive instantiation

```text
RTL explicitly instantiates
target-specific hardware
```

---

# 23. Portable vs Vendor-Specific RTL

### Portable

```verilog
reg [7:0] memory [0:255];
```

This can be understood by many synthesis tools.

### Vendor-specific

Instantiating a device-specific BRAM primitive directly.

Advantages:

* precise control
* access to device-specific features

Disadvantages:

* less portable
* more device-specific code

For general RTL development, memory inference is often preferred unless specific hardware control is required.

---

# 24. Memory Size Calculation

This is a placement favorite.

For:

```text
DEPTH × WIDTH
```

total storage is:

$$
Memory\ bits=DEPTH\times WIDTH
$$

Example:

```text
2048 × 16
```

$$
2048\times16=32768\ bits
$$

Therefore:

```text
32768 bits
= 4096 bytes
= 4 KB
```

---

# 25. Address Width

For:

```text
2048 locations
```

we need:

$$
\log_2(2048)=11
$$

Therefore:

```text
Address = 11 bits
```

For:

```text
4096 locations
```

we need:

```text
12 bits
```

---

# 26. Memory Organization

Suppose:

```text
32 KB memory
8-bit data width
```

Number of locations:

$$
32KB = 32768\ bytes
$$

Since each location stores one byte:

$$
32768\ locations
$$

Address width:

$$
\log_2(32768)=15
$$

Therefore:

```text
32K × 8
```

requires:

```text
15-bit address
8-bit data
```

---

# 27. BRAM Fragmentation

A memory request does not always perfectly fill the available physical BRAM resources.

For example, suppose the FPGA has a certain BRAM block size, but your requested memory is smaller.

The implementation may leave some physical memory capacity unused.

Conceptually:

```text
Physical BRAM
+----------------------+
| Used                  |
|                       |
| Unused capacity       |
+----------------------+
```

This is one reason memory architecture and packing matter in FPGA design.

---

# 28. Width vs Depth

Two memories can have the same total number of bits but different organizations.

Example:

```text
Memory A:
1024 × 8

Memory B:
256 × 32
```

Both contain:

$$
8192\ bits
$$

but their:

```text
address width
data width
physical mapping
port configuration
```

may differ.

Therefore:

> Total bit count alone does not completely describe how a memory maps to FPGA resources.

---

# 29. Example Comparison

| Memory    | Total bits | Address bits | Data width |
| --------- | ---------: | -----------: | ---------: |
| 256 × 8   |       2048 |            8 |          8 |
| 512 × 16  |       8192 |            9 |         16 |
| 1024 × 32 |      32768 |           10 |         32 |
| 4096 × 8  |      32768 |           12 |          8 |

Notice:

```text
1024 × 32
```

and:

```text
4096 × 8
```

have the same total capacity:

```text
32768 bits
```

but different organizations.

---

# 30. Practical Experiment

We will create a small RAM and observe the synthesis result conceptually.

Create:

```text
Day_40/
├── README.md
├── rtl/
│   ├── small_ram.v
│   └── large_ram.v
├── tb/
│   └── tb_memory.v
└── sim/
```

---

# 31. Small RAM

Create:

```text
rtl/small_ram.v
```

```verilog
module small_ram (
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

This is:

```text
16 × 8
```

or:

$$
128\ bits
$$

---

# 32. Larger RAM

Create:

```text
rtl/large_ram.v
```

```verilog
module large_ram (
    input  wire        clk,
    input  wire        we,
    input  wire [9:0]  addr,
    input  wire [31:0] din,
    output reg  [31:0] dout
);

    reg [31:0] memory [0:1023];

    always @(posedge clk) begin

        if (we)
            memory[addr] <= din;

        dout <= memory[addr];

    end

endmodule
```

This is:

```text
1024 × 32
```

Storage:

$$
1024\times32=32768\ bits
$$

or:

```text
4 KB
```

---

# 33. Testbench

Create:

```text
tb/tb_memory.v
```

```verilog
`timescale 1ns/1ps

module tb_memory;

    reg clk;

    reg small_we;
    reg [3:0] small_addr;
    reg [7:0] small_din;
    wire [7:0] small_dout;

    reg large_we;
    reg [9:0] large_addr;
    reg [31:0] large_din;
    wire [31:0] large_dout;

    small_ram small_mem (
        .clk(clk),
        .we(small_we),
        .addr(small_addr),
        .din(small_din),
        .dout(small_dout)
    );

    large_ram large_mem (
        .clk(clk),
        .we(large_we),
        .addr(large_addr),
        .din(large_din),
        .dout(large_dout)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("memory.vcd");
        $dumpvars(0, tb_memory);

        clk = 0;

        small_we   = 0;
        small_addr = 0;
        small_din  = 0;

        large_we   = 0;
        large_addr = 0;
        large_din  = 0;

        // -------------------------
        // Small RAM write
        // -------------------------

        @(negedge clk);

        small_we   = 1;
        small_addr = 4'd3;
        small_din  = 8'hA5;

        @(negedge clk);

        small_we = 0;

        // -------------------------
        // Large RAM write
        // -------------------------

        large_we   = 1;
        large_addr = 10'd100;
        large_din  = 32'hDEADBEEF;

        @(negedge clk);

        large_we = 0;

        // -------------------------
        // Read
        // -------------------------

        small_addr = 4'd3;
        large_addr = 10'd100;

        #20;

        $display(
            "Small RAM: addr=%0d data=%h",
            small_addr,
            small_dout
        );

        $display(
            "Large RAM: addr=%0d data=%h",
            large_addr,
            large_dout
        );

        #20;

        $finish;

    end

endmodule
```

---

# 34. Compile

From the Day 40 directory:

```bash
iverilog -o sim/memory_test \
    rtl/small_ram.v \
    rtl/large_ram.v \
    tb/tb_memory.v
```

Run:

```bash
vvp sim/memory_test
```

Expected values include:

```text
Small RAM: addr=3 data=a5
Large RAM: addr=100 data=deadbeef
```

Then:

```bash
gtkwave memory.vcd
```

---

# 35. Truth-Table Verification

For RAM write control:

| `we` | Result                          |
| ---: | ------------------------------- |
|    0 | No write                        |
|    1 | Write `din` into `memory[addr]` |

For a particular address:

```text
we=1
addr=3
din=A5
```

results in:

```text
memory[3] = A5
```

Then:

```text
we=0
addr=3
```

should produce:

```text
dout=A5
```

---

# 36. What Should You Check in a Real FPGA Project?

After synthesis, don't guess whether the memory became BRAM.

Check the synthesis reports.

Look for resource utilization such as:

```text
LUTs
Flip-Flops
Block RAM
Distributed RAM
```

The exact report names depend on the tool.

For Vivado, the utilization report can show how resources are being used.

The design flow is:

```text
RTL
 ↓
Synthesis
 ↓
Open Synthesized Design
 ↓
Reports
 ↓
Resource Utilization
```

---

# 37. Vivado Experiment

Since you use Vivado 2022.2, you can perform this experiment there.

After synthesis:

```text
Open Synthesized Design
        ↓
Reports
        ↓
Report Utilization
```

Look for memory-related resource usage.

Depending on the FPGA and RTL, you may see resources associated with:

```text
Block RAM
LUTs
LUTRAM / distributed RAM
Registers
```

The exact names and availability depend on the target device.

---

# 38. Important Verification Rule

Simulation proves:

```text
logical behavior
```

It does **not by itself prove**:

```text
physical resource mapping
```

For example:

```text
Icarus simulation
```

can show that a RAM correctly reads and writes.

But it cannot tell you:

```text
"This RAM will definitely use BRAM on your Xilinx FPGA."
```

For that, use:

```text
Vivado synthesis
+
resource utilization reports
```

This distinction is extremely important in FPGA design.

---

# 39. Placement Interview Questions

## Q1. What is BRAM?

Dedicated block memory hardware available inside an FPGA.

---

## Q2. What is distributed RAM?

RAM implemented using configurable LUT resources.

---

## Q3. What is memory inference?

Synthesis recognizing memory behavior in RTL and mapping it to suitable hardware resources.

---

## Q4. Which is generally better for a large FPGA memory?

Dedicated block RAM is commonly used for larger memories because it provides high-density dedicated storage.

The exact choice depends on the architecture and requirements.

---

## Q5. Which is generally useful for small memories?

Distributed RAM or registers may be suitable, depending on the memory behavior and target FPGA.

---

## Q6. Does every RAM automatically become BRAM?

No.

Resource inference depends on:

```text
RTL
+
memory size
+
read/write behavior
+
target FPGA
+
synthesis settings
```

---

## Q7. What is LUTRAM?

LUTRAM is RAM implemented using LUT resources.

It is another term commonly used for distributed RAM.

---

## Q8. Why might a small RAM not use BRAM?

Because consuming an entire dedicated BRAM resource for a tiny memory may be inefficient, and the synthesis tool may instead use LUTs or registers.

---

## Q9. What happens if you need a large memory but code it inefficiently?

The synthesis tool may fail to infer the desired memory structure or may consume excessive general-purpose resources.

Therefore memory coding style matters.

---

## Q10. How do you verify whether BRAM was inferred?

Use the target FPGA synthesis tool's resource/utilization reports.

For your Vivado flow:

```text
Synthesis
→ Open Synthesized Design
→ Report Utilization
```

---

# 40. Placement Calculation Questions

### Q1

A RAM is:

```text
2048 × 16
```

Find storage capacity.

$$
2048\times16=32768\ bits
$$

Therefore:

```text
32768 bits
= 4096 bytes
= 4 KB
```

---

### Q2

How many address bits?

$$
\log_2(2048)=11
$$

Answer:

```text
11 bits
```

---

### Q3

A memory is:

```text
8192 × 32
```

Total bits:

$$
8192\times32=262144
$$

Therefore:

```text
262144 bits
= 32768 bytes
= 32 KB
```

Address width:

$$
\log_2(8192)=13
$$

Answer:

```text
13-bit address
32-bit data
```

---

### Q4

Compare:

```text
1024 × 32
```

and:

```text
4096 × 8
```

Both contain:

$$
32768\ bits
$$

But:

```text
1024 × 32
→ 10-bit address
→ 32-bit data

4096 × 8
→ 12-bit address
→ 8-bit data
```

Same total capacity does not mean identical memory organization.

---

# 41. Practice Questions

## Basic

1. What is BRAM?
2. What is distributed RAM?
3. What is LUTRAM?
4. What is memory inference?
5. What is the difference between BRAM and distributed RAM?

## RTL

6. Write a 16 × 8 distributed-RAM-style model.
7. Write a 1024 × 32 synchronous RAM.
8. Explain asynchronous vs synchronous memory read.
9. Explain why coding style affects memory inference.
10. Explain why `reg` does not guarantee flip-flop implementation.

## Placement

11. Calculate the size of a 4096 × 16 RAM.
12. Calculate address width for 8192 locations.
13. Why might a 16 × 8 RAM use LUTs instead of BRAM?
14. How can you verify BRAM inference?
15. Why is simulation insufficient to determine physical FPGA resource usage?

---

# 42. Day 40 Assignment

Design two memories:

## Memory A — Small

```text
16 × 8
```

Use:

```text
clocked write
asynchronous read
```

Study whether the target FPGA synthesis flow maps it to distributed memory or another resource.

---

## Memory B — Larger

```text
1024 × 32
```

Use:

```text
clocked write
synchronous read
```

Synthesize it in Vivado and inspect the utilization report.

Record:

```text
LUT usage
FF usage
BRAM usage
```

Do not assume the result beforehand.

---

# 43. Recommended Git Structure

```text
RTL_50_Days/
│
├── Day_40/
│   ├── README.md
│   │
│   ├── rtl/
│   │   ├── small_ram.v
│   │   └── large_ram.v
│   │
│   ├── tb/
│   │   └── tb_memory.v
│   │
│   └── sim/
│
└── ...
```

Commit:

```bash
git add Day_40/
git commit -m "Day 40: Block RAM and Distributed RAM"
git push
```

---

# 44. Day 40 Key Takeaways

Remember:

```text
FPGA MEMORY
     |
     +----------------+
     |                |
     v                v
Distributed RAM      BRAM
   (LUTs)          (dedicated)
```

### Distributed RAM

```text
Uses LUT resources
Good for relatively small memories
```

### Block RAM

```text
Uses dedicated memory resources
Good for larger/high-density memories
```

### Registers

```text
Useful for very small storage/control structures
```

### Most important concept

```text
RTL memory description
        ↓
Synthesis
        ↓
Memory inference
        ↓
Target FPGA resources
```

And remember:

> **Do not determine physical FPGA resource usage from RTL syntax alone. Verify it using the target synthesis tool and utilization reports.**

---

# 45. Day 40 Final Mental Model

```text
             MEMORY REQUIREMENT
                     |
                     v
              Write RTL
                     |
                     v
              Synthesis Tool
                     |
          +----------+----------+
          |          |          |
          v          v          v
         FFs       LUTRAM      BRAM
      registers  distributed   block
                   memory      memory
```

Day 40 connects your **memory RTL knowledge from Days 38–39** to actual **FPGA hardware resources**.

This is particularly important before Day 41, where we build a **FIFO**, because FIFO implementation commonly uses registers, distributed RAM, or block RAM depending on depth, width, architecture, and target device.
