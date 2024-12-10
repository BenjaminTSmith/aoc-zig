const std = @import("std");

fn visit(n: u32, topological_set: *std.StaticBitSet(128), dependencies: *std.AutoHashMap(u32, std.ArrayList(u32)), visited: *std.StaticBitSet(128), fixed: *[128]u32, size: *usize) void {
    if (visited.isSet(n)) {
        return;
    }

    // visit dependencies
    const children = dependencies.get(n) orelse {
        visited.set(n);
        fixed[size.*] = n;
        size.* += 1;
        return;
    };
    for (children.items) |item| {
        if (topological_set.isSet(item)) {
            visit(@intCast(item), topological_set, dependencies, visited, fixed, size);
        }
    }

    visited.set(n);
    fixed[size.*] = n;
    size.* += 1;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;

    var dependencies = std.AutoHashMap(u32, std.ArrayList(u32)).init(std.heap.page_allocator);
    defer dependencies.deinit();

    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        const line = input orelse break;
        if (std.mem.eql(u8, line, "")) {
            break;
        }
        var tokenizer = std.mem.tokenizeAny(u8, line, "|");
        const left = try std.fmt.parseInt(u32, tokenizer.next() orelse unreachable, 10);
        const right = try std.fmt.parseInt(u32, tokenizer.next() orelse unreachable, 10);

        const array = dependencies.getPtr(right);
        if (array) |item| {
            try item.append(left);
        } else {
            var new_array = std.ArrayList(u32).init(std.heap.page_allocator);
            try new_array.append(left);
            try dependencies.put(right, new_array);
        }
    } else |err| {
        return err;
    }

    var total: u32 = 0;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        const line = input orelse break;
        var itr = std.mem.tokenizeAny(u8, line, ",");
        var set = std.StaticBitSet(128).initEmpty();
        var nums: [128]u32 = undefined;
        var count: u32 = 0;
        while (itr.next()) |token| {
            const num = try std.fmt.parseInt(u32, token, 10);
            nums[count] = num;
            count += 1;
            set.set(num);
        }

        var topological_set = std.StaticBitSet(128).initEmpty();
        var valid: bool = true;
        for (0..count) |i| {
            const array = dependencies.get(nums[i]) orelse {
                topological_set.set(nums[i]);
                set.unset(nums[i]);
                continue;
            };

            for (array.items) |item| {
                if (set.isSet(item)) {
                    valid = false;
                }
            }

            var has_dependency: bool = false;
            for (array.items) |item| {
                for (0..count) |j| {
                    if (item == nums[j]) {
                        has_dependency = true;
                    }
                }
            }
            topological_set.set(nums[i]);

            set.unset(nums[i]);
        }

        if (!valid) {
            var fixed: [128]u32 = undefined;
            var size: usize = 0;
            var visited = std.StaticBitSet(128).initEmpty();
            std.debug.print("{any}\n", .{nums[0..count]});
            std.debug.print("{any}\n", .{topological_set});
            std.debug.print("{any}\n", .{visited});
            while (topological_set.count() != visited.count()) {
                const n: u32 = @intCast(topological_set.xorWith(visited).findFirstSet().?);
                visit(@intCast(n), &topological_set, &dependencies, &visited, &fixed, &size);
            }
            std.debug.print("{any}\n", .{fixed[0..size]});
            total += fixed[size / 2];
        }
    } else |err| {
        return err;
    }

    std.debug.print("{}\n", .{total});
}
