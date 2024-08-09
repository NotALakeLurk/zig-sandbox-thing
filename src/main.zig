const std = @import("std");

const SDL = @import("sdl");

const Grid = @import("grid.zig");
const Cell = @import("cell.zig");
const utils = @import("utils.zig");

const elements = @import("elements/elements.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == std.heap.Check.leak)
        std.debug.print("leaky gpa", .{});

    const allocator = gpa.allocator();

    try SDL.init(.{
        .video = true,
        .events = true,
        .audio = true,
    });
    defer SDL.quit();

    try SDL.ttf.init();
    defer SDL.ttf.quit();

    var window = try SDL.createWindow(
        "SDL2 Wrapper Demo",
        .{ .centered = {} },
        .{ .centered = {} },
        640,
        480,
        .{ .vis = .shown },
    );
    defer window.destroy();

    var renderer = try SDL.createRenderer(window, null, .{
        .accelerated = true,
        .present_vsync = true,
    });
    defer renderer.destroy();

    var grid = try Grid.create(allocator, renderer, 100, 100);
    defer grid.destroy(allocator);

    grid.cells[0] = Cell{
        .element = elements.sand,
        .position = utils.Position{ .x = 50, .y = 0 },
        .created_tick = SDL.getTicks64(),
        .color = utils.Color.from_u32(0x00ff00ff),
    };
    grid.cells[0].?.init();

    var frame_start = SDL.getTicks64();
    mainLoop: while (true) {
        while (SDL.pollEvent()) |event| {
            switch (event) {
                .quit => {
                    std.debug.print("Quitting!", .{});
                    break :mainLoop;
                },
                else => {},
            }
        }

        try renderer.setColorRGB(0xF7, 0xA4, 0x1D);
        try renderer.clear();

        try grid.update();
        try renderer.copy(grid.texture, null, null);

        renderer.present();

        const frame_end = SDL.getTicks64();
        std.debug.print("frame_duration = {d}\n", .{frame_end - frame_start});
        frame_start = frame_end;
    }
}
fn dummy_func(_: *Cell) void {}
