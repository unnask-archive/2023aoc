const std = @import("std");
const Allocator = std.mem.Allocator;
const in = @embedFile("input");

const Coord = struct { x: usize, y: usize };

// for the others, I didn't do this, but tracking rows and columns with many
// extra \n was proving annoying. so split it I shall
fn splitInput(allocator: Allocator, input: []const u8, by: u8) ![][]const u8 {
    var list = std.ArrayList([]const u8).init(allocator);
    var iter = std.mem.splitScalar(u8, input, by);

    while (iter.next()) |section| {
        if (section.len == 0) {
            continue;
        }
        try list.append(section);
    }

    return try list.toOwnedSlice();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    comptime var icols = std.mem.indexOfScalar(u8, in, '\n').?;
    comptime var irows = in.len / (icols + 1);

    var grid = try splitInput(allocator, in, '\n');
    defer allocator.free(grid);

    var er: [irows]bool = .{true} ** irows;
    var ec: [icols]bool = .{true} ** icols;
    var coords = std.ArrayList(Coord).init(allocator);
    defer coords.deinit();

    for (grid, 0..) |line, r| {
        for (line, 0..) |ch, c| {
            std.debug.print("{c}", .{ch});

            if (ch == '#') {
                er[r] = false;
                ec[c] = false;
                try coords.append(Coord{
                    .x = c,
                    .y = r,
                });
            }
        }
        std.debug.print("\n", .{});
    }

    //var storage = allocator.alloc(u8, (irows * 2) * (icols * 2));
    //defer allocator.free(storage);

    // Actually, I don't think I even need storage here. basic math aught to do

    //As to why I need to use 999,999 instead of 100,000 for my addition in
    //part 2, dunno, and probably not going to find out.
    var offset: usize = 0;
    for (ec, 0..) |exp, i| {
        if (exp) {
            for (coords.items) |*coord| {
                if (coord.x > i + offset) {
                    coord.x += 999999;
                }
            }
            offset += 999999;
        }
    }
    offset = 0;
    for (er, 0..) |exp, i| {
        if (exp) {
            for (coords.items) |*coord| {
                if (coord.y > i + offset) {
                    coord.y += 999999;
                }
            }
            offset += 999999;
        }
    }

    // Have the new coordinates now. calculate.
    var total: usize = 0;
    for (coords.items, 0..) |coord, i| {
        if (i == coords.items.len) {
            continue;
        }
        for (coords.items[i + 1 ..]) |coord2| {
            const dist = (@max(coord.x, coord2.x) - @min(coord.x, coord2.x)) +
                (@max(coord.y, coord2.y) - @min(coord.y, coord2.y));
            total += dist;
            std.debug.print("From: {d}-{d} to {d}-{d} -- dist: {d}\n", .{ coord.y, coord.x, coord2.y, coord2.x, dist });
        }
    }
    std.debug.print("Part 1 total is: {d}\n", .{total});
}
