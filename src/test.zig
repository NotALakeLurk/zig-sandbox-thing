const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == std.heap.Check.leak)
        std.debug.print("leaky gpa", .{});

    const allocator = gpa.allocator();

    const og_data = try allocator.alloc(u8, 4);
    defer allocator.free(og_data);

    const length = og_data.len;
    const bytes = og_data.ptr;

    //std.mem.bytesAsSlice();

    const sup = std.mem.bytesAsSlice(u16, bytes[0..length]);

    sup[0] = 257;

    std.debug.print("bytes: {any}\nsup: {any}\n", .{ og_data, sup });
}
