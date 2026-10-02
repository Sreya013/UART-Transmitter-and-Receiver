# UART Transmitter and Receiver

A simple UART transmitter and receiver design using Verilog.

## About the Project

This project implements UART communication using Verilog.

The design includes:

- UART transmitter
- UART receiver
- Baud rate generator
- FSM-based control
- RX input synchronization
- Internal TX to RX loopback

The design sends three test values:

A5 → 3C → FF

The transmitted data is connected to the receiver using an internal loopback. This allows the TX and RX modules to be tested together.

## UART Transmitter

The transmitter uses four states:

IDLE → START → DATA → STOP

It sends:

- 1 start bit
- 8 data bits
- 1 stop bit

The data is transmitted LSB first.

## UART Receiver

The receiver uses four states:

IDLE → START → DATA → STOP

The receiver detects the start bit, samples the incoming data bits, and checks the stop bit.

A two-flop synchronizer is used for the RX input.

## Test Data

| Transmitted Data | Received Data |
|------------------|---------------|
| A5 | A5 |
| 3C | 3C |
| FF | FF |

## Tools Used

- Verilog
- Xilinx Vivado
- RTL Simulation
- Waveform Analysis

## Files


- uart_tx.v
- uart_rx.v
- baud_rate_gen.v
- uart_tb.v

## Verification

The design was tested using simulation and waveform analysis.

The transmitter sends the test data and the receiver receives the same data through the internal loopback connection.

## Current Status

- UART TX completed
- UART RX completed
- Baud rate generator completed
- Simulation completed

