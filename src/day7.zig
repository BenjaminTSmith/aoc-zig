const std = @import("std");

fn backtrack(target: u64, total: u64, nums: []u64, top: u64) !bool {
    if (total > target) {
        return false;
    }
    if (total == target and top == nums.len - 1) {
        return true;
    }
    if (top == nums.len - 1) {
        return false;
    }
    if (try backtrack(target, total + nums[top + 1], nums, top + 1)) {
        return true;
    }
    if (try backtrack(target, total * nums[top + 1], nums, top + 1)) {
        return true;
    }
    var buf: [256]u8 = undefined;
    const new_total = try std.fmt.parseInt(u64, try std.fmt.bufPrint(&buf, "{}{}", .{ total, nums[top + 1] }), 10);
    if (try backtrack(target, new_total, nums, top + 1)) {
        return true;
    }

    return false;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;

    var total: u64 = 0;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |input| {
        const line = input orelse break;
        var target_tokenizer = std.mem.tokenizeAny(u8, line, ":");
        const left = target_tokenizer.next() orelse unreachable;
        const target = try std.fmt.parseInt(u64, left, 10);

        const right = target_tokenizer.next() orelse unreachable;
        var op_tokenizer = std.mem.tokenizeAny(u8, right, " ");
        var num_buffer: [64]u64 = undefined;
        var num_count: u32 = 0;
        while (op_tokenizer.next()) |op| {
            num_buffer[num_count] = try std.fmt.parseInt(u64, op, 10);
            num_count += 1;
        }
        if (try backtrack(target, num_buffer[0], num_buffer[0..num_count], 0)) {
            total += target;
        }
    } else |err| {
        return err;
    }
    std.debug.print("{}\n", .{total});
}
