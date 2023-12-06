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

fn getNumFromLine(line: []const u8) usize {
    const first = std.mem.indexOfAny(u8, line, &numChars).?;
    const last = std.mem.lastIndexOfAny(u8, line, &numChars).?;

    return (line[first] - '0') * 10 + line[last] - '0';
}

fn printPart1(input: []const u8) !void {
    var answer: usize = 0;
    var iter = std.mem.splitScalar(u8, input, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const digit = getNumFromLine(line);
        answer += digit;
    }
    std.debug.print("The number is: {d}\n", .{answer});
}

const alphas: [10][]const u8 = [10][]const u8{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn findFirstWord(input: []const u8, otherwise: u8) u8 {
    if (input.len < 3) {
        return otherwise;
    }

    var slice = input;
    while (slice.len > 3) {
        var i: u8 = 0;
        for (alphas) |alpha| {
            if (slice.len >= alpha.len and std.mem.eql(u8, alpha, slice[0..alpha.len])) {
                return '0' + i;
            }
            i += 1;
        }
        slice = slice[1..];
    }

    return otherwise;
}

fn findLastWord(input: []const u8, otherwise: u8) u8 {
    if (input.len < 3) {
        return otherwise;
    }

    var start: usize = input.len - 3;
    while (start > 0) {
        var i: u8 = 0;
        const slice = input[start..];
        for (alphas) |alpha| {
            if (slice.len >= alpha.len and std.mem.eql(u8, alpha, slice[0..alpha.len])) {
                return '0' + i;
            }
            i += 1;
        }
        start -= 1;
    }

    var i: u8 = 0;
    const slice = input;
    for (alphas) |alpha| {
        if (slice.len >= alpha.len and std.mem.eql(u8, alpha, slice[0..alpha.len])) {
            return '0' + i;
        }
        i += 1;
    }
    return otherwise;
}

fn printPart2(input: []const u8) !void {
    var answer: i32 = 0;
    var iter = std.mem.splitScalar(u8, input, '\n');
    while (iter.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const first = std.mem.indexOfAny(u8, line, &numChars) orelse line.len - 1;
        const last = std.mem.lastIndexOfAny(u8, line, &numChars) orelse 0;

        const firstDigit = findFirstWord(line[0..first], line[first]);
        const lastDigit = findLastWord(line[last + 1 ..], line[last]);
        const digit = (firstDigit - '0') * 10 + lastDigit - '0';
        answer += digit;
    }
    std.debug.print("The part 2 number is: {d}\n", .{answer});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try readFile(allocator, "input");
    defer allocator.free(input);
    //try printPart1(input);
    try printPart2(input);
}
