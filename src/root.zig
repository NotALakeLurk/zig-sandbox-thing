//const std = @import("std");
//const testing = std.testing;

pub export fn main() void {
    _ = add(3, 2);
}

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

//test "basic add functionality" {
//    try testing.expect(add(3, 7) == 10);
//}
