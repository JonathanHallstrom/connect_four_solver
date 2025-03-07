const std = @import("std");
const Board = @import("Board.zig");
const NegaMax = @import("NegaMax.zig");
const AlphaBeta = @import("AlphaBeta.zig");
const MoveOrdering = @import("MoveOrdering.zig");
const TT = @import("TT.zig");
const TestFileIterator = @import("TestFileIterator.zig");

pub fn main() !void {
    {
        var board = Board.startpos();
        for ("7174362564676726631735257252323") |move| {
            board = board.after(move - '1');
        }
        std.debug.print("{}\n", .{board.move_count});
        std.debug.print("{s}\n", .{board.toAscii().slice()});
        std.debug.print("{}\n", .{board});
        std.debug.print("{}\n", .{board.isGameOver()});
        std.debug.print("{any}\n", .{board.winner()});
        var searcher = try AlphaBeta.init();
        const search_res = searcher.search(.{
            .board = board,
            .max_nodes = 10000000,
        });
        std.debug.print("{any}\n", .{search_res});
        // return;
    }

    inline for ([_][]const u8{
        "Test_L3_R1",
        "Test_L2_R1",
        "Test_L2_R2",
        "Test_L1_R1",
        "Test_L1_R2",
        "Test_L1_R3",
    }) |file_name| {
        inline for ([_]type{
            NegaMax,
            AlphaBeta,
            MoveOrdering,
            TT,
        }) |Searcher| {
            var iter = try TestFileIterator.init("tests/" ++ file_name);
            defer iter.deinit();
            var searcher = try Searcher.init();
            var solved_tests: usize = 0;
            var test_count: usize = 0;
            var average_nodes_to_solve: u64 = 0;
            var total_nodes: u64 = 0;
            var timer = try std.time.Timer.start();
            while (try iter.next()) |board_score_pair| : (test_count += 1) {
                const board, const correct_score, const raw_line = board_score_pair;
                _ = raw_line; // autofix
                const search_result = searcher.search(.{ .board = board, .max_nodes = 10000 });
                if (search_result.score == correct_score) {
                    solved_tests += 1;
                    average_nodes_to_solve += search_result.nodes;
                }
                total_nodes += search_result.nodes;
            }
            std.debug.print("{s} scored {}/{} on {s} using an average of {} nodes with a speed of {}knps\n", .{ @typeName(Searcher), solved_tests, test_count, file_name, average_nodes_to_solve / @max(1, solved_tests), @as(u128, std.time.ns_per_s) * total_nodes / timer.read() / 1000 });
        }
    }
}
