module video_sync #(
  parameter bit [9:0] H_ACTIVE_PIXELS,
  parameter bit [9:0] H_FRONT_PORCH,
  parameter bit [9:0] H_BACK_PORCH,
  parameter bit [9:0] H_SYNC,

  parameter bit [9:0] V_ACTIVE_PIXELS,
  parameter bit [9:0] V_FRONT_PORCH,
  parameter bit [9:0] V_BACK_PORCH,
  parameter bit [9:0] V_SYNC
) (
  input wire clk,
  input wire reset,
  output wire hsync,
  output wire vsync,
  output wire display_on,
  output reg [9:0] hpos,
  output reg [9:0] vpos
);

  localparam bit [9:0] HBlankTotal = H_FRONT_PORCH + H_BACK_PORCH + H_SYNC;
  localparam bit [9:0] HTotal = HBlankTotal + H_ACTIVE_PIXELS;
  localparam bit [9:0] HSyncStart = H_ACTIVE_PIXELS + H_FRONT_PORCH;
  localparam bit [9:0] HSyncEnd = HSyncStart + H_SYNC;

  localparam bit [9:0] VBlankeTotal = V_FRONT_PORCH + V_BACK_PORCH + V_SYNC;
  localparam bit [9:0] VTotal = VBlankeTotal + V_ACTIVE_PIXELS;
  localparam bit [9:0] VSyncStart = V_ACTIVE_PIXELS + V_FRONT_PORCH;
  localparam bit [9:0] VSyncEnd = VSyncStart + V_SYNC;

  assign hsync = hpos >= HSyncStart && hpos < HSyncEnd;
  assign vsync = vpos >= VSyncStart && vpos < VSyncEnd;
  assign display_on = hpos < H_ACTIVE_PIXELS && vpos < V_ACTIVE_PIXELS;

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

