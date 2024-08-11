const std = @import("std");
const Allocator = std.mem.Allocator;
const SDL = @import("sdl");

const Cell = @import("cell.zig");
const utils = @import("utils.zig");

const Grid = @This();

/// the width of the grid in cells
width: usize,
/// the height of the grid in cells
height: usize,
/// an array of all the cells in the simulation
cells: std.ArrayList(Cell),
//cells: [][]Cell,
/// the `SDL.Texture` of the grid
/// `texture` is updated with each update
texture: SDL.Texture,

/// the color of empty/null cells
pub const empty_color = utils.Color.from_u32(0x000000_FF); // not sure what alpha is doing, but I'll leave it

/// Create a grid, allocating space for a grid of width*height
pub fn create(allocator: Allocator, renderer: SDL.Renderer, width: usize, height: usize) !Grid {
    // initialize the cell array to all null cells
    //const cells_array = try allocator.alloc(?Cell, width * height);
    //for (cells_array) |*cell| cell.* = null;

    const cells_array = try std.ArrayList(Cell).initCapacity(allocator, width * height);

    const texture = try SDL.createTexture(
        renderer,
        .rgba8888, // 4 bytes per pixel (normal hex codes stuff), `Color` is u32
        .streaming,
        width,
        height,
    );

    return Grid{
        .cells = cells_array,
        .width = width,
        .height = height,
        .texture = texture,
    };
}

/// destroy the grid and deallocate what's necessary
pub fn destroy(self: *Grid) void {
    //        // free each row
    //        for (self.cells) |row| {
    //            // destroy each individual cell
    //            for (row) |cell| {
    //                allocator.destroy(cell);
    //            }
    //            allocator.free(row);
    //        }
    //        allocator.free(self.cells);

    self.cells.clearAndFree();
    self.texture.destroy();
}

/// update the grid simulation and texture
pub fn update(self: *Grid) !void {
    self.physics_update();
    try self.texture_update();
}

/// update the state of the cells in the grid
fn physics_update(self: *Grid) void {
    for (self.cells.items) |*cell| cell.*.update();
}

// TODO: create texture from grid (sdl has scaling options such as linear that will help here as well)
// https://wiki.libsdl.org/SDL2/SDL_HINT_RENDER_SCALE_QUALITY
// right now this function always updates all cells every tick, could probably have a list of cells that changed this tick
// to update instead
/// Updates the SDL Texture representation of the grid
fn texture_update(self: *const Grid) !void {
    // lock the streamed texture to get the pixels
    //var pixels = try self.texture.lock(.{ .x = 0, .y = 0, .width = self.width, .height = self.height });
    var pixel_data = try self.texture.lock(null);
    defer pixel_data.release();

    const data_slice = pixel_data.pixels[0..(pixel_data.stride * self.height)];

    const pixels = std.mem.bytesAsSlice(utils.Color, data_slice);

    // set every pixel to the empty color first
    // this is probably terrible for optimization
    // or the compiler might optimize with a bit memory map??
    for (pixels) |*pixel| pixel.* = empty_color;

    // apply each non-null cell's color
    for (self.cells.items) |cell| {
        const pos = cell.position;

        // bounds check TODO: remove?
        //if (pos.x >= self.width or pos.y >= self.height) return error.InvalidPosition;
        if (pos.x >= self.width or pos.y >= self.height) continue;

        // pixel = pixels[x][y] represented as Color
        // casting from `u8` to `Color` is safe here because we know that pixels actually contains `Color`s (`u16`s)
        //        const pixel: *utils.Color = @ptrCast(&pixels.pixels[
        //            (pos.x + (pos.y * pixels.stride)) * 2 // two bytes per pixel with .rgba4444
        //        ]);
        const index = (pos.x + (pos.y * self.width)); // two bytes per pixel with .rgba4444

        const pixel = &pixels[index];
        // set the color of the pixel
        pixel.* = cell.color;
    }
}

/// returns a pointer to the first cell at a position
pub fn cell_at(self: *const Grid, pos: utils.Position) ?*Cell {
    return for (self.cells.items) |*cell| {
        if (std.meta.eql(cell.position, pos)) break cell;
    } else null;
}

// TODO: fix this test to fit the new scheme?
test "create grid" {}
