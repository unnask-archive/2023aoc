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
    p2Answer(input);
}

const Card = struct {
    drawn: [10]usize,
    guesses: [100]bool,

    const Self = @This();

    fn parseCard(self: *Self, card: []const u8) void {
        var window = std.mem.window(u8, card, 3, 3);

        var i: usize = 0;
        while (window.next()) |num| {
            self.drawn[i] = std.fmt.parseInt(usize, std.mem.trim(u8, num, &[_]u8{' '}), 10) catch 0;
            i += 1;
        }
    }

    fn parseGuessed(self: *Self, guessed: []const u8) void {
        self.guesses = .{false} ** 100;
        var window = std.mem.window(u8, guessed, 3, 3);

        while (window.next()) |num| {
            const g = std.fmt.parseInt(usize, std.mem.trim(u8, num, &[_]u8{' '}), 10) catch 0;
            self.guesses[g] = true;
        }
    }
};

fn p1Answer(input: []const u8) void {
    var lnIter = std.mem.splitScalar(u8, input, '\n');

    var total: usize = 0;
    while (lnIter.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const idx = std.mem.indexOf(u8, line, &[_]u8{'|'}) orelse 30;
        var card = Card{
            .drawn = .{0} ** 10,
            .guesses = .{false} ** 100,
        };
        card.parseCard(line[10..idx]);
        card.parseGuessed(line[idx + 1 ..]);

        var count: usize = 0;
        for (card.drawn) |num| {
            if (card.guesses[num] == true) {
                count += 1;
            }
        }

        total += power(count);
    }
    std.debug.print("Total is: {d}\n", .{total});
}

fn power(n: usize) usize {
    return switch (n) {
        0 => 0,
        1 => 1,
        2 => 2,
        else => std.math.pow(usize, 2, n - 1),
    };
}

fn p2Answer(input: []const u8) void {
    var lnIter = std.mem.splitScalar(u8, input, '\n');

    var cards: [201]usize = .{1} ** 201;
    cards[0] = 1;
    var c: usize = 0;
    var total: usize = 0;
    while (lnIter.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        const idx = std.mem.indexOf(u8, line, &[_]u8{'|'}) orelse 30;
        var card = Card{
            .drawn = .{0} ** 10,
            .guesses = .{false} ** 100,
        };
        card.parseCard(line[10..idx]);
        card.parseGuessed(line[idx + 1 ..]);

        var count: usize = 0;
        for (card.drawn) |num| {
            if (card.guesses[num] == true) {
                count += 1;
            }
        }

        if (count != 0) {
            for (c + 1..c + count + 1) |ele| {
                cards[ele] += 1 * cards[c];
            }
        }
        c += 1;
    }
    for (cards) |ele| {
        total += ele;
    }
    std.debug.print("The total is: {d}\n", .{total});
}
