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
                    const srcstr = tlnIter.next().?;
                    const deststr = tlnIter.next().?;
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

fn findLocationFromSeed(almanac: Almanac, seed: usize) usize {
    _ = seed;
    _ = almanac;

    // lookup, find the offset (if there is one)
    // get the "to" map, and do the lookup again.
    // "easy peasy"

    return 0;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const input = try readFile(allocator, "input");
    const idx = std.mem.indexOfScalar(u8, input, '\n') orelse 0;

    const seeds = input[0..idx];
    _ = seeds;

    const almanac = try Almanac.fromInput(allocator, input[idx + 1 ..]);

    var keys = almanac.mappings.keyIterator();
    while (keys.next()) |key| {
        std.debug.print("key is: {s}\n", .{key.*});
    }
}
