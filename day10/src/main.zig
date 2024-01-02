const std = @import("std");
const input = @embedFile("example");

pub fn main() !void {
    const ll = std.mem.indexOfScalar(u8, input, '\n') + 1;
    _ = ll;
    const st = std.mem.indexOfScalar(u8, input, 'S');
    _ = st;
}
