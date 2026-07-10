`include "../video_sync.sv"

module video_sync_tb();
  reg currentReset;
  reg currentClock;
  wire hsync;
  wire vsync;
  wire display_on;
  wire [9:0] hpos;
  wire [9:0] vpos;
  integer x;

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
  task automatic check_display(
      input string file,
      input int    line,
      input int    exp_hpos,
      input int    exp_vpos,
      input bit    exp_display_on,
      input bit    exp_hsync,
      input bit    exp_vsync
  );
    repeat (1) @(posedge currentClock);
    assert (hpos == exp_hpos &&
            vpos == exp_vpos &&
            display_on == exp_display_on &&
            hsync == exp_hsync &&
            vsync == exp_vsync)
    else begin
      $error(
        "(%s:%0d) - hpos %0d/%0d, vpos %0d/%0d, display_on %0d/%0d, hsync %0d/%0d, vsync %0d/%0d",
        file, line,
        hpos, exp_hpos, vpos, exp_vpos, display_on, exp_display_on,
        hsync, exp_hsync, vsync, exp_vsync);
      $finish;
    end
  endtask

  `define CHECK_DISPLAY(hpos_, vpos_, display_on_, hsync_, vsync_) \
    check_display(`__FILE__, `__LINE__, hpos_, vpos_, display_on_, hsync_, vsync_)

  initial begin : main_tb
    $dumpfile("video_sync_tb.vcd"); $dumpvars;

    // Toggle reset
    currentReset <= 1'b1;
    currentClock <= 1'b1;
    #5
    currentReset <= 1'b0;
    currentClock <= 1'b0;
    #5

    // Iterate 10 clock cycles and ensure the hpos updates
    for (x = 0; x < 10; x = x + 1) begin
      `CHECK_DISPLAY(1 + x, 0, 1, 0, 0);
    end

    // Iterate another 9 cycles and ensure it's still on the display area
    for (x = 0; x < 9; x = x + 1) begin
      `CHECK_DISPLAY(11 + x, 0, 1, 0, 0);
    end

    // Next clock cycle should be in front porch
    `CHECK_DISPLAY(20, 0, 0, 0, 0);

    // Since front porch is set to 1 cycle, next 3 cycles should be in hsync
    `CHECK_DISPLAY(21, 0, 0, 1, 0);
    `CHECK_DISPLAY(22, 0, 0, 1, 0);
    `CHECK_DISPLAY(23, 0, 0, 1, 0);

    // Back porch is 2 cycles
    `CHECK_DISPLAY(24, 0, 0, 0, 0);
    `CHECK_DISPLAY(25, 0, 0, 0, 0);

    // Next cycle should be on the next vertical line
    `CHECK_DISPLAY(0, 1, 1, 0, 0);

    $display("%m: Test Success");
    $finish;
  end

endmodule
