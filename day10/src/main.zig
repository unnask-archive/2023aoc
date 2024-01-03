const std = @import("std");
const in = @embedFile("input");

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

fn refill(input: []const u8, output: []u8, lsz: usize, idx: usize, prev: usize) void {
    output[idx] = input[idx];
    switch (input[idx]) {
        '|' => {
            var vert = idx + lsz;
            if (prev > idx) {
                vert = idx - lsz;
            }
            refill(input, output, lsz, vert, idx);
        },
        '-' => {
            var horiz = idx + 1;
            if (prev > idx) {
                horiz = idx - 1;
            }
            refill(input, output, lsz, horiz, idx);
        },
        'L' => {
            var tmp = idx + 1;
            if (prev > idx) {
                tmp = idx - lsz;
            }
            refill(input, output, lsz, tmp, idx);
        },
        'J' => {
            var tmp = idx - 1;
            if (prev == idx - 1) {
                tmp = idx - lsz;
            }
            refill(input, output, lsz, tmp, idx);
        },
        '7' => {
            var tmp = idx - 1;
            if (prev == idx - 1) {
                tmp = idx + lsz;
            }
            refill(input, output, lsz, tmp, idx);
        },
        'F' => {
            var tmp = idx + 1;
            if (prev == idx + 1) {
                tmp = idx + lsz;
            }
            refill(input, output, lsz, tmp, idx);
        },
        else => {},
    }
}

pub fn main() !void {
    const ll = std.mem.indexOfScalar(u8, in, '\n').? + 1;
    const st = std.mem.indexOfScalar(u8, in, 'S').?;

    //actually need to check each possible direction from start
    var val: usize = 0;
    if (st > ll) {
        val = @max(val, findLoop(in, ll, st - ll, st));
    }
    if (st + ll < in.len) {
        val = @max(val, findLoop(in, ll, st + ll, st));
    }
    if (st % ll > 0) {
        val = @max(val, findLoop(in, ll, st - 1, st));
    }
    if (st + 1 < in.len) {
        val = @max(val, findLoop(in, ll, st + 1, st));
    }
    val += 1;
    val /= 2;
    std.debug.print("The length is: {d}\n", .{val});

    //part 2
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    var p2tmp = try allocator.alloc(u8, in.len);
    defer allocator.free(p2tmp);
    @memset(p2tmp, '.');

    if (st > ll) {
        refill(in, p2tmp, ll, st - ll, st);
    }
    if (st + ll < in.len) {
        refill(in, p2tmp, ll, st + ll, st);
    }
    if (st % ll > 0) {
        refill(in, p2tmp, ll, st - 1, st);
    }
    if (st + 1 < in.len) {
        refill(in, p2tmp, ll, st + 1, st);
    }
    var window = std.mem.window(u8, p2tmp, ll, ll);
    while (window.next()) |wind| {
        std.debug.print("{s}\n", .{wind});

        // I think we can ray cast through a window for each . and
        // count the intersections with everything but - or .
        // if even outside
        // if odd inside

        for (wind, 0..) |ch, i| {
            _ = i;
            _ = ch;
            //cast a ray
        }
    }
}
