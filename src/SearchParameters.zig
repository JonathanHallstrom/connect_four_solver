const std = @import("std");
const Board = @import("Board.zig");

board: Board,
max_nodes: ?u64 = null,
max_time: ?u64 = null,
max_depth: ?u8 = null,

const Self = @This();

pub fn maxNodes(self: Self) u64 {
    return self.max_nodes orelse std.math.maxInt(u64);
}

pub fn maxTime(self: Self) u64 {
    return self.max_time orelse std.math.maxInt(u64);
}

pub fn maxDepth(self: Self) u8 {
    return self.max_depth orelse std.math.maxInt(u8);
}
