const std = @import("std");

const Key = struct {
    stone: u128,
    blinks: u64,
};

fn blink_with_memo(stone: u128, blinks: u64, memo: *std.AutoHashMap(Key, u64)) !u64 {
    if (memo.get(.{ .stone = stone, .blinks = blinks })) |result| {
        return result;
    }

    if (blinks == 75) {
        return 1;
    }

    var buffer: [128]u8 = undefined;
    const stone_str = try std.fmt.bufPrint(&buffer, "{}", .{stone});
    if (stone_str.len % 2 == 0) {
        const mid = stone_str.len / 2;
        const result = try blink_with_memo(try std.fmt.parseInt(u128, stone_str[0..mid], 10), blinks + 1, memo) +
            try blink_with_memo(try std.fmt.parseInt(u128, stone_str[mid..], 10), blinks + 1, memo);
        try memo.put(.{ .stone = stone, .blinks = blinks }, result);
        return result;
    } else if (stone == 0) {
        const result = try blink_with_memo(1, blinks + 1, memo);
        try memo.put(.{ .stone = stone, .blinks = blinks }, result);
        return result;
    } else {
        const result = try blink_with_memo(stone * 2024, blinks + 1, memo);
        try memo.put(.{ .stone = stone, .blinks = blinks }, result);
        return result;
    }
}

fn blink(stone: u64, blinks: u64) !u32 {
    if (blinks == 25) {
        return 1;
    }

    var buffer: [128]u8 = undefined;
    const stone_str = try std.fmt.bufPrint(&buffer, "{}", .{stone});
    if (stone_str.len % 2 == 0) {
        const mid = stone_str.len / 2;
        return try blink(try std.fmt.parseInt(u64, stone_str[0..mid], 10), blinks + 1) + try blink(try std.fmt.parseInt(u64, stone_str[mid..], 10), blinks + 1);
    } else if (stone == 0) {
        return try blink(1, blinks + 1);
    } else {
        return try blink(stone * 2024, blinks + 1);
    }
}

fn part1() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;
    const line: []u8 = try file.reader().readUntilDelimiterOrEof(&buffer, '\n') orelse unreachable;
    var tokenizer = std.mem.tokenizeAny(u8, line, " ");
    var stones: u64 = 0;
    while (tokenizer.next()) |token| {
        const stone = try std.fmt.parseInt(u64, token, 10);
        stones += try blink(stone, 0);
    }
    std.debug.print("{}\n", .{stones});
}

fn part2() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();

    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;
    const line: []u8 = try file.reader().readUntilDelimiterOrEof(&buffer, '\n') orelse unreachable;
    var tokenizer = std.mem.tokenizeAny(u8, line, " ");
    var stones: u64 = 0;
    var memo = std.AutoHashMap(Key, u64).init(alloc.allocator());
    while (tokenizer.next()) |token| {
        const stone = try std.fmt.parseInt(u64, token, 10);
        stones += try blink_with_memo(stone, 0, &memo);
    }
    std.debug.print("{}\n", .{stones});
}

pub fn main() !void {
    try part1();
    try part2();
}
