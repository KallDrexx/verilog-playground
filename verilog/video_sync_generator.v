module video_sync_generator (
    input clk,
    input reset,
    output reg hsync, vsync,
    output display_on,
    output reg [8:0] hpos, // 0,0 position is the top left of the displayable area
    output reg [8:0] vpos
);

    localparam H_BACK = 23; // back porch
    localparam H_FRONT = 7; // front porch
    localparam H_SYNC = 23; // horizontal sync time
    localparam H_DISP = 256; // vertical displayed area

    localparam V_TOP = 5; // vertical blank top
    localparam V_BOTTOM = 14; // vertical blank bottom
    localparam V_DISP = 240; // vertical displayed area
    localparam V_SYNC = 3; // vertical sync

    localparam H_SYNC_START = H_DISP + H_FRONT;
    localparam H_SYNC_END = H_SYNC_START + H_SYNC - 1;
    localparam H_MAX = H_SYNC_END + H_BACK;

    localparam V_SYNC_START = V_DISP + V_BOTTOM;
    localparam V_SYNC_END = V_SYNC_START + V_SYNC - 1;
    localparam V_MAX = V_SYNC_END + V_TOP;

    wire is_horizontal_at_max = (hpos == H_MAX) || reset;
    wire is_vertical_at_max = (vpos == V_MAX) || reset;

    // Horizontal calculations
    always @(posedge clk) begin
        hsync <= (hpos >= H_SYNC_START) && (hpos <= H_SYNC_END);
        if (is_horizontal_at_max) begin
            hpos <= 0;
        end else begin
            hpos <= hpos + 1;
        end
    end

    // Vertical calculations
    always @(posedge clk) begin
        vsync <= (vpos >= V_SYNC_START) && (vpos <= V_SYNC_END);
        if (is_horizontal_at_max) begin
            if (is_vertical_at_max) begin
                vpos <= 0;
            end else begin
                vpos <= vpos + 1;
            end
        end
    end

    assign display_on = hpos < H_DISP && vpos < V_DISP;

endmodule
