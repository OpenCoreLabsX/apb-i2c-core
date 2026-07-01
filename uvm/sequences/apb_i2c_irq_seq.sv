class apb_i2c_irq_seq extends apb_i2c_base_seq;
  `uvm_object_utils(apb_i2c_irq_seq)

  function new(string name = "apb_i2c_irq_seq");
    super.new(name);
  endfunction

  task body();
    bit [31:0] irq_stat;
    apb_write(8'h1C, 32'h0000_0001);
    apb_write(8'h00, 32'h0000_0001);
    apb_write(8'h08, 32'h0000_0001);
    apb_write(8'h0C, 32'h0000_002A);
    apb_write(8'h10, 32'h0000_0055);
    apb_write(8'h18, 32'h0000_0005);
    repeat (80) begin
      apb_read(8'h20, irq_stat);
      if (irq_stat[0]) break;
    end
    if (!irq_stat[0]) `uvm_error(get_type_name(), "IRQ status did not set")
    apb_write(8'h20, 32'h0000_0001);
  endtask
endclass
