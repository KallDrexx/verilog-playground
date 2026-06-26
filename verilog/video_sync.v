module video_sync(
  input wire clk,
  input wire reset,
  output wire hsync,
  output wire vsync,
  output wire display_on,
  output reg [9:0] hpos,
  output reg [9:0] vpos
);

  parameter bit [9:0] H_ACTIVE_PIXELS = 640;
  parameter bit [9:0] H_FRONT_PORCH = 16;
  parameter bit [9:0] H_BACK_PORCH = 48;
  parameter bit [9:0] H_SYNC = 96;

  parameter bit [9:0] V_ACTIVE_PIXELS = 480;
  parameter bit [9:0] V_FRONT_PORCH = 10;
  parameter bit [9:0] V_BACK_PORCH = 33;
  parameter bit [9:0] V_SYNC = 2;

  localparam bit [9:0] HBlankTotal = H_FRONT_PORCH + H_BACK_PORCH + H_SYNC;
  localparam bit [9:0] HTotal = HBlankTotal + H_ACTIVE_PIXELS;

  localparam bit [9:0] VBlankeTotal = V_FRONT_PORCH + V_BACK_PORCH + V_SYNC;
  localparam bit [9:0] VTotal = VBlankeTotal + V_ACTIVE_PIXELS;

  assign hsync = hpos >= H_ACTIVE_PIXELS;
  assign vsync = vpos >= V_ACTIVE_PIXELS;
  assign display_on = !hsync && !vsync && !reset;

  always @(posedge clk) begin
    if (reset) begin
      hpos <= 0;
      vpos <= 0;
    end else begin
      if (hpos >= HTotal) begin
        hpos <= 0;
        if (vpos >= VTotal - 1) begin
          vpos <= 0;
        end else begin
          vpos <= vpos + 1;
        end

      end else begin
        hpos <= hpos + 1;
      end
    end
  end

endmodule

