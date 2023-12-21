const std = @import("std");
const os = std.os;
const c = @import("../c.zig");

fn pmsgClose() callconv(.C) void {}

fn pmsgWrite(
    log_id: c.log_id_t,
    ts: *os.timespec,
    vec: [*]os.iovec,
    nr: usize,
) callconv(.C) c_int {
    _ = log_id;
    _ = ts;
    _ = vec;
    _ = nr;
    return 0;
}
