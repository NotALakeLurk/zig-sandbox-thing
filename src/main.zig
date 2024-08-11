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

    var grid = try Grid.create(allocator, renderer, 128, 96);
    defer grid.destroy();

    try grid.cells.append(Cell{
        .grid = &grid,
        .element = elements.sand,
        .position = utils.Position{ .x = 50, .y = 0 },
        .created_tick = SDL.getTicks64(),
    });
    grid.cells.items[0].init();

    try grid.cells.append(Cell{
        .grid = &grid,
        .element = elements.sand,
        .position = utils.Position{ .x = 50, .y = 1 },
        .created_tick = SDL.getTicks64(),
    });
    grid.cells.items[1].init();

    try grid.cells.append(Cell{
        .grid = &grid,
        .element = elements.boundary,
        .position = utils.Position{ .x = 50, .y = 50 },
        .created_tick = SDL.getTicks64(),
    });
    grid.cells.items[2].init();

    var frame_start = SDL.getTicks64();
    mainLoop: while (true) {
        while (SDL.pollEvent()) |event| {
            switch (event) {
                .quit => {
                    std.debug.print("Quitting!", .{});
                    break :mainLoop;
                },
                .mouse_motion => |mouse| {
                    if (mouse.x < 0 or mouse.y < 0) continue; // don't deal with negative positions
                    // here because window could get resized, there may be an event to detect that though (windowEvent?)
                    const window_size = window.getSize();
                    // the area that the simulation is placed (leaves room for ui eventually)
                    const sim_area = SDL.Rectangle{ .width = window_size.width, .height = window_size.height, .x = 0, .y = 0 };

                    // here, mouse .x and .y are already unsigned, we know this because of the previous check
                    if (mouse.button_state.getPressed(.left)) try draw_cell_at_mouse_pos(&grid, sim_area, .{ .x = @abs(mouse.x), .y = @abs(mouse.y) });
                },
                .mouse_button_down => |mouse| {
                    if (mouse.x < 0 or mouse.y < 0) continue; // don't deal with negative positions
                    // here because window could get resized, there may be an event to detect that though (windowEvent?)
                    const window_size = window.getSize();
                    // the area that the simulation is placed (leaves room for ui eventually)
                    const sim_area = SDL.Rectangle{ .width = window_size.width, .height = window_size.height, .x = 0, .y = 0 };

                    // here, mouse .x and .y are already unsigned, we know this because of the previous check
                    if (mouse.button == .left) try draw_cell_at_mouse_pos(&grid, sim_area, .{ .x = @abs(mouse.x), .y = @abs(mouse.y) });
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

fn draw_cell_at_mouse_pos(grid: *Grid, sim_area: SDL.Rectangle, mouse_pos: utils.Position) !void {
    // the sizes of the cells in pixels
    const cell_size_x = @abs(sim_area.width) / grid.width;
    const cell_size_y = @abs(sim_area.height) / grid.height;

    std.debug.print("{d} {d}\n", .{ cell_size_x, cell_size_y });

    // the position of the mouse cursor in the grid co-ordinates
    // TODO: refactor utils.Position to hold isizes because that's what SDL expects
    const pos = utils.Position{
        .x = (mouse_pos.x - @abs(sim_area.x)) / cell_size_x,
        .y = (mouse_pos.y - @abs(sim_area.y)) / cell_size_y,
    };

    // cursor is outside grid
    if (pos.x > grid.width or
        pos.y > grid.height) return;

    std.debug.print("{any}\n", .{pos});

    // create the cell
    try grid.cells.append(Cell{
        .position = pos,
        .element = elements.sand,
        .created_tick = SDL.getTicks64(),
        .grid = grid,
    });
    const items = grid.cells.items;
    items[items.len - 1].init();
}
