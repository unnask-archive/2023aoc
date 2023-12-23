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

    fn probeSeedLocation(self: *Almanac, seed: usize) usize {
        const startKey = "seed";
        var mapo = self.maps.get(startKey);

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

    fn probeRangeLocation(self: *Almanac, start: usize, end: usize) usize {
        _ = end;
        _ = start;
        _ = self;
        return 0;
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
        const probe = almanac.probeSeedLocation(seed);
        if (probe < lowest) {
            lowest = probe;
        }
    }
    std.debug.print("Part 1: {d}\n", .{lowest});
}
