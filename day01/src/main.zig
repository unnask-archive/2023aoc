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

fn getNumFromLine(line: []const u8) [2]u8 {
    const first = std.mem.indexOfAny(u8, line, &numChars).?;
    const last = std.mem.lastIndexOfAny(u8, line, &numChars).?;

    return [2]u8{ line[first], line[last] };
}

fn nextLine(input: []const u8) []const u8 {
    const pos = std.mem.indexOfPos(u8, input, 0, &[_]u8{'\n'}) orelse input.len;
    return input[0..pos];
}

const numChars: [10]u8 = [_]u8{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try readFile(allocator, "input");
    var cursor: usize = 0;
    var answer: i32 = 0;
    while (cursor < input.len) {
        const line = nextLine(input[cursor..]);
        if (line.len == 0) {
            break;
        }
        cursor += line.len + 1;

        const digit = getNumFromLine(line);
        const castedDigit = try std.fmt.parseInt(i32, &digit, 10);
        answer += castedDigit;
    }
    std.debug.print("The number is: {d}\n", .{answer});
}
