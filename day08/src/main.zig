const std = @import("std");
const Allocator = std.mem.Allocator;

fn readFile(allocator: Allocator, filename: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filename, .{});

    const sz = (try file.stat()).size;
    var br = std.io.bufferedReader(file.reader());
    var reader = br.reader();

    return reader.readAllAlloc(allocator, sz);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const input = try readFile(allocator, "input");
    defer allocator.free(input);

    var secIter = std.mem.splitSequence(u8, input, "\n\n");
    const moves = secIter.next().?;
    const map = secIter.next().?;

    const Map = std.StringHashMap([]const u8);
    var lookup = std.AutoHashMap(u8, Map).init(allocator);
    var left = Map.init(allocator);
    var right = Map.init(allocator);
    defer {
        right.deinit();
        left.deinit();
        lookup.deinit();
    }

    var lineIter = std.mem.splitScalar(u8, map, '\n');
    while (lineIter.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var mapIter = std.mem.splitSequence(u8, line, " = ");
        const val = mapIter.next().?;
        var lr = mapIter.next().?;
        lr = lr[1 .. lr.len - 1];

        var lrIter = std.mem.splitSequence(u8, lr, ", ");
        try left.put(val, lrIter.next().?);
        try right.put(val, lrIter.next().?);
    }
    try lookup.put('L', left);
    try lookup.put('R', right);

    var total: usize = 0;
    var element: []const u8 = "AAA";
    found: while (true) {
        for (moves) |move| {
            total += 1;
            const m = lookup.get(move).?;
            element = m.get(element).?;
            if (std.mem.eql(u8, "ZZZ", element)) {
                std.debug.print("Found it\n", .{});
                break :found;
            }
        }
    }
    std.debug.print("Part 1 Total is: {d}\n", .{total});
}
