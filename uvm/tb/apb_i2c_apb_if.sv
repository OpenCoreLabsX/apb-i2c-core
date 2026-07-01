interface apb_i2c_apb_if(input logic pclk, input logic presetn);
  logic [7:0]  paddr;
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [31:0] pwdata;
  logic [3:0]  pstrb;
  logic [31:0] prdata;
  logic        pready;
  logic        pslverr;

  logic        sda_in;
  logic        sda_oe;
  logic        scl_in;
  logic        scl_oe;
  logic        irq;
endinterface
