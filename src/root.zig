const std = @import("std");
const logd_writer = @import("log/logd_writer.zig");
const pmsg_writer = @import("log/pmsg_writer.zig");
const c = @import("c.zig");

comptime {
    @export(logd_writer.logdClose, .{ .name = "LogdClose" });
    @export(logd_writer.logdWrite, .{ .name = "LogdWrite" });
    @export(pmsg_writer.pmsgClose, .{ .name = "PmsgClose" });
    @export(pmsg_writer.pmsgWrite, .{ .name = "PmsgWrite" });
}

export fn android_get_device_api_level() c_int {
    var value: [92]u8 = [1]u8{0} ** 92;
    if (c.__system_property_get("ro.build.version.sdk", @ptrCast(&value)) < 1) return -1;
    const api_level: c_int = std.fmt.parseInt(c_int, &value, 10) catch return -1;
    return if (api_level > 0) api_level else -1;
}

test "get api level" {
    _ = c.android_get_device_api_level();
}
