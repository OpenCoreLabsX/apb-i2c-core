module apb_i2c_io_cell
#(
  parameter bit USE_GF180MCU_IO = 1'b0
)
(
  inout  wire  b_apb_i2c_pad,
  input  logic i_apb_i2c_oe_n,
  output logic o_apb_i2c_in
);

`ifdef GF180MCU_SC
  logic w_drive_low_en;
  logic w_tie_low;
  logic w_pad_in;

  assign w_drive_low_en = ~i_apb_i2c_oe_n;

  gf180mcu_fd_sc_mcu9t5v0__tiel u_apb_i2c_tiel (
    .ZN (w_tie_low)
  );

  gf180mcu_fd_sc_mcu9t5v0__bufz_4 u_apb_i2c_od_drv (
    .EN (w_drive_low_en),
    .I  (w_tie_low),
    .Z  (b_apb_i2c_pad)
  );

  gf180mcu_fd_sc_mcu9t5v0__buf_2 u_apb_i2c_in_buf (
    .I  (b_apb_i2c_pad),
    .Z  (w_pad_in)
  );

  assign o_apb_i2c_in = w_pad_in;
`else
  assign b_apb_i2c_pad = i_apb_i2c_oe_n ? 1'bz : 1'b0;
  assign o_apb_i2c_in  = b_apb_i2c_pad;
`endif

endmodule
