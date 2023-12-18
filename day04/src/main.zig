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

    //std.debug.print("{s}\n", .{input});
    p1Answer(input);
}

const Card = struct {
    drawn: [10]i32,
    guesses: [25]i32,

    const Self = @This();

    fn parseCard(self: *Self, card: []const u8) void {
        var window = std.mem.window(u8, card, 3, 3);

        var i: usize = 0;
        while (window.next()) |num| {
            self.drawn[i] = std.fmt.parseInt(i32, num, 10) catch 0;
            i += 1;
        }
    }

    fn parseGuessed(self: *Self, guessed: []const u8) void {
        var window = std.mem.window(u8, guessed, 3, 3);

        var i: usize = 0;
        while (window.next()) |num| {
            self.guesses[i] = std.fmt.parseInt(i32, num, 10) catch 0;
            i += 1;
        }
    }
};

fn p1Answer(input: []const u8) void {
    var lnIter = std.mem.splitScalar(u8, input, '\n');

    while (lnIter.next()) |line| {
        const idx = std.mem.indexOf(u8, line, &[_]u8{'|'}) orelse 30;
        var card = Card{
            .drawn = .{0} ** 10,
            .guesses = .{0} ** 25,
        };
        card.parseCard(input[10..idx]);
        card.parseGuessed(input[idx + 1 ..]);

        const count = std.mem.count(i32, &card.drawn, &card.guesses);
        std.debug.print("Count is: {d}\n", count);
    }
}
