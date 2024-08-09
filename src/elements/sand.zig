const Element = @import("../element.zig");
const Cell = @import("../cell.zig");
const utils = @import("../utils.zig");

pub const sand = Element{
    .name = "sand",
    .vtable = &sand_table,
};

const sand_table = Element.VTable{
    .update = update,
    .init = init,
};

fn update(ctx: *Cell) void {
    //ctx.position.y += 1;
    _ = ctx;
}

fn init(ctx: *Cell) void {
    ctx.created_tick = 0;
    ctx.color = utils.Color.from_u32(0xFFFF00_00);
}
