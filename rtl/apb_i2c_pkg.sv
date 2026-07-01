package apb_i2c_pkg;
  typedef enum logic [1:0] {
    I2C_MODE_STANDARD  = 2'd0,
    I2C_MODE_FAST      = 2'd1,
    I2C_MODE_FAST_PLUS = 2'd2,
    I2C_MODE_HIGH_SPEED = 2'd3
  } apb_i2c_mode_e;

  typedef enum logic [3:0] {
    I2C_ST_IDLE,
    I2C_ST_START_A,
    I2C_ST_START_B,
    I2C_ST_SHIFT_LOW,
    I2C_ST_SHIFT_HIGH,
    I2C_ST_ACK_LOW,
    I2C_ST_ACK_HIGH,
    I2C_ST_STOP_A,
    I2C_ST_STOP_B
  } apb_i2c_state_e;

  localparam logic [7:0] APB_I2C_ADDR_CTRL     = 8'h00;
  localparam logic [7:0] APB_I2C_ADDR_STATUS   = 8'h04;
  localparam logic [7:0] APB_I2C_ADDR_CLKDIV   = 8'h08;
  localparam logic [7:0] APB_I2C_ADDR_ADDR     = 8'h0C;
  localparam logic [7:0] APB_I2C_ADDR_TXDATA   = 8'h10;
  localparam logic [7:0] APB_I2C_ADDR_RXDATA   = 8'h14;
  localparam logic [7:0] APB_I2C_ADDR_CMD      = 8'h18;
  localparam logic [7:0] APB_I2C_ADDR_IRQ_EN   = 8'h1C;
  localparam logic [7:0] APB_I2C_ADDR_IRQ_STAT = 8'h20;
  localparam logic [7:0] APB_I2C_ADDR_VERSION  = 8'h24;
  localparam logic [7:0] APB_I2C_ADDR_MODE     = 8'h28;
endpackage
