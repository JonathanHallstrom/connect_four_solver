pub const Side = enum {
    red,
    yel,

    pub fn flipped(self: Side) Side {
        return switch (self) {
            .red => .yel,
            .yel => .red,
        };
    }
};
