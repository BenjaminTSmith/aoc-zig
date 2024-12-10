const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [64]u8 = undefined;
    var left = std.ArrayList(i32).init(std.heap.page_allocator);
    var right = std.ArrayList(i32).init(std.heap.page_allocator);
    left.deinit();
    right.deinit();
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const input = line orelse break;
        var tokenizer = std.mem.tokenizeAny(u8, input, " ");
        var num = tokenizer.next() orelse unreachable;
        try left.append(try std.fmt.parseInt(i32, num, 10));
        num = tokenizer.next() orelse unreachable;
        try right.append(try std.fmt.parseInt(i32, num, 10));
    } else |err| {
        return err;
    }

    var num_set = try std.bit_set.DynamicBitSet.initEmpty(std.heap.page_allocator, 100000);
    defer num_set.deinit();

    var total: i64 = 0;

    for (left.items) |item| {
        if (num_set.isSet(@intCast(item))) {
            continue;
        }
        num_set.set(@intCast(item));
        var count: i32 = 0;
        for (right.items) |quantity| {
            if (quantity == item) {
                count += 1;
            }
        }
        total += count * item;
    }

    std.debug.print("{}\n", .{total});
}
