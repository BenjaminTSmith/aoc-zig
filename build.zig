const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    for (1..26) |i| {
        const name = try std.fmt.allocPrint(b.allocator, "day{}", .{i});
        defer b.allocator.free(name);

        const path = try std.fmt.allocPrint(b.allocator, "src/day{}.zig", .{i});
        defer b.allocator.free(path);

        const exe = b.addExecutable(.{
            .name = name,
            .root_source_file = b.path(path),
            .target = target,
            .optimize = optimize,
        });

        b.installArtifact(exe);

        const run_exe = b.addRunArtifact(exe);

        const run_step = b.step(name, "Run the corresponding day");
        run_step.dependOn(&run_exe.step);
    }
}
