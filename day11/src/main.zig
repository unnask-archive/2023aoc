const std = @import("std");
const Allocator = std.mem.Allocator;
const in = @embedFile("example");

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
                    .x = r,
                    .y = c,
                });
            }
        }
        std.debug.print("\n", .{});
    }

    var storage = allocator.alloc(u8, (irows * 2) * (icols * 2));
    defer allocator.free(storage);
}
