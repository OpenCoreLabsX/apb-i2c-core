# APB I2C UVM Environment

The UVM environment mirrors the AES project layout:

```text
uvm/
|-- agent/       APB transaction item, sequencer, and agent
|-- driver/      APB protocol driver
|-- monitor/     APB protocol monitor
|-- scoreboard/  Lightweight transaction scoreboard
|-- sequences/   Register, transfer, IRQ, and error sequences
|-- tb/          Interface, package, and top-level testbench
`-- tests/       UVM tests
```

The default regression is `apb_i2c_all_test`.
