const std = @import("std");

const Pos = struct {
    x: i32,
    y: i32,

    pub fn init(x: i32, y: i32) Pos {
        return .{
            .x = x,
            .y = y,
        };
    }
};

pub fn main() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    var map = std.AutoHashMap(u8, std.ArrayList(Pos)).init(alloc.allocator());
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;

    var width: i32 = 0;

    var y: u32 = 0;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        const line = input orelse break;
        var x: u32 = 0;
        for (line) |pos| {
            if (pos == '.') {
                x += 1;
                continue;
            }

            if (map.getPtr(pos)) |array| {
                try array.append(Pos.init(@intCast(x), @intCast(y)));
            } else {
                var array = std.ArrayList(Pos).init(alloc.allocator());
                try array.append(Pos.init(@intCast(x), @intCast(y)));
                try map.put(pos, array);
            }
            x += 1;
        }
        width = @intCast(x);
        y += 1;
    } else |err| {
        return err;
    }
    const height: i32 = @intCast(y);

    var count: u32 = 0;

    var set = std.StaticBitSet(4096).initEmpty();
    var itr = map.iterator();
    while (itr.next()) |array| {
        for (0..array.value_ptr.items.len) |i| {
            for (0..array.value_ptr.items.len) |j| {
                if (i == j) {
                    continue;
                }
                const pos1 = array.value_ptr.items[i];
                const pos2 = array.value_ptr.items[j];
                var dx: i32 = @intCast(@abs(pos1.x - pos2.x));
                var dy: i32 = @intCast(@abs(pos1.y - pos2.y));

                const min_x = @min(pos1.x, pos2.x);
                const min_y = @min(pos1.y, pos2.y);
                var new_x: i32 = 0;
                var new_y: i32 = 0;
                if (pos1.x == min_x) {
                    dx = -dx;
                }
                if (pos1.y == min_y) {
                    dy = -dy;
                }
                new_x = pos1.x;
                new_y = pos1.y;
                while (true) {
                    if (new_x < 0 or new_x >= width) {
                        break;
                    }
                    if (new_y < 0 or new_y >= height) {
                        break;
                    }
                    if (!set.isSet(@intCast(new_y * width + new_x))) {
                        count += 1;
                        set.set(@intCast(new_y * width + new_x));
                    }
                    new_x += dx;
                    new_y += dy;
                }
            }
        }
    }

    std.debug.print("{}\n", .{count});
}
