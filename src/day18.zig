const std = @import("std");

fn part1() void {}

fn part2() void {}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        const line = input orelse break;
        std.debug.print("{s}\n", .{line});
    } else |err| {
        return err;
    }

    part1();
    part2();
}
