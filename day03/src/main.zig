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

fn checkAdjacent(input: []const u8, start: usize, end: usize, len: usize) bool {
    const findList = [_]u8{ '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '-', '_', '=', '+', '[', ']', '\\', '|', ':', ';', '<', ',', '>', '/', '?', '~', '`' };
    //const findList = [_]u8{'%'};

    var begin = start - 1;
    var last = end + 2;

    if (std.mem.indexOfAny(u8, input[begin..last], &findList) != null) {
        return true;
    }

    if (start > len) {
        begin = begin - len;
        last = last - len;
        if (std.mem.indexOfAny(u8, input[begin..last], &findList) != null) {
            return true;
        }
    }

    begin = start - 1;
    last = end + 2;
    if (last + len < input.len) {
        begin = begin + len;
        last = last + len;
        if (std.mem.indexOfAny(u8, input[begin..last], &findList) != null) {
            return true;
        }
    }

    return false;
}

fn p1Answer(input: []const u8) void {
    var nli = std.mem.indexOf(u8, input, &[_]u8{'\n'}) orelse 0;
    nli += 1;

    var start: usize = 0;
    var end: usize = 0;
    var cursor: usize = 0;
    var total: i32 = 0;
    while (cursor < input.len - 1) {

        //find the beginning
        if (std.ascii.isDigit(input[cursor])) {
            start = cursor;

            //find the end
            while (cursor < input.len) {
                if (std.ascii.isDigit(input[cursor])) {
                    end = cursor;
                } else {
                    break;
                }
                cursor += 1;
            }

            if (checkAdjacent(input, start, end, nli)) {
                std.debug.print("{s}\n", .{input[start .. end + 1]});
                const val = input[start .. end + 1];
                const num = std.fmt.parseInt(i32, val, 10) catch 0;
                total += num;
            }
        }

        cursor += 1;
    }

    std.debug.print("The total is: {d}\n", .{total});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const input = try readFile(allocator, "input");

    //p1Answer(input);

    // for part two, look for the * rather than the numbers.
    p2Answer(input);
}

fn p2Answer(input: []const u8) void {
    var nli = std.mem.indexOf(u8, input, &[_]u8{'\n'}) orelse 0;
    nli += 1;

    var total: i32 = 0;
    for (input, 0..) |character, cursor| {
        if (character == '*') {
            if (checkGear(input, cursor, nli)) |gear| {
                total += gear.part1 * gear.part2;
                // do it
            }
        }
    }
    std.debug.print("Part 2 total is {d}\n", .{total});
}

const Gear = struct {
    part1: i32,
    part2: i32,
};

fn checkGear(input: []const u8, cursor: usize, linesz: usize) ?Gear {
    var gear = Gear{
        .part1 = 0,
        .part2 = 0,
    };

    //check the middle
    if (std.ascii.isDigit(input[cursor - 1])) {
        const number = getNumber(input, cursor - 1);
        addToGear(&gear, number);
    }
    if (std.ascii.isDigit(input[cursor + 1])) {
        const number = getNumber(input, cursor + 1);
        addToGear(&gear, number);
    }

    //check the top
    if (cursor > linesz) {
        var offset = cursor - linesz;
        if (std.ascii.isDigit(input[offset])) {
            const number = getNumber(input, offset);
            addToGear(&gear, number);
        } else {
            if (std.ascii.isDigit(input[offset - 1])) {
                const number = getNumber(input, offset - 1);
                addToGear(&gear, number);
            }
            if (std.ascii.isDigit(input[offset + 1])) {
                const number = getNumber(input, offset + 1);
                addToGear(&gear, number);
            }
        }
    }

    //check the bottom
    if (cursor + linesz < input.len) {
        var offset = cursor + linesz;
        if (std.ascii.isDigit(input[offset])) {
            const number = getNumber(input, offset);
            addToGear(&gear, number);
        } else {
            if (std.ascii.isDigit(input[offset - 1])) {
                const number = getNumber(input, offset - 1);
                addToGear(&gear, number);
            }
            if (std.ascii.isDigit(input[offset + 1])) {
                const number = getNumber(input, offset + 1);
                addToGear(&gear, number);
            }
        }
    }
    return gear;
}

fn addToGear(gear: *Gear, digit: i32) void {
    if (gear.part1 == 0) {
        gear.part1 = digit;
    } else {
        gear.part2 = digit;
    }
}

fn getNumber(input: []const u8, pos: usize) i32 {
    var start = pos;
    var end = pos;

    while (std.ascii.isDigit(input[end])) {
        end += 1;
    }
    while (std.ascii.isDigit(input[start])) {
        start -= 1;
    }
    start += 1;

    return std.fmt.parseInt(i32, input[start..end], 10) catch 0;
}
