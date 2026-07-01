class apb_i2c_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_i2c_scoreboard)

  uvm_analysis_imp #(apb_i2c_apb_item, apb_i2c_scoreboard) analysis_export;
  bit [31:0] mirror [bit [7:0]];

  function new(string name = "apb_i2c_scoreboard", uvm_component parent = null);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
  endfunction

  function void write(apb_i2c_apb_item tr);
    if (tr.write) begin
      mirror[tr.addr] = tr.data;
    end
  endfunction
endclass
