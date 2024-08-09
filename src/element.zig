const Cell = @import("cell.zig");

const Element = @This();

/// the name of the element
name: *const [4:0]u8,

/// this element's functions
vtable: *const VTable,

pub const VTable = struct {
    /// A function that updates a cell
    /// (physics / visuals / everything)
    update: *const fn (ctx: *Cell) void,

    /// A function that initializes a cell
    /// Called when the element is assigned
    init: *const fn (ctx: *Cell) void,
};
