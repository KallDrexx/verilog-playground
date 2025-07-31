module video_test_pattern (
    input clk,
    input reset,
    output hsync, vsync,
    output display_on,
    output [7:0] red,
    output [7:0] green,
    output [7:0] blue
);

    wire [8:0] hpos, vpos;

    video_sync_generator sync_gen (
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(display_on),
        .hpos(hpos),
        .vpos(vpos)
    );

    assign red = display_on && hpos[4] ? 8'hFF : 8'h00;
    assign green = display_on && vpos[4] ? 8'hFF : 8'h00;
    assign blue = display_on && (hpos == 0 || hpos == 255 || vpos == 0 || vpos == 239) ? 8'hFF : 8'h00;

endmodule
