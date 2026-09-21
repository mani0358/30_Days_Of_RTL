# WSL 2 + Ubuntu + Icarus Verilog + GTKWave

Complete setup guide for a Verilog/RTL simulation environment on **Windows using WSL 2 and Ubuntu  LTS**.

This environment is useful for:

* Verilog RTL design
* Testbench development
* Digital logic simulation
* Icarus Verilog
* GTKWave waveform analysis
* RTL practice for VLSI/FPGA placement preparation
* Basic synthesis/simulation workflows

---

# 1. Environment

| Component       | Version          |
| --------------- | ---------------- |
| Host OS         | Windows 10/11    |
| Virtualization  | WSL 2            |
| Linux           | Ubuntu 22.04 LTS (any ubuntu version)  |
| HDL Simulator   | Icarus Verilog   |
| Waveform Viewer | GTKWave          |
| HDL             | Verilog          |
| Editor          | VS Code / Vim    |
| Waveform        | VCD              |

---

# 2. Architecture

```text
Windows Laptop
│
├── WSL 2
│   │
│   └── Ubuntu 22.04
│       │
│       ├── Icarus Verilog
│       │       └── iverilog
│       │
│       ├── VVP
│       │       └── vvp
│       │
│       └── GTKWave
│               └── gtkwave
│
└── Verilog RTL + Testbench
        │
        ├── .v
        ├── .vcd
        └── waveform
```

---

# 3. Requirements

Before starting:

* Windows 10 version 2004 or later, or Windows 11
* Hardware virtualization enabled in BIOS/UEFI
* Administrator access to Windows
* Internet connection

---

# 4. Install WSL 2

Open **PowerShell as Administrator**.

Run:

```powershell
wsl --install
```

Restart Windows when requested.

After restarting, Ubuntu should start automatically.

Create your Linux username and password.

Example:

```text
Enter new UNIX username:
rf --any name 

New password:
********
```

---

# 5. Check WSL Version

Open PowerShell:

```powershell
wsl --status
```

Check installed distributions:

```powershell
wsl --list --verbose
```

Expected:

```text
NAME      STATE           VERSION
Ubuntu    Running         2
```

The important value is:

```text
VERSION 2
```

---

# 6. If Ubuntu 22.04 Is Not Installed

List available distributions:

```powershell
wsl --list --online
```

Install Ubuntu 22.04:

```powershell
wsl --install -d Ubuntu-22.04
```

Then start it:

```powershell
wsl -d Ubuntu-22.04
```

---

# 7. Verify Ubuntu Version

Inside Ubuntu:

```bash
lsb_release -a
```

Expected:

```text
Distributor ID: Ubuntu
Description:    Ubuntu 22.04.x LTS
Release:        22.04
Codename:       jammy
```

You can also use:

```bash
cat /etc/os-release
```

---

# 8. Update Ubuntu

First update the package database:

```bash
sudo apt update
```

Upgrade installed packages:

```bash
sudo apt upgrade -y
```

Recommended:

```bash
sudo apt update && sudo apt upgrade -y
```

---

# 9. Install Basic Development Tools

Install useful tools:

```bash
sudo apt install -y \
build-essential \
git \
vim \
nano \
curl \
wget \
make \
gcc \
g++
```

Check GCC:

```bash
gcc --version
```

Check Git:

```bash
git --version
```

---

# 10. Install Icarus Verilog

Install Icarus Verilog:

```bash
sudo apt install -y iverilog
```

Check installation:

```bash
iverilog -V
```

You should see the Icarus Verilog version.

Check location:

```bash
which iverilog
```

Expected:

```text
/usr/bin/iverilog
```

---

# 11. Check VVP

Icarus Verilog uses `vvp` to execute the compiled simulation.

Run:

```bash
which vvp
```

Expected:

```text
/usr/bin/vvp
```

Check version:

```bash
vvp -V
```

---

# 12. Install GTKWave

Install GTKWave:

```bash
sudo apt install -y gtkwave
```

Check:

```bash
which gtkwave
```

Expected:

```text
/usr/bin/gtkwave
```

Check version:

```bash
gtkwave --version
```

---

# 13. Important WSL GTKWave Note

GTKWave is a graphical application.

On **Windows 11 with WSL 2 + WSLg**, GTKWave can normally run directly:

```bash
gtkwave
```

If you are using Windows 10, GUI applications may require an X server such as VcXsrv.

For a modern Windows 11 system, WSLg is the preferred approach.

Check WSL version:

```powershell
wsl --version
```

---

# 14. Create Verilog Project

Create a project directory:

```bash
mkdir -p ~/verilog_projects
cd ~/verilog_projects
```

Create a first project:

```bash
mkdir and_gate
cd and_gate
```

Create RTL file:

```bash
vim and_gate.v
```

---

# 15. AND Gate RTL

Create:

```text
and_gate.v
```

Code:

```verilog
module and_gate (
    input  A,
    input  B,
    output Y
);

assign Y = A & B;

endmodule
```

---

# 16. Create Testbench

Create:

```bash
vim tb_and_gate.v
```

Code:

```verilog
`timescale 1ns/1ps

module tb_and_gate;

reg A;
reg B;
wire Y;

and_gate uut (
    .A(A),
    .B(B),
    .Y(Y)
);

initial begin

    $dumpfile("and_gate.vcd");
    $dumpvars(0, tb_and_gate);

    A = 0;
    B = 0;
    #10;

    A = 0;
    B = 1;
    #10;

    A = 1;
    B = 0;
    #10;

    A = 1;
    B = 1;
    #10;

    $finish;

end

endmodule
```

---

# 17. Compile Verilog

Run:

```bash
iverilog -o and_gate_sim and_gate.v tb_and_gate.v
```

If there are no errors, compilation was successful.

Check:

```bash
ls
```

You should see:

```text
and_gate.v
tb_and_gate.v
and_gate_sim
```

---

# 18. Run Simulation

Run:

```bash
vvp and_gate_sim
```

Expected:

```text
VCD info: dumpfile and_gate.vcd opened for output.
```

Check:

```bash
ls
```

Now you should have:

```text
and_gate.v
tb_and_gate.v
and_gate_sim
and_gate.vcd
```

---

# 19. Open Waveform

Run:

```bash
gtkwave and_gate.vcd
```

GTKWave should open.

Inside GTKWave:

1. Select `tb_and_gate`
2. Select signals
3. Add:

   * `A`
   * `B`
   * `Y`
4. Observe the waveform

---

# 20. AND Gate Truth Table

Verify the simulation against the truth table.

| A | B | Y = A & B |
| - | - | --------- |
| 0 | 0 | 0         |
| 0 | 1 | 0         |
| 1 | 0 | 0         |
| 1 | 1 | 1         |

The waveform must match this table.

---

# 21. Complete Simulation Flow

The basic Verilog workflow is:

```text
Verilog RTL
     │
     ▼
Testbench
     │
     ▼
iverilog
     │
     ▼
Compiled simulation
     │
     ▼
vvp
     │
     ▼
VCD waveform
     │
     ▼
GTKWave
```

Commands:

```bash
iverilog -o sim design.v tb.v
```

Then:

```bash
vvp sim
```

Then:

```bash
gtkwave waveform.vcd
```

---

# 22. Recommended Project Structure

Use this structure for future RTL projects:

```text
verilog_projects/
│
├── 01_and_gate/
│   ├── rtl/
│   │   └── and_gate.v
│   │
│   ├── tb/
│   │   └── tb_and_gate.v
│   │
│   ├── sim/
│   │   └── and_gate.vcd
│   │
│   └── README.md
│
├── 02_or_gate/
│
├── 03_xor_gate/
│
├── 04_mux/
│
├── 05_decoder/
│
├── 06_encoder/
│
├── 07_comparator/
│
├── 08_adder/
│
├── 09_counter/
│
├── 10_shift_register/
│
└── 11_fsm/
```

---

# 23. Useful Icarus Commands

Compile one file:

```bash
iverilog design.v
```

Compile multiple files:

```bash
iverilog -o sim design.v tb.v
```

Specify SystemVerilog:

```bash
iverilog -g2012 -o sim design.sv tb.sv
```

Run simulation:

```bash
vvp sim
```

Generate VCD:

```verilog
$dumpfile("wave.vcd");
$dumpvars(0, tb);
```

Open waveform:

```bash
gtkwave wave.vcd
```

---

# 24. SystemVerilog Support

For `.sv` files:

```bash
iverilog -g2012 -o sim design.sv tb.sv
```

Run:

```bash
vvp sim
```

---

# 25. Useful Ubuntu Commands

Current directory:

```bash
pwd
```

List files:

```bash
ls
```

Detailed list:

```bash
ls -lh
```

Change directory:

```bash
cd directory_name
```

Go home:

```bash
cd ~
```

Create directory:

```bash
mkdir project
```

Remove file:

```bash
rm file.v
```

Search files:

```bash
find . -name "*.v"
```

---

# 26. Check Complete Installation

Run:

```bash
echo "===== OS ====="
lsb_release -ds

echo "===== Icarus ====="
iverilog -V | head

echo "===== VVP ====="
which vvp

echo "===== GTKWave ====="
gtkwave --version

echo "===== Git ====="
git --version
```

Expected tools:

```text
Ubuntu 22.04.x LTS
Icarus Verilog
/usr/bin/vvp
GTKWave
git version ...
```

---

# 27. Recommended VS Code Setup

Install VS Code on Windows.

Install the extension:

```text
WSL
```

Then open your project from Ubuntu:

```bash
cd ~/verilog_projects
code .
```

VS Code should connect to the Ubuntu WSL environment.

For Verilog/SystemVerilog syntax highlighting, install a suitable Verilog/SystemVerilog extension from the VS Code Extensions marketplace.

---

# 28. Git Configuration

Configure Git:

```bash
git config --global user.name "YOUR_NAME"
```

```bash
git config --global user.email "YOUR_EMAIL"
```

Check:

```bash
git config --global --list
```

---

# 29. Create Git Repository

Inside your project:

```bash
cd ~/verilog_projects
git init
```

Create:

```bash
vim .gitignore
```

Recommended `.gitignore`:

```text
*.vcd
*.vvp
*.out
*.log
*.jou
*.wlf
sim
work
```

Add files:

```bash
git add .
```

Commit:

```bash
git commit -m "Initial Verilog simulation environment"
```

---

# 30. Troubleshooting

## Problem 1 — `iverilog: command not found`

Run:

```bash
sudo apt update
sudo apt install iverilog
```

Check:

```bash
which iverilog
```

---

## Problem 2 — `vvp: command not found`

Run:

```bash
sudo apt install iverilog
```

Then:

```bash
which vvp
```

---

## Problem 3 — `gtkwave: command not found`

Run:

```bash
sudo apt update
sudo apt install gtkwave
```

Check:

```bash
which gtkwave
```

---

## Problem 4 — GTKWave does not open

Check WSL:

```powershell
wsl --version
```

For Windows 11, update WSL:

```powershell
wsl --update
```

Then restart WSL:

```powershell
wsl --shutdown
```

Start Ubuntu again.

Try:

```bash
gtkwave
```

---

# 31. First Verification Project

After installation, run:

```bash
mkdir -p ~/verilog_projects/test
cd ~/verilog_projects/test
```

Create RTL:

```bash
nano and.v
```

Create testbench:

```bash
nano tb.v
```

Compile:

```bash
iverilog -o sim and.v tb.v
```

Run:

```bash
vvp sim
```

Open waveform:

```bash
gtkwave wave.vcd
```

If all three stages work:

```text
iverilog → PASS
vvp      → PASS
GTKWave  → PASS
```

your basic Verilog environment is ready.

---

# 32. Placement Preparation Workflow

For RTL/VLSI preparation, use this workflow:

```text
Digital Logic
     ↓
Verilog RTL
     ↓
Testbench
     ↓
Icarus Verilog
     ↓
Simulation
     ↓
VCD
     ↓
GTKWave
     ↓
Debug RTL
     ↓
Synthesis
     ↓
STA
     ↓
Physical Design
```

Recommended learning sequence:

```text
1. Gates
2. MUX / DEMUX
3. Encoder / Decoder
4. Adders
5. Comparators
6. Latches
7. Flip-Flops
8. Registers
9. Counters
10. Shift Registers
11. FSM
12. RAM
13. FIFO
14. UART
15. SPI
16. I2C
17. Verilog RTL Design
18. Testbench
19. Synthesis
20. STA
```

---



# 33. Quick Reference

| Task            | Command                         |
| --------------- | ------------------------------- |
| Start WSL       | `wsl`                           |
| Check WSL       | `wsl --status`                  |
| Check Ubuntu    | `lsb_release -a`                |
| Update Ubuntu   | `sudo apt update`               |
| Install Icarus  | `sudo apt install iverilog`     |
| Compile         | `iverilog -o sim design.v tb.v` |
| Run             | `vvp sim`                       |
| Install GTKWave | `sudo apt install gtkwave`      |
| Open waveform   | `gtkwave wave.vcd`              |
| Start VS Code   | `code .`                        |
| Check Git       | `git --version`                 |

---

# 34. Goal

The final environment should allow:

```bash
RTL
 ↓
iverilog
 ↓
vvp
 ↓
VCD
 ↓
GTKWave
```

This provides a lightweight and completely practical environment for learning **Verilog RTL design and digital VLSI fundamentals on a Windows laptop using WSL 2 + Ubuntu 22.04**.
