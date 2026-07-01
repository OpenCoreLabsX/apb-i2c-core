package apb_i2c_uvm_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "apb_i2c_defines.svh"

  `include "apb_i2c_apb_item.sv"
  `include "apb_i2c_apb_sequencer.sv"
  `include "apb_i2c_apb_driver.sv"
  `include "apb_i2c_apb_monitor.sv"
  `include "apb_i2c_scoreboard.sv"
  `include "apb_i2c_agent.sv"
  `include "apb_i2c_env.sv"

  `include "apb_i2c_base_seq.sv"
  `include "apb_i2c_reg_smoke_seq.sv"
  `include "apb_i2c_basic_transfer_seq.sv"
  `include "apb_i2c_irq_seq.sv"
  `include "apb_i2c_error_seq.sv"

  `include "apb_i2c_base_test.sv"
  `include "apb_i2c_reg_test.sv"
  `include "apb_i2c_basic_transfer_test.sv"
  `include "apb_i2c_irq_test.sv"
  `include "apb_i2c_error_test.sv"
  `include "apb_i2c_all_test.sv"
endpackage
