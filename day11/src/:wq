const std = @import("std");
const in = @embedFile("example");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    const icols = std.mem.indexOfScalar(u8, in, '\n').?;
    const irows = in.len / icols;

    const wkmem = ((icols - 1) * 2) * (irows * 2); // rows and cols will double at most
    var storage = try allocator.alloc(u8, wkmem);
    _ = storage;
}
