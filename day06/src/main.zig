const std = @import("std");
const Allocator = std.mem.Allocator;

fn readFile(allocator: Allocator, filename: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filename, .{});

    const sz = (try file.stat()).size;
    var br = std.io.bufferedReader(file.reader());
    var reader = br.reader();

    return try reader.readAllAlloc(allocator, sz);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const input = try readFile(allocator, "input");

    var inputIter = std.mem.splitScalar(u8, input, '\n');
    const timeLine = inputIter.next().?[10..];
    const distanceLine = inputIter.next().?[10..];

    var timeIter = std.mem.splitScalar(u8, timeLine, ' ');
    var distanceIter = std.mem.splitScalar(u8, distanceLine, ' ');
    var times: [4]usize = .{0} ** 4;
    var distances: [4]usize = .{0} ** 4;

    var idx: usize = 0;
    while (timeIter.next()) |time| {
        if (time.len == 0) {
            continue;
        }

        times[idx] = std.fmt.parseUnsigned(usize, time, 10) catch 0;
        idx += 1;
    }
    idx = 0;
    while (distanceIter.next()) |distance| {
        if (distance.len == 0) {
            continue;
        }

        distances[idx] = std.fmt.parseUnsigned(usize, distance, 10) catch 0;
        idx += 1;
    }

    var total: usize = 1;
    for (0..4) |i| {
        var count: usize = 0;
        for (0..times[i] + 1) |time| {
            const dist = time * (times[i] - time);
            if (dist > distances[i]) {
                count += 1;
            }
        }
        total *= count;
        std.debug.print("{d} -- {d}\n", .{ times[i], distances[i] });
    }
    std.debug.print("Part 1 total: {d}\n", .{total});

    var p2t = times[0];
    var p2d = distances[0];
    for (1..4) |i| {
        p2t = concatUnsigned(p2t, times[i]);
        p2d = concatUnsigned(p2d, distances[i]);
    }

    // This problem was a bit too easy to brute force.
    // kinda of wish it was obscenely large numbers, or multiple large numbers
    // to force a "smarter" solution
    // The winners fall in a range, so we could search from the back and front
    // to "maybe" reduce the search time.
    // We could do binary searching in both directions (splitting the numbers
    // in half each time and searching 1 number at a time to find the answers)
    // etc.
    // Or, because there wasn't very many, we can just brute force it
    total = 0;
    for (0..p2t + 1) |time| {
        const dist = time * (p2t - time);
        if (dist > p2d) {
            total += 1;
        }
    }
    std.debug.print("Part 2 total: {d}\n", .{total});
}

fn concatUnsigned(x: usize, y: usize) usize {
    var pow: usize = 10;
    while (y >= pow) {
        pow *= 10;
    }
    return x * pow + y;
}
