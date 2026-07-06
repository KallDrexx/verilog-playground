`include "../video_sync.sv"

module video_sync_tb();
  reg currentReset;
  reg currentClock;
  wire hsync;
  wire vsync;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;

  video_sync #(
    .H_ACTIVE_PIXELS(20),
    .H_FRONT_PORCH(1),
    .H_BACK_PORCH(2),
    .H_SYNC(3),
    .V_ACTIVE_PIXELS(30),
    .V_BACK_PORCH(4),
    .V_FRONT_PORCH(5),
    .V_SYNC(6)
    ) DUT (
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
    $dumpfile("video_sync_tb.vcd"); $dumpvars;

    currentReset <= 1'b1;
    currentClock <= 1'b1;
    #5
    currentReset <= 1'b0;
    currentClock <= 1'b0;
    #5

    repeat (10) @(posedge currentClock);
    assert (hpos == 10)
    else begin
      $error("Expected hpos to be 10 after 10 cycles, but was %0d", hpos);
      $finish();
    end

    $display("%m: Test Success");
    $finish();
  end

endmodule
