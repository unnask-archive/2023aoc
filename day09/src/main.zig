const std = @import("std");
const input = @embedFile("input");
const ex = @embedFile("example");

fn allZero(slice: []i64) bool {
    for (slice) |num| {
        if (num != 0) {
            return false;
        }
    }
    return true;
}

fn procLine(line: []const u8) !i64 {
    var valIter = std.mem.splitScalar(u8, line, ' ');

    var ws: [50]i64 = .{0} ** 50;
    var chk: []i64 = ws[0..0];
    var buf: []i64 = ws[25..25];

    var idx: usize = 0;
    while (valIter.next()) |snum| {
        if (snum.len == 0) {
            continue;
        }
        chk.len = idx + 1;
        chk[idx] = try std.fmt.parseInt(i64, snum, 10);
        idx += 1;
    }

    //reverse it for part 2
    std.mem.reverse(i64, chk);

    var total: i64 = chk[chk.len - 1];
    while (!allZero(chk)) {
        idx = 0;
        while (idx < chk.len - 1) {
            buf.len += 1;
            buf[idx] = chk[idx + 1] - chk[idx];
            idx += 1;
        }
        const tmp = buf;
        buf = chk[0..0];
        chk = tmp;
        total += chk[chk.len - 1];
    }

    return total;
}

pub fn main() !void {
    var inputIter = std.mem.splitScalar(u8, input, '\n');

    var total: i64 = 0;
    while (inputIter.next()) |line| {
        if (line.len == 0) {
            continue;
        }

        total += try procLine(line);
    }

    std.debug.print("Total is {d}\n", .{total});
}
