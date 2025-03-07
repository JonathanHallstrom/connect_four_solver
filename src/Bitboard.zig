const std = @import("std");
const assert = std.debug.assert;

const low_bits = 0b000000100000010000001000000100000010000001;

fn shl(bb: u64, amt: anytype) u64 {
    return std.math.rotl(u64, bb, amt);
}

fn shr(bb: u64, amt: anytype) u64 {
    return std.math.rotl(u64, bb, 64 - amt);
}

pub fn moveLeft(bb: u64, amt: anytype) u64 {
    const msk = 0b1111111 >> amt;
    return shr(bb, amt) & msk * low_bits;
}

pub fn moveRight(bb: u64, amt: anytype) u64 {
    const msk = (0b1111111 << amt) & 0b1111111;
    return shl(bb, amt) & msk * low_bits;
}

comptime {
    assert(moveLeft(1 << 0, 1) == 0);
    assert(moveLeft(1 << 7, 1) == 0);
    assert(moveLeft(1 << 8, 1) == 1 << 7);
    assert(moveRight(1 << 0, 1) == 1 << 1);
    assert(moveRight(1 << 7, 1) == 1 << 8);
    assert(moveRight(1 << 7, 1) == 1 << 8);
    assert(isWon(0b1111));
    assert(!isWon(0b111));
    assert(isWon(1 << 0 | 1 << 7 | 1 << 14 | 1 << 21));
    assert(!isWon(1 << 0 | 1 << 7 | 1 << 14));
    assert(isWon(1 << 0 | 1 << 8 | 1 << 16 | 1 << 24));
    assert(!isWon(1 << 0 | 1 << 8 | 1 << 16));
    assert(isWon(1 << 3 | 1 << 11 | 1 << 19 | 1 << 27));
    assert(!isWon(1 << 4 | 1 << 12 | 1 << 20 | 1 << 28));
    assert(isWon(1 << 5 | 1 << 12 | 1 << 19 | 1 << 26));
    assert(!isWon(1 << 5 | 1 << 12 | 1 << 19));
}

pub fn isWon(bb: u64) bool {
    // naive impl

    // var horizontal = bb;
    // horizontal &= moveRight(horizontal, 1);
    // horizontal &= moveRight(horizontal, 2);

    // var vertical = bb;
    // vertical &= vertical << 7;
    // vertical &= vertical << 14;

    // var diagonal = bb;
    // diagonal &= moveLeft(diagonal, 1) << 7;
    // diagonal &= moveLeft(diagonal, 2) << 14;

    // var antidiagonal = bb;
    // antidiagonal &= moveRight(antidiagonal, 1) << 7;
    // antidiagonal &= moveRight(antidiagonal, 2) << 14;

    // return horizontal | vertical | diagonal | antidiagonal != 0;



    // drops RThroughput from 7.8 to 2.7 on zen4/zen5 according to llvm-mca
    // see naive.s vs vectorized.s for example assembly output

    const BVec = @Vector(4, u64);
    const SVec = @Vector(4, u6);

    const horizontal_shifts: @Vector(4, i8) = .{ 1, 0, -1, 1 };
    const vertical_shifts: @Vector(4, i8) = .{ 0, 1, 1, 1 };
    const first_rank_masks: BVec = .{ moveRight(127, 1), 127, moveLeft(127, 1), moveRight(127, 1) };

    const masks_1 = first_rank_masks * @as(BVec, @splat(low_bits));
    const shifts_1: SVec = comptime @intCast(horizontal_shifts + @as(@Vector(4, i8), @splat(7)) * vertical_shifts);
    const masks_2 = masks_1 & masks_1 << shifts_1;
    const shifts_2: SVec = shifts_1 + shifts_1;

    var bbs: BVec = @splat(bb);
    bbs &= bbs << shifts_1 & masks_1;
    bbs &= bbs << shifts_2 & masks_2;
    return @reduce(.Or, bbs) != 0;
}
