const std = @import("std");
const in = @embedFile("example");

fn findLoop(input: []const u8, lsz: usize, idx: usize, prev: usize) usize {
    switch (input[idx]) {
        '|' => {
            var vert = idx + lsz;
            if (prev > idx) {
                vert = idx - lsz;
            }
            return 1 + findLoop(input, lsz, vert, idx);
        },
        '-' => {
            var horiz = idx + 1;
            if (prev > idx) {
                horiz = idx - 1;
            }
            return 1 + findLoop(input, lsz, horiz, idx);
        },
        'L' => {
            var tmp = idx + 1;
            if (prev > idx) {
                tmp = idx - lsz;
            }
            return 1 + findLoop(input, lsz, tmp, idx);
        },
        'J' => {
            var tmp = idx - 1;
            if (prev == idx - 1) {
                tmp = idx - lsz;
            }
            return 1 + findLoop(input, lsz, tmp, idx);
        },
        '7' => {
            var tmp = idx - 1;
            if (prev == idx - 1) {
                tmp = idx + lsz;
            }
            return 1 + findLoop(input, lsz, tmp, idx);
        },
        'F' => {
            var tmp = idx + 1;
            if (prev == idx + 1) {
                tmp = idx + lsz;
            }
            return 1 + findLoop(input, lsz, tmp, idx);
        },
        else => return 0,
    }
}

pub fn main() !void {
    const ll = std.mem.indexOfScalar(u8, in, '\n').? + 1;
    const st = std.mem.indexOfScalar(u8, in, 'S').?;

    //actually need to check each possible direction from start
    const val = findLoop(in, ll, st, 0);
    _ = val;
}
