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

const Almanac = struct {
    const MappingType = std.StringHashMap(Tuple);
    maps: MappingType,

    fn init(allocator: Allocator) !Almanac {
        var almanac = Almanac{
            .maps = MappingType.init(allocator),
        };
        return almanac;
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
}
