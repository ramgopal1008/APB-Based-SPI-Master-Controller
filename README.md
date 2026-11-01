# APB-Based SPI Master IP Core

## Project Overview

Designed and implemented an **APB-based SPI Master IP Core using Verilog HDL**, integrating a programmable SPI clock generator, serial shift register, APB slave interface, and slave-select control logic.

The design enables communication between an APB-based system and external SPI slave devices. It supports programmable SPI clock configuration through clock prescaler settings and configurable Clock Polarity (CPOL) and Clock Phase (CPHA), allowing operation across different SPI modes.

The project focuses on developing a reusable RTL-based peripheral IP, implementing bus-to-serial communication, and verifying its functionality through simulation, code coverage analysis, and static linting.

## Key Features

- APB-compatible interface for processor-side configuration and data access.
- Programmable SPI clock generation using prescaler configuration.
- Configurable SPI operating modes through CPOL and CPHA.
- Serial data transmission through MOSI and reception through MISO.
- Automated slave-select (SS) control during SPI transactions.
- Register-based configuration and status monitoring.
- Interrupt request support for SPI operation.
- Modular RTL architecture for easier integration, verification, and future scalability.

## Architecture and Functional Blocks

The design is organized into independent RTL modules, each responsible for a specific part of the communication process.

### 1. APB Slave Interface

Acts as the communication interface between the APB bus and the SPI controller.

- Decodes APB address and control signals.
- Handles read and write transactions.
- Provides configuration and data registers for SPI operation.
- Manages APB setup and access phases.
- Generates `PREADY` and `PSLVERR` signals for transfer completion and error indication.
- Maintains control, baud-rate, data, and status register information.

### 2. SPI Clock Generator (`baud_gen`)

Generates the serial clock (SCLK) required for SPI communication.

- Uses the APB clock as the input reference.
- Supports programmable prescaler settings through `SPPR` and `SPR`.
- Generates the required SPI clock frequency based on the selected divider configuration.
- Supports configurable CPOL and CPHA settings.
- Provides internal timing controls for serial data transmission and reception.

The programmable clock divider makes the SPI interface adaptable to different slave-device timing requirements.

### 3. Shift Register (`shift_reg`)

Handles serial data transmission and reception.

- Converts parallel transmit data into a serial data stream on MOSI.
- Captures incoming serial data from MISO.
- Performs data shifting and sampling according to the selected SPI clock mode.
- Coordinates serial data operations with the clock generator.

### 4. Slave Select Control (`slave_select`)

Controls the SPI slave-select signal.

- Activates the selected SPI slave during a communication transaction.
- Maintains the appropriate slave-select state throughout the transfer.
- Deactivates the slave after transaction completion.

### 5. Top-Level Integration (`SPI_master_core`)

Integrates the individual modules into a single SPI Master IP core.

It connects the APB interface, clock generator, shift register, and slave-select controller to coordinate configuration, serial data transfer, and transaction control.

## Operating Sequence

The SPI communication process follows these general steps:

1. **Configuration:** The processor configures the SPI control registers, clock prescaler, and operating mode through APB write transactions.
2. **Transaction Initiation:** The SPI controller receives the transfer request and activates the selected slave.
3. **Clock Generation:** The clock generator produces SCLK according to the configured prescaler, CPOL, and CPHA settings.
4. **Data Transmission:** The shift register serializes the transmit data and transfers it through MOSI.
5. **Data Reception:** Incoming MISO data is sampled and shifted into the receive register.
6. **Completion:** The controller completes the transaction, updates the relevant status information, and handles the interrupt request as configured.

## Verification and Simulation

The complete RTL design was simulated using **ModelSim Intel FPGA Edition 2020.1**.

A dedicated Verilog testbench (`tb_SPI_master_core`) was developed to verify the integrated SPI Master functionality.

The verification process covers:

- APB read and write transactions.
- Register configuration and data access.
- APB transfer handshaking.
- SPI clock generation and operating-mode behavior.
- MOSI data transmission and MISO data reception.
- Slave-select signal operation.
- SPI transaction timing and completion behavior.

Simulation waveforms were analyzed to examine signal transitions, transaction sequencing, and interactions between the APB and SPI interfaces.

## Code Coverage Analysis

Code coverage analysis was performed using **Verdi-Apex Coverage** to evaluate RTL execution during simulation.

| Coverage Metric | Achieved |
|---|---:|
| Overall Coverage Score | 84.17% |
| Line Coverage | 94.48% |
| Block Coverage | 92.31% |
| Statement Coverage | 94.48% |

Coverage analysis was also performed at the individual module level to identify RTL sections exercised during simulation and areas that could benefit from additional test scenarios.

## Static Lint Analysis

Static RTL analysis was performed using **Synopsys VC Static (X-2025.06)** to identify potential coding and structural issues.

The analysis results were:

| Check Result | Count |
|---|---:|
| Fatal Errors | 0 |
| Errors | 0 |
| Warnings | 1 |
| Informational Messages | 11 |

The linting process included design-read, language, and structural checks to assess RTL quality and identify potential issues before synthesis and implementation.

## Tools and Technologies

| Tool / Technology | Purpose |
|---|---|
| Verilog HDL | RTL design and implementation |
| ModelSim Intel FPGA Edition 2020.1 | Functional simulation and waveform debugging |
| Verdi-Apex Coverage | RTL code coverage analysis |
| Synopsys VC Static X-2025.06 | Static RTL lint analysis |
| MobaXterm | Remote Linux environment access and EDA tool execution |

## Repository Contents

The repository contains the RTL source code, associated testbench, simulation waveforms, and verification reports.

- **RTL:** Individual Verilog modules and top-level integration.
- **Testbench:** Simulation environment for the SPI Master IP core.
- **Waveforms:** Simulation results for observing APB transactions and SPI signal behavior.
- **Coverage Reports:** Code coverage analysis results.
- **Lint Reports:** Static RTL analysis results.

## Project Significance

This project demonstrates the development of a bus-connected serial communication peripheral using modular RTL design principles.

It provides practical experience in APB protocol integration, SPI communication, configurable clock generation, sequential logic design, and FSM-based control. The project also emphasizes verification beyond basic functional simulation through code coverage analysis and static RTL linting.

The developed IP core provides a foundation for future integration into FPGA-based systems and larger SoC architectures containing processor cores and memory-mapped peripherals.

---

**Project Domain:** Digital Design | RTL Design | FPGA | Design Verification

**HDL:** Verilog

