class apb_i2c_apb_sequencer extends uvm_sequencer #(apb_i2c_apb_item);
  `uvm_component_utils(apb_i2c_apb_sequencer)

  function new(string name = "apb_i2c_apb_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
