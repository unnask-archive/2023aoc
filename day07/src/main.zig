const std = @import("std");
const Allocator = std.mem.Allocator;

fn readFile(allocator: Allocator, filename: []const u8) ![]u8 {
    var file = try std.fs.cwd().openFile(filename, .{});

    const sz = (try file.stat()).size;
    var br = std.io.bufferedReader(file.reader());
    var reader = br.reader();

    return try reader.readAllAlloc(allocator, sz);
}

fn cardToValue(card: u8) u4 {
    return switch (card) {
        '2' => 1,
        '3' => 2,
        '4' => 3,
        '5' => 4,
        '6' => 5,
        '7' => 6,
        '8' => 7,
        '9' => 8,
        'T' => 9,
        'J' => 0, // part 2 makes J the lowest value for sorting ties renumber for running part 1
        'Q' => 10,
        'K' => 11,
        'A' => 12,
        else => unreachable,
    };
}

fn compareCard(context: void, lhs: u8, rhs: u8) bool {
    _ = context;
    return lhs > rhs;
}

fn getHandValue(hand: []const u8) u4 {
    var checked: [5]u8 = .{0} ** 5;
    var count: [5]u8 = .{0} ** 5;

    var jcount: u8 = 0;
    for (hand) |card| {
        // needed for part 2 to count the jokers
        if (card == 'J') {
            jcount += 1;
            continue;
        }
        // end of part 2 addition
        var idx: usize = 0;
        for (checked, 0..) |check, i| {
            if (check == 0 or check == card) {
                idx = i;
                break;
            }
        }
        checked[idx] = card;
        count[idx] += 1;
    }
    std.mem.sort(u8, &count, {}, compareCard);
    count[0] += jcount; // only needed for part 2

    if (count[0] == 5) {
        return 6;
    } else if (count[0] == 4 and count[1] == 1) {
        return 5;
    } else if (count[0] == 3 and count[1] == 2) {
        return 4;
    } else if (count[0] == 3 and count[1] == 1 and count[2] == 1) {
        return 3;
    } else if (count[0] == 2 and count[1] == 2 and count[2] == 1) {
        return 2;
    } else if (count[0] == 2 and count[1] == 1 and count[2] == 1 and count[3] == 1) {
        return 1;
    } else if (count[0] == 1 and count[1] == 1 and count[2] == 1 and count[3] == 1 and count[4] == 1) {
        return 0;
    }
    unreachable;
}

const Hand = packed struct {
    card5: u4,
    card4: u4,
    card3: u4,
    card2: u4,
    card1: u4,
    strength: u4,
    padding: u8,
};

const HandKey = packed union {
    key: u32,
    hand: Hand,
};

fn comparePlay(context: void, lhs: Play, rhs: Play) bool {
    _ = context;
    return lhs.hand.key < rhs.hand.key;
}
const Play = struct {
    hand: HandKey = .{ .key = 0 },
    bet: usize = 0,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var input = try readFile(allocator, "input");
    var inputIter = std.mem.splitScalar(u8, input, '\n');

    var plays = try std.ArrayList(Play).initCapacity(allocator, 50);
    while (inputIter.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        var lineIter = std.mem.splitScalar(u8, line, ' ');
        const hand = lineIter.next() orelse unreachable;
        const bet = lineIter.next() orelse unreachable;

        var play = Play{};

        play.hand.hand.card1 = cardToValue(hand[0]);
        play.hand.hand.card2 = cardToValue(hand[1]);
        play.hand.hand.card3 = cardToValue(hand[2]);
        play.hand.hand.card4 = cardToValue(hand[3]);
        play.hand.hand.card5 = cardToValue(hand[4]);
        play.bet = try std.fmt.parseUnsigned(usize, bet, 10);
        play.hand.hand.strength = getHandValue(hand);
        try plays.append(play);
    }

    var aplays = try plays.toOwnedSlice();
    defer allocator.free(aplays);

    std.mem.sort(Play, aplays, {}, comparePlay);

    var total: usize = 0;
    for (aplays, 1..) |play, i| {
        total += play.bet * i;
    }
    std.debug.print("Total is: {d}\n", .{total});
}
