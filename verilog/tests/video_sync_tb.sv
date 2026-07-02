`include "../video_sync.sv"

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

  always #5 currentClock = ~currentClock;

  initial begin : main_tb
    $dumpfile("dump.vcd"); $dumpvars;

    currentReset <= 1'b1;
    currentClock <= 1'b1;
    #5
    currentReset <= 1'b0;
    currentClock <= 1'b0;
    #5

    repeat (10) @(posedge currentClock);
    assert (hpos == 11)
    else begin
      $error("hpos was not 10 after 10 clock cycles");
      $finish();
    end

    $finish();
  end

endmodule
