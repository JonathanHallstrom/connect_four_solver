const std = @import("std");
const Board = @import("Board.zig");
name: []const u8,
handle: std.fs.File,
buffered_reader: BufferedReader,

const buffer_size = 4096;
const BufferedReader = std.io.BufferedReader(buffer_size, std.fs.File.Reader);

const Self = @This();

pub fn init(name: []const u8) !Self {
    const handle = try std.fs.cwd().openFile(name, .{});
    errdefer comptime unreachable; // assert there will be no errors past this point
    const reader = BufferedReader{ .unbuffered_reader = handle.reader() };
    return Self{
        .name = name,
        .handle = handle,
        .buffered_reader = reader,
    };
}

pub fn deinit(self: Self) void {
    self.handle.close();
}

pub fn next(self: *Self) !?struct { Board, i8, std.BoundedArray(u8, 42) } {
    var buf: [128]u8 = undefined;
    const line = self.buffered_reader.reader().readUntilDelimiter(&buf, '\n') catch |e| return switch (e) {
        error.EndOfStream => null,
        else => e,
    };
    var res = Board.startpos();

    var iter = std.mem.tokenizeScalar(u8, line, ' ');
    const moves = iter.next() orelse return null;
    var move_seq = try std.BoundedArray(u8, 42).init(moves.len);
    @memcpy(move_seq.slice(), moves);
    const score = iter.next() orelse return null;

    for (moves) |move| {
        res = res.after(move - '1');
    }
    return .{ res, try std.fmt.parseInt(i8, score, 10), move_seq };
}
