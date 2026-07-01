class apb_i2c_error_seq extends apb_i2c_base_seq;
  `uvm_object_utils(apb_i2c_error_seq)

  function new(string name = "apb_i2c_error_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] status;
    apb_write(8'h00, 32'h0000_0000);
    apb_write(8'h18, 32'h0000_0005);
    repeat (8) apb_read(8'h04, status);
    if (status[0]) `uvm_error(get_type_name(), "core became busy while disabled")
  endtask
endclass
