module apb_i2c_wrapper
#(
  parameter int C_APB_DATA_WIDTH = 32,
  parameter int C_APB_ADDR_WIDTH = 8,
  parameter int PCLK_FREQ_HZ     = 50_000_000
)
(
  input  logic                              i_apb_i2c_pclk,
  input  logic                              i_apb_i2c_presetn,

  input  logic [C_APB_ADDR_WIDTH-1:0]       i_apb_i2c_paddr,
  input  logic                              i_apb_i2c_psel,
  input  logic                              i_apb_i2c_penable,
  input  logic                              i_apb_i2c_pwrite,
  input  logic [C_APB_DATA_WIDTH-1:0]       i_apb_i2c_pwdata,
  input  logic [(C_APB_DATA_WIDTH/8)-1:0]   i_apb_i2c_pstrb,
  output logic [C_APB_DATA_WIDTH-1:0]       o_apb_i2c_prdata,
  output logic                              o_apb_i2c_pready,
  output logic                              o_apb_i2c_pslverr,

  inout  wire                               b_apb_i2c_sda,
  inout  wire                               b_apb_i2c_scl,
  output logic                              o_apb_i2c_irq
);

  logic w_sda_in;
  logic w_scl_in;
  logic w_sda_oe;
  logic w_scl_oe;

  apb_i2c_apb_interface #(
    .C_APB_DATA_WIDTH  (C_APB_DATA_WIDTH),
    .C_APB_ADDR_WIDTH  (C_APB_ADDR_WIDTH),
    .PCLK_FREQ_HZ      (PCLK_FREQ_HZ)
  ) u_apb_i2c_apb (
    .i_apb_i2c_pclk    (i_apb_i2c_pclk),
    .i_apb_i2c_presetn (i_apb_i2c_presetn),
    .i_apb_i2c_paddr   (i_apb_i2c_paddr),
    .i_apb_i2c_psel    (i_apb_i2c_psel),
    .i_apb_i2c_penable (i_apb_i2c_penable),
    .i_apb_i2c_pwrite  (i_apb_i2c_pwrite),
    .i_apb_i2c_pwdata  (i_apb_i2c_pwdata),
    .i_apb_i2c_pstrb   (i_apb_i2c_pstrb),
    .o_apb_i2c_prdata  (o_apb_i2c_prdata),
    .o_apb_i2c_pready  (o_apb_i2c_pready),
    .o_apb_i2c_pslverr (o_apb_i2c_pslverr),
    .i_apb_i2c_sda     (w_sda_in),
    .o_apb_i2c_sda_oe  (w_sda_oe),
    .i_apb_i2c_scl     (w_scl_in),
    .o_apb_i2c_scl_oe  (w_scl_oe),
    .o_apb_i2c_irq     (o_apb_i2c_irq)
  );

  apb_i2c_io_cell u_apb_i2c_sda_cell (
    .b_apb_i2c_pad     (b_apb_i2c_sda),
    .i_apb_i2c_oe_n    (~w_sda_oe),
    .o_apb_i2c_in      (w_sda_in)
  );

  apb_i2c_io_cell u_apb_i2c_scl_cell (
    .b_apb_i2c_pad     (b_apb_i2c_scl),
    .i_apb_i2c_oe_n    (~w_scl_oe),
    .o_apb_i2c_in      (w_scl_in)
  );

endmodule
