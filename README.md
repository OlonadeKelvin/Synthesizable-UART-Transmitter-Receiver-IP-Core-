# Synthesizable UART TX/RX IP Core in Verilog

## 📌 Overview
This repository contains the RTL design and functional verification of a fully synthesizable Universal Asynchronous Receiver-Transmitter (UART) IP core. Designed from scratch in Verilog HDL, this project demonstrates core digital design principles including Finite State Machines (FSMs), clock domain synchronization, shift registers, and oversampling techniques.

This project was developed to showcase practical, real-world ASIC/FPGA digital design skills, specifically targeting serial communication peripherals.

## ✨ Key Features
Standard Protocol: 8 Data Bits, No Parity, 1 Stop Bit (8N1).

Configurable: Parameterized system clock frequency and baud rate (default: 50MHz clk / 115200 baud).

Fully Synchronous: Safe clocking utilizing a unified Baud Rate Generator to issue single-cycle enable ticks (avoids dangerous logic-generated clocks).

Robust Receiver: Implements a 16x oversampling FSM to filter noise and safely sample the middle of data bits, mitigating clock drift between devices.

Self-Checking Verification: Includes a full top-level loopback testbench proving 100% functional correctness.

## 🏗️ Architecture & Modules
1. Baud Rate Generator (baud_gen.v)
Calculates the required timing based on the CLK_FREQ and BAUD_RATE parameters. It generates two single-cycle pulses:
tx_tick: Pulses once per baud period.
rx_tick: Pulses 16 times per baud period for receiver oversampling.

2. Transmitter (uart_tx.v)
A 4-state FSM (IDLE, START, DATA, STOP) that waits for a tx_start signal, latches the 8-bit input data, and shifts it out onto the tx_out serial line sequentially at the rate of the tx_tick.

3. Receiver (uart_rx.v)
A complex 4-state FSM utilizing the rx_tick for 16x oversampling.
Detects the falling edge of the Start bit.
Counts 8 ticks to verify the center of the Start bit (noise rejection).
Counts 16 ticks between each subsequent data bit to sample securely in the middle of the "eye diagram".

4. Top-Level Wrapper (uart_top.v)
Instantiates the baud generator, transmitter, and receiver, exposing clean user-logic interfaces and physical serial pins.

## 🔬 Simulation & Verification (Loopback Test)
The testbench (uart_top_tb.v) utilizes a Loopback Test architecture. The physical tx_out wire is routed directly back into the rx_in wire.
Random bytes (e.g., 0xA5, 0x3C) are injected into the transmitter. The testbench automatically monitors the receiver's rx_ready flag and asserts that the rx_data perfectly matches the original injected byte.
How to Run the Simulation (Icarus Verilog)
Requirements: iverilog and gtkwave.


# 🧠 Key Learnings
Understanding how non-blocking assignments (<=) synthesize into physical D-Flip-Flops.
Clock Domain Rules: Learning why dividing clocks with logic is bad practice, and utilizing synchronous enable ticks instead.
Metastability & Noise: Implementing 16x oversampling to ensure digital inputs are read cleanly.
