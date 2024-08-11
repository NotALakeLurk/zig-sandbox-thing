const std = @import("std");
const Element = @import("../element.zig");
const Cell = @import("../cell.zig");
const utils = @import("../utils.zig");
const Grid = @import("../grid.zig");

pub const sand = Element{
    .name = "sand",
    .vtable = &sand_table,
};

const sand_table = Element.VTable{
    .update = update,
    .init = init,
};

fn update(ctx: *Cell) void {
    //    if (ctx.grid.cell_at(.{
    //        .x = ctx.position.x,
    //        .y = ctx.position.y + 1,
    //    })) |cell| {
    //        if (std.meta.eql(cell.element.name.*, "sand".*)) return;
    //    }
    //    ctx.position.y += 1;
    _ = ctx;
}

fn init(ctx: *Cell) void {
    ctx.created_tick = 0;
    ctx.color = utils.Color.from_u32(0xFF0000_FF);
}
