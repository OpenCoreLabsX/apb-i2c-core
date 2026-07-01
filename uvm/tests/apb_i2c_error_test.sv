class apb_i2c_error_test extends apb_i2c_base_test;
  `uvm_component_utils(apb_i2c_error_test)

  function new(string name = "apb_i2c_error_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_i2c_error_seq seq;
    phase.raise_objection(this);
    seq = apb_i2c_error_seq::type_id::create("seq");
    seq.start(m_env.m_agent.m_sequencer);
    phase.drop_objection(this);
  endtask
endclass
