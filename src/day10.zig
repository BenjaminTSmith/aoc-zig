const std = @import("std");

fn pathfind(x: u32, y: u32, map: std.ArrayList([]u8)) !u32 {
    if (map.items[y][x] == '9') {
        return 1;
    }

    var score: u32 = 0;
    if (x != 0) {
        const weight = try std.fmt.parseInt(u32, map.items[y][x .. x + 1], 10);
        const next_weight = try std.fmt.parseInt(u32, map.items[y][x - 1 .. x], 10);
        if (next_weight == weight + 1) {
            score += try pathfind(x - 1, y, map);
        }
    }
    if (x + 1 < map.items[0].len) {
        const weight = try std.fmt.parseInt(u32, map.items[y][x .. x + 1], 10);
        const next_weight = try std.fmt.parseInt(u32, map.items[y][x + 1 .. x + 2], 10);
        if (next_weight == weight + 1) {
            score += try pathfind(x + 1, y, map);
        }
    }
    if (y != 0) {
        const weight = try std.fmt.parseInt(u32, map.items[y][x .. x + 1], 10);
        const next_weight = try std.fmt.parseInt(u32, map.items[y - 1][x .. x + 1], 10);
        if (next_weight == weight + 1) {
            score += try pathfind(x, y - 1, map);
        }
    }
    if (y + 1 < map.items.len) {
        const weight = try std.fmt.parseInt(u32, map.items[y][x .. x + 1], 10);
        const next_weight = try std.fmt.parseInt(u32, map.items[y + 1][x .. x + 1], 10);
        if (next_weight == weight + 1) {
            score += try pathfind(x, y + 1, map);
        }
    }
    return score;
}

fn dfs(x: u32, y: u32, map: std.ArrayList([]u8), visited: *std.ArrayList([]bool)) !u32 {
    visited.items[y][x] = true;

    if (map.items[y][x] == '9') {
        return 1;
    }

    var score: u32 = 0;
    if (x != 0 and !visited.items[y][x - 1]) {
        const weight = try std.fmt.parseInt(u32, map.items[y][x .. x + 1], 10);
        const next_weight = try std.fmt.parseInt(u32, map.items[y][x - 1 .. x], 10);
        if (next_weight == weight + 1) {
            score += try dfs(x - 1, y, map, visited);
        }
    }
    if (x + 1 < map.items[0].len and !visited.items[y][x + 1]) {
        const weight = try std.fmt.parseInt(u32, map.items[y][x .. x + 1], 10);
        const next_weight = try std.fmt.parseInt(u32, map.items[y][x + 1 .. x + 2], 10);
        if (next_weight == weight + 1) {
            score += try dfs(x + 1, y, map, visited);
        }
    }
    if (y != 0 and !visited.items[y - 1][x]) {
        const weight = try std.fmt.parseInt(u32, map.items[y][x .. x + 1], 10);
        const next_weight = try std.fmt.parseInt(u32, map.items[y - 1][x .. x + 1], 10);
        if (next_weight == weight + 1) {
            score += try dfs(x, y - 1, map, visited);
        }
    }
    if (y + 1 < map.items.len and !visited.items[y + 1][x]) {
        const weight = try std.fmt.parseInt(u32, map.items[y][x .. x + 1], 10);
        const next_weight = try std.fmt.parseInt(u32, map.items[y + 1][x .. x + 1], 10);
        if (next_weight == weight + 1) {
            score += try dfs(x, y + 1, map, visited);
        }
    }
    return score;
}

fn part1() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();
    var map = std.ArrayList([]u8).init(alloc.allocator());

    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        const line = input orelse break;
        var copy = try alloc.allocator().alloc(u8, line.len);
        for (line, 0..) |char, i| {
            copy[i] = char;
        }
        try map.append(copy);
    } else |err| {
        return err;
    }

    var visited = std.ArrayList([]bool).init(alloc.allocator());
    for (map.items) |row| {
        var visited_row = try alloc.allocator().alloc(bool, row.len);
        for (row, 0..) |_, i| {
            visited_row[i] = false;
        }
        try visited.append(visited_row);
    }

    var score: u32 = 0;
    for (map.items, 0..) |row, y| {
        for (row, 0..) |_, x| {
            if (map.items[y][x] == '0') {
                score += try dfs(@intCast(x), @intCast(y), map, &visited);
            }
            for (visited.items) |visited_row| {
                for (visited_row) |*visit| {
                    visit.* = false;
                }
            }
        }
    }
    std.debug.print("{}\n", .{score});
}

fn part2() !void {
    var alloc = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer alloc.deinit();
    var map = std.ArrayList([]u8).init(alloc.allocator());

    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        const line = input orelse break;
        var copy = try alloc.allocator().alloc(u8, line.len);
        for (line, 0..) |char, i| {
            copy[i] = char;
        }
        try map.append(copy);
    } else |err| {
        return err;
    }

    var visited = std.ArrayList([]bool).init(alloc.allocator());
    for (map.items) |row| {
        var visited_row = try alloc.allocator().alloc(bool, row.len);
        for (row, 0..) |_, i| {
            visited_row[i] = false;
        }
        try visited.append(visited_row);
    }

    var score: u32 = 0;
    for (map.items, 0..) |row, y| {
        for (row, 0..) |_, x| {
            if (map.items[y][x] == '0') {
                score += try pathfind(@intCast(x), @intCast(y), map);
            }
            for (visited.items) |visited_row| {
                for (visited_row) |*visit| {
                    visit.* = false;
                }
            }
        }
    }
    std.debug.print("{}\n", .{score});
}

pub fn main() !void {
    try part1();
    try part2();
}
