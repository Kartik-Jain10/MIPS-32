**MIPS 32 Microcontroller in Verilog**
**Project Overview**
This project involves the development of a MIPS 32 microcontroller using Verilog. The design implements pipelining through a behavioral approach and is based on a RISC architecture. It features 32 registers, a 32-bit program counter, and both instruction memory and data memory with 1024 addresses each of 32 bits.

**Key Features**
Pipelining: Enhanced processing efficiency by overlapping the execution of multiple instructions.
Behavioral Modeling: Utilized a high-level approach for describing the system, focusing on the functional behavior.
5-Stage Pipeline: Instruction Fetch, Decode, Execute, Memory Access, Write-back stages to optimize CPU performance.
Two Clock Signals: Used two clock signals fed to the latches between stages to prevent data loss and ensure smooth stage transition.
Instruction Set: Supported register-to-register operations, register-to-memory operations, and branch operations.
**Architecture Details**
RISC Architecture: Simplified instruction set to enhance processing speed and efficiency.
Registers: 32 registers, each 32 bits wide.
Program Counter: 32-bit program counter to manage instruction flow.
Memory:
Instruction Memory: 1024 addresses, each 32 bits wide.
Data Memory: 1024 addresses, each 32 bits wide.
