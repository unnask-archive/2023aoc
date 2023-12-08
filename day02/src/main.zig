const std = @import("std");
const Allocator = std.mem.Allocator;

fn readFile(allocator: Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var fsz = (try file.stat()).size;
    var br = std.io.BufferedReader(file.reader());
    var reader = br.reader();

    return try reader.readAllAlloc(allocator, fsz);
}

/// get the index as an i32 from text like "Game ##0"
fn getIntIdx(input: []const u8) !i32 {
    var i = input.len - 1;

    while (input[i - 1] != ' ') {
        i -= 1;
    }

    const idx = input[i..];

    return try std.fmt.parseInt(i32, idx, 10);
}

const Bag = struct {
    idx: i32,
    red: i32,
    green: i32,
    blue: i32,
};

fn parseLine(line: []const u8) Bag {
    var idxIter = std.mem.splitScalar(u8, line, ':');

    const game = idxIter.next();
    _ = game;
    const lineResults = idxIter.next();
    _ = lineResults;
}

fn performPart1(input: []const u8) !void {
    var linesIter = std.mem.splitScalar(u8, input, '\n');

    while (linesIter.next()) |line| {
        _ = line;
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = try readFile(allocator, "input");

    try performPart1(input);
}
