const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [100000]u8 = undefined;
    var line: []u8 = undefined;

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        line = input orelse break;
    } else |err| {
        return err;
    }

    var ids = std.ArrayList(u32).init(alloc.allocator());
    var gaps = std.ArrayList(u32).init(alloc.allocator());
    var num_splits = std.ArrayList(u32).init(alloc.allocator());

    var i: u32 = 0;
    while (i < line.len) : (i += 1) {
        if (i % 2 == 0) {
            try num_splits.append(0);
        } else {
            try gaps.append(try std.fmt.parseInt(u32, line[i .. i + 1], 10));
        }
    }

    i = 0;
    while (i < line.len) : (i += 1) {
        var j: u32 = @intCast(line.len - 1);
        while (j > 0) : (j -= 2) {

        }
    }

    var checksum: u64 = 0;
    for (ids.items, 0..) |id, idx| {
        checksum += id * idx;
    }
    std.debug.print("{}\n", .{checksum});
}
