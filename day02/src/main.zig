const std = @import("std");
const Allocator = std.mem.Allocator;

fn readFile(allocator: Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var fsz = (try file.stat()).size;
    var br = std.io.bufferedReader(file.reader());
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

    const game = idxIter.next().?;
    const lineResults = idxIter.next().?;

    std.debug.print("game: {s}\n line: {s}\n\n", .{ game, lineResults });

    return Bag{
        .idx = 1,
        .red = 1,
        .green = 1,
        .blue = 1,
    };
}

fn performPart1(input: []const u8) !void {
    var linesIter = std.mem.splitScalar(u8, input, '\n');

    while (linesIter.next()) |line| {
        if (line.len < 6) {
            continue;
        }
        _ = parseLine(line);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = try readFile(allocator, "input");

    try performPart1(input);
}
