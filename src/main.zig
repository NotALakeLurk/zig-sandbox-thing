const std = @import("std");
//const SDL = @import("../SDL.zig/src/wrapper/sdl.zig");
const SDL = @import("sdl2");

const Cell = struct {
    num: u8,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == std.heap.Check.leak)
        std.debug.print("leaky gpa", .{});

    const allocator = gpa.allocator();

    var grid = try Grid.create(allocator, 10, 10, 10);
    _ = &grid;
    //defer grid.destroy(allocator);

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

        renderer.present();

        //        for (tst.cells, 0..) |row, x| {
        //            for (row, 0..) |cell, y| {
        //                std.debug.print("Cell[{d}][{d}]: {any}", .{ x, y, cell });
        //            }
        //        }

        const frame_end = SDL.getTicks64();
        std.debug.print("frame_duration = {d}\n", .{frame_end - frame_start});
        frame_start = frame_end;
    }
}

/// side-length of each grid-cell in pixels
//const cell_size = 10;
//const Grid = struct {
//    cell_size: u8,
//    grid_width: u32,
//    grid_height: u32,
//    cells: *[][]Cell,
//};

const Grid = struct {
    cell_size: u8,
    cells: [][]Cell,

    /// Create a grid, allocating space for a grid of height*width
    pub fn create(allocator: std.mem.Allocator, width: u32, height: u32, cell_size: u8) std.mem.Allocator.Error!Grid {
        // allocate a slice of cell slices
        const cells_array = try allocator.alloc([]Cell, height);
        // allocate each of those slices
        for (cells_array) |*item| {
            item.* = try allocator.alloc(Cell, width);
        }

        return Grid{
            .cell_size = cell_size,
            .cells = cells_array,
        };
    }

    /// destroy the grid and deallocate what's necessary
    pub fn destroy(self: *const Grid, allocator: std.mem.Allocator) void {
        for (self.cells) |row| allocator.free(row);
        allocator.free(self.cells);
    }
};

// when i created this test i knew grid.destroy() was going to leak, i just wanted to make sure i knew what was happening
test "create grid" {
    const allocator = std.testing.allocator;

    const grid = try Grid.create(allocator, 1, 1, 10);
    defer grid.destroy(allocator);

    // do some testing!
    var count: u32 = 0;
    for (grid.cells) |row| {
        for (row) |*cell| {
            count += 1;
            cell.num = @truncate(count);
        }
    }

    try std.testing.expectEqual(1, grid.cells[0][0].num);
}

//const tst = Grid{
//    .cell_size = 5,
//    .grid_width = 100,
//    .grid_height = 100,
//    .cells = &([_][]Cell{&(.{
//        Cell{ .id = 1 },
//    } ** 100)} ** 100),
//};

fn drawGrid(grid: Grid, renderer: SDL.Renderer) void {
    _ = grid;
    _ = renderer;
}

test "simple test" {}
