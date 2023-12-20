const std = @import("std");
const Allocator = std.mem.Allocator;

fn readFile(allocator: Allocator, filename: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const sz = (try file.stat()).size;
    var br = std.io.bufferedReader(file.reader());
    var reader = br.reader();

    return try reader.readAllAlloc(allocator, sz);
}

const Pair = struct {
    position: usize,
    range: usize,
};

const Mapping = struct { from: []const u8, to: []const u8, srcOvrd: []Pair, destOvrd: []Pair };

const Almanac = struct {
    const MappingType = std.AutoHashMap([]const u8, Mapping);
    mappings: MappingType,
};

fn parseInput(input: []const u8) void {
    var lnIter = std.mem.splitScalar(u8, input, '\n');

    const seeds = lnIter.next();
    _ = seeds;
    while (lnIter.next()) |line| {
        const trimmed = std.mem.trim(u8, line, &[_]u8{ ' ', '\n' });
        if (trimmed.len == 0) {
            continue;
        }

        if (std.ascii.isDigit(trimmed[0])) {
            // new mapping section
            var mtIter = std.mem.splitSequence(u8, trimmed, "-to-");
            const from = mtIter.next();
            _ = from;
            const to = mtIter.next();
            _ = to;
            continue;
        }

        // parse the numbers
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const input = try readFile(allocator, "input");
    for (input) |char| {
        std.debug.print("{any}", .{char});
    }
}
