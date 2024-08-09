const Cell = @This();
const Element = @import("element.zig");
const utils = @import("utils.zig");

/// the tick that this cell was created on
created_tick: u64,

/// this cell's position in the virtual grid
position: utils.Position,

/// this cell's color
color: utils.Color,

/// the element of this cell
element: Element,

pub fn update(self: *Cell) void {
    self.element.vtable.update(self);
}

pub fn init(self: *Cell) void {
    self.element.vtable.init(self);
}
