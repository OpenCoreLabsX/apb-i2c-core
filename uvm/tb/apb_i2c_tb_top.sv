module apb_i2c_tb_top;
  import uvm_pkg::*;
  import apb_i2c_uvm_pkg::*;

  logic pclk;
  logic presetn;
  tri1  sda_line;
  tri1  scl_line;

  apb_i2c_apb_if apb_vif(.pclk(pclk), .presetn(presetn));

  assign sda_line = apb_vif.sda_in ? 1'bz : 1'b0;
  assign scl_line = apb_vif.scl_in ? 1'bz : 1'b0;

  initial begin
    pclk = 1'b0;
    forever #5 pclk = ~pclk;
  end

  initial begin
    presetn = 1'b0;
    apb_vif.sda_in = 1'b0;
    apb_vif.scl_in = 1'b0;
    repeat (5) @(posedge pclk);
    presetn = 1'b1;
  end

  initial begin
    uvm_config_db#(virtual apb_i2c_apb_if)::set(null, "*", "vif", apb_vif);
    run_test();
  end

  apb_i2c_wrapper u_dut (
    .i_apb_i2c_pclk    (pclk),
    .i_apb_i2c_presetn (presetn),
    .i_apb_i2c_paddr   (apb_vif.paddr),
    .i_apb_i2c_psel    (apb_vif.psel),
    .i_apb_i2c_penable (apb_vif.penable),
    .i_apb_i2c_pwrite  (apb_vif.pwrite),
    .i_apb_i2c_pwdata  (apb_vif.pwdata),
    .i_apb_i2c_pstrb   (apb_vif.pstrb),
    .o_apb_i2c_prdata  (apb_vif.prdata),
    .o_apb_i2c_pready  (apb_vif.pready),
    .o_apb_i2c_pslverr (apb_vif.pslverr),
    .b_apb_i2c_sda     (sda_line),
    .b_apb_i2c_scl     (scl_line),
    .o_apb_i2c_irq     (apb_vif.irq)
  );
endmodule
