const std = @import("std");
const Allocator = std.mem.Allocator;

fn readFile(allocator: Allocator, name: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(name, .{});

    const fileSize = (try file.stat()).size;
    var br = std.io.bufferedReader(file.reader());
    var reader = br.reader();

    return reader.readAllAlloc(allocator, fileSize);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const input = try readFile(allocator, "input");

    std.debug.print("{s}\n", .{input});
}

const Card = struct {
    drawn: [10]i32,
    guesses: [25]i32,

    const Self = @This();

    fn parseCard(self: *Self, card: []const u8) void {
        var window = std.mem.window(u8, card, 3, 3);

        for (window.next(), 0..) |num, i| {
            self.drawn[i] = std.fmt.parseInt(i32, num, 10) catch 0;
        }
    }

    fn parseGuessed(self: *Self, guessed: []const u8) void {
        var window = std.mem.window(u8, guessed, 3, 3);

        for (window.next(), 0..) |num, i| {
            self.guesses[i] = std.fmt.parseInt(i32, num, 10) catch 0;
        }
    }
};

fn p1Answer(input: []const u8) void {
    var lnIter = std.mem.splitScalar(u8, input, '\n');

    while (lnIter.next()) |line| {
        const idx = std.mem.indexOf(u8, line, '|');
        const card = Card.init(input[10..idx], input[idx + 1 ..]);
        _ = card;
    }
}
