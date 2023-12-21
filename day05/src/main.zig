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

// day 2 is *way* to slow, so need to rethink this
// We don't need to check every single number, we only need to check
// the lowest number of each range
//
// for example:
// Start    end
// 10       13
// 20       25
// 30       40
// 50       55
//
// and our interval is:
// 22 - 53
// we only actually need to check the numbers 22, 30, 50
//

const Triple = struct {
    source: usize,
    dest: usize,
    range: usize,
};

const Mapping = struct { from: []const u8, to: []const u8, map: []Triple };

const Almanac = struct {
    const MappingType = std.StringHashMap(Mapping);
    const Self = @This();
    mappings: MappingType,

    fn fromInput(allocator: Allocator, input: []const u8) !Almanac {
        var sources = std.ArrayList(Triple).init(allocator);
        var lnIter = std.mem.splitScalar(u8, input, '\n');

        var ret = Almanac{
            .mappings = MappingType.init(allocator),
        };

        while (lnIter.next()) |line| {
            const trimmed = std.mem.trim(u8, line, &[_]u8{ ' ', '\n' });
            if (trimmed.len == 0) {
                continue;
            }

            if (!std.ascii.isDigit(trimmed[0])) {
                // new mapping section
                var mtIter = std.mem.splitSequence(u8, trimmed, "-to-");
                const from = mtIter.next().?;
                const to = mtIter.next().?;

                while (lnIter.next()) |map| {
                    const tln = std.mem.trim(u8, map, &[_]u8{'\n'});
                    if (tln.len == 0) {
                        break;
                    }

                    var tlnIter = std.mem.splitScalar(u8, tln, ' ');
                    const deststr = tlnIter.next().?;
                    const srcstr = tlnIter.next().?;
                    const rangestr = tlnIter.next().?;

                    const triple = Triple{
                        .source = std.fmt.parseUnsigned(usize, srcstr, 10) catch 0,
                        .dest = std.fmt.parseUnsigned(usize, deststr, 10) catch 0,
                        .range = std.fmt.parseUnsigned(usize, rangestr, 10) catch 0,
                    };
                    try sources.append(triple);
                }

                const mapping = Mapping{
                    .to = to[0 .. to.len - 5],
                    .from = from,
                    .map = try sources.toOwnedSlice(),
                };
                try ret.mappings.put(mapping.from, mapping);
            }
        }
        return ret;
    }
};

fn probeSeedLocation(almanac: Almanac, seed: usize) usize {

    // lookup, find the offset (if there is one)
    // get the "to" map, and do the lookup again.
    // "easy peasy"
    var key = "seed";
    var mapping = almanac.mappings.get(key);
    var value = seed;
    while (mapping) |map| {
        var offset: usize = 0;
        var idx: usize = 0;
        for (map.map, 0..) |src, i| {
            const max = src.source + src.range;
            if (value <= max and value >= src.source) {
                offset = value - src.source;
                idx = i;
            }
        }
        if (offset != 0) {
            value = map.map[idx].dest + offset;
        }
        //std.debug.print("probing: {s} value: {d}\n", .{ map.from, value });
        mapping = almanac.mappings.get(map.to);
    }

    return value;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const input = try readFile(allocator, "input");
    const idx = std.mem.indexOfScalar(u8, input, '\n') orelse 0;

    var seeds = input[0..idx];
    seeds = seeds[7..];
    var seedIter = std.mem.splitScalar(u8, seeds, ' ');
    var useeds: [20]usize = .{0} ** 20;

    var i: usize = 0;
    while (seedIter.next()) |seedstr| {
        useeds[i] = std.fmt.parseUnsigned(usize, seedstr, 10) catch 0;
        i += 1;
    }

    const almanac = try Almanac.fromInput(allocator, input[idx + 1 ..]);
    var lowest: usize = std.math.maxInt(usize);
    for (useeds) |seed| {
        const value = probeSeedLocation(almanac, seed);
        if (value < lowest) {
            lowest = value;
        }
    }
    std.debug.print("The lowest location is: {d}\n", .{lowest});

    // part 2
    lowest = std.math.maxInt(usize);
    i = 0;
    while (i < useeds.len) {
        var start = @min(useeds[i], useeds[i + 1]);
        const end = @max(useeds[i], useeds[i + 1]);

        //for (start..end) |seed| { // integer overflow?????
        while (start <= end) {
            const value = probeSeedLocation(almanac, start);
            if (value < lowest) {
                lowest = value;
            }
            start += 1;
        }

        i += 2;
    }
    std.debug.print("Part 2 lowest is: {d}\n", .{lowest});
}
