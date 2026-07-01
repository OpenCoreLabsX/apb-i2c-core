`include "apb_i2c_defines.svh"

module apb_i2c_apb_interface
  import apb_i2c_pkg::*;
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

  input  logic                              i_apb_i2c_sda,
  output logic                              o_apb_i2c_sda_oe,
  input  logic                              i_apb_i2c_scl,
  output logic                              o_apb_i2c_scl_oe,
  output logic                              o_apb_i2c_irq
);

  logic [31:0] r_ctrl;
  logic [31:0] r_clkdiv;
  logic [31:0] r_addr;
  logic [31:0] r_txdata;
  logic [31:0] r_cmd;
  logic [31:0] r_mode;
  logic [31:0] r_irq_en;
  logic [31:0] r_irq_stat;
  logic [31:0] r_prdata;
  logic        w_apb_wr_en;
  logic        w_apb_rd_en;
  logic        r_start_d;
  logic        w_start_pulse;
  logic [7:0]  w_rxdata;
  logic        w_busy;
  logic        w_done;
  logic        w_ack_error;

  assign o_apb_i2c_pready  = 1'b1;
  assign o_apb_i2c_pslverr = 1'b0;
  assign w_apb_wr_en       = i_apb_i2c_psel && i_apb_i2c_penable && i_apb_i2c_pwrite;
  assign w_apb_rd_en       = i_apb_i2c_psel && !i_apb_i2c_pwrite;

  always_ff @(posedge i_apb_i2c_pclk or negedge i_apb_i2c_presetn) begin
    if (!i_apb_i2c_presetn) begin
      r_ctrl     <= 32'd0;
      r_clkdiv   <= 32'd99;
      r_addr     <= 32'd0;
      r_txdata   <= 32'd0;
      r_cmd      <= 32'd0;
      r_mode     <= 32'd0;
      r_irq_en   <= 32'd0;
      r_irq_stat <= 32'd0;
      r_start_d  <= 1'b0;
    end else begin
      r_start_d <= r_cmd[0];

      if (w_start_pulse) begin
        r_cmd[0] <= 1'b0;
      end

      if (w_done) begin
        r_irq_stat[0] <= 1'b1;
      end

      if (w_ack_error) begin
        r_irq_stat[1] <= 1'b1;
      end

      if (w_apb_wr_en) begin
        unique case (i_apb_i2c_paddr)
          APB_I2C_ADDR_CTRL     : r_ctrl   <= i_apb_i2c_pwdata;
          APB_I2C_ADDR_CLKDIV   : r_clkdiv <= i_apb_i2c_pwdata;
          APB_I2C_ADDR_ADDR     : r_addr   <= i_apb_i2c_pwdata;
          APB_I2C_ADDR_TXDATA   : r_txdata <= i_apb_i2c_pwdata;
          APB_I2C_ADDR_CMD      : r_cmd    <= i_apb_i2c_pwdata;
          APB_I2C_ADDR_MODE     : r_mode   <= i_apb_i2c_pwdata;
          APB_I2C_ADDR_IRQ_EN   : r_irq_en <= i_apb_i2c_pwdata;
          APB_I2C_ADDR_IRQ_STAT : r_irq_stat <= r_irq_stat & ~i_apb_i2c_pwdata;
          default               : ;
        endcase
      end
    end
  end

  assign w_start_pulse = r_cmd[0] & ~r_start_d;

  always_comb begin
    r_prdata = 32'd0;
    unique case (i_apb_i2c_paddr)
      APB_I2C_ADDR_CTRL     : r_prdata = r_ctrl;
      APB_I2C_ADDR_STATUS   : r_prdata = {29'd0, w_ack_error, r_irq_stat[0], w_busy};
      APB_I2C_ADDR_CLKDIV   : r_prdata = r_clkdiv;
      APB_I2C_ADDR_ADDR     : r_prdata = r_addr;
      APB_I2C_ADDR_TXDATA   : r_prdata = r_txdata;
      APB_I2C_ADDR_RXDATA   : r_prdata = {24'd0, w_rxdata};
      APB_I2C_ADDR_CMD      : r_prdata = r_cmd;
      APB_I2C_ADDR_IRQ_EN   : r_prdata = r_irq_en;
      APB_I2C_ADDR_IRQ_STAT : r_prdata = r_irq_stat;
      APB_I2C_ADDR_VERSION  : r_prdata = `APB_I2C_VERSION;
      APB_I2C_ADDR_MODE     : r_prdata = r_mode;
      default               : r_prdata = 32'd0;
    endcase
  end

  assign o_apb_i2c_prdata = w_apb_rd_en ? r_prdata : 32'd0;
  assign o_apb_i2c_irq    = |(r_irq_stat & r_irq_en);

  apb_i2c_core #(
    .PCLK_FREQ_HZ         (PCLK_FREQ_HZ)
  ) u_apb_i2c_core (
    .i_apb_i2c_clk       (i_apb_i2c_pclk),
    .i_apb_i2c_rst_n     (i_apb_i2c_presetn),
    .i_apb_i2c_enable    (r_ctrl[0]),
    .i_apb_i2c_start     (w_start_pulse),
    .i_apb_i2c_read      (r_cmd[1]),
    .i_apb_i2c_stop      (r_cmd[2]),
    .i_apb_i2c_mode      (r_mode[1:0]),
    .i_apb_i2c_clkdiv    (r_clkdiv[15:0]),
    .i_apb_i2c_addr      (r_addr[6:0]),
    .i_apb_i2c_txdata    (r_txdata[7:0]),
    .o_apb_i2c_rxdata    (w_rxdata),
    .o_apb_i2c_busy      (w_busy),
    .o_apb_i2c_done      (w_done),
    .o_apb_i2c_ack_error (w_ack_error),
    .i_apb_i2c_sda       (i_apb_i2c_sda),
    .o_apb_i2c_sda_oe    (o_apb_i2c_sda_oe),
    .i_apb_i2c_scl       (i_apb_i2c_scl),
    .o_apb_i2c_scl_oe    (o_apb_i2c_scl_oe)
  );

endmodule
