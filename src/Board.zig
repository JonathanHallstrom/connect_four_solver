const std = @import("std");
const Side = @import("Side.zig").Side;
const Bitboard = @import("Bitboard.zig");

height: [7]u8,
red: u64,
yel: u64,
stm: Side,

const Self = @This();
const Board = Self;

pub fn startpos() Self {
    return .{
        .height = .{0} ** 7,
        .red = 0,
        .yel = 0,
        .stm = .red,
    };
}

fn usPtr(self: *Self) *u64 {
    return switch (self.stm) {
        .red => &self.red,
        .yel => &self.yel,
    };
}

fn themPtr(self: *Self) *u64 {
    return switch (self.stm) {
        .yel => &self.red,
        .red => &self.yel,
    };
}

pub fn playMove(self: *Self, which: u8) void {
    self.usPtr().* |= @as(u64, 1) << @intCast(self.height[which] * 7 + which);
    self.height[which] += 1;
    self.stm = self.stm.flipped();
}

const red_char = '.';
const yel_char = '#';

// yeah this is a mess...
pub fn toAscii(self: Self) std.BoundedArray(u8, 1024) {
    var res = std.BoundedArray(u8, 1024).init(0) catch unreachable;
    const default =
        \\   +---+---+---+---+---+---+---+
        \\   |   |   |   |   |   |   |   |
        \\   |   |   |   |   |   |   |   |
        \\   +---+---+---+---+---+---+---+
        \\   |   |   |   |   |   |   |   |
        \\   |   |   |   |   |   |   |   |
        \\   +---+---+---+---+---+---+---+
        \\   |   |   |   |   |   |   |   |
        \\   |   |   |   |   |   |   |   |
        \\   +---+---+---+---+---+---+---+
        \\   |   |   |   |   |   |   |   |
        \\   |   |   |   |   |   |   |   |
        \\   +---+---+---+---+---+---+---+
        \\   |   |   |   |   |   |   |   |
        \\   |   |   |   |   |   |   |   |
        \\   +---+---+---+---+---+---+---+
        \\   |   |   |   |   |   |   |   |
        \\   |   |   |   |   |   |   |   |
        \\   +---+---+---+---+---+---+---+
        \\     1   2   3   4   5   6   7  
    ;
    res.appendSliceAssumeCapacity(default);
    const row_length = comptime 1 + std.mem.indexOfScalar(u8, default, '\n').?;

    inline for (0..6) |rank| {
        inline for (0..7) |file| {
            const i = rank * 7 + file;
            const top_left = 4 + ((6 - rank) * 3 - 2) * row_length + 4 * file;
            if (@as(u64, 1) << i & self.red != 0) {
                res.slice()[top_left] = red_char;
                res.slice()[top_left + 1] = red_char;
                res.slice()[top_left + 2] = red_char;
                res.slice()[top_left + row_length] = red_char;
                res.slice()[top_left + row_length + 1] = red_char;
                res.slice()[top_left + row_length + 2] = red_char;
            }
            if (@as(u64, 1) << i & self.yel != 0) {
                res.slice()[top_left] = yel_char;
                res.slice()[top_left + 1] = yel_char;
                res.slice()[top_left + 2] = yel_char;
                res.slice()[top_left + row_length] = yel_char;
                res.slice()[top_left + row_length + 1] = yel_char;
                res.slice()[top_left + row_length + 2] = yel_char;
            }
        }
    }
    return res;
}

pub var ascii_compatibility_mode = false;

pub fn format(self: Self, comptime actual_fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
    _ = actual_fmt;
    _ = options;
    if (ascii_compatibility_mode) {
        try writer.writeAll(self.toAscii().slice());
    } else {
        var buf: [2048]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&buf);
        _ = try fbs.write("╔══╤══╤══╤══╤══╤══╤══╗\n");
        inline for (0..6) |r| {
            const rank = 5 - r;
            _ = try fbs.write("║");
            inline for (0..7) |file| {
                if (file > 0)
                    _ = try fbs.write("│");
                const i = rank * 7 + file;
                const sq = @as(u64, 1) << @intCast(i);
                if (self.red & sq != 0) {
                    _ = try fbs.write("🔴");
                } else if (self.yel & sq != 0) {
                    _ = try fbs.write("🟡");
                } else {
                    _ = try fbs.write("  ");
                }
            }
            _ = try fbs.write("║");
            _ = try fbs.write("\n");
        }
        _ = try fbs.write("╚══╧══╧══╧══╧══╧══╧══╝\n");
        _ = try fbs.write(" １ ２ ３ ４ ５ ６ ７\n");
        try writer.writeAll(fbs.getWritten());
    }
}

pub inline fn redWon(self: Self) bool {
    return Bitboard.isWon(self.red);
}

pub inline fn yelWon(self: Self) bool {
    return Bitboard.isWon(self.yel);
}

inline fn isBoardFull(self: Self) bool {
    return self.red | self.yel == (1 << 42) - 1;
}

pub inline fn isDraw(self: Self) bool {
    if (self.redWon() or self.yelWon()) return false;
    return self.isBoardFull();
}

pub inline fn isGameOver(self: Self) bool {
    if (self.redWon()) return true;
    if (self.yelWon()) return true;
    if (self.isBoardFull()) return true;
    return false;
}

pub inline fn winner(self: Self) ?Side {
    if (self.redWon()) return .red;
    if (self.yelWon()) return .yel;
    return null;
}

test playMove {
    var board = Board.startpos();
    board.playMove(3);
    try std.testing.expect(board.red & (1 << 3) != 0);
    board.playMove(3);
    try std.testing.expect(board.yel & (1 << 3 + 7) != 0);
    board.playMove(3);
    try std.testing.expect(board.red & (1 << 3 + 14) != 0);
    board.playMove(3);
    try std.testing.expect(board.yel & (1 << 3 + 21) != 0);
}
