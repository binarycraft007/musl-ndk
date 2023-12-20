const std = @import("std");
const c = @cImport({
    @cInclude("android/api-level.h");
    @cInclude("sys/system_properties.h");
});

export fn android_get_device_api_level() c_int {
    var value: [92]u8 = [1]u8{0} ** 92;
    if (c.__system_property_get("ro.build.version.sdk", @ptrCast(&value)) < 1) return -1;
    const api_level: c_int = std.fmt.parseInt(c_int, &value, 10) catch return -1;
    return if (api_level > 0) api_level else -1;
}

test "get api level" {
    _ = c.android_get_device_api_level();
}
