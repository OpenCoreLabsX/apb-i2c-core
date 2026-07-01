class apb_i2c_basic_transfer_seq extends apb_i2c_base_seq;
  `uvm_object_utils(apb_i2c_basic_transfer_seq)

  function new(string name = "apb_i2c_basic_transfer_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] status;
    apb_write(8'h00, 32'h0000_0001);
    apb_write(8'h08, 32'h0000_0001);
    apb_write(8'h0C, 32'h0000_0050);
    apb_write(8'h10, 32'h0000_003C);
    apb_write(8'h18, 32'h0000_0005);
    repeat (80) begin
      apb_read(8'h04, status);
      if (status[1]) break;
    end
    if (!status[1]) `uvm_error(get_type_name(), "transfer did not complete")
  endtask
endclass
