const std = @import("std");
const Allocator = std.mem.Allocator;

const numChars: [10]u8 = [_]u8{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };

fn readFile(allocator: Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    //could also just
    //try std.fs.cwd().readFileAlloc(...);

    var fsz = (try file.stat()).size;
    var br = std.io.bufferedReader(file.reader());
    var reader = br.reader();

    return try reader.readAllAlloc(allocator, fsz);
}

fn getNumFromLine(line: []const u8) [2]u8 {
    const first = std.mem.indexOfAny(u8, line, &numChars).?;
    const last = std.mem.lastIndexOfAny(u8, line, &numChars).?;

    return [2]u8{ line[first], line[last] };
}

fn printPart1(input: []const u8) !void {
    var answer: i32 = 0;
    var iter = std.mem.splitScalar(u8, input, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const digit = getNumFromLine(line);
        const castedDigit = try std.fmt.parseInt(i32, &digit, 10);
        answer += castedDigit;
    }
    std.debug.print("The number is: {d}\n", .{answer});
}

fn findFirstWord(input: []const u8, otherwise: u8) u8 {
    _ = input;

    return otherwise;
}

fn findLastWord(input: []const u8, otherwise: u8) u8 {
    _ = input;

    return otherwise;
}

fn printPart2(input: []const u8) !void {
    var answer: i32 = 0;
    var iter = std.mem.splitScalar(u8, input, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const first = std.mem.indexOfAny(u8, line, &numChars).?;
        const last = std.mem.lastIndexOfAny(u8, line, &numChars).?;

        const firstDigit = findFirstWord(line[0..first], line[first]);
        const lastDigit = findLastWord(line[last + 1 ..], line[last]);
        const digit = [2]u8{ firstDigit, lastDigit };

        const castedDigit = try std.fmt.parseInt(i32, &digit, 10);
        answer += castedDigit;
    }
    std.debug.print("The part 2 number is: {d}\n", .{answer});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try readFile(allocator, "input");
    defer allocator.free(input);
    try printPart1(input);
    try printPart2(input);
}
