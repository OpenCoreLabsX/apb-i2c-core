class apb_i2c_all_test extends apb_i2c_base_test;
  `uvm_component_utils(apb_i2c_all_test)

  function new(string name = "apb_i2c_all_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_i2c_reg_smoke_seq      reg_seq;
    apb_i2c_basic_transfer_seq transfer_seq;
    apb_i2c_irq_seq            irq_seq;
    apb_i2c_error_seq          error_seq;

    phase.raise_objection(this);
    reg_seq      = apb_i2c_reg_smoke_seq::type_id::create("reg_seq");
    transfer_seq = apb_i2c_basic_transfer_seq::type_id::create("transfer_seq");
    irq_seq      = apb_i2c_irq_seq::type_id::create("irq_seq");
    error_seq    = apb_i2c_error_seq::type_id::create("error_seq");

    reg_seq.start(m_env.m_agent.m_sequencer);
    transfer_seq.start(m_env.m_agent.m_sequencer);
    irq_seq.start(m_env.m_agent.m_sequencer);
    error_seq.start(m_env.m_agent.m_sequencer);
    phase.drop_objection(this);
  endtask
endclass
