const std = @import("std");
const in = @embedFile("input");

//Apparently part 2 can be more easily resolved with
//Picks Theorem and Shoelace Formula
//Cool.

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

    var rng: usize = 0;
    var total: usize = 0;
    //technically window works, but it's const, so I just used a slice for
    //easier visual debugging.
    //var window = std.mem.window(u8, p2tmp, ll, ll);
    //while (window.next()) |wind| {
    while (rng + ll < p2tmp.len) {
        var wind = p2tmp[rng .. rng + ll];
        rng += ll;
        // I think we can ray cast through a window for each . and
        // count the intersections with everything but - or .
        // if even outside
        // if odd inside
        // careful though. F7 or F---7 or LJ or L----J count 2
        //                 L7 or L---7 or FJ or F----J count 1

        var edges: usize = 0;
        var prev: u8 = '.';
        for (wind, 0..) |ch, i| {
            //cast a ray
            if (ch == '|') {
                edges += 1;
            } else if (ch == 'J' and prev == 'F') {
                edges += 1;
            } else if (ch == '7' and prev == 'L') {
                edges += 1;
            } else if (ch == 'S') {
                edges += 1;
            } else if (ch == '.') {
                if (edges % 2 == 1) {
                    total += 1;
                    wind[i] = 'I';
                }
            }
            // we do not care about the '-' because reegardless of them,
            // F7 and F----7 for the same loop for our purpose and
            // FJ anf F----J still only form a straight line, our detection
            // doesnt care the length of the line, just that it would intersect
            // F7 and F---7 Visualization
            // -     _   <- it doesn't matter how long this is!
            // F    / \  7
            //     /   \
            //
            // FJ and F---J Visualization
            // J    /
            // -   /
            // -  /
            // F /
            if (!(ch == '-' or ch == '.')) {
                prev = ch;
            }
        }
        std.debug.print("{s}\n", .{wind});
    }
    std.debug.print("The part 2 total is {d}\n", .{total});
}
