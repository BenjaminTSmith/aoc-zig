const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});

    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    var word_search = std.ArrayList([]u8).init(alloc.allocator());
    defer word_search.deinit();

    while (true) {
        const buffer: []u8 = try alloc.allocator().alloc(u8, 1024);
        const line = try file.reader().readUntilDelimiterOrEof(buffer, '\n') orelse break;
        try word_search.append(line);
    }

    const rows: usize = word_search.items.len;
    const cols: usize = word_search.items[0].len;
    var count: u32 = 0;
    for (0..rows) |row| {
        for (0..cols) |col| {
            if (word_search.items[row][col] != 'A') {
                continue;
            }
            if (row == 0 or row == rows - 1 or col == 0 or col == cols - 1) {
                continue;
            }
            if (word_search.items[row - 1][col - 1] == 'M' and word_search.items[row + 1][col + 1] == 'S' or word_search.items[row - 1][col - 1] == 'S' and word_search.items[row + 1][col + 1] == 'M') {
                if (word_search.items[row + 1][col - 1] == 'M' and word_search.items[row - 1][col + 1] == 'S' or word_search.items[row + 1][col - 1] == 'S' and word_search.items[row - 1][col + 1] == 'M') {
                    count += 1;
                }
            }
        }
    }
    std.debug.print("{}\n", .{count});
}
