const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [128]u8 = undefined;
    var safe_reports: u32 = 0;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const report = line orelse break;
        var tokenizer = std.mem.tokenizeAny(u8, report, " ");
        var report_list = std.ArrayList(i32).init(std.heap.page_allocator);
        report_list.deinit();
        while (tokenizer.next()) |num| {
            try report_list.append(try std.fmt.parseInt(i32, num, 10));
        }

        var safe = false;

        for (0..report_list.items.len) |ignore| {
            var report_clone = try report_list.clone();
            _ = report_clone.orderedRemove(ignore);
            const increasing: bool = report_clone.items[1] - report_clone.items[0] > 0;
            const decreasing: bool = report_clone.items[1] - report_clone.items[0] < 0;

            var local_safe = true;

            if (increasing) {
                var i: u32 = 1;
                while (i < report_clone.items.len) : (i += 1) {
                    const difference: i32 = report_clone.items[i] - report_clone.items[i - 1];
                    if (difference <= 0 or difference > 3) {
                        local_safe = false;
                    }
                }
            } else if (decreasing) {
                var i: u32 = 1;
                while (i < report_clone.items.len) : (i += 1) {
                    const difference: i32 = report_clone.items[i] - report_clone.items[i - 1];
                    if (difference >= 0 or difference < -3) {
                        local_safe = false;
                    }
                }
            } else {
                local_safe = false;
            }

            if (local_safe) {
                safe = true;
            }
        }

        if (safe) {
            safe_reports += 1;
        }
    } else |err| {
        return err;
    }
    std.debug.print("{}\n", .{safe_reports});
}
