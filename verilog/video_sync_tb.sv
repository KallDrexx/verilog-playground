`include "video_sync.sv"

module video_sync_tb();
  reg currentReset;
  reg currentClock;
  wire hsync;
  wire vsync;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;

  video_sync DUT(
    .clk(currentClock),
    .reset(currentReset),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    currentReset <= 1'b1;
    currentClock <= 1'b1;
    #10
    currentReset <= 1'b0;
    currentClock <= 1'b0;
    #10
    currentClock <= 1'b1;
    #10
    currentClock <= 1'b0;
    #10
    currentClock <= 1'b1;
    #10
    $finish();

  end

endmodule
