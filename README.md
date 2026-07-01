<div align="center">

<img src="banner.png" alt="OpenCoreLabsX Banner" width="100%">

# GitHub Readme Stats

Get dynamically generated GitHub stats on your READMEs!

<p>
  <img src="https://img.shields.io/badge/Test-failing-red?style=flat&logo=github" alt="Test">
  <img src="https://img.shields.io/badge/contributors-302-brightgreen?style=flat" alt="Contributors">
  <img src="https://img.shields.io/badge/codecov-97%25-brightgreen?style=flat&logo=codecov" alt="Codecov">
  <img src="https://img.shields.io/badge/issues-167%20open-blue?style=flat" alt="Issues">
  <img src="https://img.shields.io/badge/pull%20requests-119%20open-blue?style=flat" alt="Pull Requests">
  <img src="https://img.shields.io/badge/openssf%20scorecard-6.5-yellow?style=flat" alt="OpenSSF Scorecard">
</p>

[![Powered by Vercel](https://img.shields.io/badge/Powered%20by-Vercel-black?style=for-the-badge&logo=vercel)](https://vercel.com)

</div>

---

# APB I2C Controller IP Core

APB I2C master controller written in SystemVerilog for FPGA and ASIC integration. The project includes synthesizable RTL, an APB register interface, open-drain I2C control outputs, and a UVM verification environment.

## Documentation

Open the local vendor-style documentation here:

[APB I2C IP Documentation](docs/index.html)

## Key Features

| Item | Description |
| --- | --- |
| Protocol | I2C master |
| Addressing | 7-bit slave address |
| Interface | APB register interface |
| RTL language | SystemVerilog |
| Clocking | Programmable SCL divider |
| I2C pins | Open-drain output-enable controls for SDA/SCL |
| I2C modes | Standard, Fast, Fast-mode Plus, High-speed timing profiles |
| Interrupts | Done and acknowledge-error status |
| Verification | UVM testbench |
| Lint | Verilator |
| Simulation | ModelSim |
| Target | FPGA / ASIC |

## Repository Structure

```text
.
|-- inc/        Register definitions and global macros
|-- rtl/        Synthesizable APB I2C RTL
|-- uvm/        UVM verification environment
|-- docs/       Documentation source
|-- filelist.f  RTL/UVM compile filelist
`-- Makefile    Lint, compile, run, coverage, and clean targets
```

## Register Map

| Address | Name | Description |
| --- | --- | --- |
| `0x00` | `CTRL` | Bit 0 enables the controller |
| `0x04` | `STATUS` | Bit 0 busy, bit 1 done, bit 2 ack error |
| `0x08` | `CLKDIV` | SCL timing divider |
| `0x0C` | `ADDR` | 7-bit I2C slave address |
| `0x10` | `TXDATA` | Write data byte |
| `0x14` | `RXDATA` | Read data byte |
| `0x18` | `CMD` | Bit 0 start, bit 1 read, bit 2 stop |
| `0x1C` | `IRQ_EN` | Interrupt enable bits |
| `0x20` | `IRQ_STAT` | Write-one-to-clear interrupt status |
| `0x24` | `VERSION` | IP version |
| `0x28` | `MODE` | I2C timing mode, bits [1:0] |

## Build and Verification

Run Verilator lint:

```sh
make lint
```

Compile with ModelSim:

```sh
make compile
```

Run the UVM regression:

```sh
make run
```

Run a specific UVM test:

```sh
make run UVM_TEST=apb_i2c_reg_test
```

## UVM Tests

- `apb_i2c_reg_test`
- `apb_i2c_basic_transfer_test`
- `apb_i2c_irq_test`
- `apb_i2c_error_test`
- `apb_i2c_all_test`

## Notes

`apb_i2c_wrapper` is the single top-level module. It exposes bidirectional `inout` SDA/SCL pins and instantiates `apb_i2c_io_cell` internally. For GF180 standard-cell mapping, define `GF180MCU_SC`; `apb_i2c_io_cell` instantiates `gf180mcu_fd_sc_mcu9t5v0__tiel`, `gf180mcu_fd_sc_mcu9t5v0__bufz_4`, and `gf180mcu_fd_sc_mcu9t5v0__buf_2` from the local PDK. Run `make lint-gf180` to lint that variant.

This project is intended as a reusable APB I2C RTL IP core and verification portfolio project. Before production use, extend the verification environment with a full I2C slave bus functional model, repeated-start coverage, arbitration-loss handling, clock-stretching, and NACK/recovery corner cases.
