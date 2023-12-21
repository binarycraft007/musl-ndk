const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const ndk_module = b.addModule("ndk", .{
        .source_file = .{ .path = "src/ndk.zig" },
    });
    const lib = b.addStaticLibrary(.{
        .name = "ndk",
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.defineCMacro("__ANDROID__", null);
    lib.defineCMacro("LIBLOG_LOG_TAG", "1006");
    lib.linkLibC();
    lib.linkLibCpp();
    lib.addCSourceFiles(.{
        .files = &bionic_src,
        .flags = &.{},
    });
    lib.addIncludePath(.{ .path = "src/log" });
    lib.addIncludePath(.{ .path = "include" });
    lib.installHeadersDirectory("include", "");
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib_unit_tests.addModule("ndk", ndk_module);
    lib_unit_tests.linkLibrary(lib);
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

const bionic_src = [_][]const u8{
    "src/assert.cpp",
    "src/async_safe_log.cpp",
    "src/system_properties/system_property_api.cpp",
    "src/system_properties/system_property_set.cpp",
    "src/system_properties/context_node.cpp",
    "src/system_properties/contexts_serialized.cpp",
    "src/system_properties/contexts_split.cpp",
    "src/system_properties/prop_area.cpp",
    "src/system_properties/property_info_parser.cpp",
    "src/system_properties/prop_info.cpp",
    "src/system_properties/system_properties.cpp",

    "src/log/log_event_list.cpp",
    "src/log/log_event_write.cpp",
    "src/log/logger_name.cpp",
    "src/log/logger_write.cpp",
    "src/log/logprint.cpp",
    "src/log/properties.cpp",
};
