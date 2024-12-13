const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [100000]u8 = undefined;
    var line: []u8 = undefined;

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        line = input orelse break;
    } else |err| {
        return err;
    }

    const File = struct {
        id: u32,
        size: u32,
        index: u32,
    };

    var disk = std.ArrayList(File).init(alloc.allocator());

    var index: u32 = 0;
    var i: u32 = 0;
    while (i < line.len) : (i += 1) {
        const size = try std.fmt.parseInt(u32, line[i .. i + 1], 10);
        if (i % 2 == 0) {
            try disk.append(.{
                .id = @intCast(i / 2),
                .size = size,
                .index = index,
            });
        } else {
            try disk.append(.{
                .id = 0,
                .size = size,
                .index = index,
            });
        }
        index += size;
    }

    var checksum: u64 = 0;
    i = @intCast(disk.items.len - 1);
    while (i >= 1) : (i -= 1) {
        var current_file = disk.items[i];
        if (current_file.id == 0) {
            continue;
        }
        var j: u32 = 1;
        var found: bool = false;
        while (j < i) : (j += 1) {
            if (disk.items[j].id == 0) {
                if (disk.items[j].size >= current_file.size) {
                    found = true;
                    break;
                }
            }
        }
        if (found) {
            current_file.index = disk.items[j].index;
            disk.items[j].index += current_file.size;
            disk.items[j].size -= current_file.size;
            var k: u32 = current_file.index;
            while (k < current_file.index + current_file.size) : (k += 1) {
                checksum += k * current_file.id;
            }
        } else {
            var k: u32 = current_file.index;
            while (k < current_file.index + current_file.size) : (k += 1) {
                checksum += k * current_file.id;
            }
        }
    }

    std.debug.print("{}\n", .{checksum});
}
