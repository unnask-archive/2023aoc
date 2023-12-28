const std = @import("std");
const Allocator = std.mem.Allocator;

fn readFile(allocator: Allocator, filename: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filename, .{});

    const sz = (try file.stat()).size;
    var br = std.io.bufferedReader(file.reader());
    var reader = br.reader();

    return reader.readAllAlloc(allocator, sz);
}

const Map = std.StringHashMap([]const u8);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const input = try readFile(allocator, "input");
    defer allocator.free(input);

    var secIter = std.mem.splitSequence(u8, input, "\n\n");
    const moves = secIter.next().?;
    const map = secIter.next().?;

    var lookup = std.AutoHashMap(u8, Map).init(allocator);
    var left = Map.init(allocator);
    var right = Map.init(allocator);
    defer {
        right.deinit();
        left.deinit();
        lookup.deinit();
    }

    var p2List = std.ArrayList([]const u8).init(allocator);
    defer p2List.deinit();
    var lineIter = std.mem.splitScalar(u8, map, '\n');
    while (lineIter.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        var mapIter = std.mem.splitSequence(u8, line, " = ");
        const val = mapIter.next().?;
        if (val[2] == 'A') {
            try p2List.append(val);
        }
        var lr = mapIter.next().?;
        lr = lr[1 .. lr.len - 1];

        var lrIter = std.mem.splitSequence(u8, lr, ", ");
        try left.put(val, lrIter.next().?);
        try right.put(val, lrIter.next().?);
    }
    try lookup.put('L', left);
    try lookup.put('R', right);

    var total = indexOf(moves, &lookup, "AAA", "ZZZ");
    std.debug.print("Part 1 Total is: {d}\n", .{total});

    //part 2 is a bit more annoying
    //need to navigate multiple elements ending with A through until ALL of
    //the elements land on an element ending is Z at the same time.
    //I think we can just find the lowest count of each element, then find the
    //lowest common multiple of the elements instead
    var lowList = std.ArrayList(usize).init(allocator);
    defer lowList.deinit();
    while (p2List.items.len > 0) {
        try lowList.append(indexOf2(moves, &lookup, p2List.pop()));
    }
    //while (lowList.items.len > 0) {
    //    std.debug.print("{d}\n", .{lowList.pop()});
    //}
    const nums = try lowList.toOwnedSlice();
    defer allocator.free(nums);
    std.debug.print("Part 2 is {d}\n", .{leastCommonMultiple(nums)});
}

fn indexOf(moves: []const u8, lookup: *std.AutoHashMap(u8, Map), st: []const u8, ed: []const u8) usize {
    var total: usize = 0;
    var element: []const u8 = st;
    found: while (true) {
        for (moves) |move| {
            total += 1;
            const m = lookup.get(move).?;
            element = m.get(element).?;
            if (std.mem.eql(u8, ed, element)) {
                break :found;
            }
        }
    }
    return total;
}

fn leastCommonMultiple(nums: []const usize) usize {
    var ret: usize = 1;
    for (nums) |num| {
        ret = (ret * num) / std.math.gcd(num, ret);
    }
    return ret;
}

fn indexOf2(moves: []const u8, lookup: *std.AutoHashMap(u8, Map), st: []const u8) usize {
    var total: usize = 0;
    var element: []const u8 = st;
    found: while (true) {
        for (moves) |move| {
            total += 1;
            const m = lookup.get(move).?;
            element = m.get(element).?;
            if (element[2] == 'Z') {
                break :found;
            }
        }
    }
    return total;
}
