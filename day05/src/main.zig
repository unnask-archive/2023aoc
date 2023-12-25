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

fn parseSeeds(allocator: Allocator, input: []const u8) ![]usize {
    var list = std.ArrayList(usize).init(allocator);
    defer list.deinit();

    var seedIter = std.mem.splitScalar(u8, input[7..], ' ');
    while (seedIter.next()) |seedstr| {
        try list.append(try std.fmt.parseUnsigned(usize, seedstr, 10));
    }

    return try list.toOwnedSlice();
}

const Tuple = struct {
    dest: usize,
    src: usize,
    range: usize,
};

const Map = struct {
    srcName: []const u8,
    destName: []const u8,
    maps: []const Tuple,
};

const Almanac = struct {
    const MappingType = std.StringHashMap(Map);
    maps: MappingType,
    allocator: Allocator,

    fn init(allocator: Allocator) !Almanac {
        var almanac = Almanac{
            .maps = MappingType.init(allocator),
            .allocator = allocator,
        };
        return almanac;
    }

    fn deinit(self: *Almanac) void {
        var mapsIter = self.maps.valueIterator();

        while (mapsIter.next()) |map| {
            self.allocator.free(map.*.maps);
        }

        self.maps.deinit();
    }

    fn parseSection(self: *Almanac, input: []const u8) !void {
        var inputIter = std.mem.splitScalar(u8, input, '\n');

        const src2dest = inputIter.next().?;
        var stdIter = std.mem.splitSequence(u8, src2dest, "-to-");
        const srcName = std.mem.trim(u8, stdIter.next().?, &[_]u8{ ' ', '\n' });
        const destName = std.mem.trim(u8, stdIter.next().?, &[_]u8{ ' ', '\n' });

        var list = std.ArrayList(Tuple).init(self.allocator);
        defer list.deinit();
        while (inputIter.next()) |line| {
            if (line.len == 0) {
                continue;
            }
            var lineIter = std.mem.splitScalar(u8, line, ' ');

            var tuple = Tuple{
                .dest = std.fmt.parseUnsigned(usize, lineIter.next().?, 10) catch unreachable,
                .src = std.fmt.parseUnsigned(usize, lineIter.next().?, 10) catch unreachable,
                .range = std.fmt.parseUnsigned(usize, lineIter.next().?, 10) catch unreachable,
            };

            try list.append(tuple);
        }

        try self.maps.put(srcName, Map{
            .srcName = srcName,
            .destName = destName[0 .. destName.len - 5],
            .maps = try list.toOwnedSlice(),
        });
    }

    fn probeSeedLocation(self: *Almanac, mapKey: []const u8, seed: usize) usize {
        var mapo = self.maps.get(mapKey);

        var location: usize = seed;
        while (mapo) |map| {
            for (map.maps) |tuple| {
                if (location >= tuple.src and location <= tuple.src + tuple.range) {
                    location = tuple.dest + (location - tuple.src);
                    break;
                }
            }
            mapo = self.maps.get(map.destName);
        }

        return location;
    }

    //too slow to probe every location individually.
    //we could thread it, but we could also do less work.
    //The intervals here are always mapped ascending, otherwise use the seed
    //so while we only technically need the first one, the range is relevant
    //through each section.
    //Each range ay also break up, so we will probe the start and end of
    //the broken ranges
    //seed start                                               seed end
    //[st1      ed1][st2                               ed2][st3    ed3]
    //We must break up and process each individually because the ranges are
    //also segmented.
    fn probeRangeLocation(self: *Almanac, mapKey: []const u8, start: usize, end: usize) !usize {
        //create the segments
        var segments = std.ArrayList([2]usize).init(self.allocator);
        defer segments.deinit();
        var pairs = std.ArrayList([2]usize).init(self.allocator);
        defer pairs.deinit();
        var tmp = std.ArrayList([2]usize).init(self.allocator);
        defer tmp.deinit();
        try pairs.append([2]usize{ start, end });

        var amap = self.maps.get(mapKey);
        while (amap) |mapping| {
            while (segments.popOrNull()) |segment| {
                try pairs.append(segment);
            }
            for (mapping.maps) |map| {
                const srcEnd = map.src + map.range;
                while (pairs.popOrNull()) |pair| {
                    // imagine we have
                    //                 [map str                    map end]
                    // we could have these cases:
                    // [seed str                                         seed end]
                    // [seed str                      seed end]
                    //                   [seed str                       seed end]
                    //                    [seed str            seed end]
                    // [seed str  end]
                    //                                                       [seed str   end]
                    //
                    //so we need to capture all of these potential ranges.
                    //since the maps don't overlap, if we fall in a range, we
                    //can push this to the known segments
                    //if we don't fall in the current map, we need to continue
                    //checking the split ranges through all of the maps to
                    //see if they fall in any maps. Only if the split fall in to
                    //no ranges can we then add them as it to the segments
                    const seq1 = [2]usize{ pair[0], @min(map.src, pair[1]) };
                    const seq2 = [2]usize{ @max(pair[0], map.src), @min(pair[1], srcEnd) };
                    const seq3 = [2]usize{ @max(pair[0], srcEnd), pair[1] };
                    if (seq1[1] > seq1[0]) {
                        try tmp.append(seq1);
                    }
                    if (seq3[1] > seq3[0]) {
                        try tmp.append(seq3);
                    }
                    if (seq2[1] > seq2[0]) {
                        try segments.append([2]usize{ map.dest + (seq2[0] - map.src), map.dest + (seq2[1] - map.src) });
                    }
                }

                while (tmp.popOrNull()) |tpair| {
                    try pairs.append(tpair);
                }
            }

            while (pairs.popOrNull()) |pair| {
                try segments.append(pair);
            }

            amap = self.maps.get(mapping.destName);
        }

        var lowest: usize = std.math.maxInt(usize);
        while (segments.popOrNull()) |segment| {
            if (segment[0] < lowest) {
                lowest = segment[0];
            }
        }

        return lowest;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    const input = try readFile(allocator, "input");
    var sectionIter = std.mem.splitSequence(u8, input, "\n\n");

    const seeds = try parseSeeds(allocator, sectionIter.next().?);
    defer allocator.free(seeds);

    for (seeds) |seed| {
        std.debug.print("Seed: {d}\n", .{seed});
    }
    var almanac = try Almanac.init(allocator);
    defer almanac.deinit();
    while (sectionIter.next()) |section| {
        try almanac.parseSection(section);
    }

    var lowest: usize = std.math.maxInt(usize);
    for (seeds) |seed| {
        const probe = almanac.probeSeedLocation("seed", seed);
        if (probe < lowest) {
            lowest = probe;
        }
    }
    std.debug.print("Part 1: {d}\n", .{lowest});

    var is: usize = 0;
    lowest = std.math.maxInt(usize);
    while (is < seeds.len) {
        const start = seeds[is];
        const end = seeds[is] + seeds[is + 1];

        const probe = try almanac.probeRangeLocation("seed", start, end);
        if (probe < lowest) {
            lowest = probe;
        }

        is += 2;
    }
    std.debug.print("Part 2: {d}\n", .{lowest});
}
