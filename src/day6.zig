const std = @import("std");

fn contains_loop(start_x: u32, start_y: u32, obstruction_x: u32, obstruction_y: u32, first_direction: u8, map: std.ArrayList([]u8), visited: *std.ArrayList([]u32)) bool {
    var direction = first_direction;
    var x = start_x;
    var y = start_y;
    while (x >= 0 and y >= 0 and x < map.items[0].len and y < map.items.len) {
        switch (direction) {
            '^' => {
                if (y == 0) {
                    return false;
                } else {
                    if (map.items[y - 1][x] == '#' or (y - 1 == obstruction_y and x == obstruction_x)) {
                        direction = '>';
                    } else {
                        visited.items[y][x] += 1;
                        if (visited.items[y][x] == 5) {
                            return true;
                        }
                        y -= 1;
                    }
                }
            },
            'v' => {
                if (y == map.items.len - 1) {
                    return false;
                } else {
                    if (map.items[y + 1][x] == '#' or (y + 1 == obstruction_y and x == obstruction_x)) {
                        direction = '<';
                    } else {
                        visited.items[y][x] += 1;
                        if (visited.items[y][x] == 5) {
                            return true;
                        }
                        y += 1;
                    }
                }
            },
            '>' => {
                if (x == map.items[0].len - 1) {
                    return false;
                } else {
                    if (map.items[y][x + 1] == '#' or (y == obstruction_y and x + 1 == obstruction_x)) {
                        direction = 'v';
                    } else {
                        visited.items[y][x] += 1;
                        if (visited.items[y][x] == 5) {
                            return true;
                        }
                        x += 1;
                    }
                }
            },
            '<' => {
                if (x == 0) {
                    return false;
                } else {
                    if (map.items[y][x - 1] == '#' or (y == obstruction_y and x - 1 == obstruction_x)) {
                        direction = '^';
                    } else {
                        visited.items[y][x] += 1;
                        if (visited.items[y][x] == 5) {
                            return true;
                        }
                        x -= 1;
                    }
                }
            },
            else => unreachable,
        }
    }
    return false;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [256]u8 = undefined;

    var map = std.ArrayList([]u8).init(std.heap.page_allocator);
    defer map.deinit();

    var visited = std.ArrayList([]u32).init(std.heap.page_allocator);
    defer visited.deinit();

    var x: u32 = 0;
    var y: u32 = 0;
    var current_x: u32 = 0;
    var current_y: u32 = 0;

    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const input = line orelse break;
        var row = try std.heap.page_allocator.alloc(u8, input.len);
        var visited_row = try std.heap.page_allocator.alloc(u32, input.len);
        try map.append(row);
        try visited.append(visited_row);
        for (input) |spot| {
            if (spot == '^') {
                x = current_x;
                y = current_y;
                row[current_x] = '.';
            } else {
                row[current_x] = spot;
            }
            visited_row[current_x] = 0;
            current_x += 1;
        }
        current_y += 1;
        current_x = 0;
    } else |err| {
        return err;
    }

    const start_x = x;
    const start_y = y;
    var direction: u8 = '^';
    var positions: u32 = 0;
    while (x >= 0 and y >= 0 and x < map.items[0].len and y < map.items.len) {
        switch (direction) {
            '^' => {
                if (y == 0) {
                    if (visited.items[y][x] == 0) {
                        positions += 1;
                    }
                    visited.items[y][x] = 1;
                    break;
                } else {
                    if (map.items[y - 1][x] == '#') {
                        direction = '>';
                    } else {
                        if (visited.items[y][x] == 0) {
                            positions += 1;
                        }
                        visited.items[y][x] = 1;
                        y -= 1;
                    }
                }
            },
            'v' => {
                if (y == map.items.len - 1) {
                    if (visited.items[y][x] == 0) {
                        positions += 1;
                    }
                    visited.items[y][x] = 1;
                    break;
                } else {
                    if (map.items[y + 1][x] == '#') {
                        direction = '<';
                    } else {
                        if (visited.items[y][x] == 0) {
                            positions += 1;
                        }
                        visited.items[y][x] = 1;
                        y += 1;
                    }
                }
            },
            '>' => {
                if (x == map.items[0].len - 1) {
                    if (visited.items[y][x] == 0) {
                        positions += 1;
                    }
                    visited.items[y][x] = 1;
                    break;
                } else {
                    if (map.items[y][x + 1] == '#') {
                        direction = 'v';
                    } else {
                        if (visited.items[y][x] == 0) {
                            positions += 1;
                        }
                        visited.items[y][x] = 1;
                        x += 1;
                    }
                }
            },
            '<' => {
                if (x == 0) {
                    if (visited.items[y][x] == 0) {
                        positions += 1;
                    }
                    visited.items[y][x] = 1;
                    break;
                } else {
                    if (map.items[y][x - 1] == '#') {
                        direction = '^';
                    } else {
                        if (visited.items[y][x] == 0) {
                            positions += 1;
                        }
                        visited.items[y][x] = 1;
                        x -= 1;
                    }
                }
            },
            else => unreachable,
        }
    }

    var obstructions: u32 = 0;
    for (0..map.items.len) |row| {
        for (0..map.items[0].len) |col| {
            if (visited.items[row][col] == 0) {
                continue;
            }
            if (col == start_x and row == start_y) {
                continue;
            }
            if (map.items[row][col] == '#') {
                continue;
            }

            var clone = try std.ArrayList([]u32).initCapacity(std.heap.page_allocator, visited.items.len);
            for (0..visited.items.len) |i| {
                try clone.append(try std.heap.page_allocator.alloc(u32, visited.items[i].len));
                for (0..visited.items[0].len) |j| {
                    clone.items[i][j] = 0;
                }
            }
            if (contains_loop(start_x, start_y, @intCast(col), @intCast(row), '^', map, &clone)) {
                obstructions += 1;
            }
        }
    }

    std.debug.print("{}\n", .{positions});
    std.debug.print("{}\n", .{obstructions});
}
