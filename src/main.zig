const std = @import("std");
const lib = @import("root.zig");
const Board = lib.Board;

pub fn main() !void {
    var board = Board.startpos();
    for ([_]u8{ 4, 4, 4, 5, 5, 5, 5, 4, 2, 2, 1 }) |move| {
        board.playMove(move);
    }
    std.debug.print("{s}\n", .{board.toAscii().slice()});
    std.debug.print("{}\n", .{board});
    std.debug.print("{}\n", .{board.isGameOver()});
    std.debug.print("{any}\n", .{board.winner()});
}
