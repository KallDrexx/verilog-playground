`include "video_sync_generator.v"

module nandland_go_video_test_pattern (
    input i_Clk,
    output o_VGA_HSync,
    output o_VGA_VSync,
    output o_VGA_Red_0,
    output o_VGA_Red_1,
    output o_VGA_Red_2,
    output o_VGA_Grn_0,
    output o_VGA_Grn_1,
    output o_VGA_Grn_2,
    output o_VGA_Blu_0,
    output o_VGA_Blu_1,
    output o_VGA_Blu_2
);
    wire [7:0] red;
    wire [7:0] green;
    wire [7:0] blue;

    video_test_pattern test_pattern (
        .clk(i_Clk),
        .hsync(o_VGA_HSync),
        .vsync(o_VGA_VSync),
        .red(red),
        .green(green),
        .blue(blue)
    );

    assign o_VGA_Red_2 = red[7];
    assign o_VGA_Red_1 = red[6];
    assign o_VGA_Red_0 = red[5];

    assign o_VGA_Grn_2 = green[7];
    assign o_VGA_Grn_1 = green[6];
    assign o_VGA_Grn_0 = green[5];

    assign o_VGA_Blu_2 = blue[7];
    assign o_VGA_Blu_1 = blue[6];
    assign o_VGA_Blu_0 = blue[5];

endmodule

module video_test_pattern (
    input clk,
    input reset,
    output hsync, vsync,
    output display_on,
    output [7:0] red,
    output [7:0] green,
    output [7:0] blue
);

    wire [9:0] hpos, vpos;

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
    assign blue = display_on && (hpos == 0 || hpos == 639 || vpos == 0 || vpos == 479) ? 8'hFF : 8'h00;

endmodule
