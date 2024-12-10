const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const input = line orelse break;
        std.debug.print("{s}\n", .{input});
    } else |err| {
        return err;
    }
}
