const std = @import("std");
const assert = std.debug.assert;
const SearchParameters = @import("SearchParameters.zig");
const SearchResult = @import("SearchResult.zig");
const Board = @import("Board.zig");

nodes: u64,
timer: std.time.Timer,
max_time: u64,
max_nodes: u64,
root_move: u8,

const Self = @This();

pub fn init() !Self {
    return .{
        .nodes = 0,
        .root_move = 0,
        .timer = try std.time.Timer.start(),
        .max_time = 0,
        .max_nodes = 0,
    };
}

pub fn deinit(_: Self) void {}

pub fn search(self: *Self, parameters: SearchParameters) SearchResult {
    self.nodes = 0;
    self.timer.reset();
    self.max_nodes = parameters.maxNodes();
    self.max_time = parameters.maxTime();
    var score: i8 = -100;
    var depth: u8 = 1;
    var board = parameters.board;
    while (true) {
        score = self.negaMax(
            true,
            &board,
            matedIn(0),
            -matedIn(0),
            depth,
        ) orelse break;
        if (board.move_count + depth == 42) break;
        depth += 1;
    }
    return .{
        .best_move = self.root_move,
        .nodes = self.nodes,
        .score = score,
    };
}

fn negaMax(
    self: *Self,
    comptime is_root: bool,
    board: *Board,
    alpha_: i8,
    beta: i8,
    depth: u8,
) ?i8 {
    self.nodes += 1;
    if (self.nodes >= self.max_nodes or self.timer.read() >= self.max_time) {
        return null;
    }
    var alpha = alpha_;

    if (board.isGameOver()) {
        return if (board.isDraw()) 0 else matedIn(board.move_count);
    }

    if (depth == 0) {
        return 0;
    }

    // const worst_possible = -matedIn(board.move_count + 3);
    // const best_possible = -matedIn(board.move_count + 1);

    // if (best_possible <= alpha) {
    //     return alpha;
    // }
    // if (worst_possible >= beta) {
    //     return beta;
    // }

    var best_score: ?i8 = null;
    const moves = [_]u8{ 3, 2, 4, 1, 5, 0, 6 };
    for (0..7) |idx| {
        const move = moves[idx];
        if (board.height[move] == 6) continue;
        board.playMove(move);
        defer board.undoMove(move);
        const score = -(self.negaMax(
            false,
            board,
            -beta,
            -alpha,
            depth - 1,
        ) orelse return null);
        if (score > (best_score orelse -100)) {
            best_score = score;
            if (is_root) self.root_move = @intCast(move);
        }
        if (score > alpha) {
            if (score >= beta)
                break;
            alpha = score;
        }
    }

    return best_score;
}

fn matedIn(moves: u8) i8 {
    return @as(i8, -22) + @as(i8, @intCast((moves + 1) / 2));
}
