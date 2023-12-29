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

    const input = try readFile("input");
    defer allocator.free(input);
}
