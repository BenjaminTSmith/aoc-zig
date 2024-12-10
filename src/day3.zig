const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{});
    var buffer: [100000]u8 = undefined;
    var total: u64 = 0;
    var enabled: bool = true;
    while (file.reader().readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const input = line orelse break;
        var i: u32 = 0;
        while (i < input.len) {
            if (input[i] == 'm') {
                i += 1;
                if (input[i] != 'u') continue;
                i += 1;
                if (input[i] != 'l') continue;
                i += 1;
                if (input[i] != '(') continue;

                i += 1;
                if (i == input.len) continue;
                var j: u32 = i + 1;
                while (input[j] != ',') {
                    if (j >= input.len) break;
                    j += 1;
                }
                const op1: u32 = std.fmt.parseInt(u32, input[i..j], 10) catch continue;

                i = j + 1;
                if (i == input.len) continue;
                j = i + 1;
                while (input[j] != ')') {
                    j += 1;
                }
                const op2: u32 = std.fmt.parseInt(u32, input[i..j], 10) catch continue;

                if (enabled) {
                    total += op1 * op2;
                }
            } else if (input[i] == 'd') {
                i += 1;
                if (input[i] != 'o') continue;
                i += 1;
                if (input[i] == '(' and input[i + 1] == ')') {
                    enabled = true;
                    continue;
                }
                if (input[i] != 'n') continue;
                i += 1;
                if (input[i] != '\'') continue;
                i += 1;
                if (input[i] != 't') continue;
                enabled = false;
            } else {
                i += 1;
            }
        }
    } else |err| {
        return err;
    }
    std.debug.print("{}\n", .{total});
}
