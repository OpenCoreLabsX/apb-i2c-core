class apb_i2c_base_seq extends uvm_sequence #(apb_i2c_apb_item);
  `uvm_object_utils(apb_i2c_base_seq)

  function new(string name = "apb_i2c_base_seq");
    super.new(name);
  endfunction

  task apb_write(bit [7:0] addr, bit [31:0] data);
    apb_i2c_apb_item tr;
    tr = apb_i2c_apb_item::type_id::create("wr");
    start_item(tr);
    tr.write = 1'b1;
    tr.addr  = addr;
    tr.data  = data;
    finish_item(tr);
  endtask

  task apb_read(bit [7:0] addr, output bit [31:0] data);
    apb_i2c_apb_item tr;
    tr = apb_i2c_apb_item::type_id::create("rd");
    start_item(tr);
    tr.write = 1'b0;
    tr.addr  = addr;
    tr.data  = 32'd0;
    finish_item(tr);
    data = tr.rdata;
  endtask
endclass
