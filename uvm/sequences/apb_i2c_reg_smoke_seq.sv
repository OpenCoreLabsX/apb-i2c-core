class apb_i2c_reg_smoke_seq extends apb_i2c_base_seq;
  `uvm_object_utils(apb_i2c_reg_smoke_seq)

  function new(string name = "apb_i2c_reg_smoke_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] data;
    apb_write(8'h00, 32'h0000_0001);
    apb_write(8'h08, 32'h0000_0004);
    apb_write(8'h0C, 32'h0000_0052);
    apb_write(8'h10, 32'h0000_00A5);
    apb_read(8'h00, data);
    if (data[0] !== 1'b1) `uvm_error(get_type_name(), "CTRL enable bit mismatch")
    apb_read(8'h24, data);
    if (data !== `APB_I2C_VERSION) `uvm_error(get_type_name(), "VERSION mismatch")
  endtask
endclass
