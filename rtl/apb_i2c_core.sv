module apb_i2c_core
  import apb_i2c_pkg::*;
#(
  parameter int PCLK_FREQ_HZ = 50_000_000
)
(
  input  logic        i_apb_i2c_clk,
  input  logic        i_apb_i2c_rst_n,

  input  logic        i_apb_i2c_enable,
  input  logic        i_apb_i2c_start,
  input  logic        i_apb_i2c_read,
  input  logic        i_apb_i2c_stop,
  input  logic [1:0]  i_apb_i2c_mode,
  input  logic [15:0] i_apb_i2c_clkdiv,
  input  logic [6:0]  i_apb_i2c_addr,
  input  logic [7:0]  i_apb_i2c_txdata,

  output logic [7:0]  o_apb_i2c_rxdata,
  output logic        o_apb_i2c_busy,
  output logic        o_apb_i2c_done,
  output logic        o_apb_i2c_ack_error,

  input  logic        i_apb_i2c_sda,
  output logic        o_apb_i2c_sda_oe,
  input  logic        i_apb_i2c_scl,
  output logic        o_apb_i2c_scl_oe
);

  apb_i2c_state_e r_state;
  logic [15:0]    r_clk_cnt;
  logic           w_tick;
  logic [7:0]     r_shift;
  logic [2:0]     r_bit_cnt;
  logic           r_phase_addr;
  logic           r_read_cmd;
  logic           r_stop_cmd;
  logic [7:0]     r_rxdata;
  logic           r_busy;
  logic           r_done;
  logic           r_ack_error;
  logic           r_sda_oe;
  logic           r_scl_oe;
  logic [15:0]    w_mode_clkdiv;
  logic [15:0]    w_active_clkdiv;

  function automatic logic [15:0] calc_clkdiv(input int scl_hz);
    int div_value;
    begin
      div_value = (PCLK_FREQ_HZ / (2 * scl_hz)) - 1;
      if (div_value < 1) begin
        calc_clkdiv = 16'd1;
      end else if (div_value > 65535) begin
        calc_clkdiv = 16'hFFFF;
      end else begin
        calc_clkdiv = div_value[15:0];
      end
    end
  endfunction

  always_comb begin
    unique case (apb_i2c_mode_e'(i_apb_i2c_mode))
      I2C_MODE_STANDARD   : w_mode_clkdiv = calc_clkdiv(100_000);
      I2C_MODE_FAST       : w_mode_clkdiv = calc_clkdiv(400_000);
      I2C_MODE_FAST_PLUS  : w_mode_clkdiv = calc_clkdiv(1_000_000);
      I2C_MODE_HIGH_SPEED : w_mode_clkdiv = calc_clkdiv(3_400_000);
      default             : w_mode_clkdiv = calc_clkdiv(100_000);
    endcase
  end

  assign w_active_clkdiv = (i_apb_i2c_clkdiv == 16'd0) ? w_mode_clkdiv : i_apb_i2c_clkdiv;

  assign w_tick = (r_clk_cnt == 16'd0);

  always_ff @(posedge i_apb_i2c_clk or negedge i_apb_i2c_rst_n) begin
    if (!i_apb_i2c_rst_n) begin
      r_clk_cnt <= 16'd0;
    end else if (!r_busy) begin
      r_clk_cnt <= w_active_clkdiv;
    end else if (r_clk_cnt == 16'd0) begin
      r_clk_cnt <= w_active_clkdiv;
    end else begin
      r_clk_cnt <= r_clk_cnt - 16'd1;
    end
  end

  always_ff @(posedge i_apb_i2c_clk or negedge i_apb_i2c_rst_n) begin
    if (!i_apb_i2c_rst_n) begin
      r_state     <= I2C_ST_IDLE;
      r_shift     <= 8'd0;
      r_bit_cnt   <= 3'd0;
      r_phase_addr <= 1'b0;
      r_read_cmd  <= 1'b0;
      r_stop_cmd  <= 1'b0;
      r_rxdata    <= 8'd0;
      r_busy      <= 1'b0;
      r_done      <= 1'b0;
      r_ack_error <= 1'b0;
      r_sda_oe    <= 1'b0;
      r_scl_oe    <= 1'b0;
    end else begin
      r_done <= 1'b0;

      if (!i_apb_i2c_enable) begin
        r_state  <= I2C_ST_IDLE;
        r_busy   <= 1'b0;
        r_sda_oe <= 1'b0;
        r_scl_oe <= 1'b0;
      end else if (i_apb_i2c_start && !r_busy) begin
        r_state      <= I2C_ST_START_A;
        r_shift      <= {i_apb_i2c_addr, i_apb_i2c_read};
        r_bit_cnt    <= 3'd7;
        r_phase_addr <= 1'b1;
        r_read_cmd   <= i_apb_i2c_read;
        r_stop_cmd   <= i_apb_i2c_stop;
        r_busy       <= 1'b1;
        r_ack_error  <= 1'b0;
        r_sda_oe     <= 1'b0;
        r_scl_oe     <= 1'b0;
      end else if (w_tick) begin
        unique case (r_state)
          I2C_ST_IDLE: begin
            r_busy   <= 1'b0;
            r_sda_oe <= 1'b0;
            r_scl_oe <= 1'b0;
          end

          I2C_ST_START_A: begin
            r_sda_oe <= 1'b1;
            r_scl_oe <= 1'b0;
            r_state  <= I2C_ST_START_B;
          end

          I2C_ST_START_B: begin
            r_scl_oe <= 1'b1;
            r_state  <= I2C_ST_SHIFT_LOW;
          end

          I2C_ST_SHIFT_LOW: begin
            r_scl_oe <= 1'b1;
            r_sda_oe <= (r_read_cmd && !r_phase_addr) ? 1'b0 : ~r_shift[r_bit_cnt];
            r_state  <= I2C_ST_SHIFT_HIGH;
          end

          I2C_ST_SHIFT_HIGH: begin
            r_scl_oe <= 1'b0;
            if (r_read_cmd && !r_phase_addr) begin
              r_rxdata[r_bit_cnt] <= i_apb_i2c_sda;
            end

            if (r_bit_cnt == 3'd0) begin
              r_state <= I2C_ST_ACK_LOW;
            end else begin
              r_bit_cnt <= r_bit_cnt - 3'd1;
              r_state   <= I2C_ST_SHIFT_LOW;
            end
          end

          I2C_ST_ACK_LOW: begin
            r_scl_oe <= 1'b1;
            r_sda_oe <= (r_read_cmd && !r_phase_addr) ? 1'b1 : 1'b0;
            r_state  <= I2C_ST_ACK_HIGH;
          end

          I2C_ST_ACK_HIGH: begin
            r_scl_oe <= 1'b0;
            if (!(r_read_cmd && !r_phase_addr) && i_apb_i2c_sda) begin
              r_ack_error <= 1'b1;
            end

            if (r_phase_addr && !r_read_cmd) begin
              r_phase_addr <= 1'b0;
              r_shift      <= i_apb_i2c_txdata;
              r_bit_cnt    <= 3'd7;
              r_state      <= I2C_ST_SHIFT_LOW;
            end else if (r_phase_addr && r_read_cmd) begin
              r_phase_addr <= 1'b0;
              r_bit_cnt    <= 3'd7;
              r_state      <= I2C_ST_SHIFT_LOW;
            end else if (r_stop_cmd) begin
              r_state <= I2C_ST_STOP_A;
            end else begin
              r_done  <= 1'b1;
              r_busy  <= 1'b0;
              r_state <= I2C_ST_IDLE;
            end
          end

          I2C_ST_STOP_A: begin
            r_scl_oe <= 1'b1;
            r_sda_oe <= 1'b1;
            r_state  <= I2C_ST_STOP_B;
          end

          I2C_ST_STOP_B: begin
            r_scl_oe <= 1'b0;
            r_sda_oe <= 1'b0;
            r_done   <= 1'b1;
            r_busy   <= 1'b0;
            r_state  <= I2C_ST_IDLE;
          end

          default: begin
            r_state <= I2C_ST_IDLE;
          end
        endcase
      end
    end
  end

  assign o_apb_i2c_rxdata    = r_rxdata;
  assign o_apb_i2c_busy      = r_busy;
  assign o_apb_i2c_done      = r_done;
  assign o_apb_i2c_ack_error = r_ack_error;
  assign o_apb_i2c_sda_oe    = r_sda_oe;
  assign o_apb_i2c_scl_oe    = r_scl_oe;

endmodule
