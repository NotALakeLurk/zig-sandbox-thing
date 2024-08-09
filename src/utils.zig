pub const Color = packed struct(u32) {
    // if there are problems on other systems endianess things with this and grid.texture_update are probably the problem
    a: u8,
    b: u8,
    g: u8,
    r: u8,

    pub fn from_u32(c: u32) Color {
        return @bitCast(c);
    }
};

pub const Position = struct {
    x: usize,
    y: usize,
};
