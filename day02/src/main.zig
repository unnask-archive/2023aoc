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

    const trimChars = [_]u8{ ' ', '\n', '\r' };
    const gameNo = std.mem.trim(u8, idxIter.next().?, &trimChars);
    const lineResults = std.mem.trim(u8, idxIter.next().?, &trimChars);

    const gameIndex = blk: {
        var indexIter = std.mem.splitScalar(u8, gameNo, ' ');
        _ = indexIter.next();
        const tmpIndex = indexIter.next().?;
        break :blk std.fmt.parseInt(i32, tmpIndex, 10) catch 0;
    };

    var bag: Bag = Bag{
        .idx = gameIndex,
        .red = 0,
        .blue = 0,
        .green = 0,
    };
    var gameIter = std.mem.splitScalar(u8, lineResults, ';');
    while (gameIter.next()) |game| {
        var pullIter = std.mem.splitScalar(u8, game, ',');

        while (pullIter.next()) |pull| {
            const trimPull = std.mem.trim(u8, pull, &trimChars);
            var tmpIter = std.mem.splitScalar(u8, trimPull, ' ');

            const tmpCount = tmpIter.next().?;
            const colour = tmpIter.next().?;

            const count = std.fmt.parseInt(i32, tmpCount, 10) catch 0;
            if (std.mem.eql(u8, colour, "red")) {
                if (count > bag.red) {
                    bag.red = count;
                }
            } else if (std.mem.eql(u8, colour, "blue")) {
                if (count > bag.blue) {
                    bag.blue = count;
                }
            } else {
                if (count > bag.green) {
                    bag.green = count;
                }
            }
        }
    }

    return bag;
}

fn performPart1(input: []const u8) !void {
    var linesIter = std.mem.splitScalar(u8, input, '\n');

    var total: i32 = 0;
    while (linesIter.next()) |line| {
        if (line.len < 6) {
            continue;
        }
        const bag = parseLine(line);

        if (bag.red <= 12 and bag.green <= 13 and bag.blue <= 14) {
            total += bag.idx;
        }
    }

    std.debug.print("The total is: {d}\n", .{total});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = try readFile(allocator, "input");

    try performPart1(input);
}
